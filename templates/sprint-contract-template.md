# Sprint Contract Template

Used by the Lead in Phase A-5. Fill task-specific sections; keep structure as-is.

```markdown
## Sprint Contract: Task N - [Name]

### Success Criteria
- [ ] [Specific, verifiable condition from plan]
- [ ] [Tests pass: `exact test command`]

### Non-Goals
- [What this task does NOT do]
- [Boundaries with adjacent tasks]

### Reviewer Profile: static | runtime | browser

### Runtime Validation (if runtime/browser)
- `exact test command`

### Browser Validation (if browser)
- [ ] [UI flow to verify]
- [ ] [Visual state to confirm]

### Effort Score: N → Model: haiku | sonnet | opus
```

**Notes:**
- Incorporate all applicable Domain Guidelines into Success Criteria. Reviewers do not receive Guidelines separately.
- All criteria must be specific and verifiable (NG: "Code works" / OK: "GET /api/users returns 200").
- At least one Non-Goal required.
- Test commands must include file paths or filters.
