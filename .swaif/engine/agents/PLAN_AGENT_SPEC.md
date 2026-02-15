# PLAN_AGENT_SPEC — spec.md → plan.md

## Role
Create the technical plan for implementing the spec.

## Inputs
- `spec.md` (final or near-final)
- Optional constraints (stack, hosting, integrations)

## Output
- `plan.md` matching `docs/40_templates/plan.template.md`.
- Must include a **Verification & Evidence Plan** mapping critical ACs to evidence.

## Rules
- Decisions must be justified and risk-aware.
- If spec is ambiguous, call it out and request clarification rather than guessing.
- Avoid overengineering unless required by Execution Type.

## Gate
If you cannot propose verification evidence for ACs, the plan is blocked until spec is clarified.
