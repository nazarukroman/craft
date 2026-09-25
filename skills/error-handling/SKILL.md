---
name: error-handling
description: "Handle failures in TypeScript and Node: error classification, catch-variable narrowing, Error.cause, AbortSignal, propagation across layers, retry, timeouts, unhandledRejection, SIGTERM and graceful shutdown. Use when writing a catch block, an error path, or a process-level handler."
---

# Error handling

## Classify before you catch

- **Programming errors** — `TypeError`, `ReferenceError`, a failed assertion, a
  bad argument. The code is wrong. Let them crash; a retry just runs the bug
  again, and a `catch` hides the stack that would have told you where it was.
- **Operational errors** — timeout, connection refused, 404, invalid user input,
  disk full. Expected in a healthy system. Recover, escalate or report.

Every rule below follows from that split. If a `catch` cannot say which kind it
is handling, it is too broad.

## Narrowing the catch variable

Under `strict`, a `catch` variable is `unknown` — `error.code` does not compile,
and `error as Error` is a lie the compiler cannot check.

```ts
function errorCode(error: unknown): string | undefined {
  return typeof error === 'object' && error !== null && 'code' in error
    ? String((error as { code?: unknown }).code)
    : undefined;
}

try {
  return await fetchData(url);
} catch (error) {
  if (errorCode(error) === 'ECONNREFUSED') return fallback();
  throw error;
}
```

Write the guard once per shape and reuse it. `instanceof` works for your own
error classes; it does not work across realms, worker boundaries or after
serialization.

## Never lose the original error

Re-throwing without `cause` destroys the stack that identifies the real fault.

```ts
try {
  await db.insert(row);
} catch (error) {
  throw new Error(`saving order ${order.id}`, { cause: error });
}
```

`console.error` and Node's inspector print the whole `cause` chain. Do not paste
the original message into the new one instead — the stack is what you need.

## Abort is not failure

An aborted request is the caller changing its mind. Rendering it as an error is
a bug, and it is the most common one in React effects.

```ts
try {
  return await fetch(url, { signal });
} catch (error) {
  if (signal.aborted) return;           // unmounted, or superseded
  throw error;
}
```

`controller.abort()` produces `AbortError`; `AbortSignal.timeout(ms)` produces
`TimeoutError`. Comparing against `AbortError` alone silently treats a timeout
as a cancellation — check `signal.aborted`, and branch on the name only when the
two need different handling.

## Retry

Retry operational errors only. The obvious loop retries bugs too:

```ts
const TRANSIENT = new Set(['ECONNREFUSED', 'ETIMEDOUT', 'ECONNRESET', 'EAI_AGAIN']);

async function retry<T>(fn: () => Promise<T>, attempts = 3): Promise<T> {
  for (let i = 0; ; i++) {
    try {
      return await fn();
    } catch (error) {
      const code = errorCode(error);
      const transient = code !== undefined && TRANSIENT.has(code);
      if (!transient || i >= attempts - 1) throw error;
      const backoff = 2 ** i * 200;
      await sleep(backoff / 2 + Math.random() * backoff);   // jitter
    }
  }
}
```

- Retry only what you recognise as transient. The tempting inverse — "throw if
  the code is known and not transient" — lets everything *without* a code
  through, and a `TypeError` has no code: the bug gets run three times.
- Backoff is exponential, not linear: `delay * (i + 1)` is arithmetic and barely
  helps a struggling dependency.
- Jitter is not optional. Without it, every caller that failed together retries
  together, and the retry storm is worse than the original outage.
- `attempts` must run the function at least once. A loop that returns
  `undefined` for `attempts: 0` fails silently at the call site.
- Give the whole operation a deadline — `AbortSignal.timeout()` — as well as a
  per-attempt one. Three retries of a hung request is three hung requests.

## Across layers

```
domain throws a plain Error
  → service adds context with { cause }
    → API maps to a known code
      → client gets { code, message }
```

Map to codes at the boundary. Never send a stack, a SQL fragment, a file path or
an internal message to a client: it is an information leak, and it couples the
client to your internals.

## Process level

```ts
process.on('uncaughtException', (error) => {
  logger.fatal({ error }, 'uncaught');
  process.exit(1);
});
```

- `uncaughtException`: log and exit. State is unknown after it; continuing means
  serving corrupted data.
- Do **not** register an `unhandledRejection` handler that only logs. Since
  Node 15 the default is to crash, and replacing it with a log downgrades a real
  bug into a warning nobody reads. Fix the missing `await` or `.catch()`.

## Graceful shutdown

On `SIGTERM` (Kubernetes, systemd and Docker send this, not `SIGINT`):

1. Stop accepting new work — `server.close()`, unsubscribe the consumer.
2. Let in-flight requests finish, under a deadline shorter than the platform's
   kill timeout.
3. Release resources: DB pool, queue connections, file handles.
4. Exit 0. If the deadline passes, exit non-zero — a shutdown that hangs gets
   `SIGKILL` and loses everything in flight anyway.

Handle `SIGINT` too, so local `Ctrl-C` takes the same path as production.
