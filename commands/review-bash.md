---
description: Read-only review of all Bash / shell scripts in the project
---

# /review-bash

Read-only review of every shell script and shell snippet in the project. Do not edit any file.

## Scope

Find:
- `.sh`, `.bash` files anywhere in the repo
- `scripts/`, `bin/`, `tools/` directories
- `.github/workflows/*.yml` — `run:` / `shell:` sections
- `package.json` `scripts` entries that are non-trivial (>~50 chars, multiple commands, conditionals, pipes)
- `Dockerfile` `RUN` steps that use shell features
- Git hooks under `.husky/`, `.git/hooks/`
- `~/.claude/hooks/*.sh` if the project includes them

## Skills

- `bash-scripting` — strict mode, quoting, error handling, traps, portability, ShellCheck-grade issues
- `error-handling` — exit codes, stderr usage, fail-fast vs degrade
- `self-review`

## What to check per script

- **Shebang** correct and portable: `#!/usr/bin/env bash` (not `/bin/bash` when bash features are used)
- **Strict mode**: `set -euo pipefail` and `IFS=$'\n\t'`, or a documented reason it's missing
- **Quoting**: every `$var`, every `$@`, every `"${array[@]}"` — never bare
- **Conditionals**: `[[ ]]` not `[ ]`; `(( ))` for arithmetic
- **Substitution**: `$(...)` not backticks
- **Temp files**: `mktemp` + `trap 'rm -rf "$tmp"' EXIT`, never `/tmp/foo`
- **No `eval`**, no parsing of `ls`, no unquoted `for` over command output, no `cat | command` (UUOC)
- **Errors go to stderr**; exit codes are meaningful (`0`/`1`/`2`/`>2`) and documented if non-trivial
- **Dependency check at the top**: `command -v jq curl …` before relying on them
- **Function variables** declared `local`
- **ShellCheck would pass** — or warnings are explicitly suppressed with `# shellcheck disable=SCxxxx  # reason`
- **Length**: scripts >~150 lines or with nested data structures should be Python / Node / Go instead — flag for rewrite

## Output

Findings per file (most-broken first). Each finding: `severity  file:line  rule  one-line reason`.
Severity: `critical` (silent data corruption / data loss path) → `high` (breaks under common inputs like spaces in filenames) → `medium` → `low` → `nit`.

End with: which script is in worst shape, and one rewrite-priority recommendation.
