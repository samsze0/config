# Harness Workers

Opt-in Pi coding workers for Codex, routed through OpenRouter. Codex owns planning,
architecture, review and integration. Independent workers implement scoped tasks
in Git worktrees and return validated commits.

Built with **Bun, Pi SDK, Drizzle ORM, SQLite, and Ink**. Bun 1.3.14 is the tested
baseline. The terminal theme uses blue headings/success, gray context, white
content, yellow waiting/warnings, and red failures.

## Setup

```sh
cd ~/harness-system
bun install --frozen-lockfile
cp -n .env.example .env
chmod 600 .env
# Edit .env and set OPENROUTER_API_KEY.
bun run setup
bun run workers -- doctor
```

The CLI and coordinator automatically read this package's `.env`, regardless of
the repository being worked on. Existing process variables take precedence.
The installer creates `~/.local/bin/harness-workers`; add `~/.local/bin` to PATH
if needed, or use `bun run workers --` from this package.

Setup registers the MCP server and the `using-workers` skill in Codex, replaces
the legacy home AGENTS managed block, and converts the old home MCP symlink into
a regular file while preserving its entries. Reload Codex MCP connections after
installation. Desktop and CLI share the same coordinator. Installer preflight
rejects conflicting entries; rerunning setup is safe.

Credentials can alternatively be stored in the private credentials file using
`harness-workers credentials` with a key piped from a secret manager. Never pass
keys in command arguments. Credential order: process environment, harness `.env`,
then `credentials.json` in the configuration directory. Restart the coordinator
after changing a key that was loaded into its environment.

## Use from Codex

Ask: **“Use Pi workers for this task with the deepseek preset.”** Codex invokes the
skill and creates a task-specific run. Ordinary tasks have no enabled run.

Workers receive a task contract, applicable AGENTS instructions, ownership paths,
acceptance criteria and validation commands. Codex retains architecture, interface
decisions, integration, final review and end-to-end verification. Workers have no
recursive delegation, publishing, merge, or push workflow.

| Preset      | OpenRouter model                  | Requested reasoning |
| ----------- | --------------------------------- | ------------------- |
| `deepseek`  | `deepseek/deepseek-v4.1-flash` | high                |
| `muse`      | `meta/muse-spark-1.3-contributor` | high                |
| `muse-deep` | `meta/muse-spark-1.3-contributor` | xhigh               |
| `standard`  | `meta/muse-spark-1.3`             | high                |

DeepSeek V4.1 Flash at high is the default. The installed Pi SDK does not expose
xhigh for this model. Muse presets remain explicit alternatives; Contributor
prompts and outputs may be used to improve Meta's products. Model presence,
tool support and Pi reasoning compatibility are checked before enqueueing; runtime
provider errors are reported without silently switching models.

## CLI workflow

```sh
harness-workers on --repo /absolute/path/to/repo --preset deepseek
# Retain the returned run_id.
harness-workers spawn --run RUN_ID --file job.json
harness-workers status --run RUN_ID
harness-workers wait --run RUN_ID --after REVISION
harness-workers result --run RUN_ID --job JOB_ID
harness-workers use deepseek --run RUN_ID
harness-workers off --run RUN_ID
harness-workers on --run RUN_ID
```

Example `job.json`:

```json
{
  "task": "Implement the agreed slug helper and its tests.",
  "mode": "implementation",
  "ownership": ["src/slug.ts", "tests/slug.test.ts"],
  "acceptance": [
    "Whitespace collapses to a single dash",
    "Existing tests pass"
  ],
  "validation": ["bun test tests/slug.test.ts"]
}
```

Ownership entries are exact repository-relative filenames or directory prefixes;
they are not glob patterns. `.` grants the entire repository. Prefer disjoint,
specific ownership for parallel jobs. Read-only jobs use `mode: "read_only"`, need
acceptance criteria, and cannot supply validation commands or invoke shell/edit tools.

`batch --file jobs.json` takes an array of jobs. Each job can select a preset or
explicit `base_ref`. `steer --message TEXT` queues a correction at a tool boundary.
`cancel` stops execution, including subprocesses, and retains work. `resume` requires
an enabled run, checks the saved workspace, and continues its saved Pi session.
All these operations require the corresponding `--run` and `--job` identifiers.

`off` cancels queued jobs and lets active jobs finish. New presets affect subsequent
jobs; enqueued/running jobs keep their frozen settings. `--json` always emits JSON;
piped output also uses JSON. Interactive results use Ink.

## Snapshots, validation and review

The default starting snapshot includes tracked staged/unstaged changes, including
staged new files, without moving the source branch or modifying its index. Add
`--include relative/file` for explicit untracked inputs. Ignored inputs remain
excluded. `--base-ref HEAD` or another ref starts from committed code instead.
Conflicted indexes and dirty submodules require resolution or an explicit committed
base. Ownership paths are relative to the Git repository root, which may differ
from the supplied directory in dotfiles repositories.

Each job gets an isolated worktree under the repository's ignored `.worktree/`
directory and a `codex/workers/JOB_ID` branch. Read-only jobs also get a stable
snapshot worktree. The service changes the local Git exclude file to ignore this
directory; it does not edit application `.gitignore` files.

The coordinator checks file ownership, runs the supplied validation commands,
checks ownership again, and creates a commit only on success. The result reports
commands, exit codes, log paths, changed files, usage, uncertainties and the base
and result commits. Failed work remains available. Do not cherry-pick the starting
snapshot commit: it contains input changes, not the worker's contribution.

Codex must inspect results before integrating them. Passing commands do not prove
every acceptance criterion. Local commands run as the local user: worktrees isolate
Git changes, not operating-system access. File tools reject paths outside their
worktree and Git metadata; shell tools are ordinary local processes. Only use local
execution for repositories and commands you trust. Worker shells receive a minimal
environment without API keys, and ambient Pi plugins/settings are not loaded.

## Configuration and persistence

Default configuration: `~/.config/harness-workers/config.json`.
Default state: `~/.local/state/harness-workers/`.
The respective XDG variables are supported, as are `HARNESS_WORKERS_CONFIG_DIR`
and `HARNESS_WORKERS_STATE_DIR`. Use absolute override paths.

```json
{
  "limits": { "concurrency": 8, "timeout_ms": 1800000, "max_turns": 80 },
  "presets": {
    "custom": {
      "model": "provider/model-id",
      "effort": "high",
      "max_output_tokens": 16384
    }
  }
}
```

Run `harness-workers restart` after editing configuration or environment credentials.
The default capacity is eight simultaneous workers shared across all runs. Set
`limits.concurrency` from 1 to 16 to change it.
`harness-workers stop` interrupts active jobs and stops the service. `models QUERY --refresh`
lists current OpenRouter tool-capable models. Effort options are validated against
the selected model; non-reasoning models should use `off`.

The coordinator starts on demand over a private Unix socket and persists while
clients disconnect. Drizzle migrations are applied at startup. Jobs, results and
usage live in SQLite; per-job directories contain Pi sessions and validation logs.
After a coordinator crash or stop, unfinished jobs become interrupted and require
explicit resume. Limits apply to each attempt; `max_turns` counts model calls,
including retries and compaction. Usage accumulates across attempts and includes
Pi's model-price estimates. There is no harness dollar cap; OpenRouter key limits
can enforce an account-side billing bound.

Worktrees and job artifacts are retained for review and recovery. Remove reviewed
worktrees with `git worktree remove PATH`; remove their branches only when no longer
needed. No automatic cleanup deletes unfinished work.

## Development and verification

```sh
bun run check
bun run db:generate       # After changing src/db-schema.ts; review the migration.
bun run smoke            # Explicit, small real-OpenRouter test; requires a key.
bun run smoke standard   # Same bounded test using the standard preset.
bun run eval:live        # Selected-model complex evaluation; defaults to DeepSeek V4.1 Flash.
bun run setup -- --uninstall
```

Offline tests exercise Pi's real OpenRouter request adapter against scripted
responses, tool execution, sessions, steering, retries, cancellation, scheduling,
Git snapshots, result commits, Drizzle persistence, installer migration, Ink rendering,
and actual MCP/CLI transport. They make no paid model calls. The separate smoke
command uses a disposable repository and performs a bounded real implementation job.

Uninstall removes only the managed Codex entry, skill link, launcher and worker
instruction block. It preserves configuration, credentials, runtime state,
worktrees and unrelated MCP entries.

Architecture: [design](docs/design.md). Test evidence: [verification](docs/verification.md).
Complex evaluation: [workflow and interpretation](docs/evaluation.md).
Primary references checked September 15,
2026: [Pi SDK](https://pi.dev/docs/latest/sdk),
[OpenRouter tools](https://openrouter.ai/docs/guides/features/tool-calling),
[DeepSeek V4.1 Flash](https://openrouter.ai/deepseek/deepseek-v4.1-flash),
[Codex MCP](https://learn.chatgpt.com/docs/extend/mcp),
[Drizzle with Bun SQLite](https://orm.drizzle.team/docs/sqlite/connect-bun-sqlite).
