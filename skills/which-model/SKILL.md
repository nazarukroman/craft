---
name: which-model
description: "Advise which Claude tier — Fable 5, Opus 5, Sonnet 5, Haiku 4.5 — fits the task at hand, by stakes, ambiguity and scope rather than habit. Use when asked which model to use, whether to switch off Opus, or before starting a task that is unusually hard or unusually routine."
---

# Which model

Four tiers, ordered by capability ceiling and cost: Haiku 4.5 < Sonnet 5 <
Opus 5 < Fable 5. Cost follows the same order — check Anthropic's current
pricing page rather than trusting a number here; prices move and this file
doesn't get re-priced.

Defaulting to Opus for everything is a habit, not a decision — most of what
lands in a coding session is squarely Sonnet-tier work, and paying Opus or
Fable rates for it buys nothing back.

## Pick by the task, not by inertia

**Haiku 4.5** — mechanical, low-stakes, well-specified. Classification,
formatting, boilerplate, a lookup with one right answer, high-volume subagent
work where the orchestrator already did the thinking. Wrong choice the moment
the task needs judgment.

**Sonnet 5** — the default. Near-Opus quality on coding and agentic work at a
fraction of the cost. Routine features, refactors, most bug fixes, most
reviews — anything a competent engineer wouldn't need to stop and think hard
about. Start here; move up only when the task earns it.

**Opus 5** — complex agentic coding, deep reasoning, long-horizon autonomous
work, architecture calls, debugging where the cause isn't obvious — anything
ambiguous or high-stakes enough that getting it right matters more than the
extra cost.

**Fable 5** — the hardest problems only: long-horizon agentic runs that would
exhaust Opus, reasoning at the edge of what any model does well, correctness
that matters more than cost or latency. Not the default upgrade from Opus —
reach for it when the task is genuinely at that edge, not when Opus "might"
struggle.

## Signals, not vibes

Ask, roughly in this order:

1. **Is there one right answer, or judgment?** One right answer → Haiku,
   unless it's also high-stakes.
2. **Would a competent engineer need to stop and think?** No → Sonnet. Yes →
   Opus or Fable.
3. **How bad is a wrong answer?** Cheap to redo (a draft, a throwaway script)
   → bias down a tier. Expensive to redo (a migration, a security decision, a
   long autonomous run) → bias up.
4. **Is the task genuinely at the frontier**, not just "hard for a first
   pass"? Only then Fable — most "hard" tasks are Opus-hard, not Fable-hard.

## Effort is the other axis — don't conflate them

Model tier sets the capability ceiling; `effortLevel` (`/effort`) sets how
much of that ceiling gets spent per request. A capable-but-idle Opus at `low`
effort can lose to Sonnet at `high` on a task that needs depth, not raw
capability. If a task feels expensive, check effort before dropping a model
tier — the cheaper fix is often lowering effort at the same tier, not
switching tiers.

## When asked "which model for this"

Give one tier, one sentence of why, tied to the signals above — not a survey
of all four. If the task is already running and clearly mismatched (Opus
grinding through mechanical work, Haiku stalling on something ambiguous), say
so and name the better tier.
