# Specification: [Feature Name]

<!-- 
INSTRUCTIONS:
- Fill in all sections below
- Delete instruction comments after completing
- Link this spec to downstream plans and tasks
- Get stakeholder approval before proceeding to Phase -1
-->

---

## Frontmatter

```yaml
spec_id: SPEC-NNNN                    # Sequential number, e.g., SPEC-001
title: [Feature Name]                 # Brief, descriptive title
version: 1.0.0                        # Semantic version
status: Draft                         # Draft | In Review | Approved | Implemented
author: [Your Name]                   # Primary author
created_date: YYYY-MM-DD              # Creation date
last_updated: YYYY-MM-DD              # Last modification date
stakeholders:                         # Who needs to approve this
  - [Product Owner Name]
  - [Engineering Lead Name]
  - [Business Stakeholder Name]
related_docs:                         # Links to related specs/plans
  - SPEC-XXX: [Related Feature]
  - PLAN-XXX: [Implementation Plan]
constitutional_version: 1.0.0         # Version of constitution this spec follows
```

---

## Constitutional Compliance Checklist

<!-- Article I: Traceability & Linkage -->
- [ ] **Traceability (Article I)**: All user stories have unique IDs (US-NNN)
- [ ] **Linkage**: Spec ID (SPEC-NNN) will be referenced in downstream PLAN-NNN and TASKS-NNN
- [ ] **Orphan Prevention**: All requirements trace to acceptance tests

<!-- Article II: Stage Gate Discipline -->
- [ ] **Stage Gate (Article II)**: This spec is the Phase 0 entry gate output
- [ ] **Documentation**: Using approved `swaif-spec-template.md`

<!-- Article III: Test-First Engineering -->
- [ ] **Test-First (Article III)**: Acceptance criteria defined for all user stories
- [ ] **Test Coverage**: Integration test scenarios documented

<!-- Article VIII: Security -->
- [ ] **Security (Article VIII)**: Security requirements identified in NFRs section
- [ ] **Compliance**: Regulatory requirements documented (if applicable)

<!-- Article IX: Documentation Sync -->
- [ ] **Documentation (Article IX)**: Last updated timestamp included
- [ ] **Living Doc**: Spec will be updated if requirements change during implementation

---

## Executive Summary

<!-- 2-3 paragraphs answering:
- What is this feature?
- Why are we building it?
- What business value does it deliver?
- Who are the users?
-->

**Problem Statement**:
[Describe the problem this feature solves. What pain point does it address?]

**Solution Overview**:
[High-level description of the proposed solution. What will we build?]

**Business Value**:
[Expected outcomes, metrics, or KPIs this feature will impact.]

**Target Users**:
[Who will use this feature? User personas, roles, or segments.]

---

## User Stories

<!-- 
Format: 
- Each story has a unique ID (US-NNN)
- Follow "As a... I want... So that..." format
- Include detailed acceptance criteria
- Link to constitutional articles
-->

### US-001: [User Story Title]

**As a** [user role]  
**I want to** [capability]  
**So that** [benefit/value]

**Priority**: High | Medium | Low  
**Estimated Complexity**: High | Medium | Low  

**Acceptance Criteria**:
<!-- These become the basis for integration tests in Phase -1 -->
1. ✅ **Given** [context/precondition]  
   **When** [action]  
   **Then** [expected outcome]

2. ✅ **Given** [context]  
   **When** [action]  
   **Then** [outcome]

3. ✅ **Given** [edge case context]  
   **When** [action]  
   **Then** [edge case handling]

**Out of Scope**:
- [Explicitly list what this story does NOT include]

**Dependencies**:
- US-XXX: [Dependent user story]
- External: [External system or API dependency]

**Constitutional Compliance**:
- Article I (Traceability): Will be traced in PLAN-NNN → TASKS-NNN
- Article III (Test-First): Acceptance criteria will become integration tests

**Notes**:
[Any additional context, design constraints, or technical considerations]

---

### US-002: [Second User Story]

**As a** [user role]  
**I want to** [capability]  
**So that** [benefit]

**Priority**: Medium  
**Estimated Complexity**: Low  

**Acceptance Criteria**:
1. ✅ [Criterion 1]
2. ✅ [Criterion 2]
3. ✅ [Criterion 3]

**Out of Scope**:
- [Exclusions]

**Dependencies**:
- None

**Constitutional Compliance**:
- Article VI (Integration-First): Will define API contract in PLAN-NNN

---

<!-- Add more user stories as needed: US-003, US-004, etc. -->

---

## Non-Functional Requirements (NFRs)

<!-- These define quality attributes and constraints -->

### Performance

| Metric | Requirement | Rationale |
|--------|-------------|-----------|
| Response Time | < 200ms (p95) | User experience expectation |
| Throughput | 1000 req/sec | Expected peak load |
| Data Volume | Handle 10M records | Projected growth |

**Performance Tests**: 
- Load test with [N] concurrent users
- Stress test at [X] req/sec for [Y] minutes

---

### Scalability

- **Horizontal Scaling**: Service must support 10 instances without shared state
- **Data Partitioning**: Database must support sharding by [partition key]
- **Caching Strategy**: [Describe caching approach]

---

### Security (Article VIII)

| Requirement | Implementation | Priority |
|-------------|----------------|----------|
| Authentication | OAuth 2.0 / JWT | MUST |
| Authorization | Role-based access control (RBAC) | MUST |
| Input Validation | Sanitize all inputs, parameterized queries | MUST |
| Encryption in Transit | TLS 1.3 | MUST |
| Encryption at Rest | AES-256 | SHOULD |
| Audit Logging | Log all auth events and data access | MUST |
| Secret Management | Use AWS Secrets Manager / HashiCorp Vault | MUST |

**Security Threats**:
- [List potential threats: SQL injection, XSS, CSRF, etc.]

**Mitigation Strategies**:
- [Describe how each threat is mitigated]

---

### Reliability

- **Availability**: 99.9% uptime (SLA)
- **Error Rate**: < 0.1% of requests
- **Fault Tolerance**: Graceful degradation if [dependency] fails
- **Disaster Recovery**: RPO < 1 hour, RTO < 4 hours

---

### Observability (Article VII)

- **Logging**: Structured JSON logs with request IDs
- **Metrics**: Expose Prometheus metrics for request count, latency, errors
- **Tracing**: Distributed tracing with OpenTelemetry
- **CLI Interface**: `myapp health`, `myapp metrics`, `myapp debug`

---

### Compliance

<!-- If applicable -->
- [ ] GDPR: User data deletion within 30 days of request
- [ ] HIPAA: PHI encrypted and access logged
- [ ] SOC 2: Audit trail for all data access

---

### Usability

- **Accessibility**: WCAG 2.1 Level AA compliance
- **Internationalization**: Support English, Spanish, French
- **Mobile**: Responsive design for mobile browsers

---

### Maintainability

- **Code Standards**: Follow [language style guide]
- **Test Coverage**: 80%+ unit test coverage, 100% user story coverage
- **Documentation**: API docs auto-generated from code

---

## Risk Assessment

<!-- Identify risks early so they can be mitigated in Phase -1 -->

| Risk ID | Risk Description | Probability | Impact | Mitigation Strategy | Owner |
|---------|------------------|-------------|--------|---------------------|-------|
| R-001 | External API dependency may be slow | Medium | High | Implement caching + timeout | [Name] |
| R-002 | Data migration complexity | High | Medium | Phased rollout, feature flags | [Name] |
| R-003 | Security vulnerability in [component] | Low | High | Challenger review + pen test | [Name] |
| R-004 | Performance bottleneck at scale | Medium | Medium | Load testing in Phase -1 | [Name] |

**Risk Register Updates**:
- Risks will be revisited during Phase -1 (technical planning)
- Mitigation plans will be detailed in PLAN-NNN

---

## Constraints & Assumptions

### Constraints
<!-- Hard limits that cannot be changed -->
- **Budget**: $[X] development cost
- **Timeline**: Must launch by [date]
- **Technology**: Must use existing [tech stack]
- **Team**: [N] engineers available
- **Compliance**: Must meet [regulation]

### Assumptions
<!-- Things we believe to be true but should validate -->
- Assumption 1: Users have modern browsers (Chrome, Firefox, Safari)
- Assumption 2: External API will maintain current SLA
- Assumption 3: Database can handle 10x current load
- Assumption 4: [Assumption to validate in Phase -1]

**Validation Plan**:
- [How and when each assumption will be validated]

---

## Success Metrics

<!-- How will we know this feature is successful? -->

| Metric | Baseline | Target | Measurement Method |
|--------|----------|--------|--------------------|
| User Adoption | 0 users | 5,000 users in 3 months | Analytics dashboard |
| Task Completion Rate | N/A | 90% | User analytics |
| Error Rate | N/A | < 1% | Application logs |
| User Satisfaction | N/A | 4.5/5 stars | Post-use survey |
| Performance | N/A | p95 < 200ms | APM tool |

**Monitoring**:
- Metrics will be reviewed weekly for first month
- Dashboard: [Link to monitoring dashboard]

---

## Stage Gate Requirements

### Entry Criteria (Phase 0 → Phase -1)
- [ ] All user stories have acceptance criteria
- [ ] NFRs are clearly defined
- [ ] Risks are identified
- [ ] Stakeholders have reviewed spec
- [ ] **Approval signatures obtained** (see Approval section below)

### Exit Criteria (Phase -1 → Phase 0 Planning)
- [ ] Technical plan (PLAN-NNN) created
- [ ] Phase -1 gates passed (Simplicity, Anti-Abstraction, Integration-First)
- [ ] Challenger review completed
- [ ] Technical feasibility confirmed

---

## Dependencies

### Upstream Dependencies
<!-- What must be completed before we can start? -->
- SPEC-XXX: [Prerequisite feature]
- External: [Third-party API, infrastructure, etc.]

### Downstream Dependencies
<!-- What depends on this feature? -->
- SPEC-YYY: [Feature that builds on this]
- Teams: [Teams that need to integrate with this]

### External Dependencies
- [Third-party service or API]
- [Infrastructure or tooling]
- [Data sources]

---

## Out of Scope

<!-- Explicitly state what is NOT included to prevent scope creep -->

This specification does **NOT** include:
- [Feature or capability explicitly excluded]
- [Future enhancement to be scoped separately]
- [Related but separate concern]

**Future Considerations**:
- [Ideas for v2 or follow-on work]

---

## Approval

### Review History

| Date | Reviewer | Role | Status | Comments |
|------|----------|------|--------|----------|
| YYYY-MM-DD | [Name] | Product Owner | Approved | [Comments] |
| YYYY-MM-DD | [Name] | Engineering Lead | Changes Requested | [Comments] |
| YYYY-MM-DD | [Name] | Security Reviewer | Approved | [Comments] |

### Approval Signatures

**This specification is approved for progression to Phase -1 (Technical Planning).**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| **Product Owner** | [Name] | __________ | ______ |
| **Engineering Lead** | [Name] | __________ | ______ |
| **Stakeholder** | [Name] | __________ | ______ |

---

## Appendix

### Glossary
<!-- Define domain-specific terms -->
- **[Term]**: [Definition]
- **[Acronym]**: [Expansion and meaning]

### References
<!-- Links to external resources -->
- [Industry standard or best practice]
- [Research paper or article]
- [Competitive analysis]

### Mockups / Wireframes
<!-- If applicable, link to or embed design mockups -->
- [Link to Figma/Sketch/etc.]
- ![Wireframe](path/to/wireframe.png)

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | YYYY-MM-DD | [Name] | Initial specification |
| 1.1.0 | YYYY-MM-DD | [Name] | Added US-003, updated NFRs |

---

## Traceability

<!-- This section tracks where this spec is implemented -->

**Downstream Documents**:
- PLAN-NNN: [Technical Plan] (Phase -1)
- TASKS-NNN: [Task Breakdown] (Phase 0)

**Source Code** (updated post-implementation):
- `src/[module]/[file].py` (US-001, US-002)
- `tests/test_[feature].py` (US-001)

**Last Synced With Code**: [Commit hash or N/A if not yet implemented]

---

**End of Specification**

<!-- 
Next Steps:
1. Get stakeholder approval (signatures above)
2. Create PLAN-NNN using swaif-plan-template.md
3. Pass Phase -1 gates before proceeding to task breakdown
-->
# SWAIF Specification Template

> Template owner: Product + Architecture.
> Expected inputs: problem statement, user outcomes, constraints, constitution version, and delivery context.

## Metadata (YAML)

```yaml
spec_id: SPEC-YYYY-NNN
name: <short-title>
version: 0.1.0
status: draft # draft|review|approved|implemented|retired
owner:
  product: <name>
  engineering: <name>
  risk: <name>
constitution_ref:
  doc: <path-or-uri>
  version: <semver>
lifecycle_stage: specification
risk_mode: low # low|moderate|high|critical
last_updated: YYYY-MM-DD
```

## 1) Problem and Outcome Definition

- **Problem statement**: `[what is broken or missing]`
- **Target users/stakeholders**: `[who benefits or is impacted]`
- **Desired outcomes**: `[measurable outcomes]`
- **Out of scope**: `[explicit exclusions]`

## 2) Functional Scope

- **Capabilities in scope**
  - `[capability 1]`
  - `[capability 2]`
- **Interfaces affected**
  - `[UI/API/Event/Data contracts]`
- **Migration/rollout assumptions**
  - `[assumptions]`

## 3) Constitutional Checklist

> Mark each item `PASS`, `PARTIAL`, or `FAIL` and justify with evidence links.

- [ ] **Purpose alignment** — Solution directly supports constitutional purpose.
- [ ] **Decision rights** — Named accountable owners and approvers.
- [ ] **Stage-gate readiness** — Required artifacts are identified.
- [ ] **Quality baseline** — Test strategy and acceptance criteria defined.
- [ ] **Security/privacy baseline** — Threats, controls, and data handling defined.
- [ ] **Risk handling** — Risk level, mitigations, and exceptions documented.
- [ ] **Observability baseline** — Telemetry and incident signals defined.

## 4) Non-Functional Requirements (NFRs)

| Category | Requirement | Target | Verification Method | Owner |
|---|---|---|---|---|
| Performance | `[e.g., p95 latency]` | `[target]` | `[load/perf test]` | `[role]` |
| Availability | `[uptime objective]` | `[target]` | `[SLO monitor]` | `[role]` |
| Reliability | `[error budget / MTTR]` | `[target]` | `[ops drill + dashboards]` | `[role]` |
| Security | `[control objective]` | `[target]` | `[scan/review/test]` | `[role]` |
| Privacy | `[data minimization]` | `[target]` | `[review/audit]` | `[role]` |
| Compliance | `[framework requirement]` | `[target]` | `[evidence artifact]` | `[role]` |

## 5) Risk Assessment

- **Risk mode**: `[low|moderate|high|critical]`
- **Top risks**:
  1. `[risk]` — Probability: `[L/M/H]`, Impact: `[L/M/H]`, Mitigation: `[plan]`
  2. `[risk]` — Probability: `[L/M/H]`, Impact: `[L/M/H]`, Mitigation: `[plan]`
- **Residual risk summary**: `[remaining risk after controls]`
- **Exception requests** (if any): `[id, rationale, expiry, approver]`

## 6) Approval Record

| Role | Name | Decision | Date | Notes |
|---|---|---|---|---|
| Product Owner | `[name]` | `[approve/revise/reject]` | YYYY-MM-DD | `[notes]` |
| Engineering Lead | `[name]` | `[approve/revise/reject]` | YYYY-MM-DD | `[notes]` |
| Security/Risk | `[name]` | `[approve/revise/reject]` | YYYY-MM-DD | `[notes]` |

## 7) Evidence and Trace Links

- Constitution reference: `[link]`
- Plan artifact: `[link when available]`
- Tasks artifact: `[link when available]`
- Supporting research: `[links]`
