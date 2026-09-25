---
description: Audit ~/.claude config and skills for staleness, duplication, contradictions
---

# /audit-config

Run a self-audit of the user's global Claude Code configuration. The user runs this manually every few weeks to keep the config tight as their work evolves.

## What to read

Read these files in parallel:
- `~/.claude/CLAUDE.md`
- `~/.claude/settings.json`
- Every `~/.claude/skills/*/SKILL.md`
- Any `~/.claude/commands/*.md` (other than this one)

## What to look for

For each file, find:

1. **Stale rules** — guidance that no longer matches how the user actually works. Cross-check by sampling 3–5 recent sessions in `~/.claude/projects/` (most recent subdirectory by mtime).
2. **Contradictions** — two rules that pull in opposite directions, in the same file or across files.
3. **Duplication with system prompt** — instructions Claude Code already enforces by default (be concise, no comments, surgical edits, etc.). These add tokens without adding behaviour.
4. **Duplication across skills** — the same rule restated in multiple SKILL.md files.
5. **Skill descriptions that don't match the skill body** — the description controls auto-trigger; if it lies, the skill never loads.
6. **Orphan skills** — present in `~/.claude/skills/` but not referenced anywhere in `CLAUDE.md` and not auto-triggered (description too narrow / wrong).
7. **Hooks pointing at non-existent paths** — every command in `settings.json` `hooks` should resolve.
8. **Permissions / env that no longer apply.** For each env var in `settings.json`, cross-check the name against the canonical list at https://code.claude.com/docs/en/env-vars (use WebFetch). Common stale names that look right but are no-ops or renamed:
   - `DISABLE_BUG_COMMAND` → renamed to `DISABLE_FEEDBACK_COMMAND`
   - `DISABLE_NON_ESSENTIAL_MODEL_CALLS` → removed; use umbrella `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` (also subsumes `DISABLE_TELEMETRY`, `DISABLE_ERROR_REPORTING`, `DISABLE_AUTOUPDATER`, `DISABLE_FEEDBACK_COMMAND`)
   For each unrecognized env var, report `stale` and name the canonical replacement if known. For redundant pairs (granular var set alongside its umbrella), report `duplicate`.

## What NOT to do

- Do not edit any file. This is read-only audit.
- Do not list things that are fine. Only report findings.
- Do not propose adding new rules unless the user explicitly asks at the end.

## Output format

Group findings by file. For each finding: one line, severity (`stale | contradiction | duplicate | broken | orphan`), and a one-sentence reason. Example:

```
~/.claude/CLAUDE.md
  duplicate    "Be concise" — already enforced by Claude Code default prompt.
  contradiction  "Surgical changes" vs "Atomic consistency" — clarify when each applies.

~/.claude/skills/foo/SKILL.md
  stale        Mentions library X, but recent sessions use Y everywhere.
  orphan       Description "any input" doesn't match a real trigger pattern.
```

End with a single line: `Found N findings across M files.` Then ask: "Хочешь, чтобы я применил какие-то из них?"
