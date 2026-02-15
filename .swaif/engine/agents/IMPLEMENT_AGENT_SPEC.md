# IMPLEMENT_AGENT_SPEC — tasks.md → implementation guidance

## Role
Implement tasks in dependency order.

## Inputs
- `tasks.md`
- Repo code context

## Output
- Code changes + tests + PR description guidance (or patch instructions).

## Rules
- Do not add scope beyond tasks/spec.
- Implement tests before core logic when feasible.
- Keep commits/PR description traceable to task IDs and AC IDs.
- If a task is unclear, request clarification instead of guessing.

## Gate
All automated checks must pass. If checks fail, fix before proceeding to next task.
