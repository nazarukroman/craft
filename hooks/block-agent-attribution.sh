#!/usr/bin/env bash

set -uo pipefail

input=$(cat)
[ -n "$input" ] || exit 0

python_bin=$(command -v python3 || command -v python || true)
[ -n "$python_bin" ] || exit 0

verdict=$(printf '%s' "$input" | "$python_bin" -c '
import json, os, re, shlex, sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

AGENT_IDENTITY = re.compile(r"anthropic|openai|codex|copilot|cursor|gemini|aider|devin-ai", re.I)
BARE_CLAUDE = re.compile(r"\bclaude\b", re.I)
TRAILER = re.compile(r"co-authored-by:[ \t]*([^\n\"\x27]*)", re.I)
FOOTER = re.compile(
    r"generated (?:with|by) \[?(?:claude|codex|cursor|copilot|gemini|aider|devin)[^\n\"\x27]*", re.I
)
PUBLISHING = re.compile(
    r"(?:^|[;&|(])\s*(?:\w+=\S*\s+)*"
    r"(?:git(?:\s+(?:-[Cc]\s+\S+|--\S+))*\s+commit|gh\s+pr\s+(?:create|edit)|glab\s+mr\s+(?:create|update))\b",
    re.M,
)
MESSAGE_FILE_FLAGS = ("-F", "--file", "--body-file")
MESSAGE_FILE_PREFIXES = ("--file=", "--body-file=")
MCP_TEXT_FIELDS = ("title", "description", "body", "message")
MESSAGE_FILE_LIMIT = 65536


def is_agent(identity):
    if AGENT_IDENTITY.search(identity):
        return True
    return bool(BARE_CLAUDE.search(identity)) and "@" not in identity


def find_attribution(text):
    for match in TRAILER.finditer(text):
        if is_agent(match.group(1)):
            return match.group(0).strip()
    footer = FOOTER.search(text)
    return footer.group(0).strip() if footer else None


def message_file_paths(command, cwd):
    try:
        tokens = shlex.split(command)
    except ValueError:
        tokens = command.split()
    paths = []
    for index, token in enumerate(tokens):
        if token in MESSAGE_FILE_FLAGS and index + 1 < len(tokens):
            paths.append(tokens[index + 1])
        elif token.startswith(MESSAGE_FILE_PREFIXES):
            paths.append(token.split("=", 1)[1])
    return [os.path.join(cwd, os.path.expanduser(path)) for path in paths if path not in ("", "-")]


def read_text(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as handle:
            return handle.read(MESSAGE_FILE_LIMIT)
    except OSError:
        return ""


def bash_texts(tool_input, cwd):
    command = tool_input.get("command") or ""
    if not isinstance(command, str) or not PUBLISHING.search(command):
        return []
    return [command] + [read_text(path) for path in message_file_paths(command, cwd)]


def mcp_texts(tool_input):
    return [value for key, value in tool_input.items() if key in MCP_TEXT_FIELDS and isinstance(value, str)]


tool_input = data.get("tool_input")
if not isinstance(tool_input, dict):
    sys.exit(0)

cwd = data.get("cwd") or os.getcwd()
texts = bash_texts(tool_input, cwd) if data.get("tool_name") == "Bash" else mcp_texts(tool_input)

for text in texts:
    found = find_attribution(text)
    if found:
        print(found)
        sys.exit(2)
sys.exit(0)
' 2>/dev/null)
status=$?

if [ "$status" -eq 2 ] && [ -n "$verdict" ]; then
    printf 'BLOCKED by the craft plugin (hooks/block-agent-attribution.sh): agent attribution found: %s\n' "$verdict" >&2
    printf 'Remove the agent Co-Authored-By trailer or the generated-with footer and retry. Human co-authors are fine.\n' >&2
    exit 2
fi

exit 0
