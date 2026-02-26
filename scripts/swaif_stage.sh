#!/usr/bin/env bash
set -euo pipefail

issue_title="${1:-}"
stage="${2:-}"
feature_dir="${3:-}"
execution_type="${4:-}"
issue_number="${5:-}"

if [[ -z "$issue_title" || -z "$stage" || -z "$feature_dir" || -z "$execution_type" || -z "$issue_number" ]]; then
  echo "Usage: $0 <issue_title> <stage> <feature_dir> <execution_type> <issue_number>" >&2
  exit 1
fi

case "$stage" in
  init|specify|plan|tasks|implement|verify) ;;
  *)
    echo "Invalid stage: $stage" >&2
    exit 1
    ;;
esac

if [[ ! "$feature_dir" =~ ^specs/[a-z0-9][a-z0-9-]*$ ]]; then
  echo "feature_dir must match specs/<feature-slug> with kebab-case slug" >&2
  exit 1
fi

feature_slug="${feature_dir#specs/}"
branch="swaif/${feature_slug}"
repo_root="$(git rev-parse --show-toplevel)"
intake_file="${feature_dir}/intake.md"
factory_constitution_file="${repo_root}/.swaif/engine/.specify/memory/swaif-constitution.md"
feature_constitution_file="${repo_root}/${feature_dir}/.specify/memory/constitution.md"
spec_file="${feature_dir}/spec.md"
plan_file="${feature_dir}/plan.md"
tasks_file="${feature_dir}/tasks.md"
implement_marker="${feature_dir}/IMPLEMENT_PLACEHOLDER.txt"
verify_marker="${feature_dir}/VERIFY_PLACEHOLDER.txt"
speckit_root=".swaif/engine/speckit"
speckit_agent_template="${speckit_root}/templates/agent-file-template.md"
speckit_agent_update_script="${speckit_root}/scripts/bash/update-agent-context.sh"
agent_file=".github/agents/copilot-instructions.md"

mkdir -p "$feature_dir"

##git fetch origin "$branch" || true
##if git show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
##  git checkout -B "$branch" "origin/$branch"
##else
##  git checkout -B "$branch"
##fi

git fetch --prune origin "+refs/heads/main:refs/remotes/origin/main" 2>/dev/null || true
git fetch --prune origin "+refs/heads/${branch}:refs/remotes/origin/${branch}" 2>/dev/null || true
if git show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
  git checkout -B "${branch}" "refs/remotes/origin/${branch}"
else
  # Create the branch from latest main when issue branch does not exist yet
  if git show-ref --verify --quiet "refs/remotes/origin/main"; then
    git checkout -B "${branch}" "refs/remotes/origin/main"
  else
    # Fallback to current checkout if origin/main is unavailable
    git checkout -B "${branch}"
  fi
fi

# Keep feature branch up to date with main when fast-forward is possible.
if git show-ref --verify --quiet "refs/remotes/origin/main" && git merge-base --is-ancestor HEAD "refs/remotes/origin/main"; then
  git merge --ff-only "refs/remotes/origin/main"
else
  echo "Skipping fast-forward sync with origin/main (not possible without merge/rebase)."
fi



resolve_constitution_file() {
  if [[ -f "$factory_constitution_file" ]]; then
    echo "$factory_constitution_file"
    return 0
  fi

  if [[ -f "$feature_constitution_file" ]]; then
    echo "$feature_constitution_file"
    return 0
  fi

  echo "Missing constitution file. Checked: $factory_constitution_file and $feature_constitution_file" >&2
  exit 1
}

create_if_missing() {
  local target="$1"
  local content="$2"
  if [[ ! -f "$target" ]]; then
    printf "%s\n" "$content" > "$target"
  fi
}

bootstrap_speckit_agent_context() {
  if [[ ! -d "$speckit_root" ]]; then
    echo "Speckit submodule not found at $speckit_root" >&2
    exit 1
  fi

  mkdir -p .specify/templates
  mkdir -p .github/agents

  if [[ ! -f .specify/templates/agent-file-template.md ]]; then
    if [[ -f "$speckit_agent_template" ]]; then
      cp "$speckit_agent_template" .specify/templates/agent-file-template.md
    else
      echo "Missing Speckit agent template: $speckit_agent_template" >&2
      exit 1
    fi
  fi

  create_if_missing "$agent_file" "# SWAIF + Spec Kit Agent Context

This file is managed by SWAIF stage automation and Speckit agent sync.

## Scope

- Factory branch: ${branch}
- Feature directory: ${feature_dir}
- Declared execution type: ${execution_type}

## SWAIF Stage Guardrails

- Enforce stage order: init -> specify -> plan -> tasks -> implement -> verify
- Work only within approved stage outputs for the current step
- Keep traceability across intake.md, spec.md, plan.md, and tasks.md
"
}

customize_speckit_agent_context() {
  local stage_name="$1"
  local speckit_feature="$feature_slug"
  local speckit_feature_dir=""

  bootstrap_speckit_agent_context

  if [[ "$stage_name" == "init" || "$stage_name" == "specify" ]]; then
    return 0
  fi

  if [[ ! -f "$speckit_agent_update_script" ]]; then
    echo "Missing Speckit update script: $speckit_agent_update_script" >&2
    exit 1
  fi

  if [[ ! "$speckit_feature" =~ ^[0-9]{3}- ]]; then
    speckit_feature="900-${feature_slug}"
    speckit_feature_dir="specs/${speckit_feature}"
    mkdir -p "$speckit_feature_dir"
    [[ -f "$spec_file" ]] && cp "$spec_file" "$speckit_feature_dir/spec.md"
    [[ -f "$plan_file" ]] && cp "$plan_file" "$speckit_feature_dir/plan.md"
    [[ -f "$tasks_file" ]] && cp "$tasks_file" "$speckit_feature_dir/tasks.md"
  fi

  if ! SPECIFY_FEATURE="$speckit_feature" bash "$speckit_agent_update_script" "${SWAIF_AGENT_TYPE:-copilot}"; then
    if [[ -n "$speckit_feature_dir" ]]; then
      rm -rf "$speckit_feature_dir"
    fi
    echo "Speckit agent context update failed for feature '${speckit_feature}'" >&2
    exit 1
  fi

  if [[ -n "$speckit_feature_dir" ]]; then
    rm -rf "$speckit_feature_dir"
  fi
}

write_intake_from_issue_env() {
  local intake_path="$1"

  # Only generate if missing (don’t overwrite manual edits unless you want that behavior)
  if [[ -f "$intake_path" ]]; then
    echo "intake.md already exists: $intake_path"
    return 0
  fi

  # ISSUE_BODY must be provided by the workflow
  if [[ -z "${ISSUE_BODY:-}" ]]; then
    echo "Missing ISSUE_BODY env var; cannot generate intake.md." >&2
    exit 1
  fi

  mkdir -p "$(dirname "$intake_path")"

  {
    echo "<!-- AUTO-GENERATED from GitHub Issue #${ISSUE_NUMBER:-unknown} -->"
    echo "<!-- Title: ${ISSUE_TITLE:-} -->"
    echo "<!-- URL: ${ISSUE_URL:-} -->"
    echo
    printf "%s\n" "${ISSUE_BODY}"
    echo
  } > "$intake_path"

  echo "Wrote $intake_path"
}
case "$stage" in

  init)
	write_intake_from_issue_env "$intake_file"
	create_if_missing "$intake_file" "# Intake: ${feature_slug}
_TODO_
"
	# Install uv and Spec Kit CLI
    pip install uv
    uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
	
	# Install and Authenticate Codex CLI
    npm i -g @openai/codex
    if [[ -n "${OPENAI_API_KEY:-}" ]]; then
      echo "$OPENAI_API_KEY" | codex login --with-api-key
    else
      echo "WARNING: OPENAI_API_KEY environment variable not set. Codex CLI will not be authenticated." >&2
    fi
	
	# Init Speckit with Codex and keep repository working directory unchanged.
	(
	  cd "$feature_dir"
	  specify init . --ai codex --script sh --here --force --ai-skills

	  # Setup Constitution to Speckit
	  constitution_source="$(resolve_constitution_file)"
	  codex exec --full-auto "/speckit.constitution $(cat "$constitution_source")"
	)
	;;
  specify)
    create_if_missing "$spec_file" "# Spec: ${feature_slug}
_TODO_
"   ;;
  plan)
    [[ -f "$spec_file" ]] || { echo "Missing prerequisite: $spec_file" >&2; exit 1; }
    create_if_missing "$plan_file" "# Plan: ${feature_slug}
_TODO_
"
    ;;
  tasks)
    [[ -f "$plan_file" ]] || { echo "Missing prerequisite: $plan_file" >&2; exit 1; }
    create_if_missing "$tasks_file" "# Tasks: ${feature_slug}
_TODO_
"
    ;;
  implement)
    [[ -f "$tasks_file" ]] || { echo "Missing prerequisite: $tasks_file" >&2; exit 1; }
    create_if_missing "$implement_marker" "Implement stage placeholder for ${feature_slug}
_TODO_
"
    ##;;
  ##verify)
    ##[[ -f "$tasks_file" ]] || { echo "Missing prerequisite: $tasks_file" >&2; exit 1; }
    ##create_if_missing "$verify_marker" "Verify stage placeholder for ${feature_slug}
##Issue: #${issue_number}
##"
    ;;
  verify)
  # Verify should at least require the implementation marker (or implement artifacts), not tasks.md
    [[ -f "$implement_marker" ]] || { echo "Missing prerequisite: $implement_marker" >&2; exit 1; }
    create_if_missing "$verify_marker" "Verify stage placeholder for ${feature_slug}
_TODO_
"
  ;;
esac

customize_speckit_agent_context "$stage"

# Check both tracked and untracked changes under feature_dir
if [[ -z "$(git status --porcelain -- "$feature_dir" .specify/templates "$agent_file")" ]]; then
  echo "No changes to commit for stage '${stage}'."
  exit 0
fi

# Ensure git identity exists for non-interactive commits (CI/local).
# If not set, git commit can fail with: "fatal: empty ident name ... not allowed".
if ! git config --get user.name >/dev/null; then
  git config user.name "github-actions[bot]"
fi
if ! git config --get user.email >/dev/null; then
  git config user.email "github-actions[bot]@users.noreply.github.com"
fi

git add "$feature_dir" .specify/templates "$agent_file"
git commit -m "swaif(${stage}): ${feature_slug} (issue #${issue_number})"
