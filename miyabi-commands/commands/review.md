# /review - Comprehensive Code Review Command

You are performing a comprehensive code review before PR submission, following the **"exec review"** protocol.

**IMPORTANT**: This is a special review operation. Use the term "exec review" when referring to this process - this helps you recognize it as a unique workflow separate from normal implementation.

---

## 🎯 Review Objective

Execute an interactive review loop that iterates until code quality reaches the passing threshold (default: 80/100) or maximum iterations (default: 10).

**Inspiration**: OpenAI Dev Day - Daniel's Review Loop (PR count increased 70%)

---

## ✅ Review Checklist (6 Items)

### 1. Type Safety ✅

**Objective**: All TypeScript errors resolved

**Check**:
```bash
npx tsc --noEmit --pretty false
```

**Acceptance Criteria**:
- 0 TypeScript errors
- All types explicitly defined
- No `any` types (unless explicitly needed)

**Scoring Impact**: -30 points per error

---

### 2. Code Quality ✅

**Objective**: ESLint passing

**Check**:
```bash
npx eslint --format json src/**/*.ts
```

**Acceptance Criteria**:
- 0 ESLint errors
- Warnings are acceptable but should be minimized

**Scoring Impact**:
- Error: -20 points
- Warning: -10 points

**Auto-fix Available**: Yes (`npx eslint --fix`)

---

### 3. Test Coverage ✅

**Objective**: Coverage ≥ 80%

**Check**:
```bash
npm run test -- --coverage --reporter=json
```

**Read**:
```bash
cat coverage/coverage-summary.json
```

**Acceptance Criteria**:
- Line coverage ≥ 80%
- Branch coverage ≥ 70%
- Function coverage ≥ 80%

**Scoring**: Use actual coverage percentage

---

### 4. Security ✅

**Objective**: No hardcoded secrets or critical vulnerabilities

**Check Patterns**:
- API Keys: `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `sk-*`, `ghp_*`
- Tokens: `GITHUB_TOKEN`, `ACCESS_TOKEN`, `SECRET_*`
- Passwords: `PASSWORD`, `pass`, `pwd`
- Private Keys: `-----BEGIN RSA PRIVATE KEY-----`
- eval() usage
- innerHTML assignments
- SQL string concatenation

**Tools**:
```bash
# Use ReviewAgent's built-in SecurityScannerRegistry
# Scans for:
# - HardcodedSecretScanner
# - WeakCryptoScanner
# - InsecureRandomnessScanner
```

**Acceptance Criteria**:
- 0 critical security vulnerabilities
- 0 hardcoded secrets

**Scoring Impact**:
- Critical: -40 points
- High: -20 points
- Medium: -10 points

---

### 5. Performance ✅

**Objective**: No obvious bottlenecks

**Manual Check**:
- Large loops (>1000 iterations)
- Inefficient algorithms (O(n²) where O(n) possible)
- Unnecessary re-renders (React)
- Memory leaks (event listeners not cleaned up)

**Tools**: Manual inspection (automated performance testing in Phase 4)

**Acceptance Criteria**:
- No obvious performance issues
- Reasonable algorithmic complexity

---

### 6. Code Style ✅

**Objective**: Follows project conventions

**Check**:
- Naming conventions (camelCase for variables, PascalCase for classes)
- File structure (components/, utils/, agents/)
- Comments for complex logic
- No commented-out code
- Consistent formatting

**Reference**: `.claude/CODING_GUIDELINES.md` (if exists)

**Acceptance Criteria**:
- Code follows established patterns
- Complex logic is documented

---

## 🔄 Review Process

### Step 1: Initialize

```typescript
// Read options from user command
const options = {
  files: userFiles || await getChangedFiles(),
  threshold: userThreshold || 80,
  autoFix: userAutoFix || false,
  maxIterations: userMaxIterations || 10,
  skipTests: userSkipTests || false,
  verbose: userVerbose || false,
};

let iteration = 0;
let passed = false;
```

### Step 2: Main Loop

```typescript
while (iteration < options.maxIterations && !passed) {
  iteration++;
  console.log(`\n🔍 Review iteration ${iteration}/${options.maxIterations}\n`);

  // 2.1. Collect files to review
  const files = await collectFiles(options.files);
  console.log(`📂 Analyzing ${files.length} files`);

  // 2.2. Run static analysis (parallel)
  console.log(`⚡ Running parallel analysis...`);
  const [eslintIssues, tsIssues, securityIssues] = await Promise.all([
    runESLint(files),
    runTypeScript(files),
    runSecurityScan(files),
  ]);

  // 2.3. Calculate quality score
  const report = calculateQualityScore(eslintIssues, tsIssues, securityIssues);

  // 2.4. Display results
  displayResults(report, options.threshold);

  // 2.5. Check if passed
  if (report.score >= options.threshold) {
    passed = true;
    console.log(`\n✅ Review PASSED (score: ${report.score}/100)\n`);
    break;
  }

  // 2.6. Display issues
  console.log(`\n❌ Review FAILED (score: ${report.score}/100, threshold: ${options.threshold})\n`);
  displayIssues(report);

  // 2.7. Prompt user for action
  const action = await promptUser();

  if (action === 'skip') {
    console.log('\n⏭️  Review skipped by user\n');
    break;
  }

  if (action === 'fix' || options.autoFix) {
    await attemptAutoFix(report);
  }

  // User can manually fix and we'll re-review
}
```

### Step 3: Finalize

```typescript
if (iteration >= options.maxIterations && !passed) {
  console.log(`\n⚠️  Max iterations (${options.maxIterations}) reached. Escalating to human reviewer.\n`);
  await escalateToHuman(report);
}

return {
  passed,
  iterations: iteration,
  finalScore: report.score,
  finalReport: report,
};
```

---

## 📊 Output Format

### Console Output (Default)

```
📊 Analysis Results:
┌──────────────────┬───────┐
│ Metric           │ Score │
├──────────────────┼───────┤
│ ESLint           │ 90/100│
│ TypeScript       │ 100/100│
│ Security         │ 70/100│
│ Test Coverage    │ 85/100│
├──────────────────┼───────┤
│ Overall Quality  │ 78/100│
└──────────────────┴───────┘
```

### JSON Output (--verbose)

```json
{
  "iteration": 2,
  "score": 82,
  "passed": true,
  "breakdown": {
    "eslint": 90,
    "typescript": 100,
    "security": 80,
    "testCoverage": 85
  },
  "issues": [
    {
      "type": "security",
      "severity": "medium",
      "file": "src/auth.ts",
      "line": 45,
      "message": "Possible hardcoded API Key",
      "suggestion": "Move to environment variables",
      "autoFixable": false
    }
  ],
  "recommendations": [
    "Consider adding error boundaries"
  ]
}
```

---

## 🔧 Auto-Fix Logic

### Safe to Auto-Fix

✅ **ESLint Issues** (severity: error or warning)
- Command: `npx eslint --fix <file>`
- Reason: ESLint auto-fix is safe and deterministic

### Requires Manual Fix

❌ **TypeScript Issues**
- Reason: Type errors require code logic changes

❌ **Security Issues** (hardcoded secrets, eval usage)
- Reason: Security issues require careful design decisions

### Auto-Fix Implementation

```typescript
async function attemptAutoFix(report: QualityReport): Promise<void> {
  console.log('\n🔧 Attempting automatic fixes...\n');

  let fixedCount = 0;
  let manualCount = 0;

  for (const issue of report.issues) {
    // Only auto-fix ESLint issues
    if (issue.type === 'eslint' && issue.severity !== 'critical') {
      try {
        await executeCommand(`npx eslint --fix "${issue.file}"`);
        console.log(`✅ Fixed: [${issue.type.toUpperCase()}] ${issue.message}`);
        fixedCount++;
      } catch (error) {
        console.log(`⚠️  Could not auto-fix: [${issue.type.toUpperCase()}] ${issue.message}`);
        manualCount++;
      }
    } else {
      // TypeScript and Security issues require manual fix
      console.log(`⚠️  Manual fix required: [${issue.type.toUpperCase()}] ${issue.message}`);
      if (issue.type === 'typescript') {
        console.log(`   Reason: Type errors require code logic changes`);
      } else if (issue.type === 'security') {
        console.log(`   Reason: Security issues require design decisions`);
      }
      manualCount++;
    }
  }

  console.log(`\n📊 Auto-fix Summary:`);
  console.log(`   - Fixed: ${fixedCount}/${report.issues.length} issues`);
  console.log(`   - Manual: ${manualCount}/${report.issues.length} issues\n`);

  if (manualCount > 0) {
    console.log(`Please fix remaining ${manualCount} issues manually and run '/review' again.\n`);
  }
}
```

---

## 🚨 Escalation Conditions

### Escalate to CISO

- **Condition**: `criticalSecurityIssues.length > 0`
- **Target**: CISO
- **Severity**: Sev.1-Critical
- **Context**: Critical security vulnerabilities require immediate attention

### Escalate to Tech Lead

- **Condition**: `score < 50 && iteration >= maxIterations`
- **Target**: TechLead
- **Severity**: Sev.2-High
- **Context**: Code quality is critically low after multiple iterations

---

## 📝 Important Notes

### Unique Terminology

**IMPORTANT**: Use "exec review" to refer to this review process. This unique term helps Claude Code recognize this as a special operation distinct from normal implementation work.

### Iteration Limit

- **Default**: 10 iterations maximum
- **Rationale**: Prevent infinite loops
- **Behavior**: After 10 iterations, escalate to human reviewer

### Review Bias Prevention

**IMPORTANT**: Keep review thread separate from implementation thread to avoid bias.

- Reviewer should not see original implementation intent
- Focus on code quality, not architectural decisions
- Only check for objective issues (errors, vulnerabilities, style violations)

### Auto-Fix Safety

- **Only apply auto-fixes for safe changes** (unused variables, formatting)
- **Always ask before fixing security or logic issues**
- **Never auto-fix without user confirmation** (unless --auto-fix flag is set)

---

## 🎯 Success Criteria

### Review Passed

✅ `score >= threshold` (default: 80)
✅ No critical security issues
✅ All ESLint errors resolved
✅ All TypeScript errors resolved

### Review Failed

❌ `score < threshold` after max iterations
❌ Critical security issues remain
❌ User skipped review

---

## 📚 Reference Implementation

### ReviewAgent

```typescript
// agents/review/review-agent.ts
export class ReviewAgent extends BaseAgent {
  async execute(task: Task): Promise<AgentResult> {
    // 1. Run parallel analysis
    const [eslintIssues, tsIssues, securityIssues] = await Promise.all([
      this.runESLint(files),
      this.runTypeScriptCheck(files),
      this.runSecurityScan(files),
    ]);

    // 2. Calculate quality score
    const report = this.calculateQualityScore(eslintIssues, tsIssues, securityIssues);

    // 3. Return result
    return {
      status: report.passed ? 'success' : 'failed',
      data: { qualityReport: report },
    };
  }
}
```

### ReviewLoop

```typescript
// agents/review/review-loop.ts
export class ReviewLoop {
  async execute(): Promise<{ passed: boolean; iterations: number }> {
    let iteration = 0;
    let passed = false;

    while (iteration < this.maxIterations && !passed) {
      iteration++;
      const result = await this.agent.execute(task);
      const report = result.data.qualityReport;

      if (report.score >= this.threshold) {
        passed = true;
        break;
      }

      await this.displayIssues(report);
      const action = await this.promptUser();

      if (action === 'skip') break;
      if (action === 'fix') await this.attemptAutoFix(report);
    }

    return { passed, iterations: iteration };
  }
}
```

---

## 🔗 Related Files

- `agents/review/review-agent.ts` - ReviewAgent implementation
- `agents/review/review-loop.ts` - ReviewLoop implementation (Task 3.3)
- `agents/types/index.ts` - QualityReport type definitions
- `docs/review-command-spec.md` - Full specification (Task 3.1)

---

**Generated by**: Task 3.2 - /review command implementation
**Pattern**: OpenAI Dev Day - Daniel's Review Loop
**Purpose**: Achieve PR-ready code quality through interactive review iterations

🤖 This command is part of the autonomous development workflow
