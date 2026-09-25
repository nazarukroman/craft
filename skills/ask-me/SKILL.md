---
name: ask-me
description: "Interview before working: keep a written list of what the request could mean, kill hypotheses with questions only the user can answer, test stated rules against concrete edge cases, then hand off a self-contained brief. Use when asked for clarifying questions, for help deciding or thinking something through, for a half-formed idea, or to research a topic properly."
---

# Ask me first

Runs before the work, not instead of it. The job: turn a half-formed question
into one a specialist could answer without ever meeting the user — then hand it
to whoever should answer it.

Most of what follows comes from four measured sources, named at the end. Where a
rule rests on nothing but judgement, it says so.

## The spine: a written list of hypotheses

Not a mental note — a visible list, maintained across the whole interview, of
the distinct things this request could mean. Everything else in this skill
serves it. Five steps:

1. **Generate three to six deliberately different hypotheses** about what is
   being asked. Different, not adjacent: if two would lead to the same work,
   they are one hypothesis.
2. **Check every hypothesis against every answer already given** — all of them,
   not just the last one.
3. **Delete the ones that no longer fit**, and say which died and why. A visibly
   shrinking list is the user's evidence that answering is working.
4. **Carry the survivors forward unchanged.** Do not regenerate the list each
   round; regenerating loses the constraints you already bought.
5. **Put the newest answer at the top** whenever you restate the state of the
   interview, not at the bottom in chronological order.

This is the highest-value part of the skill, and the one most tempting to skip.
Replacing an explicit filtered list with the model's own recollection of the
conversation was measured at 88% → 18% task success — by a wide margin the worst
of every component that was ablated. The stated mechanism: models "regularly
sample hypotheses incompatible with past observations and exhibit premature
overconfidence, with both issues becoming more pronounced" as the history grows.
So the danger is not forgetting. It is confidently asking something the user
already answered, and getting worse at it the longer the interview runs.

A prompt cannot compute expected information gain, and the measured gap between
computing it and asking a model to "pick the most informative question" is large
— roughly 37 points of success rate, with reasoning-style prompting closing
about a quarter of it. Thinking harder does not substitute. Maintaining the
list is the part that does transfer.

## Rule zero — never ask what you can find

Before the first question, go get everything that does not live in the user's
head: the repo, whatever the request names (a ticket, a doc, a URL, a metric),
this conversation, any memory already recalled. In parallel, without narrating
it. A question is a paid action, and one that spends the user's attention on
something you could have read is the worst possible trade.

## Ask only when the question beats the answer

The gate is not "is this ambiguous". Ambiguity is always present, and a detector
built on it degenerates into asking every time — measured as indistinguishable
from a policy of always asking. The gate is a comparison:

> Is the best question I have right now worth more than the best answer I could
> give right now?

Asking is genuinely risky. A policy of asking exactly one clarifying question
was measured as *worse* than never asking, on every metric, against a user with
no patience for a bad one. The binding constraint is question quality, not
question count.

Each candidate question must also pass both of these:

- **Only the user can answer it.** Not the repo, not the web, not you.
- **Two different answers lead to two different pieces of work.** If not, take
  the sensible default, record it as an assumption, and move on.

And generate the questions for *this* request. Selecting from a stock list of
clarifying questions — by any strategy, including cleverly — was measured as no
better than picking at random. The generic intake form is not a lazy version of
a good interview; it is a measurably different and worse thing.

## How to ask

Use `AskUserQuestion`. Its limits are hard — break one and the call fails:
**1–4 questions per call, 2–4 options each, `header` at most 12 characters.**
"Other" is added automatically; never write your own.

- **Keep each question bite-sized** — one decision, answerable without composing
  an essay. This constraint is per question, not per turn.
- **Three or four options.** Two is not a middle ground: two-option panels
  measured worse than three, while three through five behaved about the same.
- **Ask a question, not a menu.** Putting a real question above the options,
  rather than a neutral label over the same options, was worth 48% more
  engagement across 2.5M users per arm. The framing itself does the work.
- **Each option states its cost**, not just its label — what you get and what
  you pay.
- **Recommended option first**, with `(Recommended)` in the label. Judgement,
  not evidence.
- **No jargon without explanation**, and no redundancy with anything already
  asked. Neither emerges on its own — the one human-validated interview prompt
  in the literature had to demand both explicitly.
- A plain yes/no question is not a downgrade. It was the only question form that
  improved on user-written specifications in every setting studied.
- Ask in the user's language, whatever the language of this file.

Before sending, check specificity separately from quality. A question that would
make equal sense pasted into someone else's project is a generic question, and
generic questions reliably *feel* fine — which is exactly why they survive
review. Rewrite until each one could only have been asked about this request.

## When the user says "I don't know"

This is the case the skill exists for. Never re-ask the same question louder.

- **It was a preference.** Take the recommended option, record it as an
  assumption, move on. One line.
- **It was a fact.** Then it was never the user's job. Go find it, come back
  with the answer, and re-ask only if a decision still stands on top of it.
- **They don't know what they want.** Stop asking about the goal and switch to
  concrete cases — see below. Asking someone to articulate a preference they
  have not formed is the one move guaranteed to fail.

## Test the stated rule against edge cases

When the user does state a rule, a constraint or a preference, do not take it at
face value and do not ask them to restate it more precisely. Generate three to
five concrete boundary cases and ask them to judge each one.

This is not a politeness check. Stated preferences were measured diverging from
the same person's own later decisions — one participant wrote that an address
must end in `.com` or `.co.uk`, then accepted `user@domain.edu`. In that domain,
a user-written specification performed slightly *worse* than no specification at
all, and generating edge cases for the user to label was the only method that
significantly beat asking nothing.

So: what the user decides about a specific case outranks what they declared in
general. The brief carries the decided cases, not the declared rule.

## When to stop

No counters. Every published number for "how many clarifying questions" failed
verification, and a fixed budget is the wrong shape anyway — it forces a bad
question when you have run out of good ones. Two stopping rules:

- **The best remaining question no longer beats answering now.**
- **The hypothesis list has stopped shrinking.** Two rounds that kill nothing
  mean the remaining ambiguity is not the kind questions resolve.

Guards on top:

- Any sign of impatience — "just do it", a one-word answer, a rewritten prompt —
  ends the interview immediately. Collapse to explicit assumptions, say which
  are load-bearing, go.
- Never let the interview cost more than the work it precedes. For scale only:
  the one study run on live humans gave its interviews a five-minute budget,
  about five turns. That is a design choice from an experiment, not a measured
  optimum — treat it as an order of magnitude, not a target.
- When this skill was invoked by name, the user has already priced the
  interruption. Asking nothing is a failure. When it fired on its own, it has
  not been priced — earn it with one round, or none.

## The brief

Not a summary of the conversation. Four things:

- **The surviving hypotheses** — what the request still could mean, and what was
  ruled out. If one hypothesis remains, say so; that is the result.
- **The decided cases** — the concrete judgements, verbatim, ahead of any rule
  the user stated in general.
- **The question-and-answer pairs**, most recent first.
- **The assumptions** you are standing on, so they stay falsifiable.

The test for whether it is finished: *could an agent that sees only this text,
and never meets the user, reach the same answer as one who could ask them
anything?* If not, name what is missing and go get it.

This structure is inference, not measurement — its three parts are each
supported separately, but no source evaluated a handoff document. Treat it as
the skill's own hypothesis and revise it from real runs.

Confirm the brief once, but only when the next step is expensive or hard to
undo. For a question you are about to answer yourself, the brief is the opening
paragraph of the answer, not a checkpoint.

## Handing off

Route by what the brief turned out to be.

**A question about the world** → the bundled deep research workflow:
`Workflow({ name: 'deep-research', args: '<the question>' })`. It decomposes
into five search angles, searches in parallel, fetches sources, verifies each
extracted claim with three adversarial votes, and synthesises a cited report.
Its own guidance asks for two or three clarifying questions first — this skill
is that step, done properly.

**`args` is the only channel.** Nothing else crosses into the workflow — not the
conversation, not the answers, not the repo. Compress the brief into one
self-contained paragraph carrying the question, the surviving hypothesis, the
decided cases, and what would make an answer useless. A one-line `args` after a
three-round interview throws the interview away.

At its caps the workflow spends around a hundred agent calls. That is what makes
the brief worth confirming before launch, and what makes a vague question
expensive rather than merely unhelpful.

**A question about this codebase** → `craft:explorer` or `Explore`. The deep
research workflow only searches the web; it cannot read the repo, and a codebase
question sent there returns a confident essay about nothing.

**A choice between options** → answer it yourself: each option, what it buys,
what it costs, when it is the wrong call, and a recommendation.

**Work to be done** → `craft:planner` for the breakdown, `craft:executor` to
build it.

Whichever way it goes, the brief travels with it, verbatim.

## Failure modes

Each of these was observed and measured, not imagined:

1. **An irrelevant question is worse than no question.** Not neutral — worse.
2. **"Does this need a question?" collapses into "always ask"** when it is
   judged from the request alone instead of from the question you would ask.
3. **Optimising for "was that a good question?" produces generic questions**,
   because vague questions reliably score well. Score specificity separately.
4. **Confident recall produces questions incompatible with answers already
   given**, and gets worse as the interview lengthens. This is what the
   hypothesis list exists to prevent.
5. **A stated rule diverges from the same user's concrete decisions.** Test it
   with cases instead of trusting it.
6. **Non-redundancy does not emerge on its own.** It has to be demanded.

And three from judgement, unmeasured: asking what the repo already answered;
writing the brief and then not using it; handing off a one-line `args` after a
long interview.

## Where the evidence runs out

The rules above lean on four sources: Wang & Ai (TOIS 2022) on the cost of
asking, Zamani et al. (WWW 2020) on question framing and option sets, GATE (ICLR
2025) — the only one run on live humans, 388 participants — on prompt-level
question policy and edge-case elicitation, and BED-LLM (ICLR 2026) on the
hypothesis list.

What none of them cover, so treat as open:

- **Batching versus one question per turn.** Never compared head-to-head. The
  human-validated design generates one question per turn; this skill batches
  because a CLI turn is expensive. That is a considered trade, not a finding.
- **Interviewer sycophancy** — agreeing instead of probing. No surviving source
  measures it.
- **User fatigue.** Only ever modelled as a hand-set parameter, never measured
  on people.
- **Domain transfer.** The hypothesis-list result comes from settings where the
  answer is one item from an enumerable set. A person's intent is not that, and
  the mechanism may carry further than the numbers do.
