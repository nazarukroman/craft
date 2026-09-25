---
description: Review, translate to English, and optimize a project CLAUDE.md by best practices
---

# /review-claudemd

Review the project-level CLAUDE.md for quality, accuracy, and adherence to Claude Code best practices. Optionally translate it to English. The user runs this when setting up a new project or when an existing CLAUDE.md feels stale.

## Inputs

The command accepts an optional argument:
- No argument → review the CLAUDE.md in the current project root (`.claude/CLAUDE.md` first, then `CLAUDE.md`)
- A path → review the CLAUDE.md at that path

## Step 1 — Read

Read in parallel:
- The target CLAUDE.md
- `~/.claude/CLAUDE.md` (global — to detect duplicates)
- The project's `.claude/settings.json` if it exists
- A quick scan of the project structure: `ls` the root, check for `package.json`, `tsconfig.json`, key directories to understand what the project actually is

## Step 2 — Audit

Evaluate the CLAUDE.md against these criteria, in order of importance:

### 2.1 Accuracy
- **Stale references**: file paths, commands, library names, or conventions that no longer exist in the project
- **Wrong stack claims**: says "Python" but the project is all TypeScript, etc.
- **Outdated instructions**: rules that contradict how the project actually works (verify by checking the codebase)

### 2.2 Duplication with global CLAUDE.md
- Rules already stated in `~/.claude/CLAUDE.md` should NOT be repeated in the project CLAUDE.md — they already apply globally
- Mark each duplicate and note which can be safely removed

### 2.3 Redundancy with Claude Code defaults
- Claude Code already enforces: be concise, surgical edits, no unnecessary comments, match existing style, etc.
- These rules add tokens without adding behavior — flag them

### 2.4 Structure and clarity
- No vague rules ("write good code", "be careful") — every rule must be actionable and specific
- No prose paragraphs where a bullet works
- Sections should be in a logical order: Language → Stack → Architecture → Conventions → Workflow

### 2.5 Best practices for CLAUDE.md
- Rules should be **prescriptive**, not descriptive ("Use Vitest" not "We use testing")
- Rules should be **scoped** to what Claude needs to know — not project history or team org chart
- Rules should be **non-obvious** — things Claude wouldn't infer from the code itself
- Avoid rules that are just restating standard practices unless the project explicitly deviates
- Keep it under ~150 lines; beyond that, rules get ignored

## Step 3 — Report

Output a structured report:

```
## Findings

### Accuracy (N)
  stale    Line 23: references `src/api/` — directory doesn't exist (now `src/routes/`)
  wrong    Line 8: says "Python" — project is TypeScript

### Duplication with global CLAUDE.md (N)
  duplicate  "Reply in Russian" — already in ~/.claude/CLAUDE.md, remove from project
  duplicate  "No any" — already global, remove

### Redundant with Claude Code defaults (N)
  redundant  "Make surgical edits" — Claude Code already enforces this

### Structure (N)
  vague    "Write clean code" — not actionable, remove or replace with specific rule
  verbose  "Error handling" section is 20 lines of prose — compress to 3 bullets

### Best practices (N)
  missing   No language preference specified
  missing   No test runner specified
  bloated   210 lines — target under 150; cut findings above first

## Summary: N findings (M critical, K removable)
```

Then ask: "Apply changes? I'll: (1) translate to English, (2) remove duplicates and redundancies, (3) fix accuracy issues, (4) restructure. Or pick specific categories."

## Step 4 — Apply (only after user confirms)

When the user confirms:
1. Translate all content to English (if not already)
2. Apply all fixes from the report
3. Restructure sections in order: Language → Stack → Architecture → Conventions → Workflow
4. Write the updated file
5. Show a diff of what changed

Do NOT apply changes without confirmation.
