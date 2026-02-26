#!/usr/bin/env bash
set -euo pipefail

# -------- Debug/Diagnostics helpers --------
SWAIF_DEBUG_LOG="${SWAIF_DEBUG_LOG:-.swaif/logs/swaif-stage-debug.log}"
SWAIF_TEST_MODE="${SWAIF_TEST_MODE:-0}"

mkdir -p "$(dirname "$SWAIF_DEBUG_LOG")" 2>/dev/null || true

ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

log_event() {
  local level="$1"
  local category="$2"
  local message="$3"
  printf '[%s] [%s] [%s] %s\n' "$(ts)" "$level" "$category" "$message" | tee -a "$SWAIF_DEBUG_LOG" >&2
}

fail_with() {
  local category="$1"
  local message="$2"
  local code="${3:-1}"
  log_event "ERROR" "$category" "$message"
  exit "$code"
}

on_unhandled_error() {
  local code="$1"
  local line="$2"
  local cmd="$3"
  log_event "ERROR" "UNHANDLED" "code=${code} line=${line} cmd=${cmd}"
  exit "$code"
}

trap 'on_unhandled_error "$?" "$LINENO" "$BASH_COMMAND"' ERR

# -------- Args/context --------
issue_title="${1:-}"
stage="${2:-}"
feature_dir="${3:-}"
execution_type="${4:-}"
issue_number="${5:-}"

if [[ -z "$issue_title" || -z "$stage" || -z "$feature_dir" || -z "$execution_type" || -z "$issue_number" ]]; then
  fail_with "INPUT" "Usage: $0 <issue_title> <stage> <feature_dir> <execution_type> <issue_number>" 2
fi

case "$stage" in
  init|specify|plan|tasks|implement|verify) ;;
  *) fail_with "INPUT" "Invalid stage: $stage" 2 ;;
esac

if [[ ! "$feature_dir" =~ ^specs/[a-z0-9][a-z0-9-]*$ ]]; then
  fail_with "INPUT" "feature_dir must match specs/<feature-slug> with kebab-case slug" 2
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

sync_branch_state() {
  if [[ "$SWAIF_TEST_MODE" == "1" ]]; then
    log_event "INFO" "TEST_MODE" "Skipping git fetch/checkout sync"
    return 0
  fi

  git fetch --prune origin "+refs/heads/main:refs/remotes/origin/main" 2>/dev/null || true
  git fetch --prune origin "+refs/heads/${branch}:refs/remotes/origin/${branch}" 2>/dev/null || true

  if git show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
    git checkout -B "${branch}" "refs/remotes/origin/${branch}"
  else
    if git show-ref --verify --quiet "refs/remotes/origin/main"; then
      git checkout -B "${branch}" "refs/remotes/origin/main"
    else
      git checkout -B "${branch}"
    fi
  fi

  if git show-ref --verify --quiet "refs/remotes/origin/main" && git merge-base --is-ancestor HEAD "refs/remotes/origin/main"; then
    git merge --ff-only "refs/remotes/origin/main"
  else
    log_event "INFO" "GIT_SYNC" "Skipping fast-forward sync with origin/main"
  fi
}

resolve_constitution_file() {
  if [[ -f "$factory_constitution_file" ]]; then
    echo "$factory_constitution_file"
    return 0
  fi
  if [[ -f "$feature_constitution_file" ]]; then
    echo "$feature_constitution_file"
    return 0
  fi
  fail_with "PREREQUISITE" "Missing constitution file. Checked: $factory_constitution_file and $feature_constitution_file"
}

create_if_missing() {
  local target="$1"
  local content="$2"
  if [[ ! -f "$target" ]]; then
    printf "%s\n" "$content" > "$target"
    log_event "INFO" "ARTIFACT" "Created ${target}"
  fi
}

ensure_required_stage_files() {
  local stage_name="$1"
  local required_files=()

  case "$stage_name" in
    specify) required_files=("$intake_file") ;;
    plan) required_files=("$intake_file" "$spec_file") ;;
    tasks) required_files=("$intake_file" "$spec_file" "$plan_file") ;;
    implement|verify) required_files=("$intake_file" "$spec_file" "$plan_file" "$tasks_file") ;;
    *) return 0 ;;
  esac

  local missing=()
  local file
  for file in "${required_files[@]}"; do
    [[ -f "$file" ]] || missing+=("$file")
  done

  if (( ${#missing[@]} > 0 )); then
    fail_with "PREREQUISITE" "Missing prerequisite files for stage '${stage_name}': ${missing[*]}"
  fi
}

speckit_command_for_stage() {
  local stage_name="$1"
  case "$stage_name" in
    specify) printf '/speckit.specify %s\n' "$intake_file" ;;
    plan) printf '/speckit.plan %s\n' "$spec_file" ;;
    tasks) printf '/speckit.tasks %s\n' "$plan_file" ;;
    implement) printf '/speckit.implement %s\n' "$tasks_file" ;;
    verify) printf '/speckit.checklist %s\n' "$tasks_file" ;;
    *) return 1 ;;
  esac
}

stage_template_with_speckit_block() {
  local stage_name="$1"
  local heading="$2"
  local command=""
  command="$(speckit_command_for_stage "$stage_name")" || fail_with "TEMPLATE" "Unable to map Speckit command for stage '${stage_name}'"
  cat <<TPL
# ${heading}: ${feature_slug}

## Speckit command (${stage_name})

\`\`\`bash
${command}
\`\`\`

## Notes
_TODO_
TPL
}

bootstrap_speckit_agent_context() {
  if [[ "$SWAIF_TEST_MODE" == "1" ]]; then
    log_event "INFO" "TEST_MODE" "Skipping speckit bootstrap"
    return 0
  fi

  [[ -d "$speckit_root" ]] || fail_with "SPECKIT" "Speckit submodule not found at $speckit_root"

  mkdir -p .specify/templates .github/agents

  if [[ ! -f .specify/templates/agent-file-template.md ]]; then
    [[ -f "$speckit_agent_template" ]] || fail_with "SPECKIT" "Missing Speckit agent template: $speckit_agent_template"
    cp "$speckit_agent_template" .specify/templates/agent-file-template.md
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
  [[ "$stage_name" == "init" || "$stage_name" == "specify" ]] && return 0
  [[ "$SWAIF_TEST_MODE" == "1" ]] && return 0

  [[ -f "$speckit_agent_update_script" ]] || fail_with "SPECKIT" "Missing Speckit update script: $speckit_agent_update_script"

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
    fail_with "SPECKIT" "Speckit agent context update failed for feature '${speckit_feature}'"
  fi

  [[ -n "$speckit_feature_dir" ]] && rm -rf "$speckit_feature_dir"
}

write_intake_from_issue_env() {
  local intake_path="$1"
  if [[ -f "$intake_path" ]]; then
    log_event "INFO" "ARTIFACT" "intake.md already exists: $intake_path"
    return 0
  fi

  [[ -n "${ISSUE_BODY:-}" ]] || fail_with "INPUT" "Missing ISSUE_BODY env var; cannot generate intake.md."

  mkdir -p "$(dirname "$intake_path")"
  {
    echo "<!-- AUTO-GENERATED from GitHub Issue #${ISSUE_NUMBER:-unknown} -->"
    echo "<!-- Title: ${ISSUE_TITLE:-} -->"
    echo "<!-- URL: ${ISSUE_URL:-} -->"
    echo
    printf "%s\n" "${ISSUE_BODY}"
    echo
  } > "$intake_path"
  log_event "INFO" "ARTIFACT" "Wrote $intake_path"
}

run_stage() {
  ensure_required_stage_files "$stage"

  case "$stage" in
    init)
      write_intake_from_issue_env "$intake_file"
      create_if_missing "$intake_file" "# Intake: ${feature_slug}
_TODO_
"
      if [[ "$SWAIF_TEST_MODE" != "1" ]]; then
        pip install uv
        uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
        npm i -g @openai/codex
        if [[ -n "${OPENAI_API_KEY:-}" ]]; then
          echo "$OPENAI_API_KEY" | codex login --with-api-key
        else
          log_event "WARN" "AUTH" "OPENAI_API_KEY not set; Codex CLI not authenticated"
        fi
        (
          cd "$feature_dir"
          specify init . --ai codex --script sh --here --force --ai-skills
          constitution_source="$(resolve_constitution_file)"
          codex exec --full-auto "/speckit.constitution $(cat "$constitution_source")"
        )
      fi
      ;;
    specify)
      create_if_missing "$intake_file" "$(stage_template_with_speckit_block "specify" "Specify")"
      ;;
    plan)
      create_if_missing "$spec_file" "$(stage_template_with_speckit_block "plan" "Plan")"
      ;;
    tasks)
      create_if_missing "$plan_file" "$(stage_template_with_speckit_block "tasks" "Tasks")"
      ;;
    implement)
      create_if_missing "$tasks_file" "$(stage_template_with_speckit_block "implement" "Implement")"
      ;;
    verify)
      [[ -f "$implement_marker" ]] || fail_with "PREREQUISITE" "Missing prerequisite: $implement_marker"
      create_if_missing "$implement_marker" "$(stage_template_with_speckit_block "verify" "Verify")"
      ;;
  esac

  customize_speckit_agent_context "$stage"
}

finalize_commit() {
  if [[ "$SWAIF_TEST_MODE" == "1" ]]; then
    log_event "INFO" "TEST_MODE" "Skipping git add/commit finalize"
    return 0
  fi

  if [[ -z "$(git status --porcelain -- "$feature_dir" .specify/templates "$agent_file")" ]]; then
    log_event "INFO" "COMMIT" "No changes to commit for stage '${stage}'."
    exit 0
  fi

  git config --get user.name >/dev/null || git config user.name "github-actions[bot]"
  git config --get user.email >/dev/null || git config user.email "github-actions[bot]@users.noreply.github.com"

  git add "$feature_dir" .specify/templates "$agent_file"
  git commit -m "swaif(${stage}): ${feature_slug} (issue #${issue_number})"
}

main() {
  log_event "INFO" "START" "stage=${stage} feature=${feature_slug} issue=${issue_number}"
  sync_branch_state
  run_stage
  finalize_commit
  log_event "INFO" "DONE" "stage=${stage} completed"
}

main "$@"
