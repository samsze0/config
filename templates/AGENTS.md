# AGENTS.md

This bootstrap is for application repositories using the harness system. Keep it
compact: baseline behavior lives here, while detailed procedures live in skills
and project documentation.

## Operating Model

- Read `SPEC.md` first when it exists, then load relevant docs progressively.
- Before substantial work, inspect available skill names/descriptions and load
  every materially relevant skill.
- Use AGENTS.md for non-negotiable defaults and retrieval cues. Use skills for
  deeper workflows, tool usage, and task-specific procedures.
- Load only context that can change the outcome. Prefer concise retrieval maps,
  durable artifacts, and targeted source reads over broad prompt mass.
- For broad or interrupted work, create or update a durable task artifact: task
  brief, handoff, or eval report.
- Use bounded delegation only for independent research questions, disjoint
  implementation slices, or separate QA/evaluation passes.

## Harness Boundary

- Normal downstream work serves the application repo: use project docs, task
  artifacts, local tests, and downstream-facing skills.
- Changes to the harness package itself, including shared skills, setup,
  templates, evals, or workflow policy, are harness-maintenance work.
- For harness-maintenance work, read `harness-system/README.md` and use
  `improving-harness-system`. Use that skill only for harness-system changes,
  not ordinary application implementation.

## Core Skills

- `documentation-driven-development`: source-of-truth docs, requirements, and
  spec-test-implementation alignment.
- `implementing-features`: feature design, tests as specifications, and
  implementation after docs are aligned.
- `general-coding-style`: general engineering style for code, tests, APIs,
  configuration, and repository structure.
- `git-hygiene`: worktree, branch, staging, conflict, and integration hygiene.
- `generating-technical-design-specification`: reverse-sync docs when code has
  drifted ahead of specs.
- `playwright-web-ui-tests`: Playwright web UI test design and stabilization.
- `python-coding-style` and `ios-app-development`: language/platform-specific
  guidance when relevant.

## Artifacts And Evaluation

- Use `templates/task-brief.md` for broad task framing.
- Use `templates/handoff.md` before pausing or transferring ownership.
- Use `templates/eval-report.md` when recording agent, harness, or test results.
- If a task cites benchmarks, evals, or current model behavior, record source
  date, environment assumptions, and residual uncertainty.
