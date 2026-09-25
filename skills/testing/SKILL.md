---
name: testing
description: "Write and review tests in JavaScript/TypeScript. Use when adding or fixing tests, reproducing a bug, choosing what to mock, or when a test suite is slow, flaky or passing while the feature is broken."
---

# Testing

A test earns its place by failing when the system breaks and staying green when
the code is merely rearranged. Everything below follows from that.

## Test behaviour, not implementation

If you rewrote the unit from scratch and kept its contract, the test must still
pass. If it breaks, it was testing the implementation.

Concretely: assert on what a caller can observe — the returned value, the HTTP
status, the text on screen — never on which internal function ran, how many
times a hook fired, or what got logged.

## What deserves a test

- **Every bug fix.** Write the failing test first, then fix. It is the only
  thing that stops the bug coming back, and the only proof you understood it.
- **Every meaningful branch** — each arm of an `if`/`switch` that changes what
  the caller sees.
- **Edge cases that have actually bitten**: empty, `null`, huge, concurrent,
  unicode, timezone, leap day.
- **Public contracts** that other modules import.
- **State machine transitions** — every legal one, and the rejection of the
  illegal ones.

Do not test third-party libraries, trivial accessors, a presentational component
with no logic, or code unreachable from the public API — delete that instead.

## Expected values come from outside the code

The most common way to write a test that can never fail:

```ts
// Useless — recomputes the expectation the same way the code does
const expected = items.reduce((sum, i) => sum + i.price, 0);
expect(total(items)).toBe(expected);

// Real — the number comes from the spec, not from the algorithm
expect(total([{ price: 10 }, { price: 5 }])).toBe(15);
```

An expectation must come from an independent source: a literal you worked out by
hand, a worked example from the spec, a golden file. If the assertion mirrors the
implementation, it agrees with the code by construction — including when both are
wrong.

## Naming

Name the behaviour, not the call.

```ts
test('rejects login when password is empty');
test('returns the cached value on a second call within TTL');
test('marks the order paid when the webhook reports succeeded');
```

If you cannot write the name without an internal function name, the test is
about implementation.

## Mocking

Mock at process boundaries; never inside your own code.

- **Mock**: third-party HTTP, payment providers, email, the clock.
- **Do not mock**: your own modules, your own database, your own pure functions.

Use **MSW** for HTTP — it intercepts at the network layer, so the code under test
runs its real client, real serialization and real error paths. Stubbing your own
`fetch` wrapper tests the stub.

For the clock use `vi.useFakeTimers()` and advance it explicitly. Never
`await sleep(100)` to "let it settle" — that is how a suite becomes flaky.

If testing something requires mocking five of your own modules, the design is
wrong, not the test. Pass dependencies in as arguments and hand it real ones.

**Never mock the unit under test.** It happens more often than it sounds.

## Two Vitest traps that break generated tests

`vi.mock` is hoisted above the imports, so its factory runs before any
module-scope `const` exists:

```ts
const server = { get: vi.fn() };
vi.mock('./server', () => ({ server }));   // ReferenceError: Cannot access 'server'

const { server } = vi.hoisted(() => ({ server: { get: vi.fn() } }));
vi.mock('./server', () => ({ server }));   // correct
```

And the mocked path must match the import specifier exactly — `@/lib/db` and
`../lib/db` are two different modules to the mock registry, and mocking one
leaves the other real.

## Components (React Testing Library)

- Query by role, then label, then text. `getByTestId` is a last resort and a
  signal that the component is not accessible.
- `userEvent` over `fireEvent`: it replays the real focus/key/input sequence and
  catches bugs `fireEvent` walks past.
- `findBy*` for async appearance, `getBy*` for present-now, `queryBy*` only to
  assert absence.
- Cover all four states of anything that fetches: loading, error, empty, success.
- Assert what the user sees, never that a hook was called.

## Backend

Prefer integration tests with a real database over unit tests with a mocked one.
A mocked DB re-implements the ORM in mock form and catches none of the migration,
SQL or index bugs that actually happen. Use a test instance with a transaction
rolled back per test, and exercise handlers over real HTTP so middleware, status
codes and serialization are in the path.

Keep unit tests for pure domain logic — those should be fast and numerous.

Most tests should be unit, fewer integration, and only the handful of flows that
would cost real money e2e. An inverted pyramid is slow and flaky, and nobody
runs it locally.

## Vitest or Jest

Vitest for anything new — ESM-native, shares the Vite config. Stay on Jest where
it is already integrated. Never both in one project.

## Do not

- Write tests afterwards to lift coverage. Coverage measures execution, not
  verification.
- `.skip` a failing test to land a PR. Fix it or delete it; skipped tests rot.
- Assert on log output — logs are not a contract.
- Reach into privates with `(obj as any).field`. If the test needs it, the API
  is wrong.
- Write one 200-line test asserting thirty things. When it fails you learn
  nothing.
- Depend on test order or shared mutable module state.
