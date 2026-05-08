---
name: implementing-features
description: >
  Use when implementing new features or modifying behavior after requirements
  and source-of-truth documentation are aligned. Covers reviewable design trees,
  tests, and implementation.
metadata:
  is-custom: true
---

# Implementing Features

Use this after `documentation-driven-development` has clarified requirements and
aligned relevant docs/specs.

## Step 3. Design implementation hierarchy

Remove ambiguity by sketching a reviewable design tree before coding broad or
risky changes. Show enough layers for the user to inspect structure without
reviewing every low-level implementation detail.

- Start with public behavior, then key modules/classes/functions, then risky or
  important helpers.
- For each important node, state responsibility, interface shape, and whether it
  should be pure or owns side effects.
- Keep interfaces small, domain-named, and decoupled from caller context.
- Keep I/O, persistence, external tools, time, randomness, and mutation at clear
  boundaries.

For broad or risky changes, present the design tree before implementation. Use
`templates/task-brief.md` when the design needs to survive handoff or review.

## Step 4. Write tests as specifications

Use tests to specify observable behavior before or alongside implementation.

- Cover expected behavior, important edge cases, and failure paths.
- Prefer readable tests that explain behavior over tests that mirror internals.
- For structured data, prefer schema or shape validation over long assertion
  chains.
- Map tests to acceptance criteria and to design-tree nodes when structure is
  important.

For broad or risky changes, review the test plan before implementation.

## Step 5. Implement

Implement the smallest coherent change, then iterate until targeted checks pass
or remaining failures are explicitly reported.

## Checklist

- Confirm requirements, source-of-truth docs, and acceptance criteria align.
- Map each acceptance criterion to a test or named manual verification.
- For broad or risky changes, present a design tree with responsibilities,
  interfaces, side-effect boundaries, and test mapping.
- Keep side effects and external-tool calls at clear boundaries.
- Prefer the smallest coherent implementation that satisfies the mapped criteria.
- Run targeted checks that cover the touched behavior, or state why they could
  not be run.
- Before handoff, review the diff for unrelated churn, accidental formatting,
  generated noise, and docs/code mismatch.
