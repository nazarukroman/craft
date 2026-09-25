---
description: Read-only review of the backend layer (Node.js)
---

# /review-backend

Read-only review of the backend layer. Do not edit any file.

## Scope

Identify the backend tree from `package.json`, workspace config, and top-level directories. Typical: `server/`, `api/`, `apps/api/`, `packages/server/`, `backend/`. In a monorepo with several backends — ask which one before scanning.

Read entry point, route registration, DI/wiring first, and write a one-paragraph mental model before reviewing.

## Skills, one pass each

1. `js-conventions` — style and naming
2. `error-handling` — propagation, retry, recovery, escalation, status codes
3. `js-data-structures` — collection choice and complexity
4. `js-gof` — patterns: fit / missing / over-applied
5. `self-review` — final pass

## CLAUDE.md cross-checks

- TypeScript: `any`, `as` silencing, missing guards on external inputs (HTTP / queue / DB rows)
- Simplicity: layers without payoff, abstractions wrapping a single implementation
- Architecture: SOLID, GRASP, **provider abstraction** (`web-access` not `tavily`), vendor names leaking into public API / env vars / DB tables
- Surgical / atomic: dead handlers, dead routes, half-migrated states across modules
- Boundary validation: validate at HTTP / queue / DB ingress; trust internal code

## Backend-specific checks

- N+1 queries; missing indexes (when schema visible)
- Concurrency / race conditions: shared mutable state, missing locks, optimistic vs pessimistic decisions
- Resource leaks: unclosed streams / DB connections / timers / file descriptors
- Logging: too verbose, too sparse, missing correlation ids, secrets in logs
- Auth and permission checks at every entry that needs them — no implicit trust
- Secrets and config: never hardcoded, loaded from env at startup, fail-fast on missing required values
- Idempotency on retry-prone endpoints (queue handlers, webhooks, payment-adjacent flows)

## Skip

- Performance speculation without an observable hot path.
- What TS / ESLint already catch.

## Output

Findings grouped by severity: `critical → high → medium → low → nit`.
Each finding: `severity  path:line  short reason`.
Cap at ~25 findings.

End with 2–3 sentences on state plus the single most important theme.
Then ask which to fix and how to ship.
