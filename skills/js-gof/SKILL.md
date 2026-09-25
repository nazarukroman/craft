---
name: js-gof
description: Choose whether a design pattern is warranted in JavaScript/TypeScript, and which language feature replaces it. Use when reaching for a factory, builder, singleton, object pool, adapter, decorator, proxy, facade or EventEmitter, or when a review flags over-abstraction.
---

# Design patterns in JS/TS

A pattern is a workaround for something a language cannot express. JavaScript
expresses most of them directly, so the useful question is never "which pattern
is this" — it is "does this need a pattern at all, and what does the language
already give me".

Naming a pattern is not a design argument. If the only reason for an
abstraction is that it has a name, delete it.

## Decide first

Apply in order. Stop at the first that answers.

1. **Is there a second case yet?** One implementation behind an interface is
   indirection, not a seam. Two make it real. Write the concrete thing; extract
   when the second case arrives.
2. **Does the language already do this?** Most GoF patterns exist because C++
   and Java lack closures, first-class functions, modules and object literals.
   See the table below.
3. **Would deleting the abstraction remove complexity or move it?** If callers
   get simpler when it is gone, it was not carrying its weight.
4. **Can this be data instead of code?** A lookup table beats a Strategy
   hierarchy, and a discriminated union beats a State class tree.

## What the language replaces

| Pattern | Reach for this instead |
|---|---|
| Factory | a function that returns an object |
| Abstract Factory | a module that exports several such functions |
| Builder | an options object, or `Partial<T>` plus one validated constructor |
| Singleton | a module-scope value — ES modules are already single-instance |
| Prototype | `structuredClone`, or a factory taking defaults |
| Strategy | a function parameter, or `Record<Kind, Handler>` |
| State | a discriminated union plus an exhaustive `switch` |
| Template Method | a function taking the varying steps as callbacks |
| Command | a closure, or a plain `{ type, payload }` object |
| Observer | `EventTarget`, or Node's `EventEmitter` |
| Iterator | a generator, or implement `Symbol.iterator` |
| Decorator | a higher-order function wrapping the original |
| Chain of Responsibility | `Array.prototype.find`, or a middleware array |
| Memento | `structuredClone` of the state you need to restore |
| Visitor | pattern-match on a discriminated union |

## Patterns that still earn their place

These solve problems the language does not.

- **Adapter** — when a third-party shape must not leak past your boundary. The
  adapter's contract is yours, not the vendor's; a vendor rename must not reach
  callers. This is the one wrapper worth writing for a single implementation.
- **Facade** — when a subsystem has a genuinely large surface and callers need a
  small, stable slice of it.
- **Proxy** — for lazy loading, access control and instrumentation, via
  `Proxy` when the trap must be dynamic, a wrapper function when it need not be.
- **Object pool** — only for objects whose construction is measurably expensive
  (sockets, workers, parsers). Never for plain objects: the allocator is faster
  than your pool.
- **Revealing module** — a closure exposing a small public surface. Prefer a
  class only when several instances hold state.

## Rules

- Compose objects; do not build inheritance chains. Depth beyond one level is
  almost always the wrong shape.
- Never use `class` for a namespace or for a bag of static methods — that is a
  module.
- Never implement an abstract method by throwing at runtime. TypeScript has
  `abstract`, and a union of concrete types is usually better than either.
- An adapter must convert, not just forward. A `dequeue()` that calls `pop()`
  has silently turned a queue into a stack.
- When wrapping an emitter or a callback, forward every argument with rest and
  spread — dropping the tail is the classic wrapper bug.
- Keep pattern names out of identifiers. `UserFactory` and `PaymentStrategy`
  describe the mechanism; `createUser` and `chargeCard` describe the job.
- A pattern applied to make code "extensible" for a requirement nobody has is
  speculative generality. Delete it and inline the caller.
