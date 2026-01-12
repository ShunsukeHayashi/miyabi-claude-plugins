# Issue Analysis Skill - Test Cases

## Test Case 1: Security Vulnerability (Critical)

**Issue Title**: "Fix SQL injection vulnerability in user authentication"

**Issue Description**:
```
The user authentication endpoint is vulnerable to SQL injection attacks.
An attacker can bypass authentication by injecting SQL code in the username field.
This is a critical security issue affecting all users in production.

Steps to reproduce:
1. Go to /api/auth/login
2. Enter username: admin' OR '1'='1
3. Authentication succeeds without password

Expected behavior: SQL queries should use parameterized statements
Actual behavior: Direct string concatenation allows SQL injection

Impact: All users' accounts can be compromised
```

**Expected Labels**:
- TYPE: `🐛 type:bug`
- PRIORITY: `🔥 priority:P0-Critical`
- SEVERITY: `🚨 severity:Sev.1-Critical`
- SPECIAL: `🔐 security`
- AGENT: `🤖 agent:codegen`
- STATE: `📥 state:pending`

---

## Test Case 2: New Feature Request (Medium Priority)

**Issue Title**: "Add dark mode support to UI"

**Issue Description**:
```
Users have requested a dark mode option for the application UI.
This would improve usability during nighttime usage and reduce eye strain.

Requirements:
- Toggle switch in settings
- Persist user preference
- Apply theme across all pages
- Use CSS variables for theming

Nice-to-have:
- Auto-detect system preference
- Smooth theme transition animation

Target: Next minor release (v1.2.0)
```

**Expected Labels**:
- TYPE: `✨ type:feature`
- PRIORITY: `📊 priority:P2-Medium`
- PHASE: `🎯 phase:planning`
- AGENT: `🤖 agent:codegen`
- COMMUNITY: `👋 good-first-issue`
- STATE: `📥 state:pending`

---

## Test Case 3: Documentation Update (Low Priority)

**Issue Title**: "Update README with installation instructions"

**Issue Description**:
```
The README file is missing clear installation instructions for new users.

Tasks:
- Add prerequisites section (Rust, Node.js versions)
- Document cargo install command
- Add troubleshooting section for common issues
- Include examples of basic usage

This is a simple documentation update that would help new contributors.
```

**Expected Labels**:
- TYPE: `📚 type:docs`
- PRIORITY: `📝 priority:P3-Low`
- AGENT: None (manual)
- COMMUNITY: `👋 good-first-issue`
- STATE: `📥 state:pending`

---

## Test Case 4: Performance Issue (High Priority)

**Issue Title**: "Slow response time on /api/users endpoint"

**Issue Description**:
```
The /api/users endpoint is taking 5-10 seconds to respond with 1000+ users.
This is affecting the admin dashboard user experience.

Current performance:
- 100 users: 200ms
- 500 users: 1s
- 1000 users: 5s
- 5000 users: timeout (30s)

Expected performance: <500ms for 5000 users

Root cause analysis needed:
- Missing database indexes?
- N+1 query problem?
- Inefficient serialization?

Impact: Admin users experiencing delays
```

**Expected Labels**:
- TYPE: `🐛 type:bug`
- PRIORITY: `⚠️ priority:P1-High`
- SEVERITY: `⚠️ severity:Sev.2-High`
- SPECIAL: `📊 performance`
- AGENT: `🤖 agent:codegen`
- PHASE: `🔧 phase:development`
- STATE: `📥 state:pending`

---

## Test Case 5: Architecture Migration (High Priority)

**Issue Title**: "Migrate from monolith to microservices architecture"

**Issue Description**:
```
We need to break down the monolithic application into microservices
to improve scalability and independent deployment.

Proposed architecture:
1. User Service (authentication, profiles)
2. API Gateway (routing, rate limiting)
3. Data Service (database access)
4. Notification Service (emails, push notifications)

Migration plan:
- Phase 1: Extract User Service (2 weeks)
- Phase 2: Set up API Gateway (1 week)
- Phase 3: Extract Data Service (3 weeks)
- Phase 4: Extract Notification Service (2 weeks)

Risks:
- Service communication complexity
- Data consistency across services
- Deployment coordination
- Monitoring and debugging

Dependencies: Docker, Kubernetes, Service mesh
Budget: $50k (infrastructure costs estimated)
```

**Expected Labels**:
- TYPE: `🏗️ type:architecture`
- PRIORITY: `⚠️ priority:P1-High`
- PHASE: `🎯 phase:planning`
- SPECIAL: `💰 cost-watch`
- AGENT: `🤖 agent:coordinator`
- HIERARCHY: `🌳 hierarchy:root`
- STATE: `📥 state:pending`

---

## Test Case 6: Deployment Automation (Medium Priority)

**Issue Title**: "Automate staging environment deployment"

**Issue Description**:
```
Currently, deploying to staging requires manual steps.
We should automate this process using GitHub Actions.

Requirements:
- Trigger on merge to develop branch
- Run tests before deployment
- Build Docker image
- Deploy to staging server
- Run smoke tests
- Send Slack notification

CI/CD tools: GitHub Actions, Docker, Firebase
```

**Expected Labels**:
- TYPE: `🚀 type:deployment`
- PRIORITY: `📊 priority:P2-Medium`
- PHASE: `🚀 phase:deployment`
- AGENT: `🤖 agent:deployment`
- TRIGGER: `🤖 trigger:deploy-staging`
- STATE: `📥 state:pending`

---

## Test Case 7: Refactoring Task (Medium Priority)

**Issue Title**: "Refactor error handling to use Result<T, E>"

**Issue Description**:
```
The codebase currently uses panic! for error handling in many places.
We should refactor to use proper Result<T, E> pattern.

Files to update:
- src/parser.rs
- src/validator.rs
- src/converter.rs

Benefits:
- Better error propagation
- More testable code
- Clearer error messages
- No unexpected crashes

This is a code quality improvement with no new features.
```

**Expected Labels**:
- TYPE: `🔧 type:refactor`
- PRIORITY: `📊 priority:P2-Medium`
- AGENT: `🤖 agent:codegen`
- QUALITY: `🟡 quality:fair`
- STATE: `📥 state:pending`

---

## Test Case 8: Test Coverage Improvement (Low Priority)

**Issue Title**: "Increase test coverage to 80%"

**Issue Description**:
```
Current test coverage is 65%. We should aim for 80% minimum.

Areas needing tests:
- Authentication module (40% coverage)
- Data validation (50% coverage)
- API endpoints (70% coverage)

Test types needed:
- Unit tests for business logic
- Integration tests for API
- E2E tests for critical flows

Good first issue for new contributors familiar with testing.
```

**Expected Labels**:
- TYPE: `🧪 type:test`
- PRIORITY: `📝 priority:P3-Low`
- AGENT: `🤖 agent:codegen`
- COMMUNITY: `👋 good-first-issue`, `🙏 help-wanted`
- STATE: `📥 state:pending`

---

## Expected Output Format

For each test case, the Skill should output:

```markdown
## Issue Analysis Results

**Issue**: [Title]

### Inferred Labels

#### Required Labels
- **TYPE**: [label] - [reasoning]
- **PRIORITY**: [label] - [reasoning]
- **STATE**: [label] - [reasoning]

#### Optional Labels
- **SEVERITY**: [label] - [reasoning] (if applicable)
- **AGENT**: [label] - [reasoning] (if agent assignment needed)
- **SPECIAL**: [label] - [reasoning] (if special handling needed)
- **HIERARCHY**: [label] - [reasoning] (if part of hierarchy)
- **COMMUNITY**: [label] - [reasoning] (if suitable for community)

### Reasoning

[Explanation of why these labels were chosen based on:
- Keywords found in title/description
- Impact assessment
- Urgency evaluation
- Technical complexity
- Resource requirements]

### Escalation Recommendations

[If SEVERITY labels are applied, specify who should be notified]

### Suggested Next Steps

1. [Action 1]
2. [Action 2]
3. [Action 3]
```

---

## Success Criteria

✅ All 8 test cases analyzed correctly
✅ Required labels (TYPE, PRIORITY, STATE) always present
✅ Optional labels only when applicable
✅ Reasoning clearly explains label choices
✅ Escalation recommendations for critical issues
✅ Suggested next steps provided
✅ Output format matches specification


