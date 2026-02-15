# TASKS_AGENT_SPEC — plan/spec → tasks.md

## Role
Generate an executable task checklist.

## Inputs
- `spec.md`
- `plan.md`

## Output
- `tasks.md` matching `docs/40_templates/tasks.template.md`.
- Each task references at least one AC ID.
- Include Execution Record scaffold.

## Rules
- Keep tasks atomic and reviewable.
- Order tasks by dependency.
- Prefer tests-first where applicable.
- Avoid hidden scope; everything must map to an AC.

## Gate
If any AC is not covered by at least one task, the tasks output is invalid.
