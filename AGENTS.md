# AGENTS.md

`craft` is a Claude Code and Codex plugin, and this repository is also its marketplace: `.claude-plugin/marketplace.json` lists the plugin with `source: "./"`. It is public.

## Layout

- `skills/*/SKILL.md` — loaded when their description matches the task. The description is paid in every session, so keep it short and never put an unquoted `#` or `:` in it.
- `agents/*.md` — every file here is registered as an agent. Do not put shared fragments in this directory.
- `commands/*.md` — slash commands.
- `hooks/` — `block-dangerous-bash.sh` runs before every Bash tool call; `block-agent-attribution.sh` runs before every Bash tool call and before MCP tools that create commits, pull requests or merge requests. Each must exit 0 on its own internal errors.
- `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json` — manifests for the two harnesses.

## Rules

- Nothing employer-specific: no company, product, host, ticket key or colleague name. Project-specific rules belong in a separate profile plugin.
- Commits carry the personal email. The GitHub leak guard installed by the owner's dotfiles checks every commit and push.

## Before pushing

```sh
claude plugin validate .
shellcheck hooks/*.sh
```
