# craft

Engineering judgement for Claude Code and Codex: JS/TS conventions, data structures, design patterns, error handling, testing, Bash and React skills; specialised subagents; read-only review commands; and a best-effort hook against accidental destructive shell commands.

The hook needs `bash` and `python3` (or `python`). It is a guard against slips, not a sandbox: it inspects the top-level command only, and it lets the command through when it cannot run. Do not rely on it in place of permission prompts.

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
