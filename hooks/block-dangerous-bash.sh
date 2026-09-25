#!/usr/bin/env bash
# PreToolUse hook for the Bash tool.
#
# Blocks a small set of clearly-destructive commands by exiting 2 with an
# explanation on stderr. Everything else passes through.
#
# The matching runs on shlex tokens, not on a regex over the raw string. The
# regex version this replaces had five holes that a live test found:
#
#   rm -rf ~/            passed — the target pattern required ~ to END the word
#   rm -rf "$HOME"       passed — quotes were not stripped
#   rm -rf -- /          passed — "--" did not match the flag pattern
#   git commit -n        passed — only the long --no-verify was checked
#   grep 'DROP DATABASE' BLOCKED — the SQL rule matched inside a search string
#
# On any internal error this exits 0. A safety hook that fails closed would
# block every shell call the moment it breaks, which is worse than the risk it
# guards against.

set -uo pipefail

input=$(cat)
[ -n "$input" ] || exit 0

python_bin=$(command -v python3 || command -v python || true)
[ -n "$python_bin" ] || exit 0

# shellcheck disable=SC2016  # the single quotes are the point: this is a Python
# program, and nothing in it may be expanded by the shell before python sees it.
verdict=$(printf '%s' "$input" | "$python_bin" -c '
import json, re, shlex, sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

command = (data.get("tool_input") or {}).get("command") or ""
if not command.strip():
    sys.exit(0)

# One shell line can hold several commands. Judge each on its own so that a
# harmless prefix cannot smuggle a destructive tail past the rules.
SPLIT = re.compile(r"\|\||&&|;|\||\n")

# Targets that must never be handed to a recursive delete. Everything else --
# ./build, /tmp/scratch, node_modules -- is ordinary work and stays allowed.
HOME_ROOT = re.compile(r"^(/Users|/home)/[^/]+/?$")
def is_catastrophic(target):
    t = target.strip().rstrip("*").rstrip("/")
    if t in ("", "/", "~", "$HOME", "${HOME}"):
        return True
    return bool(HOME_ROOT.match(target.strip().rstrip("*")))

def rm_targets(tokens):
    """Arguments of rm that are not flags, with -- handled."""
    args, seen_ddash = [], False
    for tok in tokens[1:]:
        if seen_ddash:
            args.append(tok)
        elif tok == "--":
            seen_ddash = True
        elif tok.startswith("-"):
            continue
        else:
            args.append(tok)
    return args

def rm_is_recursive(tokens):
    for tok in tokens[1:]:
        if tok == "--":
            break
        if tok.startswith("--"):
            if tok in ("--recursive", "--force"):
                return True
        elif tok.startswith("-") and ("r" in tok or "R" in tok):
            return True
    return False

# SQL is only destructive when something actually executes it. The same words
# inside a grep pattern or an echo are not a threat, and blocking them makes the
# hook untrustworthy -- which is how people end up disabling it.
SQL_CLIENTS = {"psql", "mysql", "mariadb", "clickhouse", "clickhouse-client",
               "sqlite3", "mongo", "mongosh", "cockroach", "usql"}
SQL_DESTRUCTIVE = re.compile(r"\b(drop\s+database|drop\s+table|truncate\s+table)\b", re.I)

def verdict_for(segment):
    stripped = segment.strip()
    if not stripped:
        return None
    try:
        tokens = shlex.split(stripped)
    except ValueError:
        tokens = stripped.split()
    if not tokens:
        return None

    # Skip an env-var prefix (FOO=bar cmd ...) and sudo, so `sudo rm -rf /`
    # is judged as `rm -rf /`.
    i = 0
    while i < len(tokens) and ("=" in tokens[i] and not tokens[i].startswith("-")):
        i += 1
    if i < len(tokens) and tokens[i] in ("sudo", "doas"):
        i += 1
        while i < len(tokens) and tokens[i].startswith("-"):
            i += 1
    tokens = tokens[i:]
    if not tokens:
        return None

    head = tokens[0].rsplit("/", 1)[-1]

    if head == "rm" and rm_is_recursive(tokens):
        for target in rm_targets(tokens):
            if is_catastrophic(target):
                return "rm -r targeting %s" % target

    if head == "git" and len(tokens) > 1:
        sub = tokens[1]
        flags = tokens[2:]
        if sub == "push":
            forced = any(f in ("--force", "-f") for f in flags)
            lease = any(f.startswith("--force-with-lease") for f in flags)
            if forced and not lease and any(re.search(r"\b(main|master)\b", f) for f in flags):
                return ("git push --force to main/master "
                        "(use --force-with-lease, or push a feature branch)")
        if sub in ("commit", "merge", "rebase", "tag", "push"):
            # -n means --no-verify for commit, but --dry-run for push. Only the
            # first is a bypass.
            if "--no-verify" in flags or (sub == "commit" and "-n" in flags):
                return "git %s --no-verify (bypasses hooks; fix the failure instead)" % sub
        if sub == "reset" and "--hard" in flags:
            if any(f.startswith("origin/") for f in flags):
                return "git reset --hard origin/* (discards local history)"

    if head == "chmod":
        if any(f in ("-R", "--recursive") for f in tokens[1:]) and "777" in tokens[1:]:
            return "chmod -R 777 (world-writable)"

    if head in SQL_CLIENTS or head == "docker" and "exec" in tokens[:3]:
        if SQL_DESTRUCTIVE.search(stripped):
            return "destructive SQL through %s (irreversible -- confirm explicitly)" % head

    return None

for segment in SPLIT.split(command):
    reason = verdict_for(segment)
    if reason:
        print(reason)
        sys.exit(2)
sys.exit(0)
' 2>/dev/null)
status=$?

if [ "$status" -eq 2 ] && [ -n "$verdict" ]; then
    printf 'BLOCKED by the craft plugin (hooks/block-dangerous-bash.sh): %s\n' "$verdict" >&2
    printf 'If this is genuinely required, ask the user to confirm and run it themselves.\n' >&2
    exit 2
fi

exit 0
