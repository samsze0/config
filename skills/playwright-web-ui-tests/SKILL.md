---
name: playwright-web-ui-tests
description: Use when writing, reviewing, stabilizing, or improving Playwright web UI tests.
metadata:
  is-custom: true
---

# Playwright Web UI tests

## Checklist

- Prefer user-visible selectors: roles, labels, accessible names, and visible text.
- Use stable `data-testid` only when semantic selectors are insufficient.
- Avoid selectors tied to DOM depth, CSS classes, styling, generated IDs, or exact layout.
- Assert user-observable outcomes instead of implementation details.
- Avoid keeping assertion-heavy tests for exact layout, copy, counts, or presentation details; prefer flow, state, permission, and business-logic coverage.
- Highly specific temporary tests can help verify a narrow behavior or agentic code change; after running them, discard them instead of keeping them in the suite.
- Wait for meaningful UI or network state instead of arbitrary sleeps.
- Keep each test focused on one user workflow or behavior.
- Make test names describe the user behavior and expected outcome.
- Keep assertions focused so failures identify the broken behavior quickly.
- Prefer helper functions for repeated flows, but keep helpers explicit and easy to debug.
- Avoid hiding important user actions inside overly abstract helpers.
