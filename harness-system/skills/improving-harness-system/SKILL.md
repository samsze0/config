---
name: improving-harness-system
description: >
  Use when creating, updating, or reviewing agent harness system: including but not limited to skills and AGENTS.md. Covers individual skill authoring and holistic review of the skillset for consistency and quality.
metadata:
  is-custom: true
---

# Improving Harness System

Use this skill for changes to root `AGENTS.md`, `templates/AGENTS.md`,
`README.md`, skills, templates, researcher, setup, or harness evals. The goal is
compact bootstraps, focused skills, durable artifacts, and repeatable checks.

## Skill Anatomy

Every skill has a required `SKILL.md` plus optional bundled resources:

```text
skill-name/
├── SKILL.md
└── references/ | scripts/ | assets/
```

- Use lowercase hyphenated names, preferably gerunds such as `using-tool`.
- Make `description` precise; it is the trigger text agents see before loading.
- Keep `SKILL.md` under 500 words.
- Move detailed variants, examples, or other assets into directly linked references.
- Do not add auxiliary docs such as README, changelog, or install guides inside
  a skill.
- Custom skills are indicated by the `is-custom` flag in the metadata. Do not modify skills that are not custom.

## Holistic Review

When reviewing the suite, read all `SKILL.md` files and AGENTS.md together.
Look for:

- Contradictions between AGENTS.md and skills.
- Contradictions between skills.
- AGENTS.md content that belongs in a skill.
- Missing or stale AGENTS.md references to skills.
- Confusion between root `AGENTS.md` for harness maintenance and
  `templates/AGENTS.md` for downstream application work.
- Skills that exceed the 500-word target or contain stale tool manuals.
- Project-specific facts inside skills that should live in project docs.
- Missing cross-references when one skill delegates to another.
- Empty or stub skills that should be filled or removed.
- Researcher, setup, template, or eval contracts that README does not mention.

Present findings by severity with a concrete suggested fix for each.

## Verification

- Run `nu scripts/harness-eval.nu static` after harness changes when available.
- Check word counts, frontmatter, local path references, script parseability, and
  ignored secret files.
- Keep external research as source-intake evidence until the user decides to
  incorporate it.
