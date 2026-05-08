---
name: general-coding-style
description: Apply the user's general coding style for software engineering work. Use when planning, implementing, reviewing, refactoring, debugging, or cleaning up code, tests, APIs, configuration, module boundaries, git diffs, or repository structure in any language.
metadata:
  is-custom: true
---

# General Coding Style

## Core Standard

Write code that is generic, robust, concise, readable, and easy to review. Prefer small, clear changes over clever or broad rewrites. Keep behavior explicit and code ownership boundaries obvious.

## Checklist

- Generic code: prefer reusable behavior with minimal assumptions over one-off logic.
- Minimal side effects: keep side effects explicit, isolated, and near system boundaries.
- Pure functions where practical: pass inputs clearly, return outputs, and avoid hidden mutation.
- Nice interfaces: expose small, stable, understandable function and module APIs.
- Proper components and modules: keep responsibilities separated and ownership boundaries clear.
- Robust logic: avoid hacky, fragile, timing-dependent, or environment-assuming implementations.
- Short, concise code: minimize the code we have to maintain without sacrificing clarity.
- Extreme readability: choose straightforward structure, minimal branching, and clear control flow.
- Explanatory naming: use unambiguous names that state intent and domain meaning.
- Refactor awareness: plan and suggest focused refactors when a better boundary or simpler design appears.
- Existing patterns first: follow the codebase's local architecture, style, helpers, and tests before inventing new ones.
- Diagnose first: pinpoint the real error or design issue before assuming, guessing, or patching symptoms.
- Focused git history: keep commits small and concise, with a working tree and staging area that are easy to review.
- Minimal unnecessary change: avoid unrelated edits, broad churn, and config/API expansion that the task does not require.
- Read relevant code, tests, schemas, and runtime output before deciding on a fix.
- Keep request handlers, reusable helpers, presets, persistence, UI code, external-tool wrappers, and tests in clear ownership boundaries.
- Treat tests as part of the design, and run targeted checks that match the touched code.
- Before finalizing, inspect the diff for accidental churn, unrelated edits, generated noise, and config/schema bloat.
- Use clear names that explain domain intent, not implementation mechanics.
- Keep branching shallow by extracting small helpers or choosing clearer data structures.
- Side effects are explicit, isolated, and cleaned up.
- Add focused tests for behavior contracts, edge cases, cleanup, and error mapping. Avoid tests that overfit private implementation details.
