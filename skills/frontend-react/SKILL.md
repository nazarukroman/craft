---
name: frontend-react
description: "Apply when building or reviewing React components, hooks, state management, forms, lists, accessibility, or any frontend UI in TypeScript/JavaScript. Use for stack-choice decisions on React projects (the team design system at work, Radix + pure CSS for own projects, pure CSS/SCSS for simple ones). Pairs with frontend-design for visual polish."
---

# frontend-react

Engineering rules for React UI work. Visual choices live in `frontend-design`; this skill is about architecture, state, accessibility, and stack discipline.

## Stack choice

- **Work projects**: the design system the team or project profile names, nothing else.
- **Own projects, mid / large, low custom**: Radix primitives + pure CSS / CSS Modules. shadcn/ui if a richer pre-built system is genuinely useful.
- **Own projects, small / custom**: pure CSS or SCSS, no UI library.
- Do not pull Tailwind, MUI, AntD, Chakra into a greenfield project unless the user explicitly asks.
- Do not mix two component libraries in the same app.

## Component architecture

- Separate **presentational** (no data, no side effects) from **container** (data, state, effects).
- Co-locate component, styles, types, tests in one folder.
- Public API of a component is its props. Avoid hidden coupling via `useContext` unless context is intentional cross-cutting state.
- One default export per file, named the same as the file.

## State

- Local state by default. Lift only when two siblings genuinely need it.
- **Derive, don't sync.** If X can be computed from Y, compute it inline. Never use `useEffect` to mirror a prop or state into another state.
- **Server state ≠ app state ≠ form state.** Server state belongs in a query library (TanStack Query, SWR), not in component state and not in Redux. Form state belongs in form-state libraries (React Hook Form) for non-trivial forms.
- Do not introduce Redux / Zustand / Jotai unless cross-cutting client state actually exists. Most apps don't need a global store.
- Forms: controlled inputs unless you have a measured reason for uncontrolled. Validate on blur or on submit, not on every keystroke.

## State machines (preferred for non-trivial state)

Model state as a finite state machine using a discriminated union — make impossible states unrepresentable. Always prefer this over multiple boolean flags.

**Bad** (impossible states are reachable):
```ts
const [isLoading, setIsLoading] = useState(false);
const [isError, setIsError] = useState(false);
const [data, setData] = useState<T | null>(null);
const [error, setError] = useState<Error | null>(null);
```

**Good** (states are mutually exclusive by construction):
```ts
type State =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };
```

**When to apply:**
- Networking flows (idle → loading → success / error → retry).
- Wizard / multi-step forms.
- Modals / dialogs with several phases (open → submitting → confirming → closed).
- Auth and payment flows.
- Any component with three or more interacting boolean flags.

**When NOT to apply:**
- A single toggle (`isOpen`) — overkill.
- Two independent booleans with no interaction.

**Tooling, by complexity:**
1. Discriminated union + `useState` — small components.
2. Discriminated union + `useReducer` with explicit transitions — most cases.
3. XState — parallel states, hierarchical states, complex side effects, visualisation needed.

**Rules:**
- Transitions are explicit. Never mutate state outside the reducer / machine.
- Each rendering path matches on `state.status`. The compiler must reject unhandled cases (use exhaustive `switch` or assertNever).
- Side effects (fetch, navigation) are triggered by entering a state, not by ad-hoc handlers spread across the component.

## useEffect rules

- Effects synchronize with **external systems** (DOM APIs, network, subscriptions, timers). They are not for transforming data and not for chaining state updates.
- If you reach for `useEffect` to "react to a prop change", it is almost always a derived value or an event handler instead.
- Dependencies must be exact. No empty `[]` to silence eslint when you actually depend on something.
- Cleanup is mandatory for subscriptions, listeners, timers, aborts.

## Lists and keys

- `key` is a stable id from data. Never the array index, unless the list is read-only and never reorders.
- Virtualize lists above ~200 visible rows.

## Memoization

- Check for the React Compiler first (`babel-plugin-react-compiler`). With it
  on, delete manual `useMemo` / `useCallback` / `React.memo`: the compiler does
  this better, and hand-memoization defeats its analysis.
- Without it: memoize only after a measured render problem. Default is none.
- Memoizing a primitive is almost always wrong.
- "It might rerender" is not a measurement. Remove it.

## React 19

- `use()` reads a promise or context during render — it replaces most manual
  loading-state plumbing behind Suspense.
- Form actions and `useActionState` own submit/pending/error for forms. Reach for
  them before writing a reducer to track a submit.
- `ref` is a normal prop on function components; `forwardRef` is no longer needed
  for new code.

## Async effects and cancellation

Cleanup must abort in-flight work, and the abort must not be rendered as a
failure — that pairs with the four-state rule below and is the most common bug
in this file's subject area.

```tsx
useEffect(() => {
  const controller = new AbortController();
  load(id, controller.signal)
    .then(setState)
    .catch((error) => {
      if (controller.signal.aborted) return;   // unmount, or id changed
      setState({ status: 'error', error });
    });
  return () => controller.abort();
}, [id]);
```

Without the `aborted` check, every unmount and every changed dependency paints an
error state the user never caused. See `error-handling` for the classification
rules behind this.

## Component states (always handle all four)

1. **Loading**
2. **Error** — with a way to retry or report
3. **Empty** — no data yet, or no matches for current filters
4. **Success** — data rendered

Skipping any of these is a bug, not a polish task. Apply this checklist on every fetching component.

## Accessibility (baseline, not optional)

- Semantic HTML first. `button`, not `div onClick`. ARIA only when semantics are insufficient.
- Every interactive element reachable by Tab and operable by keyboard (Enter / Space activates buttons; Esc closes modals).
- Visible focus rings. Never `outline: none` without a replacement.
- Form inputs have `<label htmlFor>`, not just placeholder.
- Images have `alt`. Decorative images get `alt=""`.
- Color contrast meets WCAG AA: 4.5:1 body, 3:1 large.
- Modals trap focus and restore it on close.

## Styling

- Pure CSS / CSS Modules: BEM-ish naming inside the file is fine. Design tokens (colors, spacing, radii, typography) live in one shared file, not scattered.
- SCSS only when nesting / mixins genuinely save lines. Do not adopt SCSS for a single nested rule.
- No inline styles unless the value is dynamic from runtime data. Static styling belongs in CSS.
- One styling system per project. No mixing CSS Modules with styled-components in the same codebase.

## TypeScript for components

- Props typed with `type` (not `interface`) unless extension is needed.
- Children: `React.ReactNode`, not `JSX.Element`.
- Event handlers: `React.ChangeEvent<HTMLInputElement>` etc., not `any`.
- Generic components: type parameters with meaningful names, not `T`.

## Routing

- Route concerns (params, search, redirects) live in route-level files. Presentational components do not import the router.
- Loaders / data fetching at route level when the framework supports it (React Router, Next, TanStack Router).

## Don't

- Don't wrap everything in a `<Provider>` "for flexibility".
- Don't generate generic AI-looking UI: purple gradients, the default Tailwind
  palette, three-card hero grids, a centred column of evenly-spaced cards. Pick
  a deliberate layout, a real type scale and a palette with one accent.
- Don't pull a CSS-in-JS library into a project that already uses CSS Modules.
- Don't write giant components. If a component file passes ~200 lines, extract subcomponents or hooks.

## Pair with

- `frontend-design` — visual direction and distinctive layout, when available.
- `js-conventions` — formatting and naming.
- `error-handling` — abort handling, `Error.cause`, retry classification.
- `self-review` — before declaring a feature done.
