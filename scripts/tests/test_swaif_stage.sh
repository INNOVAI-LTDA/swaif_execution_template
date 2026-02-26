#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT="$REPO_ROOT/scripts/swaif_stage.sh"

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; exit 1; }

setup_repo() {
  local dir="$1"
  git init -q "$dir"
  (
    cd "$dir"
    git config user.name tester
    git config user.email tester@example.com
    mkdir -p specs
    echo "seed" > README.md
    git add README.md
    git commit -qm "init"
  )
}

assert_file_contains() {
  local file="$1"
  local needle="$2"
  grep -F "$needle" "$file" >/dev/null || fail "expected '$needle' in $file"
}

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# Test 1: failure mechanism coverage (missing spec for plan)
FAIL_REPO="$TMPDIR/failure-repo"
setup_repo "$FAIL_REPO"
mkdir -p "$FAIL_REPO/specs/feature-a"
cat > "$FAIL_REPO/specs/feature-a/intake.md" <<TXT
Intake ok
TXT

set +e
(
  cd "$FAIL_REPO"
  SWAIF_TEST_MODE=1 "$SCRIPT" "Issue" "plan" "specs/feature-a" "manual" "1" >out.log 2>err.log
)
CODE=$?
set -e
[[ $CODE -ne 0 ]] || fail "plan should fail when spec.md is missing"
grep -F "[ERROR] [PREREQUISITE]" "$FAIL_REPO/err.log" >/dev/null || fail "missing categorized prerequisite error"
pass "failure path categorization"

# Test 2: common flow (specify -> plan -> tasks -> implement -> verify)
OK_REPO="$TMPDIR/ok-repo"
setup_repo "$OK_REPO"
mkdir -p "$OK_REPO/specs/feature-b"
cat > "$OK_REPO/specs/feature-b/intake.md" <<TXT
Intake baseline
TXT

(
  cd "$OK_REPO"
  SWAIF_TEST_MODE=1 "$SCRIPT" "Issue" "specify" "specs/feature-b" "manual" "2"
  SWAIF_TEST_MODE=1 "$SCRIPT" "Issue" "plan" "specs/feature-b" "manual" "2"
  SWAIF_TEST_MODE=1 "$SCRIPT" "Issue" "tasks" "specs/feature-b" "manual" "2"
  SWAIF_TEST_MODE=1 "$SCRIPT" "Issue" "implement" "specs/feature-b" "manual" "2"
  SWAIF_TEST_MODE=1 "$SCRIPT" "Issue" "verify" "specs/feature-b" "manual" "2"
)

assert_file_contains "$OK_REPO/specs/feature-b/spec.md" "/speckit.specify specs/feature-b/intake.md"
assert_file_contains "$OK_REPO/specs/feature-b/plan.md" "/speckit.plan specs/feature-b/spec.md"
assert_file_contains "$OK_REPO/specs/feature-b/tasks.md" "/speckit.tasks specs/feature-b/plan.md"
assert_file_contains "$OK_REPO/specs/feature-b/IMPLEMENT_PLACEHOLDER.txt" "/speckit.implement specs/feature-b/tasks.md"
assert_file_contains "$OK_REPO/specs/feature-b/VERIFY_PLACEHOLDER.txt" "/speckit.checklist specs/feature-b/tasks.md"
pass "common flow artifact generation"

echo "All tests passed"
