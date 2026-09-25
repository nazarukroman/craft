---
name: engineering
description: "Baseline rules for any code change: scope discipline, verify before claiming done, TypeScript strictness, secret hygiene, and what needs the user's approval. Load before the first edit and before reporting anything finished."
---

# Engineering rules

These hold for every agent and every task. Role prompts add language, tools and
output format on top; they do not override these.

Only rules a capable model gets wrong by default belong here. "Make the smallest
change", "report failed commands", "match the surrounding style" are already how
a good agent behaves — restating them costs context and changes nothing.

## Editing

- Edit through structured file tools. Never rewrite a file with `sed`, `awk` or
  shell redirection: they corrupt encodings, mangle CRLF and silently truncate
  on a partial match, and none of it shows up in the diff you report.
- Do not add a dependency, an abstraction or a refactor the task did not ask
  for. One implementation behind an interface is indirection, not a seam.
- Keep code, types, tests and configuration consistent within the scope you
  touched. A half-migrated state is worse than either end of the migration.

## Verifying

- Reproduce before diagnosing. You may not propose a cause until you have run a
  command that fails the way the user described, and you can name that command.
- Run the narrowest relevant check — the single test, the type-check, the lint —
  not the whole suite, and not nothing.
- An unrun command is not evidence. Say "I did not run this" rather than
  implying you did.

## TypeScript

- Never reach for `any` or a type assertion to silence the compiler. Narrow
  `unknown` with an explicit type guard at the boundary where it enters.
- Under `strict`, a `catch` variable is `unknown`. Narrow it before touching a
  property — `error instanceof Error`, or a guard for the shape you expect.

## Reporting

- Findings are ordered by severity on one ladder: `critical`, `high`, `medium`,
  `low`, `nit`. Every finding carries `file:line` and a concrete failure
  scenario. A finding you cannot make fail is a suggestion, not a finding.

## Safety

- Never write a secret into a tracked file, a log, a diff or a report, and never
  echo one back to prove you found it.
- Destructive and outward-facing actions — force-push, dropping data, sending a
  message, deleting a branch — need the user to say so for that action. Approval
  for one does not carry to the next.
- Do not bypass a hook, a lint or a signature check to make something pass.
