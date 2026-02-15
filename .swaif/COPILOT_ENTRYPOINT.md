# SWAIF Copilot/Codex Entrypoint

Follow these sources first:

1. `.swaif/engine/agents/*`
2. `.swaif/engine/templates/*`

Do not skip stage gates. Run exactly one factory step per request.

## Prompt patterns

- **FIP validation**
  - "Validate this Factory Input Package against SWAIF gate criteria and list gaps only."
- **Spec generation**
  - "Using `.swaif/engine/templates/swaif-spec-template.md`, generate `specs/<NNN-feature>/spec.md` from this FIP."
- **Plan generation**
  - "Given `spec.md`, generate `plan.md` using `.swaif/engine/templates/swaif-plan-template.md`."
- **Tasks generation**
  - "Given `plan.md`, generate `tasks.md` using `.swaif/engine/templates/swaif-tasks-template.md`."
- **Implement**
  - "Implement only tasks approved in `tasks.md`; do not introduce unplanned scope."
- **Verify**
  - "Verify completion against acceptance criteria and task traceability; report blockers deterministically."
