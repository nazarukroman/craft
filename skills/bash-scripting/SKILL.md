---
name: bash-scripting
description: "Write and review shell — POSIX sh and Bash. Use when editing .sh files, git or Claude hooks, Makefile recipes, Dockerfile RUN lines, CI run: blocks, package.json scripts that chain commands, or fixing ShellCheck warnings."
---

# Shell scripting

Shell punishes clever code with silent data loss. Bias every choice toward
correctness, and reach for another language early.

## Pick the shell first, then write for it

Declare it in the shebang and stay inside that dialect. Most breakage in shell
comes from writing Bash under `#!/bin/sh`, where it either fails on another
machine or, worse, does something subtly different.

- `#!/bin/sh` — POSIX only. Runs everywhere, including `dash` and BusyBox.
  Use it for installers, hooks and anything a stranger will run.
- `#!/usr/bin/env bash` — when you genuinely need arrays, `[[ ]]`, `<( )`,
  `local`, or `pipefail`. Never `#!/bin/bash`: macOS ships bash 3.2 and not
  always at that path.

**Bash-only, so never under `#!/bin/sh`:** `[[ ]]`, `(( ))`, arrays, `local`,
`declare`, `<( )`, `$'...'`, `${var^^}`, `set -o pipefail`, `mapfile`, `+=`.
Under `dash` these are syntax errors, and `set -o pipefail` kills the script on
the first line.

## Skeleton

```sh
#!/bin/sh
set -eu

die() { printf '%s\n' "$*" >&2; exit 1; }

main() {
    :
}

main "$@"
```

`set -e` exits on error, `set -u` on an unset variable. `pipefail` is Bash-only —
under POSIX check the stage you care about explicitly, or accept that a pipeline
reports only its last command.

## Quoting

**Quote every expansion.** This one rule prevents most shell bugs.

```sh
rm -rf "$dir"          # right
rm -rf $dir            # wrong: splits on whitespace, expands globs

for f in "$@"; do      # right: preserves arguments containing spaces
for f in $*; do        # wrong
```

An unquoted `$var` is a bug until you can say precisely why it is safe.

## Variables in functions

POSIX has no `local`, so every variable is global and a nested call can silently
overwrite its caller's:

```sh
link() {
    src=$1                 # clobbers any `src` up the stack
    displace "$target"     # which may assign `src` too
}
```

Under `#!/bin/sh`, either prefix function variables (`_link_src`) or run the
function body in a subshell `( ... )` when it needs no side effects. Under Bash,
declare `local` on the first line of every function.

## Errors and cleanup

```sh
# A command in a condition suspends -e for that command — use it deliberately.
if ! curl -sf "$url" -o "$file"; then
    die "download failed: $url"
fi

value="${NAME:-default}"                  # default without tripping -u
config="${1:?usage: $0 <config-file>}"    # exit with a message if unset

tmp=$(mktemp -d) || die "mktemp failed"
trap 'rm -rf "$tmp"' EXIT INT TERM HUP    # cleanup on every exit path
```

Errors go to stderr. Exit `0` success, `1` general failure, `2` misuse. Never
write to a fixed path like `/tmp/foo` — race, leftover and symlink attack.

## Loops

```sh
# Right: preserves leading whitespace and backslashes
while IFS= read -r line; do
    process "$line"
done < input.txt

# Wrong: parsing ls — breaks on spaces, newlines and globs
for f in $(ls); do
```

Globs are safe: `for f in *.txt` is fine, and yields the literal pattern when
nothing matches, so guard with `[ -e "$f" ] || continue`.

A pipeline's `while read` runs in a subshell — assignments inside it are lost
after the loop. Feed the loop with a redirect or a here-doc instead.

`printf '%s\n' "$x"`, never `echo "$x"`: `echo` mangles values starting with
`-`, and interprets escapes differently across shells.

## Avoid

- `eval` — almost always a security hole.
- Backticks — use `$( )`, which nests.
- `cat file | cmd` — use `cmd < file`.
- Hardcoded tool paths — probe with `command -v`.
- A loop that calls `grep`/`cut`/`jq` per item — one `awk` or `jq` invocation is
  orders of magnitude faster.

Check dependencies up front rather than failing halfway:

```sh
for cmd in jq curl git; do
    command -v "$cmd" >/dev/null || die "missing dependency: $cmd"
done
```

## ShellCheck

Run it on everything, and give it the dialect: `shellcheck -s sh script.sh`. It
catches quoting and unset-variable bugs the shell accepts silently. Suppress
only a specific rule, with the reason:

```sh
# shellcheck disable=SC2086  # word splitting is intended here
result=$(command $args)
```

## When not to write shell

Past ~150 lines, or as soon as you need nested data, real argument parsing or
arithmetic beyond counting — switch to Python, Node or Go. Shell is glue. A long
shell script is a program written in the worst available language for it.
