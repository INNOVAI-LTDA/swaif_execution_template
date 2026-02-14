# SWAIF Case Folder Template

This template defines the standard structure for every SWAIF case.

Each case must live under:

cases/`<case-id>`{=html}/

------------------------------------------------------------------------

## Required Files

cases/`<case-id>`{=html}/ - intake.md - spec.md - plan.md - tasks.md -
execution-log.md

Additional files may be required depending on Execution Type.

------------------------------------------------------------------------

# intake.md

Must include:

-   Execution Type
-   Business Context
-   Problem Statement
-   Constraints
-   Non-Goals
-   Risk Level
-   Stakeholders
-   Success Criteria

Minimum Declaration:

Execution Type: \<Hands-On \| Research \| Prototype \| PoC \| MVP \|
Scaled Product\>

------------------------------------------------------------------------

# spec.md

Must contain:

-   User stories (if applicable)
-   Acceptance Criteria (AC-IDs required)
-   Functional requirements
-   Non-functional requirements
-   Constraints explicitly restated

All Acceptance Criteria must be measurable.

------------------------------------------------------------------------

# plan.md

Must describe:

-   Architecture approach
-   Key technical decisions
-   Risk mitigation strategy
-   Dependencies
-   Integration considerations

For MVP+ types, include deployment strategy.

------------------------------------------------------------------------

# tasks.md

Must:

-   Reference AC IDs
-   Be dependency ordered
-   Use checklist format
-   Remain atomic and reviewable

Example:

-   [ ] T-01 Implement authentication handler (AC-01)

------------------------------------------------------------------------

# execution-log.md

Must capture:

-   Case ID
-   Execution Type
-   Start Date
-   End Date
-   AC Coverage
-   Drift occurrences
-   Rework cycles
-   Observations
-   Lessons learned

For Research / MVP+ types, include metrics summary.

------------------------------------------------------------------------

This structure is mandatory for all SWAIF cases.
