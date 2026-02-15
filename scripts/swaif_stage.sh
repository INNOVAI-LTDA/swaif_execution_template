#!/usr/bin/env bash
set -euo pipefail

STAGE="${1:-}"
FEATURE_DIR="${2:-}"
EXECUTION_TYPE="${3:-}"
ISSUE_NUMBER="${4:-}"

if [ -z "$STAGE" ] || [ -z "$FEATURE_DIR" ] || [ -z "$ISSUE_NUMBER" ]; then
  echo "Usage: swaif_stage.sh <stage> <feature_dir> <execution_type> <issue_number>"
  exit 1
fi

FEATURE_SLUG="$(basename "$FEATURE_DIR")"
BRANCH="swaif/${FEATURE_SLUG}"

git config user.name "swaif-bot"
git config user.email "swaif-bot@users.noreply.github.com"

git checkout -B "$BRANCH"
mkdir -p "$FEATURE_DIR"

# NOTE:
# This is a scaffold. It creates artifacts using templates when missing,
# and enforces basic prerequisites between stages.
# Replace placeholders with your Copilot/LLM execution mechanism later.

TEMPL_DIR=".swaif/engine/templates"

render_from_template () {
  local template="$1"
  local out="$2"
  if [ ! -f "$out" ]; then
    cp "$template" "$out"
  fi
}

case "$STAGE" in
  specify)
    render_from_template "$TEMPL_DIR/spec-template.md" "$FEATURE_DIR/spec.md"
    ;;

  plan)
    test -f "$FEATURE_DIR/spec.md"
    render_from_template "$TEMPL_DIR/plan-template.md" "$FEATURE_DIR/plan.md"
    ;;

  tasks)
    test -f "$FEATURE_DIR/plan.md"
    render_from_template "$TEMPL_DIR/tasks-template.md" "$FEATURE_DIR/tasks.md"
    ;;

  implement)
    test -f "$FEATURE_DIR/tasks.md"
    echo "(implement stage placeholder — replace with Copilot/agent execution)" > "$FEATURE_DIR/IMPLEMENT_PLACEHOLDER.txt"
    ;;

  verify)
    test -f "$FEATURE_DIR/tasks.md"
    echo "(verify stage placeholder — capture evidence + fill execution record)" > "$FEATURE_DIR/VERIFY_PLACEHOLDER.txt"
    ;;

  *)
    echo "Unknown stage: $STAGE"
    exit 1
    ;;
esac

git add "$FEATURE_DIR"
git commit -m "[SWAIF] ${FEATURE_SLUG}: ${STAGE} (issue #${ISSUE_NUMBER})" || true
git push -u origin "$BRANCH"
