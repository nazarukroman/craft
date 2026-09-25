---
description: Read-only review of the frontend layer (React + TypeScript + styling)
---

# /review-frontend

Read-only review of the frontend layer. Do not edit any file.

## Scope

Identify the frontend tree from `package.json`, workspace config, and top-level directories. Typical: `src/`, `app/`, `apps/web/`, `packages/ui/`, `frontend/`. In a monorepo with several frontends — ask which one before scanning.

Read entry points and key components first and write a one-paragraph mental model before reviewing.

## Skills, one pass each (do not mix)

1. `js-conventions` — style, naming, idioms
2. `frontend-react` — components, hooks, state, state machines, useEffect, lists/keys, memoization, four required states (loading / error / empty / success), a11y, stack consistency
3. `frontend-design` — generic AI-look, design tokens, contrast, layout
4. `error-handling` — error boundaries, retry, recovery
5. `js-data-structures` — Map / Set / Array choice
6. `js-gof` — patterns that fit, patterns missing, patterns added without need
7. `self-review` — final pass

## CLAUDE.md cross-checks

- TypeScript: `any`, `as` to silence the compiler, missing type guards at external boundaries
- Simplicity: overengineering, single-use abstractions, configurability nobody asked for
- Surgical / atomic: orphan code from prior edits, half-migrated states
- Architecture: SOLID, vendor lock-in in public names

## Skip

- Anything TypeScript compiler / ESLint / Prettier already catch — assume closed if configs exist.
- Stylistic nits when pre-commit hooks exist.
- Speculative refactors "for the future".

## Output

Findings grouped by severity: `critical → high → medium → low → nit`.
Each finding: one line — `severity  path:line  short reason`.
Cap at ~25 findings, most important first.

End with 2–3 sentences on overall state and the single most important theme to fix first.
Then ask: «Что чинить и одним PR или несколькими?»
