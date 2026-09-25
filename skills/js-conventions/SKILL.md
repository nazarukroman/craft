---
name: js-conventions
description: Naming, comments and TypeScript idiom for JavaScript/TypeScript. Use when writing or editing .ts, .tsx, .js, .jsx or .mjs files, or when asked about code style, `satisfies`, `enum`, or formatter precedence.
---

# JavaScript and TypeScript style

## Formatting is the formatter's job

The repository's Prettier/ESLint config decides quotes, width, semicolons and
indentation. Run its format script instead of hand-formatting, and never argue
with it in review — if the config is wrong, change the config.

## Naming

- `camelCase` for values, `UpperCamelCase` for types and classes,
  `UPPER_SNAKE_CASE` for module-level constants.
- Boolean names assert: `isOpen`, `hasAccess`, `canRetry`, `shouldRefresh`.
- Functions and handlers are verbs: `parseOrder`, `createUser`, `handleSubmit`.
- Singular for one thing, plural for a collection. `user` and `users`, never
  `userList` or `userArray` — the type already says which it is.
- Put units in the name when a bare number is ambiguous: `timeoutMs`,
  `sizeBytes`, `maxAgeSeconds`.
- `error` in a catch, not `err`. Short names (`i`, `e`, `x`) only inside a
  one-line callback; anything multiline gets a real name.
- Do not encode the mechanism: `createUser`, not `UserFactory`; `chargeCard`,
  not `PaymentStrategy`.

## Values

- `const` by default, `let` when it genuinely changes, `var` never.
- Do not mutate a parameter. Return a new value; the caller decides what to keep.
- `===` and `!==` only. The one deliberate exception is `x == null`, which tests
  for `null` and `undefined` together — if the lint forbids it, write both.
- Read a possibly-absent value with `?.` and default it with `??`. `||` also
  replaces `0`, `''` and `false`, which is a live class of bug.
- Decompose a long expression into named intermediates. A name is the cheapest
  comment there is.
- Prefer non-mutating array methods — `toSorted`, `toReversed`, `with`,
  `toSpliced` — over `sort`/`reverse`/`splice` on an array you did not create.
- `.forEach` only for a genuine side effect. If you are building a value, use
  `map`, `filter`, `flatMap` or `reduce`; if you are awaiting, use `for..of`.
- `.forEach` does not await. `await` inside it is dropped on the floor — use
  `for..of` for sequential work, `Promise.all` over `map` for parallel.

## TypeScript

`any`, type assertions and `unknown`-narrowing are covered in [[engineering]] —
that rule holds everywhere, not just here.

- `satisfies` when you want the literal type checked but not widened;
  `as const` for a literal that must stay literal. Neither is `as`.
- Prefer a union of string literals to an `enum`. TypeScript `enum` emits
  runtime code, does not exist in JS, and breaks under `erasableSyntaxOnly` and
  type-stripping runtimes.
- Type function parameters and public returns. Let inference handle locals —
  annotating them adds noise and a second place to be wrong.
- Model impossible states out of existence with a discriminated union rather
  than several independent booleans.

## Comments

- Comment *why*, never *what*. If the what is unclear, the code is wrong.
- Delete commented-out code. Git remembers it; the file should not.
- No `TODO` without a ticket key, and no author or date stamps — `git blame`
  already has both.
- Tag temporary debug output so it is greppable and cannot survive a review:
  `// DEBUG-1234` next to the log, removed with the branch.

## Performance

Do not micro-optimize on folklore. `try`/`catch` in a loop, a cached
`array.length` and monomorphic call sites cost nothing measurable on a modern
engine, and writing for them makes code worse today for a runtime that stopped
existing years ago.

Spend the budget where it moves: algorithmic complexity, allocation inside hot
loops, and work done per render or per request. Measure before you change
anything, and keep the measurement in the PR description.
