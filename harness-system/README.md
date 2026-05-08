# harness-system

A lightweight workflow and skill suite for AI agent-driven software development.

## What is this

`harness-system` is a methodology package intended to be added to other
repositories as a git subtree. It provides:

- **AGENTS bootstraps**: root `AGENTS.md` for maintaining this harness repo,
  plus `templates/AGENTS.md` for downstream application repositories.
- **Workflow skills**: reusable process rules for documentation-driven
  development, implementation, skill improvement, worktrees, and spec editing.
- **Templates**: lightweight artifacts for task briefs, handoffs, eval reports,
  and source intake decisions.
- **Harness evals**: static checks for validating AGENTS.md, skills, setup,
  researcher, and documentation contracts.
- **Researcher subsystem**: an ACPX-backed source-discovery loop that generates
  dated, cited digests for human review.
- **MCP config**: pre-configured documentation/tool servers, including Context7.

## Two layers

This project has two related but separate layers:

- **Improving the harness system**: maintaining this reusable workflow package,
  including its README, root `AGENTS.md`, skills, setup, researcher, templates,
  and harness evals.
- **Applying the harness system**: using the package inside a downstream
  application repository, where `templates/AGENTS.md`, installed skills,
  project docs, task artifacts, and local tests guide normal product work.

Keep this boundary clear. Changes to the harness system should improve the
reusable package itself. Changes made while applying the harness should serve the
downstream application and keep application-specific workflow details out of this
repo's root bootstrap.

## Core philosophy

- **Persistent context for baseline behavior**: keep AGENTS.md compact, but put
  high-leverage guidance there when the agent should not have to decide whether
  to retrieve it.
- **Skills for deep workflows**: use skills for detailed process rules,
  specialized actions, and tool references that are best loaded on demand.
- **Source-of-truth documentation**: for downstream app repos, technical design
  specs drive implementation.
- **Spec-first development**: clarify requirements, update docs, design tests,
  then implement.
- **Harness-aware development**: for broad or long-running work, structure the
  model's environment with scoped plans, handoff artifacts, acceptance criteria,
  independent evaluation, and bounded delegation only when work can parallelize.
- **Live tool references**: for tool syntax and flags, fetch current docs through
  Context7 or official documentation rather than relying on memory.
- **Context quality with retrieval hooks**: more tokens can reduce reliability,
  so persistent context should be compressed, high-signal, and paired with
  retrieval pointers instead of embedded full manuals.

## AGENTS.md and skills

This project treats AGENTS.md and skills as complementary parts of an agentic
coding system across the two layers:

- Root `AGENTS.md` belongs to the harness-system layer. It is the
  harness-maintainer bootstrap for changing this repo's README, skills, setup,
  researcher, templates, and evals.
- `templates/AGENTS.md` belongs to the harness-application layer. Setup copies
  its guidance into downstream application repos as a managed block in their
  `AGENTS.md`.
- AGENTS files are always-available bootstraps. Use them for non-negotiable
  workflow rules, project documentation entry points, compressed indexes, and
  retrieval hints that should influence every turn.
- Skills are the deep reference layer. Use them for workflow details, tool usage,
  reusable procedures, and actions the agent can intentionally load when needed.
- For critical framework or project knowledge, prefer retrieval-led reasoning:
  tell the agent where the current source of truth is and when to read it, rather
  than relying on model pre-training.

This balance is informed by Vercel's article
[`AGENTS.md` outperforms skills in our agent evals](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals)
by Jude Gao, published January 27, 2026. In Vercel's hardened Next.js 16 evals,
baseline usage with no docs scored 53%, default skill usage also scored 53%,
skills with explicit AGENTS.md instructions scored 79%, and a compressed 8KB
docs index embedded directly in AGENTS.md scored 100%. Their interpretation was
that passive context removes the tool-retrieval decision point, stays available
on every turn, and avoids brittle ordering choices such as whether to read docs
before or after exploring the project. The practical lesson for this repo is not
"skills are obsolete"; it is that important baseline behavior belongs in
AGENTS.md, while skills remain valuable for vertical, action-specific workflows.

It is also constrained by Chroma's technical report
[Context Rot: How Increasing Input Tokens Impacts LLM Performance](https://www.trychroma.com/research/context-rot)
by Kelly Hong, Anton Troynikov, and Jeff Huber, published July 14, 2025.
Chroma evaluated 18 LLMs, including GPT-4.1, Claude 4, Gemini 2.5, and Qwen3
models, and found that model performance becomes increasingly unreliable as input
length grows, even on controlled tasks where only context length changes. Their
experiments show that semantic ambiguity, distractors, haystack content, document
structure, and long conversation history can all affect reliability. The design
lesson is that "put important things in AGENTS.md" does not mean "put everything
in context." Use AGENTS.md for compact defaults and retrieval cues, use skills
for deeper procedures, and load task-specific source material only when it can
change the outcome.

For long-running builds, this repo also follows Anthropic's article
[Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps)
by Prithvi Rajasekaran, published March 24, 2026. Anthropic describes two common
failure modes in extended coding runs: agents lose coherence as context fills,
and agents judge their own work too generously. Their harness work addressed this
with explicit orchestration around the model: planner agents expanded short
prompts into product specs, generator agents worked against scoped contracts, and
separate evaluator agents used tools such as Playwright to test running apps
against product, design, functionality, and code-quality criteria. The practical
lesson is to design the surrounding workflow, not just the prompt: decompose
broad work, define done before coding, preserve handoff state in artifacts, and
use independent QA when subjective or user-facing quality matters. Harnesses
should also be revisited as models improve, because scaffolding that was
load-bearing for one model may become unnecessary overhead for the next.

For broad research-like work, this repo also incorporates Anthropic's
[How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system),
published June 13, 2025 and written by Jeremy Hadfield, Barry Zhang, Kenneth
Lien, Florian Scholz, Jeremy Fox, and Daniel Ford. Anthropic's Research feature
uses an orchestrator-worker pattern: a lead agent plans the search, creates
specialized subagents with separate context windows, gathers their findings, and
synthesizes the final answer with citations. Their internal eval found that a
multi-agent system with Claude Opus 4 as lead and Claude Sonnet 4 subagents
outperformed single-agent Claude Opus 4 by 90.2% on research tasks, but the
system used roughly 15x more tokens than chat interactions. Anthropic also notes
that many coding tasks are less parallelizable than research and that real-time
agent coordination remains hard. The practical lesson is to use multi-agent
systems selectively: delegate only when the task has genuinely independent
branches, enough value to justify the cost, clear ownership boundaries, and
artifact-based outputs that the coordinator can synthesize without losing
detail.

## Keeping the workflow current

Agentic coding systems should evolve as current model behavior, framework APIs,
and tooling patterns change. A user may ask an agent to incorporate fresh
findings from technical articles, framework teams, model providers, or other
credible engineering sources so this workflow keeps pace with state-of-the-art
LLMs and current coding-agent performance.

The user may also ask the agent to look for potentially useful current articles
or research posts to tune this agentic software engineering harness. Treat that
as a research-and-curation task: find credible sources, screen them for relevance
to coding agents, harness design, context management, evaluation, tools, or model
behavior, then propose only the findings that should change the workflow.

The `researcher/` subsystem automates that intake path through
[openclaw/acpx](https://acpx.sh/), a unified ACP client for running different
agent backends behind one CLI. It reads this README plus
`researcher/instructions.md`, researches current AI and agentic software
engineering updates, and writes fully cited digests to
`researcher/digests/YYYY-MM-DD.md`. Existing digests are cumulative review
history, so later runs should use them to avoid re-evaluating the same sources
unless an article has materially changed. To use it, install `acpx`,
authenticate the chosen backend agent, copy `researcher/.env.example` to
`researcher/.env`, set `RESEARCHER_AGENT=codex`, `opencode`, `gemini`,
`claude`, or another ACP-compatible agent, then run `nu researcher/run.nu`.
`RESEARCHER_MODEL` is optional and only works for adapters that support model
switching. Digests are review inputs only: the user decides what belongs in
README, AGENTS.md, or skills.

When incorporating cutting-edge external information:

- Read the source directly and record the title, author, publisher, publication
  date, and URL.
- Distill the finding into a concrete workflow change: what the agent should do
  differently, when it applies, and what tradeoff it introduces.
- Prefer dated, cited guidance over timeless-sounding claims when the underlying
  model or tool behavior may change.
- Keep AGENTS.md small but high-signal; use it for durable retrieval cues,
  compact indexes, and default behavior, then place deeper procedures in skills
  or docs.
- Do not convert every article into permanent prompt mass. Extract the
  actionable rule, cite the source, and prefer pointers to longer material.
- For long-running or ambiguous work, define the harness before implementation:
  the spec source, scoped task chunks, acceptance criteria, handoff notes, and
  who or what evaluates the result.
- Use multi-agent patterns for breadth-first research, independent investigation,
  or disjoint implementation slices. Keep ordinary tightly coupled coding work in
  one agent unless delegation clearly reduces risk or latency.
- Give each delegated agent a concrete objective, ownership boundary, expected
  output format, and tool or source guidance. Scale effort to task complexity
  instead of spawning agents by default.
- Prefer artifact-based handoffs such as files, concise reports, citations, or
  QA findings over relaying all details through a coordinator's conversation
  history.
- Use independent evaluation for subjective, visual, product, and end-to-end
  quality. Self-review is useful, but it is not a substitute for a separate QA
  pass when quality depends on judgment or realistic interaction.
- Evaluate multi-agent results by final outcome and important checkpoints, not
  by requiring every agent to follow the same path.
- Revisit workflow scaffolding when adopting a newer model. Remove parts that no
  longer improve results, and add structure only where the current model still
  needs help.
- Treat external results as evidence to adapt, not universal law. When possible,
  validate them with project-specific tests, evals, or observed agent behavior.

Sources worth watching:

- [Anthropic Research](https://www.anthropic.com/research): AI safety, model
  internals, societal impacts, alignment, economic research, and dated
  publications that may affect agent harness design.
- [Anthropic Engineering](https://www.anthropic.com/engineering): practical
  engineering writeups on agent systems, coding workflows, evaluation, and model
  behavior.
- [OpenAI Research](https://openai.com/research/index/): model, safety, evaluation,
  and capability research relevant to agentic systems.
- [OpenAI Developers](https://developers.openai.com/) and
  [OpenAI API docs](https://platform.openai.com/docs): current platform,
  tooling, model, and API guidance.
- [Vercel Blog](https://vercel.com/blog): framework, frontend, AI SDK, and
  agent workflow findings from production web development.
- [Chroma Research](https://www.trychroma.com/research): retrieval, context,
  memory, and embedding research that can shape context-management rules.
- Model provider and framework release notes when relevant to a downstream repo.

When reviewing sources, prefer dated primary sources from model labs, framework
maintainers, infrastructure companies, tooling teams, or reproducible technical
reports. Do not incorporate speculative, marketing-only, or unrelated material.
If several credible sources disagree, document the tradeoff rather than forcing
one rule.

Operational loop:

1. Use `researcher/` to produce a cited digest when current external evidence is
   needed.
2. Review the digest with `researcher/templates/source-intake.md` and decide
   whether to incorporate, watch, or reject each finding.
3. Update README, root AGENTS.md, `templates/AGENTS.md`, skills, or templates
   with `improving-harness-system` when the finding changes this harness.
4. Record task continuity with `templates/task-brief.md` and
   `templates/handoff.md` for broad or interrupted work, and use
   `templates/eval-report.md` when documenting harness or agent results.
5. Verify harness health with `nu scripts/harness-eval.nu static`.

## Usage as a git subtree

Add to your project:

```bash
git subtree add --prefix harness-system https://github.com/<owner>/harness-system.git main --squash
```

Run setup from the downstream project root:

```bash
nu harness-system/manager.nu setup
```

In a clean downstream repo, setup creates a regular `AGENTS.md` containing a
marked harness-managed block generated from `harness-system/templates/AGENTS.md`,
symlinks `.mcp.json`, and installs the local skills with Vercel's skills tool
using non-interactive project-scope symlink defaults. Skill installation uses
the first available runner in this order: `bunx`, `deno`, then `npx`; each runner
is invoked in a form that can fetch the `skills` package if it is not already
installed.

If the downstream repo already has an `AGENTS.md`, setup leaves project-owned
instructions in place and inserts or updates only a marked harness-managed block
generated from `harness-system/templates/AGENTS.md`. Keep project-specific
guidance outside these markers:

```md
<!-- BEGIN harness-system managed block: source=harness-system/templates/AGENTS.md -->
...
<!-- END harness-system managed block -->
```

Rerun setup after pulling harness updates. Existing managed blocks are
refreshed, old harness-created `AGENTS.md` symlinks are migrated to regular
files, and unexpected existing `.mcp.json` files or symlinks fail
non-destructively with manual merge instructions.

Configure the upstream once:

```bash
git config harness-system.repo https://github.com/<owner>/harness-system.git
git config harness-system.ref main
```

Pull harness updates into the subtree:

```bash
nu harness-system/manager.nu pull
```

Push committed local harness changes back upstream:

```bash
nu harness-system/manager.nu push
```

Both commands also accept `--repo`, `--ref`, and `--prefix`. `--repo` overrides
`HARNESS_SYSTEM_REPO`, which overrides `git config harness-system.repo`.
