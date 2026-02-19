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

spec_file="${feature_dir}/spec.md"
plan_file="${feature_dir}/plan.md"
tasks_file="${feature_dir}/tasks.md"
implement_marker="${feature_dir}/IMPLEMENT_PLACEHOLDER.txt"
verify_marker="${feature_dir}/VERIFY_PLACEHOLDER.txt"

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

case "$stage" in
  specify)
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
    create_if_missing "$tasks_file" "# Tasks: ${feature_slug}

Derived from: plan.md

- [ ] TASK-001 _TODO_
"
    ;;
  implement)
    [[ -f "$tasks_file" ]] || { echo "Missing prerequisite: $tasks_file" >&2; exit 1; }
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

# Check both tracked and untracked changes under feature_dir
if [[ -z "$(git status --porcelain -- "$feature_dir")" ]]; then
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

git add "$feature_dir"
git commit -m "swaif(${stage}): ${feature_slug} (issue #${issue_number})"
