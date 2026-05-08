---
name: documentation-driven-development
description: >
  Use for non-trivial project changes, source-of-truth documentation decisions,
  requirements clarification, and keeping docs, tests, and implementation
  aligned.
metadata:
  is-custom: true
---

# Documentation-Driven Development

Treat project documentation as the source of truth during normal development.
Implementation follows documented intent; undocumented existing behavior is a
drift-repair case.

## Start With Documentation

- Read the project entry document first, usually `SPEC.md` when it exists.
- Inspect the documentation hierarchy before choosing detailed docs.
- Progressively load only docs that can affect the current decision.
- If the repo defines a different documentation entry point, follow it.

## Source-of-Truth Rule

- Do not change behavior before the intended behavior is represented in the
  relevant documentation.
- For new or changed behavior, clarify requirements, update docs when needed,
  design tests, then implement.
- If implementation has already drifted ahead of docs, use
  `generating-technical-design-specification` and update docs to match the
  current code without changing code behavior.

## Documentation Shape

- Use progressive disclosure: high-level overview first, detailed docs linked
  from parent docs.
- Keep each fact in exactly one canonical place; reference it elsewhere instead
  of repeating it.
- Document stable architecture, feature behavior, and public contracts.
- Keep volatile implementation details in code unless they affect a public
  contract or user-facing behavior.

## Context Discipline

Load only context that can change the outcome. Challenge each document or
reference: does this content materially reduce ambiguity for the current task?

## Workflow

1. Load the source-of-truth docs and enough code context to understand the
   current state.
2. Clarify intent, scope, constraints, and success criteria.
3. Update relevant docs/specs before behavior changes when docs are incomplete.
4. Use `implementing-features` to turn accepted behavior into a reviewable
   implementation design, tests, and code.
5. Verify docs, tests, and behavior still describe the same outcome.

## Checklist

- Name the source-of-truth document(s) used for the task.
- Note any relevant docs that were intentionally not loaded and why.
- Track blocking open questions explicitly; do not treat hidden assumptions as
  clarified requirements.
- For behavior changes, state at least one observable acceptance criterion
  before implementation.
- For broad or risky changes, make sure acceptance criteria are specific enough
  to support an implementation design tree and test mapping.
- In the final handoff, say whether docs were changed, intentionally unchanged,
  or routed to reverse-sync via `generating-technical-design-specification`.
