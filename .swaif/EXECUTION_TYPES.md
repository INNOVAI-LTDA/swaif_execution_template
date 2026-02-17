# SWAIF Execution Types

This document defines the operational execution modes of SWAIF.

Each execution type determines:
- Objective
- Scope
- Required artifacts
- Governance level
- Logging requirements
- Definition of Done (DoD)
- Branching policy

Execution repositories must explicitly declare which type applies to each case.

---

# 1. Hands-On Run

## Objective
Quick structured implementation using SWAIF discipline without formal research or benchmarking.

## Typical Use
- Internal improvements
- Fast delivery for low-risk modules
- Operational refinements

## Required Artifacts
- intake.md
- spec.md
- plan.md
- tasks.md
- execution-log.md (minimal)

## Governance Level
Standard stage-gated workflow enforced.

## Logging Requirements
- Basic traceability (AC → task → PR)
- Execution timestamps

## Definition of Done
- Acceptance criteria satisfied
- Tests passing
- Stage gates completed
- Case summary recorded

## Branching Policy
- Base branch: `main`
- Working branch pattern: `feature/<case-id>-hands-on`
- Merge method: squash merge (single commit per case)
- Protection level: required CI checks + 1 reviewer
- Hotfix handling: optional `hotfix/<case-id>` branch for urgent fixes, then squash into `main`

---

# 2. Research Experiment

## Objective
Controlled experimental validation of SWAIF methodology.

## Typical Use
- Benchmark vs non-SWAIF approaches
- Academic publication
- Funding program validation
- Internal method validation

## Required Artifacts
- Frozen intake.md
- spec.md (ID-tagged ACs)
- plan.md
- tasks.md
- execution-log.md (full)
- metrics.csv (exported)
- deviation-report.md (if applicable)

## Governance Level
Strict freeze policy enforced.

## Logging Requirements
- Full metric capture
- Post-merge defect window tracking
- Drift log
- Statistical dataset export

## Definition of Done
- All metrics recorded
- Dataset exported
- Experimental integrity validated
- Summary report produced

## Branching Policy
- Base branch: `research/main` (or protected `main` if a dedicated research branch does not exist)
- Working branch pattern: `research/<case-id>-exp`
- Merge method: rebase merge to preserve commit-level chronology for analysis
- Protection level: required CI checks + 2 reviewers (one method owner)
- Freeze rule: after AC freeze, only commits that map to pre-approved tasks are allowed
- Tagging: create immutable tag `research/<case-id>/freeze` at spec freeze and `research/<case-id>/final` at completion

---

# 3. Prototype

## Objective
Rapid feasibility validation with structured documentation.

## Typical Use
- Demonstrating concept to stakeholders
- Testing architecture viability
- Early-stage clinic digitalization ideas

## Required Artifacts
- intake.md
- simplified spec.md
- minimal plan.md
- tasks.md
- execution-log.md (light)

## Governance Level
Stage gates applied with flexibility.

## Logging Requirements
- Core traceability only
- No long-term metric tracking required

## Definition of Done
- Feasibility proven
- Risks identified
- Clear go/no-go decision documented

## Branching Policy
- Base branch: `develop`
- Working branch pattern: `proto/<case-id>`
- Merge method: squash merge
- Protection level: lightweight CI + 1 reviewer
- Lifecycle rule: prototype branches may be archived after decision and should not be promoted directly to production

---

# 4. Proof of Concept (PoC)

## Objective
Validate technical and operational viability under near-real conditions.

## Typical Use
- Clinic workflow digitization pilot
- Integration with third-party systems
- Regulatory feasibility testing

## Required Artifacts
- Full intake.md
- spec.md with AC IDs
- plan.md
- tasks.md
- risk-analysis.md
- execution-log.md
- compliance-notes.md (if applicable)

## Governance Level
High discipline, audit-friendly.

## Logging Requirements
- Traceability complete
- Risk log
- Security considerations documented

## Definition of Done
- Functional validation completed
- Regulatory constraints evaluated
- Deployment readiness assessed

## Branching Policy
- Base branch: `preprod`
- Working branch pattern: `poc/<case-id>`
- Merge method: rebase merge
- Protection level: required CI/security checks + 2 reviewers
- Promotion rule: only signed release branches `release/poc/<case-id>` may be promoted to `main`

---

# 5. MVP (Minimum Viable Product)

## Objective
Deliver deployable software with production intent.

## Typical Use
- First deployable clinic module
- Paid pilot
- Early commercial release

## Required Artifacts
- intake.md
- spec.md
- plan.md
- tasks.md
- execution-log.md
- risk-analysis.md
- deployment-plan.md
- monitoring-plan.md

## Governance Level
Full stage-gated enforcement.

## Logging Requirements
- Full traceability
- Defect window monitoring
- Security validation
- Operational readiness checklist

## Definition of Done
- Deployable artifact
- Monitoring enabled
- Documentation complete
- Audit trail preserved

## Branching Policy
- Base branch: `main`
- Working branch pattern: `mvp/<case-id>`
- Merge method: squash merge by default; rebase merge allowed when maintaining traceability across multiple implementation commits is required
- Protection level: full CI/CD, security scanning, and 2 reviewers
- Release rule: cut `release/<version>` from the merged branch before deployment

---

# 6. Scaled Product

## Objective
Long-term production-grade system for multiple clinics.

## Typical Use
- Multi-tenant healthcare platform
- White-label system
- Enterprise-grade deployment

## Required Artifacts
- All MVP artifacts
- architecture-review.md
- performance-benchmark.md
- security-review.md
- scalability-plan.md
- data-governance-plan.md

## Governance Level
Maximum discipline.

## Logging Requirements
- Continuous metric tracking
- Benchmark documentation
- Incident tracking
- Change log

## Definition of Done
- Production stability achieved
- Compliance requirements satisfied
- Monitoring and rollback strategies in place
- Maintenance strategy documented

## Branching Policy
- Base branch: `main`
- Working branch pattern: `product/<domain>/<case-id>`
- Merge method: rebase merge (or merge commit when preserving multi-team integration history is required)
- Protection level: strict branch protection, mandatory status checks, CODEOWNERS approval, and change-management sign-off
- Multi-stream rule: long-lived support branches `support/<major>.x` and emergency branches `hotfix/<incident-id>` are mandatory for production continuity

---

# Execution Declaration Rule

Every case must include in its intake.md:

`Execution Type: <Hands-On | Research | Prototype | PoC | MVP | Scaled Product>`

Failure to declare execution type invalidates the case.

---

# Design Philosophy

Execution types allow SWAIF to:

- Adapt to business context
- Preserve methodological integrity
- Maintain audit readiness
- Scale from idea to enterprise system
- Support high-ticket healthcare engagements

This classification is mandatory for all SWAIF execution repositories.

