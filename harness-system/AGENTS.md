# Harness workers

Read README.md for the behavior contract and docs/design.md for architecture.
Use Bun for installation, execution, tests, and type checking. Run `bun run check`
after changes. Keep worker configuration explicit and all inference on OpenRouter.
Preserve unrelated dotfile changes; this directory belongs to the parent dotfiles
repository. Never stage credentials, runtime state, or worker worktrees.

Keep MCP and CLI behavior aligned through the shared operation dispatcher.
Test observable lifecycle, Git, and integration behavior with temporary fixtures.
Never claim provider compatibility from a mock alone; distinguish offline tests
from live OpenRouter checks. Keep source documentation and contracts up to date.
