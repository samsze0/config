---
name: generating-technical-design-specification
description: >
  Use only for reverse-syncing technical design documentation when existing
  implementation has drifted ahead of docs. Document observed behavior without
  changing code.
metadata:
  is-custom: true
---

# Generating Technical Design Specifications

This is the reverse path for drift repair. Normal development flows from docs
to tests to implementation; use this only when implementation already exists and
documentation needs to catch up.

Do not change code behavior. Update documentation to describe observed behavior.

## When to Use

- Implemented modules, interfaces, commands, workflows, or features are missing
  from docs.
- Architectural decisions made during implementation are undocumented.
- The user explicitly asks to resync TDS from code.

## What to Document

- Document architecture, module boundaries, feature behavior, and public
  contracts.
- Document implementation structure only when it has become stable architecture,
  an important module boundary, or a public contract.
- Do not document volatile internals or private helper design.
- Keep each fact in one canonical home and reference it elsewhere.

## Workflow

1. Read the project entry document first, then inspect docs to understand
   current coverage.
2. Explore the relevant implementation and compare observed behavior with docs.
3. Present documentation gaps by category and get confirmation when intent is
   ambiguous or the change is broad.
4. Update confirmed docs using existing structure, tone, and cross-references.
5. Verify parent links, documentation hierarchy, and duplicated facts.

## Checklist

- Confirm this is reverse-sync work: existing behavior is the evidence source,
  and code behavior should not change.
- Name the docs inspected and implementation areas used as evidence.
- For each proposed gap, keep at least one concrete evidence reference.
- Ask before documenting gaps that require product intent decisions rather than
  observation.
- After editing docs, verify changed facts have one canonical home and parent
  links still point to the right detailed docs.
- In the final handoff, report changed docs, evidence used, and whether any
  gaps remain intentionally undocumented.
