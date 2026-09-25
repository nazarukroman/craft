---
description: Commit current changes fast with Conventional Commits, no repo-history convention lookup
model: haiku
---

Commit current changes fast. No convention detection, no history review — always Conventional Commits, always English.

## Inspect

Run in parallel: `git status`, `git diff`, `git diff --staged`. Do not read `git log` to detect a local convention — this command always writes Conventional Commits, regardless of what the rest of the repo's history looks like.

## Group

One commit = one logical change (feature, bugfix, refactor) — never one commit per file. Split only when changes are clearly independent.

## Message — Conventional Commits

Format: `<type>[optional scope]: <description>`

| type       | when                                             |
|------------|---------------------------------------------------|
| `feat`     | new capability                                    |
| `fix`      | bug fix                                           |
| `docs`     | docs only                                         |
| `style`    | formatting, no logic change                       |
| `refactor` | neither fixes a bug nor adds a feature            |
| `perf`     | performance improvement                           |
| `test`     | adding or correcting tests                        |
| `build`    | build system or dependencies                      |
| `ci`       | CI configuration                                  |
| `chore`    | everything else (tooling, config, misc)           |
| `revert`   | reverts a previous commit                         |

- **Header**: ≤72 chars, imperative mood ("add", "fix", "remove"), lowercase after the colon, no trailing period
- **Scope**: optional, parenthesized, names the affected module/area — omit if it doesn't add signal
- **Body**: only when the "why" isn't obvious from the diff; bullets for multi-aspect changes; blank line before it
- **Breaking change**: `!` after type/scope (`feat!:`) plus a `BREAKING CHANGE:` footer line, only if applicable
- **No trailers**: no `Co-Authored-By`, `Signed-off-by`, etc.
- **Always English**, regardless of the repo's dominant commit language

## Commit

1. Stage by explicit paths — never `git add -A` / `git add .`
2. Create commit with a HEREDOC message
3. Never `--no-verify` or skip hooks
4. `git status` after to verify

If nothing to commit, say so and stop.
