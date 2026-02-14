# Technical Plan: [Feature Name]

<!-- 
INSTRUCTIONS:
- This is a Phase -1 document (Design phase)
- Must pass all Phase -1 gates before proceeding to Phase 0 (task breakdown)
- Link to parent specification (SPEC-NNN)
- Get Challenger review before approval
- All integration tests should be defined here
-->

---

## Frontmatter

```yaml
plan_id: PLAN-NNNN                    # Same number as parent spec
title: [Feature Name - Technical Plan]
version: 1.0.0                        # Semantic version
status: Draft                         # Draft | In Review | Challenger Review | Approved
author: [Your Name]                   # Technical lead/architect
created_date: YYYY-MM-DD
last_updated: YYYY-MM-DD
parent_spec: SPEC-NNNN                # Link to parent specification
reviewers:
  - [Tech Lead Name]
  - [Senior Engineer Name]
challenger: [Challenger Name/AI]      # Who will perform adversarial review
constitutional_version: 1.0.0
```

---

## Constitutional Compliance Checklist

<!-- Article I: Traceability & Linkage -->
- [ ] **Traceability (Article I)**: Linked to parent SPEC-NNNN
- [ ] **User Story Mapping**: Each user story mapped to architecture components
- [ ] **Test Traceability**: Integration tests map to acceptance criteria

<!-- Article II: Stage Gate Discipline -->
- [ ] **Phase -1 Gates**: Simplicity, Anti-Abstraction, Integration-First (see below)
- [ ] **Stage Documentation**: Using approved `swaif-plan-template.md`

<!-- Article III: Test-First Engineering -->
- [ ] **Integration Tests First**: Integration test scenarios defined before implementation
- [ ] **Test Types**: Integration, unit, and acceptance tests planned

<!-- Article IV: Challenger Mode -->
- [ ] **Challenger Assigned**: [Name] will perform adversarial review
- [ ] **Challenger Review**: Completed with findings addressed

<!-- Article V: Simplicity & Anti-Abstraction -->
- [ ] **Simplicity Gate**: Solution explained in plain language (see Phase -1 Gates)
- [ ] **Abstraction Justification**: All abstractions justified by 3+ use cases

<!-- Article VI: Integration-First Development -->
- [ ] **API Contracts**: Defined before implementation
- [ ] **Integration Test Scenarios**: Full end-to-end flows documented

<!-- Article VII: Observability & CLI Interface -->
- [ ] **CLI Interface**: Health, inspect, metrics, debug commands planned
- [ ] **Structured Logging**: Log format and fields defined

<!-- Article VIII: Security -->
- [ ] **Security Considerations**: Authentication, authorization, input validation addressed
- [ ] **Security Review**: Plan includes security testing strategy

<!-- Article IX: Documentation Sync -->
- [ ] **Documentation Plan**: API docs, runbooks, architecture docs planned
- [ ] **Last Updated**: Timestamp included

---

## Phase -1 Gate: Simplicity

**Gate Question**: Can this solution be explained in plain language to a non-technical stakeholder?

### Plain Language Explanation

<!-- Explain the architecture as if to a smart 10-year-old or business stakeholder -->

[Write 3-5 paragraphs explaining:
- What components exist and what each does
- How data flows through the system
- How users interact with the system
- What happens when things go wrong
Use analogies, avoid jargon, draw comparisons to everyday concepts]

**Example**:
> This feature works like a library checkout system. When a user wants to log in (check out a book), 
> they present their credentials (library card) at the front desk (API gateway). The librarian (auth service) 
> checks their records (database) to confirm the card is valid. If valid, they get a temporary pass (JWT token) 
> that lets them access the reading rooms (protected resources). The pass expires after a set time for security.

### Simplicity Checklist

- [ ] No component does more than one thing
- [ ] Data flow is linear (no circular dependencies)
- [ ] Error handling is straightforward (fail fast, clear messages)
- [ ] No "clever" solutions or performance tricks (unless profiling justifies)
- [ ] Can draw the architecture on a whiteboard in 5 minutes

**Simplicity Gate Status**: ⏳ Pending / ✅ Passed / ❌ Failed

---

## Phase -1 Gate: Anti-Abstraction

**Gate Question**: Are all abstractions justified by multiple concrete use cases?

### Abstraction Inventory

List every abstraction (interface, base class, generic type, framework) and justify:

| Abstraction | Type | Justification | Use Cases (need 3+) | Escape Hatch |
|-------------|------|---------------|---------------------|--------------|
| `IAuthProvider` | Interface | Support multiple auth methods | 1. OAuth, 2. SAML, 3. LDAP | Direct implementation bypass |
| `BaseRepository<T>` | Generic class | [Justify or remove!] | 1. UserRepo, 2. OrderRepo, 3. ProductRepo | Raw SQL queries |

### Anti-Abstraction Checklist

- [ ] No abstractions exist without 3+ concrete use cases
- [ ] No frameworks used "just in case" (only if solving actual problem)
- [ ] No "future-proofing" or "we might need to swap X later"
- [ ] All abstractions have escape hatches (ways to bypass if needed)
- [ ] Codebase prefers duplication over wrong abstraction

**Examples to Avoid**:
```python
# BAD: Abstract repository pattern with no concrete use cases
class AbstractRepository:
    def save(self, entity): pass
    def find(self, id): pass

# GOOD: Concrete implementation for actual use case
def save_user(db, user):
    db.execute("INSERT INTO users ...")
```

**Anti-Abstraction Gate Status**: ⏳ Pending / ✅ Passed / ❌ Failed

---

## Phase -1 Gate: Integration-First

**Gate Question**: Does the plan start with integration tests that validate end-to-end flows?

### Integration Test Scenarios

<!-- Define complete user flows that will be tested -->

#### Integration Test 1: [User Story ID] - [Test Name]

**Traces To**: SPEC-NNNN → US-001 (User Login)

**Scenario**: Successful user login with valid credentials

**Test Steps**:
1. **Setup**: Create test user in database with email `test@example.com` and hashed password
2. **Action**: POST to `/api/auth/login` with valid credentials
3. **Assert**: Response status 200, contains JWT token, token is valid
4. **Verify**: User can access protected endpoint with token
5. **Verify**: Token expires after configured time
6. **Cleanup**: Delete test user

**Expected API Contract**:
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "SecurePass123!"
}

Response 200 OK:
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2024-01-20T12:00:00Z",
  "user": {
    "id": "123",
    "email": "test@example.com",
    "name": "Test User"
  }
}
```

**Failure Cases to Test**:
- Invalid email → 401 Unauthorized
- Invalid password → 401 Unauthorized
- Missing fields → 400 Bad Request
- Rate limit exceeded → 429 Too Many Requests

---

#### Integration Test 2: [User Story ID] - [Test Name]

**Traces To**: SPEC-NNNN → US-002

[Repeat format for each user story...]

---

### Integration-First Checklist

- [ ] Integration tests defined for 100% of user stories
- [ ] API contracts specified before implementation
- [ ] Tests cover happy path + error cases
- [ ] Tests can be written before any code exists
- [ ] Test data setup/teardown strategy defined

**Integration-First Gate Status**: ⏳ Pending / ✅ Passed / ❌ Failed

---

## Architecture Overview

### High-Level Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        WebUI[Web UI]
        MobileApp[Mobile App]
        CLI[CLI Tool]
    end
    
    subgraph "API Layer"
        Gateway[API Gateway]
        AuthAPI[Auth API]
        UserAPI[User API]
    end
    
    subgraph "Service Layer"
        AuthSvc[Auth Service]
        UserSvc[User Service]
        EmailSvc[Email Service]
    end
    
    subgraph "Data Layer"
        PrimaryDB[(PostgreSQL)]
        Cache[(Redis Cache)]
        Queue[Message Queue]
    end
    
    WebUI -->|HTTPS| Gateway
    MobileApp -->|HTTPS| Gateway
    CLI -->|HTTPS| Gateway
    
    Gateway -->|Route| AuthAPI
    Gateway -->|Route| UserAPI
    
    AuthAPI --> AuthSvc
    UserAPI --> UserSvc
    
    AuthSvc --> PrimaryDB
    AuthSvc --> Cache
    UserSvc --> PrimaryDB
    UserSvc --> Queue
    
    Queue --> EmailSvc
    EmailSvc -->|SMTP| ExternalEmail[External Email Service]
```

### Component Descriptions

| Component | Responsibility | Technology | Rationale |
|-----------|----------------|------------|-----------|
| API Gateway | Route requests, rate limiting, auth | Kong / NGINX | Industry standard, proven scalability |
| Auth Service | Authenticate users, issue tokens | Python / FastAPI | Team expertise, async support |
| Primary Database | Persist user data | PostgreSQL 15 | ACID guarantees, JSON support |
| Redis Cache | Cache tokens, rate limit counters | Redis 7 | Fast lookups, built-in expiration |

---

### Data Flow Diagram

```mermaid
sequenceDiagram
    participant User
    participant Gateway
    participant AuthAPI
    participant AuthService
    participant Database
    participant Cache
    
    User->>Gateway: POST /api/auth/login
    Gateway->>AuthAPI: Forward request
    AuthAPI->>AuthService: validate_credentials(email, password)
    AuthService->>Database: SELECT user WHERE email = ?
    Database-->>AuthService: User record
    AuthService->>AuthService: bcrypt.verify(password, hash)
    AuthService->>AuthService: generate_jwt(user_id)
    AuthService->>Cache: SET token:abc123 = user_id (TTL 30min)
    Cache-->>AuthService: OK
    AuthService-->>AuthAPI: {token, expires_at, user}
    AuthAPI-->>Gateway: 200 OK + JSON
    Gateway-->>User: Response
```

---

## Data Models

### User Model

```python
class User:
    """
    Represents a user in the system.
    Traces to: SPEC-NNNN → US-001
    """
    id: UUID                    # Primary key
    email: str                  # Unique, indexed, max 255 chars
    password_hash: str          # bcrypt hash, never exposed in API
    name: str                   # Display name, max 100 chars
    created_at: datetime        # Auto-set on creation
    updated_at: datetime        # Auto-updated on modification
    is_active: bool             # Soft delete flag
    last_login_at: datetime     # Track last successful login
    
    # Indexes:
    # - PRIMARY KEY (id)
    # - UNIQUE INDEX (email)
    # - INDEX (is_active) for filtering active users
```

**Validation Rules**:
- `email`: Must match regex `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
- `password`: Minimum 8 characters, must contain uppercase, lowercase, number
- `name`: 1-100 characters, no special chars except spaces, hyphens, apostrophes

**Database Schema**:
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMP
);

CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_email ON users(email);
```

---

### Session/Token Model

```python
class Session:
    """
    Represents an active user session (stored in Redis).
    Traces to: SPEC-NNNN → US-001
    """
    token: str                  # JWT token (stored as cache key)
    user_id: UUID               # Reference to user
    issued_at: datetime         # When token was created
    expires_at: datetime        # When token becomes invalid
    ip_address: str             # For security auditing
    user_agent: str             # Browser/client info
    
    # Redis key format: session:{token}
    # TTL: 30 minutes (auto-expire)
```

---

## API Contracts

### Authentication API

#### POST /api/auth/login

**Description**: Authenticate user and issue JWT token

**Request**:
```http
POST /api/auth/login HTTP/1.1
Host: api.example.com
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response (Success - 200 OK)**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2024-01-20T12:00:00Z",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

**Response (Invalid Credentials - 401 Unauthorized)**:
```json
{
  "error": "invalid_credentials",
  "message": "Email or password is incorrect"
}
```

**Response (Rate Limited - 429 Too Many Requests)**:
```json
{
  "error": "rate_limit_exceeded",
  "message": "Too many login attempts. Try again in 60 seconds.",
  "retry_after": 60
}
```

**Response (Validation Error - 400 Bad Request)**:
```json
{
  "error": "validation_error",
  "message": "Invalid request data",
  "fields": {
    "email": "Invalid email format",
    "password": "Password is required"
  }
}
```

**Rate Limiting**:
- 5 requests per minute per IP address
- 10 requests per hour per email address
- Implement exponential backoff on repeated failures

**Security**:
- HTTPS required (reject HTTP)
- Password must not appear in logs
- Failed login attempts logged for monitoring
- Account lockout after 5 failed attempts in 15 minutes

---

#### GET /api/auth/me

**Description**: Get current user info (requires authentication)

**Request**:
```http
GET /api/auth/me HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (200 OK)**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "John Doe",
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Response (Unauthorized - 401)**:
```json
{
  "error": "unauthorized",
  "message": "Invalid or expired token"
}
```

---

#### POST /api/auth/logout

**Description**: Invalidate current session token

**Request**:
```http
POST /api/auth/logout HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (200 OK)**:
```json
{
  "message": "Logged out successfully"
}
```

---

## Integration Test Scenarios

### Test Scenario 1: Happy Path - User Login

**Traces To**: SPEC-NNNN → US-001

**Preconditions**:
- User with email `test@example.com` exists in database
- Password is `SecurePass123!`
- No rate limiting active for test IP

**Steps**:
1. Send POST /api/auth/login with valid credentials
2. Assert response status 200
3. Assert response contains valid JWT token
4. Extract token from response
5. Send GET /api/auth/me with token in Authorization header
6. Assert response status 200
7. Assert response contains user info
8. Wait 31 minutes (past token expiration)
9. Send GET /api/auth/me with expired token
10. Assert response status 401

**Expected Results**:
- Login succeeds with token
- Token grants access to protected endpoints
- Token expires after 30 minutes
- Expired token is rejected

---

### Test Scenario 2: Error Path - Invalid Credentials

**Traces To**: SPEC-NNNN → US-001

**Preconditions**:
- User with email `test@example.com` exists

**Steps**:
1. Send POST /api/auth/login with valid email, wrong password
2. Assert response status 401
3. Assert error message is generic (doesn't reveal whether email exists)
4. Send POST /api/auth/login with non-existent email
5. Assert response status 401
6. Assert same error message as step 3 (no user enumeration)

**Expected Results**:
- Invalid credentials return 401
- Error messages don't leak information about which field is wrong

---

### Test Scenario 3: Security - Rate Limiting

**Traces To**: SPEC-NNNN → NFR-Security

**Preconditions**:
- User with email `test@example.com` exists

**Steps**:
1. Send 5 POST /api/auth/login requests with wrong password within 1 minute
2. Assert first 5 requests return 401
3. Send 6th request immediately
4. Assert response status 429 (Too Many Requests)
5. Assert response contains `retry_after` field
6. Wait for `retry_after` seconds
7. Send another request
8. Assert request is allowed (status 401 or 200)

**Expected Results**:
- Rate limiting triggers after 5 attempts
- Retry-after header guides client when to retry
- Rate limit resets after specified time

---

## Observability Plan (Article VII)

### CLI Interface

**Tool Name**: `myapp` (or project-specific name)

#### Health Command

```bash
$ myapp health

Status: Healthy
Uptime: 3 days, 4 hours, 23 minutes

Services:
  ✅ API Gateway: Healthy (2ms)
  ✅ Auth Service: Healthy (5ms)
  ✅ User Service: Healthy (4ms)
  ⚠️  Email Service: Degraded (timeout on 2/10 checks)

Dependencies:
  ✅ PostgreSQL: Connected (3ms latency)
  ✅ Redis: Connected (1ms latency)
  ❌ External Email SMTP: Connection failed (timeout)

Exit Code: 1 (degraded)
```

#### Inspect Command

```bash
$ myapp inspect --user-id 550e8400-e29b-41d4-a716-446655440000

User ID: 550e8400-e29b-41d4-a716-446655440000
Email: user@example.com
Name: John Doe
Status: Active
Created: 2024-01-01T00:00:00Z
Last Login: 2024-01-20T10:30:00Z

Active Sessions: 2
  - Token: eyJ... (expires in 15 minutes)
  - Token: abc... (expires in 28 minutes)

Recent Activity:
  - 2024-01-20 10:30:00: Login from 192.168.1.1
  - 2024-01-20 09:15:00: Password changed
  - 2024-01-19 14:20:00: Login from 192.168.1.1
```

#### Metrics Command

```bash
$ myapp metrics --service auth --last 1h

Auth Service Metrics (Last 1 hour):

Requests:
  Total: 1,234 requests
  Success: 1,100 (89.1%)
  Errors: 134 (10.9%)

Latency:
  p50: 45ms
  p95: 120ms
  p99: 350ms
  Max: 1,200ms

Error Breakdown:
  401 Unauthorized: 120 (invalid credentials)
  429 Rate Limited: 10 (too many attempts)
  500 Server Error: 4 (database timeout)

Top Endpoints:
  POST /api/auth/login: 800 requests
  GET /api/auth/me: 300 requests
  POST /api/auth/logout: 134 requests
```

#### Debug Command

```bash
$ myapp debug --trace-request req-12345

Request ID: req-12345
Timestamp: 2024-01-20T10:30:15Z
Method: POST /api/auth/login
Client IP: 192.168.1.1
User-Agent: Mozilla/5.0...

Trace:
  10:30:15.001 - Request received at API Gateway
  10:30:15.003 - Rate limit check: PASSED (2/5 attempts)
  10:30:15.005 - Routed to Auth Service
  10:30:15.010 - Database query: SELECT user WHERE email = ?
  10:30:15.015 - Password verification: FAILED
  10:30:15.016 - Response: 401 Unauthorized
  10:30:15.017 - Request completed (16ms total)

Logs:
  [ERROR] auth_service: Login failed for user@example.com (invalid password)
```

---

### Structured Logging

**Log Format**: JSON

**Required Fields**:
- `timestamp`: ISO 8601 format
- `level`: DEBUG | INFO | WARN | ERROR
- `service`: Service name
- `request_id`: Trace requests across services
- `user_id`: If applicable (for auditing)
- `message`: Human-readable message
- `context`: Additional structured data

**Example Log Entry**:
```json
{
  "timestamp": "2024-01-20T10:30:15Z",
  "level": "ERROR",
  "service": "auth-service",
  "request_id": "req-12345",
  "user_email": "user@example.com",
  "message": "Login failed: invalid password",
  "context": {
    "ip_address": "192.168.1.1",
    "user_agent": "Mozilla/5.0...",
    "attempt_number": 3
  }
}
```

---

### Metrics to Collect

| Metric Name | Type | Description | Labels |
|-------------|------|-------------|--------|
| `http_requests_total` | Counter | Total HTTP requests | method, endpoint, status |
| `http_request_duration_seconds` | Histogram | Request latency | method, endpoint |
| `auth_login_attempts_total` | Counter | Login attempts | result (success/failure) |
| `auth_active_sessions` | Gauge | Current active sessions | - |
| `database_query_duration_seconds` | Histogram | DB query time | query_type |
| `cache_hit_rate` | Gauge | Redis cache hit rate | - |

---

## Security Considerations (Article VIII)

### Authentication & Authorization

**Authentication Method**: JWT (JSON Web Tokens)
- Algorithm: HS256 (HMAC with SHA-256)
- Token Lifetime: 30 minutes
- Refresh Token: Not implemented in v1 (future enhancement)

**Authorization Model**: Role-Based Access Control (RBAC)
- Roles: `admin`, `user`, `readonly`
- Permissions checked at API gateway level
- User roles stored in database, included in JWT claims

### Input Validation

All inputs MUST be validated:

| Input | Validation Rule | Sanitization |
|-------|----------------|--------------|
| Email | RFC 5322 regex, max 255 chars | Lowercase, trim whitespace |
| Password | Min 8 chars, complexity rules | None (hashed immediately) |
| Name | 1-100 chars, allowed chars only | Trim, escape HTML entities |
| User Agent | Max 500 chars | None (logged as-is) |

**Validation Library**: Use existing validation framework (e.g., Pydantic for Python)

### Password Security

- **Hashing Algorithm**: bcrypt with cost factor 12
- **Storage**: Only hashed passwords stored, never plaintext
- **Transmission**: Only over HTTPS, never logged
- **Complexity Requirements**:
  - Minimum 8 characters
  - At least 1 uppercase letter
  - At least 1 lowercase letter
  - At least 1 number
  - At least 1 special character

### Secrets Management

| Secret | Storage Method | Rotation |
|--------|----------------|----------|
| JWT Signing Key | AWS Secrets Manager / Vault | Every 90 days |
| Database Password | Environment variable (K8s secret) | Every 180 days |
| Redis Password | Environment variable (K8s secret) | Every 180 days |
| SMTP Password | AWS Secrets Manager | As needed |

**No secrets in code or config files committed to version control!**

### Encryption

- **In Transit**: TLS 1.3 for all API communication
- **At Rest**: Database encryption enabled (PostgreSQL native encryption)
- **Backups**: Encrypted with AES-256

### Audit Logging

Log these security events:
- All login attempts (success and failure)
- Password changes
- Account lockouts
- Token generation and expiration
- Suspicious activity (rate limit violations, invalid tokens)

Audit logs stored separately from application logs, with 1-year retention.

### Security Testing Plan

- [ ] OWASP Top 10 testing during Challenger review
- [ ] Automated SAST scanning (CodeQL, Semgrep)
- [ ] Dependency vulnerability scanning (Dependabot, Snyk)
- [ ] Penetration testing before production launch
- [ ] Security review of all API endpoints

---

## Dependencies & Constraints

### Technical Dependencies

| Dependency | Version | Purpose | Risk Level |
|------------|---------|---------|------------|
| Python | 3.11+ | Runtime | Low (LTS) |
| FastAPI | 0.104+ | API framework | Low (stable) |
| PostgreSQL | 15+ | Primary database | Low (stable) |
| Redis | 7+ | Caching | Low (stable) |
| bcrypt | 4.0+ | Password hashing | Low (mature) |
| PyJWT | 2.8+ | JWT handling | Low (mature) |

### External Dependencies

- **SMTP Server**: Required for email notifications
  - Risk: If down, emails won't send (implement retry queue)
- **DNS**: Required for domain resolution
  - Risk: Low (redundant DNS servers)

### Performance Requirements

| Requirement | Target | Measurement Method |
|-------------|--------|-------------------|
| Login API Latency (p95) | < 200ms | APM tool (Datadog/New Relic) |
| Throughput | 1000 req/sec | Load testing (k6, Locust) |
| Concurrent Users | 10,000 | Load testing |
| Database Connection Pool | 50 connections | Connection pool metrics |

### Infrastructure Requirements

- **Compute**: 3 API servers (for redundancy)
- **Database**: PostgreSQL with read replicas
- **Cache**: Redis cluster (3 nodes)
- **Load Balancer**: AWS ALB or similar
- **SSL Certificate**: Valid TLS certificate for HTTPS

---

## Deployment Strategy

### Deployment Phases

1. **Phase 1: Internal Testing**
   - Deploy to staging environment
   - Run integration tests
   - Manual testing by QA team
   - Duration: 1 week

2. **Phase 2: Beta Launch**
   - Feature flag enabled for 5% of users
   - Monitor metrics and errors
   - Collect user feedback
   - Duration: 1 week

3. **Phase 3: Full Rollout**
   - Feature flag to 100%
   - Monitor for 48 hours
   - Remove feature flag code

### Rollback Plan

If critical issues detected:
1. Set feature flag to 0% (instant disable)
2. Investigate root cause
3. Deploy hotfix or revert to previous version
4. Post-mortem analysis

---

## Risk Register

| Risk ID | Risk Description | Probability | Impact | Mitigation | Owner |
|---------|------------------|-------------|--------|------------|-------|
| R-001 | Database connection pool exhaustion | Medium | High | Implement connection limits, monitoring, auto-scaling | DevOps |
| R-002 | JWT secret key compromise | Low | Critical | Store in Secrets Manager, rotate regularly, monitor for suspicious tokens | Security |
| R-003 | Redis cache failure causes service outage | Medium | Medium | Graceful degradation (fall back to database), Redis clustering | Tech Lead |
| R-004 | SMTP service unreliable | High | Low | Implement retry queue, use reliable provider (SendGrid, AWS SES) | Backend |
| R-005 | Rate limiting too strict, blocks legitimate users | Medium | Medium | Start with lenient limits, monitor false positives, adjust | Product |

---

## Challenger Review

### Challenger: [Name or "GitHub Copilot in Challenger Mode"]

**Review Date**: YYYY-MM-DD

**Instructions to Challenger**: 
Review this plan with the goal of finding flaws, not approving it. Ask:
- What breaks if [X] fails?
- How would an attacker exploit this?
- Can we simplify further?
- What are we assuming that might not be true?

### Challenger Findings

| Finding ID | Severity | Category | Description | Status | Resolution |
|------------|----------|----------|-------------|--------|------------|
| CF-001 | High | Security | No account lockout mechanism after failed logins | Open | Added: Lock account after 5 failed attempts in 15 min |
| CF-002 | Medium | Complexity | Why use Redis? Can we use database for sessions? | Open | Justified: Redis provides TTL, faster than DB |
| CF-003 | Low | Simplicity | JWT refresh token adds complexity, can we skip for v1? | Resolved | Agreed: Skip refresh tokens for v1 |
| CF-004 | High | Integration | What if database is down during login? | Open | Added: Health check fails, load balancer stops routing |
| CF-005 | Medium | Security | Password complexity rules are weak | Open | Updated: Added special character requirement |

**Challenger Sign-off**: 
- [ ] All Critical/High findings resolved
- [ ] Challenger approves plan for progression to Phase 0

---

## Approval

### Review History

| Date | Reviewer | Role | Status | Comments |
|------|----------|------|--------|----------|
| YYYY-MM-DD | [Name] | Tech Lead | Approved | LGTM after Challenger fixes |
| YYYY-MM-DD | [Name] | Security Engineer | Changes Requested | See CF-001, CF-005 |
| YYYY-MM-DD | [Name] | Challenger | Approved | All findings addressed |

### Phase -1 Gate Status

- [x] **Simplicity Gate**: Passed (plain language explanation provided)
- [x] **Anti-Abstraction Gate**: Passed (no unjustified abstractions)
- [x] **Integration-First Gate**: Passed (integration tests defined)
- [x] **Challenger Review**: Completed and approved

### Approval Signatures

**This plan is approved for progression to Phase 0 (Task Breakdown).**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| **Tech Lead** | [Name] | __________ | ______ |
| **Senior Engineer** | [Name] | __________ | ______ |
| **Challenger** | [Name] | __________ | ______ |

---

## Appendix

### Alternative Designs Considered

**Alternative 1: Session-Based Auth (Cookie)**
- Pros: More secure (HttpOnly cookies), simpler (no JWT)
- Cons: Harder to scale (stateful), requires sticky sessions
- Decision: Rejected in favor of stateless JWT for scalability

**Alternative 2: OAuth 2.0 with External Provider (Google, GitHub)**
- Pros: No password management, better UX for users
- Cons: Dependency on external service, not all users have accounts
- Decision: Deferred to v2, implement internal auth first

### Performance Benchmarks

[Link to load testing results, if available]

### References

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [PostgreSQL Performance Tuning Guide](https://wiki.postgresql.org/wiki/Performance_Optimization)

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | YYYY-MM-DD | [Name] | Initial technical plan |
| 1.1.0 | YYYY-MM-DD | [Name] | Addressed Challenger findings |

---

## Traceability

**Upstream Document**: 
- SPEC-NNNN: [Feature Name Specification]

**Downstream Documents** (created after approval):
- TASKS-NNNN: [Task Breakdown]

**Source Code** (created during implementation):
- `src/auth/` (authentication service)
- `tests/integration/test_auth_flow.py` (integration tests)

**Last Synced With Code**: [Commit hash or N/A if not yet implemented]

---

**End of Technical Plan**

<!-- 
Next Steps:
1. Address Challenger findings
2. Get approval signatures
3. Verify all Phase -1 gates passed
4. Create TASKS-NNNN using swaif-tasks-template.md
-->
# SWAIF Implementation Plan Template

> Template owner: Engineering Leadership.
> Expected inputs: approved spec, architecture constraints, team capacity, platform standards, and risk mode.

## Plan Metadata

- **Plan ID**: `PLAN-YYYY-NNN`
- **Spec reference**: `[path/uri]`
- **Owner**: `[name/role]`
- **Risk mode**: `[low|moderate|high|critical]`
- **Target window**: `[start/end]`

## Phase -1 Readiness Gates (Pre-Execution)

> All Phase -1 gates must pass before feature coding begins.

| Gate | Required Inputs | Exit Criteria | Approver |
|---|---|---|---|
| Scope Gate | Approved spec, success metrics | Scope frozen or controlled change process active | Product + Eng |
| Architecture Gate | ADRs, system/data/API designs | Design accepted and risks logged | Architecture |
| Security Gate | Threat model, data classification | Controls defined; blockers resolved | Security |
| Operability Gate | SLO draft, telemetry plan, runbook skeleton | Monitoring and response ownership assigned | SRE/Ops |
| Delivery Gate | Task breakdown, dependencies, staffing | Execution plan baselined | Delivery Lead |

## 1) Architecture Plan

- **Current state summary**: `[brief]`
- **Target architecture**: `[brief + diagram link]`
- **Key design decisions (ADRs)**:
  - `[ADR-001]`
  - `[ADR-002]`
- **Trade-offs and rationale**: `[summary]`

## 2) Data Plan

- **Data entities and ownership**: `[table or bullets]`
- **Schema changes/migrations**: `[forward/backward compatibility, rollback]`
- **Retention and deletion policy impacts**: `[requirements]`
- **Data quality controls**: `[validation checks, reconciliation]`

## 3) API and Integration Plan

- **Contract changes**: `[endpoints/events/versioning]`
- **Compatibility strategy**: `[versioning/deprecation timelines]`
- **External dependency handling**: `[SLAs, retries, circuit breaking]`
- **Test strategy for integrations**: `[contract tests, sandbox tests]`

## 4) Observability Plan

- **SLIs/SLOs**: `[definitions + targets]`
- **Metrics/logs/traces**: `[required telemetry by component]`
- **Alerts**: `[critical alerts + on-call routing]`
- **Runbooks**: `[incident runbook links]`

## 5) Security and Compliance Plan

- **Threat model summary**: `[top abuse/failure cases]`
- **Controls mapping**: `[control -> implementation]`
- **Secrets and key management**: `[approach]`
- **Compliance evidence generation**: `[automated/manual artifacts]`

## 6) Delivery and Rollout Plan

- **Milestones**: `[phase/milestone list]`
- **Rollout strategy**: `[dark launch/canary/phased/full]`
- **Rollback strategy**: `[trigger + mechanism + owner]`
- **Communication plan**: `[stakeholder updates + cadence]`

## 7) Exit Criteria and Handover

- **Definition of done**: `[criteria]`
- **Production readiness sign-off**: `[roles + checklist links]`
- **Post-launch validation window**: `[duration + success checks]`
