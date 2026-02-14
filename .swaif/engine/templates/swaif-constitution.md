# Software Factory Constitution

---

## Metadata

| Field | Value |
|-------|-------|
| **Version** | 1.0.0 |
| **Effective Date** | YYYY-MM-DD |
| **Last Amended** | YYYY-MM-DD |
| **Authority** | [Engineering Lead, Tech Lead, Product Owner] |
| **Scope** | [Project/Organization Name] |
| **Status** | Draft / Active / Superseded |

---

## Preamble

### Purpose of This Constitution

This Software Factory Constitution establishes the foundational principles, practices, and governance model for our engineering organization. It exists to:

1. **Ensure Quality**: Define non-negotiable standards for software quality, testing, and delivery
2. **Enable Traceability**: Create clear linkages from business requirements through code to production
3. **Enforce Discipline**: Establish stage gates and review processes that prevent defects
4. **Foster Collaboration**: Define how humans and AI agents work together effectively
5. **Maintain Velocity**: Balance rigor with pragmatism to deliver value sustainably

### Why We Need a Constitution

Software development without governing principles leads to:
- Requirements that don't map to delivered features
- Code that works in isolation but fails in integration
- Technical debt that compounds until systems become unmaintainable
- Security vulnerabilities discovered in production
- Documentation that diverges from reality

This constitution prevents these failure modes by establishing **constitutional requirements** that all factory outputs must satisfy.

### Scope and Applicability

This constitution applies to:
- ✅ All new feature development
- ✅ Major refactoring and architectural changes
- ✅ Bug fixes that require design decisions
- ✅ Documentation and specification work
- ✅ Work performed by humans, AI agents, or mixed teams

This constitution may be waived for:
- ⚠️ Emergency hotfixes (with retroactive documentation)
- ⚠️ Experimental prototypes (clearly labeled as non-production)
- ⚠️ One-off scripts (with explicit approval)

### Constitutional Authority

The authority to interpret, amend, and enforce this constitution rests with: **[Define your governance structure here]**

Example:
- **Constitutional Authority**: Engineering Lead + Tech Lead (joint approval required)
- **Amendment Power**: Requires 2/3 team vote after 1-week comment period
- **Enforcement**: Tech Lead reviews compliance, escalates violations
- **Exceptions**: Require written justification and authority approval

---

## Article I: Traceability & Linkage

### Principle

Every line of code, test, and document SHALL be traceable to a requirement, and every requirement SHALL be traceable to delivered artifacts.

### Requirements

#### 1.1 Bidirectional Traceability (MUST)

All factory outputs MUST maintain bidirectional links:

```
Specification (SPEC-NNN)
    ↕ (implements/implemented-by)
Technical Plan (PLAN-NNN)
    ↕ (executes/executed-by)
Task Breakdown (TASKS-NNN)
    ↕ (produces/produced-by)
Source Code + Tests
```

**Implementation**:
- Use consistent ID prefixes: `SPEC-`, `PLAN-`, `TASK-`, `US-` (user story)
- Include traceability sections in all documents
- Reference IDs in commit messages: `git commit -m "TASK-042: Implement login API"`
- Link PRs to tasks, tasks to plans, plans to specs

#### 1.2 User Story Mapping (MUST)

Every user story MUST map to:
- At least one acceptance test
- At least one integration test scenario
- One or more tasks in the task breakdown
- Specific source files or modules

#### 1.3 Orphan Prevention (MUST)

- **No orphan code**: All code must trace to a requirement
- **No orphan requirements**: All approved specs must have implementation plans
- **No orphan tests**: All tests must reference the requirement they verify

#### 1.4 Traceability Verification (SHOULD)

Projects SHOULD implement automated traceability checking:
- Link validators that verify IDs exist
- Coverage reports showing requirement→test mapping
- Orphan detectors that flag unlinked artifacts

### Rationale

Traceability prevents scope creep, enables impact analysis, and ensures that what we built matches what was requested. It's the foundation of factory discipline.

---

## Article II: Stage Gate Discipline

### Principle

Software development SHALL proceed through defined stages with clear entry/exit criteria. No stage SHALL be skipped, and no stage SHALL proceed without satisfying its gates.

### Requirements

#### 2.1 Factory Stages (MUST)

All work MUST progress through these stages:

| Stage | Name | Entry Criteria | Exit Criteria | Outputs |
|-------|------|----------------|---------------|---------|
| **Phase 0** | Requirements | Stakeholder request | Approved specification | SPEC-NNN.md |
| **Phase -1** | Design | Approved spec | Phase -1 gates passed | PLAN-NNN.md |
| **Phase 0** | Planning | Approved plan | Task breakdown complete | TASKS-NNN.md |
| **Phase 1-N** | Implementation | Task list ready | All tests pass | Code + Tests |
| **Phase N+1** | Delivery | Tests pass + review | Production deployment | Released feature |

#### 2.2 Phase -1 Gates (MUST)

Before moving from Design (Phase -1) to Planning (Phase 0), the plan MUST pass these gates:

1. **Simplicity Gate**:
   - Can the solution be explained in plain language to a non-technical stakeholder?
   - Is the architecture the simplest that could possibly work?
   - Have we removed all unnecessary abstractions?

2. **Anti-Abstraction Gate**:
   - Are abstractions justified by 3+ concrete use cases?
   - Can the code work without frameworks or libraries that hide behavior?
   - Is every layer of indirection necessary?

3. **Integration-First Gate**:
   - Does the plan start with integration tests?
   - Are API contracts defined before implementation?
   - Can we test the whole flow before building parts?

**Challenger Review**: A designated engineer (or AI agent in Challenger mode) MUST review the plan adversarially, attempting to find flaws in logic, security, or design.

#### 2.3 Stage Documentation (MUST)

Each stage MUST produce its specified output document:
- Specifications MUST use `swaif-spec-template.md`
- Plans MUST use `swaif-plan-template.md`
- Tasks MUST use `swaif-tasks-template.md`

#### 2.4 Gate Bypassing (MUST NOT)

No work MAY proceed to the next stage without satisfying gates, except:
- Emergency hotfixes (with retroactive documentation within 24 hours)
- Explicit written exception approved by constitutional authority

### Rationale

Stage gates prevent "code first, think later" approaches that lead to rework. They ensure designs are vetted before implementation costs are sunk.

---

## Article III: Test-First Engineering

### Principle

Tests SHALL be written before implementation code. The specification defines what to test, the plan defines how to test, and tests prove that implementation is correct.

### Requirements

#### 3.1 Test-First Mandate (MUST)

For all new features and significant changes:
1. Write integration tests first (based on user stories)
2. Write unit tests for components second
3. Write implementation code last
4. All tests MUST pass before code review

#### 3.2 Test Types (MUST)

Every feature MUST have:

| Test Type | Purpose | Scope | When Written |
|-----------|---------|-------|--------------|
| **Integration Tests** | Verify user stories end-to-end | Full feature flow | Phase -1 (in plan) |
| **Unit Tests** | Verify component behavior | Individual functions/classes | Phase 1 (before code) |
| **Acceptance Tests** | Verify acceptance criteria | User story validation | Phase 0 (in spec) |

#### 3.3 Test Coverage Requirements (SHOULD)

Projects SHOULD maintain:
- Integration test coverage: 100% of user stories
- Unit test coverage: 80%+ of business logic
- API contract tests: 100% of public endpoints

#### 3.4 Test-Driven Development (TDD) Workflow (MUST)

1. **Red**: Write a failing test that defines desired behavior
2. **Green**: Write the simplest code that makes the test pass
3. **Refactor**: Improve code while keeping tests green
4. **Repeat**: Continue until acceptance criteria met

#### 3.5 Test Ownership (MUST)

- Tests MUST be co-located with code (e.g., `src/auth.py` → `tests/test_auth.py`)
- Tests MUST be version controlled alongside code
- Tests MUST run in CI/CD pipeline before merge

### Rationale

Test-first engineering provides executable specifications, prevents regressions, and enables confident refactoring. It shifts quality left in the development process.

---

## Article IV: Challenger Mode & Adversarial Review

### Principle

All designs, plans, and implementations SHALL be subjected to adversarial review by a "Challenger" who actively attempts to find flaws, edge cases, and security vulnerabilities.

### Requirements

#### 4.1 Challenger Role (MUST)

For every plan and significant implementation:
- A Challenger MUST be assigned (human engineer or AI in Challenger mode)
- The Challenger's goal is to break the design, not approve it
- The Challenger MUST provide written feedback before approval

#### 4.2 Challenger Review Scope (MUST)

The Challenger MUST review:

1. **Logic Flaws**:
   - Does the design handle edge cases?
   - Are there race conditions or concurrency issues?
   - Can inputs cause unexpected behavior?

2. **Security Vulnerabilities**:
   - Are authentication/authorization checks present?
   - Can inputs be exploited (injection, XSS, etc.)?
   - Are secrets properly managed?

3. **Integration Failures**:
   - Will this work with existing systems?
   - Are API contracts backward compatible?
   - What happens if dependencies fail?

4. **Complexity & Maintainability**:
   - Is this simpler than necessary?
   - Can a new engineer understand this?
   - Are there hidden abstractions?

#### 4.3 Challenger Questions (SHOULD)

Challengers SHOULD ask:
- "What breaks if [X] fails?"
- "How would an attacker exploit this?"
- "Can we delete [Y] and still meet requirements?"
- "What are we assuming that might not be true?"

#### 4.4 Responding to Challenges (MUST)

Authors MUST:
- Address every Challenger comment with either a fix or documented justification
- Re-submit for review after significant changes
- Document accepted risks in a "Risk Register" section

#### 4.5 Copilot Challenger Mode (MAY)

AI agents MAY be used in Challenger mode by prompting:
```
Act as a Challenger reviewer for this plan. Your goal is to find
flaws, edge cases, and security issues. Be adversarial but constructive.
Review: [plan content]
```

### Rationale

Adversarial review catches bugs before they're written. The Challenger mindset is different from normal code review—it actively seeks to break rather than approve.

---

## Article V: Simplicity & Anti-Abstraction

### Principle

The factory SHALL favor concrete, simple solutions over abstract, flexible ones. Abstractions MUST be justified by multiple real use cases, not hypothetical future needs.

### Requirements

#### 5.1 Simplicity First (MUST)

When multiple designs meet requirements:
- MUST choose the simplest that could possibly work
- MUST avoid premature optimization
- MUST avoid speculative features

#### 5.2 Abstraction Justification (MUST)

Every abstraction (interface, base class, framework, library) MUST be justified by:
- **Three Concrete Use Cases**: Show 3+ real scenarios that need the abstraction
- **Complexity Budget**: Prove the abstraction reduces total complexity, not just shifts it
- **Escape Hatch**: Provide a way to bypass the abstraction if needed

**Example (BAD)**:
```python
# Premature abstraction - no justification
class AbstractDataProcessor:
    def process(self): pass

class UserProcessor(AbstractDataProcessor):
    def process(self): return process_user()
```

**Example (GOOD)**:
```python
# Concrete implementation - no abstraction until needed
def process_user(user_data):
    return transform_and_validate(user_data)
```

#### 5.3 No Speculative Generality (MUST NOT)

Code MUST NOT include:
- Frameworks for "future flexibility" without current use cases
- Configuration options for features that don't exist
- Abstraction layers "in case we need to swap implementations"

**Rule of Three**: Don't abstract until you have 3 concrete use cases.

#### 5.4 Framework Skepticism (SHOULD)

Projects SHOULD:
- Prefer libraries over frameworks (libraries are called by you; frameworks call you)
- Avoid frameworks that hide control flow or make debugging hard
- Question whether a framework is solving a problem you actually have

#### 5.5 Plain Language Test (MUST)

Every design MUST pass the Plain Language Test:
- Can you explain the architecture to a smart 10-year-old?
- Can a non-technical stakeholder understand the data flow?
- If not, simplify until you can.

### Rationale

Complexity is the enemy of maintainability, security, and velocity. Most abstractions age poorly and become technical debt. Concrete code is easier to understand, test, and modify.

---

## Article VI: Integration-First Development

### Principle

Development SHALL begin with integration tests that validate the entire feature flow, not with isolated unit tests or bottom-up component development.

### Requirements

#### 6.1 Integration-First Order (MUST)

Development MUST proceed in this order:

1. **Define API Contracts**: Specify inputs, outputs, and error cases
2. **Write Integration Tests**: Test the full feature end-to-end (tests will fail initially)
3. **Implement Components**: Build parts needed to make integration tests pass
4. **Add Unit Tests**: Test components in isolation
5. **Refine & Refactor**: Improve while keeping integration tests green

#### 6.2 API-First Design (MUST)

Before writing any implementation:
- MUST define API contracts (REST endpoints, function signatures, CLI commands)
- MUST document request/response formats with examples
- MUST specify error codes and edge case behavior

**Example API Contract**:
```yaml
POST /api/auth/login
Request:
  {
    "email": "user@example.com",
    "password": "secret123"
  }
Response (200):
  {
    "token": "jwt...",
    "expires_at": "2024-01-20T12:00:00Z"
  }
Response (401):
  {
    "error": "Invalid credentials"
  }
```

#### 6.3 Contract Testing (MUST)

All API contracts MUST have:
- Contract tests that verify the interface signature
- Example requests/responses in documentation
- Version compatibility tests (for breaking changes)

#### 6.4 Vertical Slices (SHOULD)

Features SHOULD be built as vertical slices:
- One complete user story at a time (not layers)
- Each slice goes from UI → API → Database → back to UI
- Each slice delivers user value independently

#### 6.5 No Isolated Development (MUST NOT)

Developers MUST NOT:
- Build components without integration tests
- Write unit tests without a parent integration test
- Develop "in a vacuum" without testing against real dependencies

### Rationale

Integration is where most bugs hide. Building components in isolation leads to integration hell. Starting with integration tests ensures parts work together from day one.

---

## Article VII: Observability & CLI Interface

### Principle

Every system SHALL be observable via command-line interfaces (CLIs) that expose internal state, metrics, and health. Production systems MUST be debuggable without modifying code.

### Requirements

#### 7.1 CLI Interface Mandate (MUST)

Every service/component MUST provide a CLI that supports:

| Command Category | Purpose | Examples |
|------------------|---------|----------|
| **Health** | Check system status | `myapp health`, `myapp status` |
| **Inspect** | View internal state | `myapp inspect --user-id 123` |
| **Metrics** | Show performance data | `myapp metrics --last 1h` |
| **Debug** | Troubleshoot issues | `myapp debug --trace request-id` |
| **Config** | View configuration | `myapp config show` |

#### 7.2 Health Endpoints (MUST)

All services MUST implement:
- `/health` or `health` command: Returns system health status
- `/ready` or `ready` command: Returns readiness for traffic
- Exit codes: 0 for healthy, non-zero for unhealthy

**Example**:
```bash
$ myapp health
Status: Healthy
Database: Connected (5ms latency)
Cache: Connected (2ms latency)
External API: Degraded (500ms latency)
```

#### 7.3 Structured Logging (MUST)

All logs MUST be:
- Structured (JSON or key-value pairs, not free text)
- Include request ID for tracing
- Include severity level (DEBUG, INFO, WARN, ERROR)
- Include timestamp in ISO 8601 format

**Example**:
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "ERROR",
  "request_id": "req-12345",
  "service": "auth-api",
  "message": "Login failed",
  "user_email": "user@example.com",
  "error": "Invalid password"
}
```

#### 7.4 Metrics Exposure (SHOULD)

Services SHOULD expose:
- Request count (by endpoint, status code)
- Latency percentiles (p50, p95, p99)
- Error rates
- Resource usage (CPU, memory, connections)

#### 7.5 Debugging Without Code Changes (MUST)

Production issues MUST be debuggable using only CLI commands and logs:
- No requirement to add print statements
- No requirement to redeploy with debug flags
- No requirement to attach debuggers

### Rationale

Observability is a constitutional requirement because production debugging is inevitable. CLIs provide human- and automation-friendly interfaces. Structured logs enable automated analysis.

---

## Article VIII: Security & Constitutional Review

### Principle

Security SHALL be a constitutional requirement, not a best practice. All code MUST pass security review before production deployment.

### Requirements

#### 8.1 Security Review Mandate (MUST)

Before production deployment, code MUST pass:

1. **Automated Security Scanning**:
   - SAST (static analysis): CodeQL, Semgrep, etc.
   - Dependency scanning: Check for vulnerable libraries
   - Secret scanning: Ensure no hardcoded credentials

2. **Manual Security Review**:
   - Challenger reviews security assumptions
   - Check authentication/authorization at every boundary
   - Verify input validation and sanitization

#### 8.2 Security Checklist (MUST)

Every plan MUST include a Security Considerations section addressing:

- [ ] **Authentication**: How is user identity verified?
- [ ] **Authorization**: How are permissions checked?
- [ ] **Input Validation**: How are inputs sanitized?
- [ ] **Secrets Management**: How are credentials stored/accessed?
- [ ] **Encryption**: Is data encrypted in transit and at rest?
- [ ] **Audit Logging**: Are security events logged?
- [ ] **Error Handling**: Do errors leak sensitive information?

#### 8.3 No Hardcoded Secrets (MUST NOT)

Code MUST NOT contain:
- Passwords, API keys, or tokens
- Connection strings with credentials
- Cryptographic keys

Secrets MUST be:
- Stored in environment variables or secret managers
- Rotated regularly
- Never committed to version control

#### 8.4 Dependency Management (MUST)

Projects MUST:
- Pin dependency versions explicitly
- Monitor for security advisories
- Update vulnerable dependencies within 7 days of disclosure

#### 8.5 Least Privilege (MUST)

All components MUST:
- Run with minimum required permissions
- Use read-only access when possible
- Fail securely (deny by default)

### Rationale

Security vulnerabilities are defects, not "nice to have" fixes. Constitutional security requirements prevent vulnerabilities from reaching production.

---

## Article IX: Documentation Sync

### Principle

Documentation SHALL be synchronized with code, not aspirational. Outdated documentation is worse than no documentation.

### Requirements

#### 9.1 Documentation Timeliness (MUST)

Documentation MUST be updated:
- Within 24 hours of code changes
- In the same pull request as code changes
- Before marking work as "complete"

#### 9.2 Living Documentation (MUST)

All documentation MUST include:
- `Last Updated` timestamp
- `Last Synced With Code` timestamp
- Version or commit hash it reflects

**Example**:
```markdown
---
last_updated: 2024-01-15
synced_with_commit: abc123
status: Current
---
```

#### 9.3 Documentation Types (MUST)

Projects MUST maintain:

| Document Type | Purpose | Update Trigger |
|---------------|---------|----------------|
| **README** | Project overview, setup | Major changes |
| **API Docs** | API reference, examples | API changes |
| **Architecture Docs** | System design, data flow | Design changes |
| **Runbooks** | Operations, troubleshooting | Process changes |

#### 9.4 Code Comments (SHOULD)

Code comments SHOULD:
- Explain *why*, not *what* (code shows what)
- Be removed if they become outdated
- Link to specifications for context

**Example (GOOD)**:
```python
# SPEC-100: Use bcrypt because MD5 is vulnerable to rainbow tables
password_hash = bcrypt.hash(password)
```

**Example (BAD)**:
```python
# Hash the password (redundant - code already says this)
password_hash = bcrypt.hash(password)
```

#### 9.5 Documentation Validation (SHOULD)

Projects SHOULD:
- Run link checkers to verify traceability links
- Use linters to check documentation syntax
- Include documentation builds in CI/CD

### Rationale

Outdated documentation misleads developers and wastes time. Documentation sync is a constitutional requirement because accurate docs are essential for maintainability.

---

## Governance

### Amendment Process

This constitution MAY be amended by:

1. **Proposal**: Any team member may propose an amendment
2. **Comment Period**: 1-week minimum for team feedback
3. **Vote**: Requires [2/3 majority / unanimous consent / authority approval]
4. **Effective Date**: Amendments take effect after [1 week / next sprint / immediate]

**Amendment History**:
| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0.0 | YYYY-MM-DD | Initial constitution | [Name] |

### Enforcement

**Compliance Reviews**:
- All specifications MUST reference constitutional articles they satisfy
- Pull requests MUST pass constitutional compliance checks
- Quarterly audits review adherence to constitutional principles

**Violation Handling**:
- Minor violations: Corrected in code review
- Major violations: Work rejected, requires redesign
- Repeated violations: Escalated to constitutional authority

### Exception Process

To request an exception to constitutional requirements:

1. **Submit written request** to constitutional authority
2. **Justify why exception is necessary** (not just convenient)
3. **Document risks** of granting exception
4. **Define remediation plan** (how will you restore compliance?)
5. **Get approval** from authority

All exceptions MUST be documented and time-limited.

### Constitutional Authority

**Primary Authority**: [Engineering Lead + Tech Lead]

**Responsibilities**:
- Interpret constitutional requirements
- Approve exceptions and amendments
- Enforce compliance
- Resolve disputes

**Term**: [Duration or "Until successor appointed"]
# SWAIF Constitution Template

> Template owner: Governance Council / Principal Architecture.
> Expected inputs: organizational mission, regulatory context, risk appetite, and delivery model.

## Preamble

We establish this constitution to ensure all software initiatives remain safe, valuable, auditable, and operationally sustainable. This document defines binding principles, decision rights, and enforcement pathways for delivery teams.

---

## Article I — Purpose and Scope

- Define the mission and boundaries of the system.
- Identify in-scope products, platforms, and stakeholder groups.
- Clarify exclusions and non-goals.

## Article II — Values and Design Principles

- Enumerate primary values (e.g., safety, transparency, reliability).
- Provide precedence rules when values conflict.
- Define principle interpretation guidance.

## Article III — Roles and Decision Rights

- Define accountable roles (e.g., Product Owner, Tech Lead, Security Lead).
- Map decision authorities by domain.
- Specify escalation routes for disputed decisions.

## Article IV — Delivery Lifecycle and Stage Gates

- Define required lifecycle stages.
- Specify mandatory entry/exit criteria per stage.
- Include evidence requirements for gate approval.

## Article V — Quality, Reliability, and NFR Baselines

- State baseline quality metrics and reliability targets.
- Define minimum testing obligations.
- Define availability, performance, and recoverability baselines.

## Article VI — Security, Privacy, and Compliance

- Define security baseline requirements.
- Define privacy/data-handling obligations.
- Identify compliance frameworks and audit expectations.

## Article VII — Risk and Exception Management

- Define risk scoring and treatment expectations.
- Define exception process (who can approve, duration, and compensating controls).
- Define revalidation cadence for accepted risks.

## Article VIII — Observability and Operational Readiness

- Define logging, metrics, tracing, and alerting minimums.
- Define incident management obligations.
- Define operational readiness checklist requirements.

## Article IX — Change Management and Accountability

- Define change proposal process.
- Define review quorum and approval thresholds.
- Define accountability for violations and remediation timelines.

---

## Governance Model

### Governing Bodies
- **Constitution Council**: owns this document and major amendments.
- **Architecture Review Board**: validates technical alignment.
- **Risk & Compliance Committee**: validates risk posture and compliance adherence.

### Decision Cadence
- Regular governance review cadence: `[e.g., monthly]`
- Emergency decision process: `[document trigger + approvers + communication path]`

### Enforcement
- Required evidence artifacts: `[links to templates, reports, and logs]`
- Non-compliance handling: `[action plan, waiver, or rollout stop]`

---

## Version History

### Version 1.0.0 (YYYY-MM-DD)
- Initial constitution
- Established 9 foundational articles
- Defined governance and amendment process

---

## Ratification

This constitution is hereby ratified and adopted as the governing framework for [Project/Organization Name].

**Signatures**:

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Engineering Lead | [Name] | __________ | ______ |
| Tech Lead | [Name] | __________ | ______ |
| Product Owner | [Name] | __________ | ______ |
| [Other Stakeholder] | [Name] | __________ | ______ |

---

## Appendix: Quick Reference

### Constitutional Compliance Checklist

Use this checklist when creating specifications, plans, and tasks:

- [ ] **Article I**: Traceability links present (SPEC → PLAN → TASK → Code)
- [ ] **Article II**: Stage gates satisfied (Phase -1 gates for plans)
- [ ] **Article III**: Tests written before code
- [ ] **Article IV**: Challenger review completed
- [ ] **Article V**: Simplicity verified, abstractions justified
- [ ] **Article VI**: Integration tests defined first
- [ ] **Article VII**: CLI interface and health endpoints planned
- [ ] **Article VIII**: Security checklist completed
- [ ] **Article IX**: Documentation updated with code

### Enforcement Levels

| Keyword | Meaning | Violation Severity |
|---------|---------|-------------------|
| **MUST** | Mandatory requirement | High - work blocked |
| **MUST NOT** | Prohibited action | High - work blocked |
| **SHOULD** | Strongly recommended | Medium - requires justification |
| **MAY** | Optional, discretionary | Low - advisory only |

### Common Questions

**Q: Can I skip tests for a quick prototype?**  
A: Yes, if marked as experimental and non-production. Must follow Article III before production.

**Q: What if the Challenger is blocking my work unfairly?**  
A: Escalate to constitutional authority for interpretation.

**Q: Can AI agents enforce constitutional compliance?**  
A: Yes! Use Challenger mode prompts and automated validators.

---

**End of Constitution**

This constitution is a living document. Propose improvements via [your process].
| Version | Date | Author | Summary of Changes | Approved By |
|---|---|---|---|---|
| 0.1.0 | YYYY-MM-DD | `[name]` | Initial draft | `[governing body]` |
| 0.1.1 | YYYY-MM-DD | `[name]` | `[minor update]` | `[governing body]` |
| 1.0.0 | YYYY-MM-DD | `[name]` | Ratified baseline constitution | `[governing body]` |
