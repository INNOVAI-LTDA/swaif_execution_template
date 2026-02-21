#!/usr/bin/env bash
set -euo pipefail

stage="${1:-}"
feature_dir="${2:-}"
execution_type="${3:-}"
issue_number="${4:-}"

if [[ -z "$stage" || -z "$feature_dir" || -z "$execution_type" || -z "$issue_number" ]]; then
  echo "Usage: $0 <stage> <feature_dir> <execution_type> <issue_number>" >&2
  exit 1
fi

case "$stage" in
  specify|plan|tasks|implement|verify) ;;
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
repo_root="$(pwd)"

spec_file="${feature_dir}/spec.md"
plan_file="${feature_dir}/plan.md"
tasks_file="${feature_dir}/tasks.md"
implement_marker="${feature_dir}/IMPLEMENT_PLACEHOLDER.txt"
verify_marker="${feature_dir}/VERIFY_PLACEHOLDER.txt"
speckit_root=".swaif/engine/speckit"
speckit_agent_template="${speckit_root}/templates/agent-file-template.md"
speckit_agent_update_script="${speckit_root}/scripts/bash/update-agent-context.sh"
speckit_create_feature_script="${speckit_root}/scripts/bash/create-new-feature.sh"
speckit_setup_plan_script="${speckit_root}/scripts/bash/setup-plan.sh"
speckit_check_prereq_script="${speckit_root}/scripts/bash/check-prerequisites.sh"
agent_file=".github/agents/copilot-instructions.md"

mkdir -p "$feature_dir"

##git fetch origin "$branch" || true
##if git show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
##  git checkout -B "$branch" "origin/$branch"
##else
##  git checkout -B "$branch"
##fi

git fetch --prune origin "+refs/heads/${branch}:refs/remotes/origin/${branch}" 2>/dev/null || true
if git show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
  git checkout -B "${branch}" "refs/remotes/origin/${branch}"
else
  # Create the branch off the currently checked out commit (workflow checkout)
  git checkout -B "${branch}"
fi



create_if_missing() {
  local target="$1"
  local content="$2"
  if [[ ! -f "$target" ]]; then
    printf "%s\n" "$content" > "$target"
  fi
}

prepare_speckit_sandbox() {
  local sandbox_root="$1"
  local sandbox_feature="$2"
  local sandbox_feature_dir="${sandbox_root}/specs/${sandbox_feature}"

  mkdir -p "${sandbox_root}/.specify/templates"
  mkdir -p "${sandbox_root}/specs"

  if [[ -d ".specify/templates" ]]; then
    cp -R .specify/templates/. "${sandbox_root}/.specify/templates/"
  fi

  if [[ -d "${speckit_root}/templates" ]]; then
    cp -R "${speckit_root}/templates/." "${sandbox_root}/.specify/templates/"
  fi

  mkdir -p "$sandbox_feature_dir"

  if [[ -f "$spec_file" ]]; then
    cp "$spec_file" "${sandbox_feature_dir}/spec.md"
  fi
  if [[ -f "$plan_file" ]]; then
    cp "$plan_file" "${sandbox_feature_dir}/plan.md"
  fi
  if [[ -f "$tasks_file" ]]; then
    cp "$tasks_file" "${sandbox_feature_dir}/tasks.md"
  fi
}

run_speckit_stage_hook() {
  local stage_name="$1"
  local sandbox_root=""
  local speckit_feature="900-${feature_slug}"

  if [[ ! -d "$speckit_root" ]]; then
    echo "Speckit submodule not found at $speckit_root" >&2
    exit 1
  fi

  sandbox_root="$(mktemp -d)"

  prepare_speckit_sandbox "$sandbox_root" "$speckit_feature"

  case "$stage_name" in
    specify)
      [[ -f "$speckit_create_feature_script" ]] || { echo "Missing Speckit script: $speckit_create_feature_script" >&2; exit 1; }
      (
        cd "$sandbox_root"
        bash "${repo_root}/${speckit_create_feature_script}" --json --short-name "$feature_slug" --number 900 "$feature_slug" >/dev/null
      )
      if [[ -f "${sandbox_root}/specs/${speckit_feature}/spec.md" ]]; then
        cp "${sandbox_root}/specs/${speckit_feature}/spec.md" "$spec_file"
      fi
      ;;
    plan)
      [[ -f "$speckit_setup_plan_script" ]] || { echo "Missing Speckit script: $speckit_setup_plan_script" >&2; exit 1; }
      (
        cd "$sandbox_root"
        SPECIFY_FEATURE="$speckit_feature" bash "${repo_root}/${speckit_setup_plan_script}" --json >/dev/null
      )
      if [[ -f "${sandbox_root}/specs/${speckit_feature}/plan.md" ]]; then
        cp "${sandbox_root}/specs/${speckit_feature}/plan.md" "$plan_file"
      fi
      ;;
    tasks)
      [[ -f "$speckit_check_prereq_script" ]] || { echo "Missing Speckit script: $speckit_check_prereq_script" >&2; exit 1; }
      (
        cd "$sandbox_root"
        SPECIFY_FEATURE="$speckit_feature" bash "${repo_root}/${speckit_check_prereq_script}" --json >/dev/null
      )
      ;;
    implement)
      [[ -f "$speckit_check_prereq_script" ]] || { echo "Missing Speckit script: $speckit_check_prereq_script" >&2; exit 1; }
      (
        cd "$sandbox_root"
        SPECIFY_FEATURE="$speckit_feature" bash "${repo_root}/${speckit_check_prereq_script}" --json --require-tasks --include-tasks >/dev/null
      )
      ;;
  esac

  rm -rf "$sandbox_root"
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

- Enforce stage order: specify -> plan -> tasks -> implement -> verify
- Work only within approved stage outputs for the current step
- Keep traceability across spec.md, plan.md, and tasks.md
"
}

customize_speckit_agent_context() {
  local stage_name="$1"
  local speckit_feature="$feature_slug"
  local speckit_feature_dir=""

  bootstrap_speckit_agent_context

  if [[ "$stage_name" == "specify" ]]; then
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
    [[ -n "$speckit_feature_dir" ]] && rm -rf "$speckit_feature_dir"
    echo "Speckit agent context update failed for feature '${speckit_feature}'" >&2
    exit 1
  fi

  [[ -n "$speckit_feature_dir" ]] && rm -rf "$speckit_feature_dir"
}

case "$stage" in
  specify)
    run_speckit_stage_hook "specify"
    create_if_missing "$spec_file" "# Spec: ${feature_slug}

- Declared Execution Type: ${execution_type}
- Issue: #${issue_number}

## Problem
_TODO_

## Acceptance Criteria
- [ ] AC-001 _TODO_
"
    ;;
  plan)
    [[ -f "$spec_file" ]] || { echo "Missing prerequisite: $spec_file" >&2; exit 1; }
    run_speckit_stage_hook "plan"
    create_if_missing "$plan_file" "# Plan: ${feature_slug}

Derived from: spec.md

## Approach
_TODO_

## Risks
- _TODO_
"
    ;;
  tasks)
    [[ -f "$plan_file" ]] || { echo "Missing prerequisite: $plan_file" >&2; exit 1; }
    run_speckit_stage_hook "tasks"
    create_if_missing "$tasks_file" "# Tasks: ${feature_slug}

Derived from: plan.md

- [ ] TASK-001 _TODO_
"
    ;;
  implement)
    [[ -f "$tasks_file" ]] || { echo "Missing prerequisite: $tasks_file" >&2; exit 1; }
    run_speckit_stage_hook "implement"
    create_if_missing "$implement_marker" "Implement stage placeholder for ${feature_slug}
Issue: #${issue_number}
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
Issue: #${issue_number}
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
