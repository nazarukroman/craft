---
description: Analyze current changes and create commit(s)
model: haiku
---

Analyze current changes and create commit(s).

## Inspect

Run in parallel: `git status`, `git diff`, `git diff --staged`, `git log --oneline -30`. The log reveals the convention — prefix style (`feat: ...`, `PROJ-123: ...`, `type(scope): ...`, plain), language, title-only vs title+body. Replicate the structure, not the laziness.

## Group

One commit = one logical change (feature, bugfix, refactor) — never one commit per file. Split only when changes are clearly independent.

## Message

- **Title**: ≤72 chars, concise, follows the detected prefix
- **Body**: only when nuance is worth noting; bullets if multi-aspect; omit if the title is self-explanatory
- **No trailers**: no `Co-Authored-By`, `Signed-off-by`, etc.
- **Lowercase after the prefix**: `feat: add banner rotation`, `PROJ-123: добавлена ротация`

### Language — match recent commits

- **English**: imperative — "Add", "Fix", "Refactor"
- **Russian**: third-person impersonal — "Добавлен", "Исправлена", "Обновлены". Never first/second person ("Я добавил", "Добавь")

## Commit

1. Stage by explicit paths — never `git add -A` / `git add .`
2. Create commit with a HEREDOC message
3. Never `--no-verify` or skip hooks
4. `git status` after to verify

If nothing to commit, say so and stop.
