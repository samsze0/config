# AGENTS.md

This bootstrap is for developing and maintaining the harness system itself. The
downstream application bootstrap lives at `templates/AGENTS.md`.

## Maintainer Model

- Read `README.md` first; it is the source of truth for this harness repo.
- Use `improving-harness-system` for changes to README, AGENTS templates,
  skills, setup, researcher, templates, or harness evals.
- Use `documentation-driven-development` for source-of-truth documentation
  changes and source-intake decisions.
- Load only context that can change the outcome. Keep persistent guidance
  compact and move detailed procedures into skills or templates.
- Use `researcher/` only when the user asks for current source discovery or a
  research digest. Generated digests are review inputs, not automatic changes.
- After harness changes, run `nu scripts/harness-eval.nu static` when available.

## Skill Index

- `improving-harness-system`: harness repo structure, AGENTS templates, skills,
  researcher, setup, and evals.
- `documentation-driven-development`: source-of-truth docs and cited source
  intake.
- `implementing-features`: implementation after documentation and acceptance
  criteria are aligned.
- `general-coding-style`: general engineering quality for code and config.
- `git-hygiene`: branch, worktree, staging, and integration hygiene.
- `generating-technical-design-specification`: reverse-sync docs from existing
  implementation.
- `playwright-web-ui-tests`, `python-coding-style`, and `ios-app-development`:
  domain-specific guidance when relevant.

## Separation Rule

Do not put downstream application workflow details in this file. Put downstream
always-loaded guidance in `templates/AGENTS.md`, and put deeper procedures in
skills.
