<!--
Sync Impact Report
- Version change: placeholder -> 1.0.0
- Modified principles: Template placeholders replaced with Articles I-IX
- Added sections: Governance and Enforcement, Appendix: Quick Reference
- Removed sections: None
- Templates requiring updates:
  - .specify/templates/plan-template.md: updated
  - .specify/templates/spec-template.md: updated
  - .specify/templates/tasks-template.md: updated
- Follow-up TODOs: None
-->
# SWAIF Execution Template Constitution

## Core Principles

### Article I: Traceability and Linkage
- All artifacts MUST be bidirectionally traceable: Spec (SPEC-*) <-> Plan (PLAN-*) <->
  Tasks (TASKS-*) <-> Code and Tests.
- Every user story MUST map to acceptance tests, integration scenarios, and tasks.
- Orphan prevention is mandatory: no orphan code, requirements, or tests.
- Traceability verification SHOULD be automated (link validators, coverage reports,
  orphan detectors).

Rationale: Traceability prevents scope creep and ensures delivered code matches
approved requirements.

### Article II: Stage Gate Discipline
- Work MUST progress through defined stages: Requirements -> Design -> Planning ->
  Implementation -> Delivery.
- Phase -1 gates are mandatory before planning: Simplicity, Anti-Abstraction,
  Integration-First, and Challenger Review.
- Gate bypassing MUST NOT occur without explicit written exception or emergency
  hotfix documentation.

Rationale: Stage gates prevent rework by validating design quality before code.

### Article III: Test-First Engineering
- Integration tests MUST be written first, then unit tests, then implementation.
- Every feature MUST include integration, unit, and acceptance tests.
- TDD workflow is mandatory: Red -> Green -> Refactor.
- Tests MUST be co-located with code and run in CI before merge.

Rationale: Tests are executable specifications that prevent regressions and clarify
behavior.

### Article IV: Challenger Mode and Adversarial Review
- Every plan and significant implementation MUST have a Challenger review.
- Challenger reviews MUST cover logic flaws, security issues, integration failures,
  and maintainability.
- Authors MUST respond to every challenge and record accepted risks in a
  Risk Register section.

Rationale: Adversarial review finds edge cases before they reach production.

### Article V: Simplicity and Anti-Abstraction
- The simplest viable design MUST be chosen.
- Abstractions MUST be justified by three concrete use cases and a clear
  complexity reduction.
- Speculative generality is prohibited; follow the Rule of Three.
- Designs MUST pass the Plain Language Test.

Rationale: Simplicity reduces maintenance cost and security risk.

### Article VI: Integration-First Development
- API contracts MUST be defined before implementation.
- Integration tests MUST be written before component code.
- Contract tests and example requests/responses are mandatory.
- Vertical slices SHOULD be preferred; isolated development is prohibited.

Rationale: Integration is where most defects appear; start there.

### Article VII: Observability and CLI Interface
- Every service/component MUST provide CLI commands for health, inspect, metrics,
  debug, and config.
- Health/ready endpoints or commands MUST exist with correct exit codes.
- Logs MUST be structured with timestamp, level, and request ID.
- Debugging MUST be possible without code changes.

Rationale: Production issues must be diagnosable using standard interfaces.

### Article VIII: Security and Constitutional Review
- Automated and manual security reviews are mandatory before deployment.
- Plans MUST include a Security Considerations checklist: authentication,
  authorization, input validation, secrets, encryption, audit logging, error
  handling.
- Hardcoded secrets are prohibited; dependencies MUST be pinned and monitored.
- Least-privilege execution is required.

Rationale: Security defects are production defects.

### Article IX: Documentation Sync
- Documentation MUST be updated with code changes within 24 hours and in the same
  PR.
- Docs MUST include last-updated metadata and the commit they reflect.
- Required docs include README, API docs, architecture docs, and runbooks.

Rationale: Outdated documentation is worse than missing documentation.

## Governance and Enforcement

Amendment process:
1. Proposal by any team member.
2. Minimum one-week comment period.
3. Approval by 2/3 of the SWAIF Constitution Council.
4. Effective at next sprint start unless marked urgent.

Enforcement:
- Specs, plans, and tasks MUST reference constitutional articles they satisfy.
- PRs MUST pass constitutional compliance checks.
- Major violations require redesign before merge.

Exception process:
1. Submit written request with justification.
2. Document risks and remediation plan.
3. Obtain council approval and time-limit the exception.

Authority: SWAIF Constitution Council (Engineering Lead, Tech Lead, Product Owner).

Ratification: This constitution governs the SWAIF execution repository
INNOVAI-LTDA/swaif_execution_template.

## Appendix: Quick Reference

Constitutional compliance checklist:
- Article I: Traceability links present (SPEC -> PLAN -> TASK -> Code)
- Article II: Stage gates satisfied (Phase -1 gates for plans)
- Article III: Tests written before code
- Article IV: Challenger review completed
- Article V: Simplicity verified, abstractions justified
- Article VI: Integration tests defined first
- Article VII: CLI interface and health endpoints planned
- Article VIII: Security checklist completed
- Article IX: Documentation updated with code

Enforcement levels:
- MUST / MUST NOT: Mandatory, blocking
- SHOULD: Strongly recommended, requires justification if skipped
- MAY: Optional

Common questions:
- Can I skip tests for a prototype? Only if explicitly marked experimental and
  non-production; before production Article III applies.
- What if Challenger feedback blocks work unfairly? Escalate to the council.
- Can AI agents enforce compliance? Yes, via Challenger prompts and validators.

## Governance

- This constitution supersedes local team practices when conflicts exist.
- All specifications, plans, and tasks MUST include traceability IDs.
- Compliance checks are required for every PR and release.
- Use the .specify templates and skills to keep artifacts aligned.

**Version**: 1.0.0 | **Ratified**: 2026-02-20 | **Last Amended**: 2026-02-20
