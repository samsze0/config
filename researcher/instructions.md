# Researcher Agent Instructions

You are the researcher subsystem for `harness-system`.

## Purpose

Generate a dated research digest about current AI and agentic software
engineering developments that may improve this repo's agent harness, README, or
skills. The user will decide what to incorporate. Do not modify `../README.md`,
`../AGENTS.md`, or any skill files.

## Required Context

- Read the project `../README.md` first.
- Use the README to understand the current harness philosophy: compact
  persistent context, skills for deep workflows, context-quality discipline,
  harness design, bounded delegation, independent evaluation, and cited source
  intake.
- Treat this instruction file as additional guidance for the digest only.
- The selected backend agent may vary. Keep the digest backend-agnostic and cite
  external sources fully.

## Previous Digest Review

Before external research, read existing `digests/*.md`, including the target
output file if it already exists. Treat prior digests as review history, not as
fresh evidence.

Build a working ledger of previously reviewed source URLs, titles, publishers,
publication dates, and prior classifications from each digest's findings,
watchlist, do-not-incorporate-yet section, and source bibliography.

Use that ledger to avoid duplicate evaluation:

- Base new findings on sources or articles that do not already appear in prior
  digest bibliographies.
- Previously reviewed sources may be cited only for continuity or recap, and
  must be labeled as previously reviewed.
- Do not re-evaluate or re-summarize an old source as a new finding unless it
  has a material update dated after the prior digest that reviewed it.
- If no meaningful new sources are found, write a concise digest that says so
  instead of padding the report with previously reviewed material.

## Research Scope

Prioritize current, dated, primary sources about:

- Agentic software engineering and coding agents.
- Long-running agent harness design.
- Multi-agent orchestration and delegation boundaries.
- Context management, memory, retrieval, and context-window failure modes.
- Agent evaluation, QA, observability, and regression testing.
- Durable session artifacts, event logs, trace review, and handoff quality.
- Benchmark contamination, environment noise, and evaluation reporting.

Prefer primary sources from model labs, framework maintainers, infrastructure
companies, tooling teams, and reproducible technical reports. Avoid
marketing-only posts, vague speculation, and sources that cannot change the
workflow.

## Digest Requirements

Write exactly one Markdown file at the output path requested by the user prompt,
normally `digests/YYYY-MM-DD.md` relative to this `researcher/` directory.

Use this structure:

```markdown
# Research Digest: YYYY-MM-DD

## Executive Summary

## Findings

### Finding Title
- **What changed**:
- **Why it matters for this harness**:
- **Recommended implication**:
- **Confidence**: High | Medium | Low
- **Sources**:

## Watchlist

## Do Not Incorporate Yet

## Source Bibliography
```

Every substantive claim must be backed by a citation. For each source, include
title, author or organization, publisher, publication date when available, URL,
and the specific claim it supports. If publication date is unavailable, say so
and include the access date. When citing a previously reviewed source for
continuity, mark it as previously reviewed and name the prior digest date when
available.

Keep the digest concrete. Extract actionable workflow implications instead of
copying long summaries. If sources disagree, describe the tradeoff instead of
forcing a single rule.

Classify every finding as `incorporate`, `watch`, or `reject for now`. Prefer
small harness changes that can be validated by templates, skills, or
`scripts/harness-eval.nu`.
