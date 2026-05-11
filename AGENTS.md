# AGENTS.md

Guidance for coding agents working in this personal dotfiles repository.

## Repository Overview

This is a macOS-first dotfiles repository with best-effort Linux support for shared shell, editor, terminal, and tool configuration. The repo uses an inverted `.gitignore`: everything is ignored by default, then specific files and directories are allowlisted.

Always use `git ls-files` as the source of truth for what is part of version control. There may be many local config files under `$HOME` that are intentionally untracked.

## Scope Rules

- Inspect `git ls-files` before making broad cleanup or documentation changes.
- Only edit tracked files unless the user explicitly asks to add or modify untracked files.
- Preserve existing dirty worktree changes. If a tracked file already has local edits, read it carefully and work with those edits rather than overwriting them.
- Do not commit secrets, machine-local state, generated caches, histories, or private app config.
- Keep macOS behavior first-class, but avoid breaking Linux branches in shared configs.

## Tracked Configuration Areas

- **Shell:** Nushell in `.config/nushell/`, Zsh entrypoint and plugin submodules under `.config/zsh/`
- **Terminal:** Kitty, Ghostty, tmux
- **Editors:** Zed project and user settings
- **Window management:** AeroSpace
- **Tools:** Yazi, Karabiner-Elements, Starship, bat, bottom, Topiary, PulseAudio, tmuxinator
- **Package management:** private Homebrew bundle submodule at `.config/brew-bundles/`
- **Docs:** `README.md`, `OSX.md`, `AGENTS.md`

Do not assume untracked directories, such as local Neovim config, are part of the repo unless they appear in `git ls-files`.

## Platform Notes

macOS is the primary setup target. Homebrew bundle management, Karabiner generation, AeroSpace, and macOS defaults belong to that path.

Linux support is best effort for tracked shared configs. Current tracked files include Linux-aware Nushell setup, Linux prompt metadata in Starship, and a Linux tmuxinator profile. The complete Linux system configuration lives separately in the NixOS repo linked from `README.md`.

## Common Commands

```bash
# Show the tracked repository surface
git ls-files

# Check local modifications before editing
git status --short

# Install Homebrew packages from an interactive bundle selector
brew-bundle-install

# Regenerate Karabiner config from the tracked TypeScript source
cd ~/.config/karabiner && bun run generate

# Regenerate Starship config from the tracked TypeScript source
cd ~/.config/starship && bun run generate
```

Machine-local overrides should stay ignored, including terminal env files and `.config/nushell/local.env.nu`.

When changing generated configuration, update the source generator and the generated tracked output together when both are tracked.

Do not add files inside `.config/brew-bundles/` to the parent repo. That path is a private submodule; the public parent should only track its gitlink.

<!-- BEGIN harness-system managed block: source=harness-system/templates/AGENTS.md -->

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

<!-- END harness-system managed block -->
