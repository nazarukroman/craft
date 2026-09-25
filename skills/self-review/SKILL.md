---
name: self-review
description: Unbiased self-review of completed implementation. Use after finishing a feature.
allowed-tools: Read, Grep, Glob, Bash
---

You are doing a fresh, unbiased self-review of your own implementation. Forget any prior context, assumptions, or decisions — approach the code as if you're seeing it for the first time.

## Instructions

1. **Gather changes**: Run `git diff main...HEAD` (or `git diff --cached`, or `git diff` — whichever shows the relevant changes).

2. **Analyze ALL changes thoroughly**. Be critical, sober, and unbiased:

   **Completeness**:
   - Is the logic fully implemented? Nothing left as TODO, stub, or half-done?
   - Are there missing edge cases, error paths, or boundary conditions?

   **Connectivity**:
   - Is all created code actually wired up and used? No dangling classes, methods, or variables?
   - Are all imports, registrations, and dependency injections in place?
   - No orphaned files or dead code introduced?

   **Correctness**:
   - Bugs, logic errors, off-by-one mistakes, race conditions?
   - Security issues (injection, auth, data leaks)?
   - Consistency with existing codebase patterns and conventions?

   **Documentation**:
   - Is documentation affected by the changes updated and accurate?
   - Do comments, docstrings, READMEs reflect the current state?

3. **Output format**:
   - Start with a 1-2 sentence summary of what the changes do
   - List issues found, grouped by severity: `critical` → `high` → `medium` → `low` → `nit`
   - For each issue: file:line, what's wrong, and how to fix it
   - End with a verdict: LGTM / Minor issues / Needs changes
