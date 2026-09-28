# craft

Engineering judgement for Claude Code and Codex: JS/TS conventions, data structures, design patterns, error handling, testing, Bash and React skills; specialised subagents; read-only review commands; and best-effort hooks against accidental destructive shell commands and agent attribution.

## Hooks

Both hooks run in Claude Code only and need `bash` and `python3` (or `python`). They guard against slips, not a sandbox: they inspect what the agent passes to the tool, and they let the call through when they cannot run. Do not rely on them in place of permission prompts.

- `block-dangerous-bash.sh` blocks a small set of clearly destructive shell commands. It inspects the top-level command only.
- `block-agent-attribution.sh` blocks commits, pull requests and merge requests that credit a coding agent: a `Co-Authored-By` trailer naming Claude, Codex, Copilot, Cursor, Gemini, Aider or Devin, or a "Generated with …" footer. Human co-authors pass. It checks `git commit` (including a message file passed with `-F` or `--file`), `gh pr create|edit` (including `--body-file`), `glab mr create|update`, and MCP tools named `create_merge_request`, `update_merge_request`, `create_pull_request`, `update_pull_request`, `push_files` and `create_or_update_file`.

The attribution hook catches the trailer after the agent has written it. To stop Claude Code from asking for it in the first place, set `"attribution": false` in `~/.claude/settings.json` (Claude Code 2.1.281 or later; older versions skip the whole file, so there use `{"commit": "", "pr": "", "sessionUrl": false}`). A plugin cannot set this key.

## Install

Claude Code:

```sh
claude plugin marketplace add nazarukroman/craft
claude plugin install craft@nazarukroman
```

Codex:

```sh
codex plugin marketplace add nazarukroman/craft
codex plugin add craft@nazarukroman
```
