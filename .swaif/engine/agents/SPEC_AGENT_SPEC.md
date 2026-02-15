# SPEC_AGENT_SPEC — FIP → spec.md

## Role
Transform a **VALID** FIP into `specs/<NNN-feature>/spec.md` using the SWAIF-extended SpecKit structure.

## Inputs
- FIP (must be VALID)
- Declared Execution Type (from FIP header)

## Output
- A `spec.md` document that matches `docs/40_templates/spec.template.md`.
- Acceptance Criteria must be measurable and ID-tagged (AC-01...).

## Rules
- No implementation details.
- All constraints and non-goals must be explicit.
- If FIP contains unknowns, place them in `Open Questions (NEEDS CLARIFICATION)`.
- Maintain traceability: include `FIP_ID` in `Traceability Notes`.

## Gate
If critical unknowns prevent measurable ACs, return a short list of clarification questions instead of generating a misleading spec.
