---
name: python-coding-style
description: Apply the user's Python-specific coding style. Use when planning, implementing, reviewing, refactoring, debugging, or testing Python code.
metadata:
  is-custom: true
---

# Python Coding Style

## Baseline

Apply `general-coding-style` first. Python code should stay generic, side-effect-light, readable, concise, well-separated by responsibility, and easy to review.

## Checklist

- Model data with small dataclasses, Pydantic models, protocols, or typed aliases when they clarify boundaries; do not add structure just to appease the type checker.
- Use domain-specific exception types for expected failures instead of broad `ValueError` when the caller needs to handle the failure intentionally.
- Use clear names that explain domain intent, not implementation mechanics.
- Keep branching shallow by extracting small helpers or choosing clearer data structures.
- Treat typing errors and warnings as useful signals, but do not contort clear runtime code just to satisfy static typing.
