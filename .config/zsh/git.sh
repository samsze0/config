#!/usr/bin/env bash

git_current_branch() {
  git rev-parse --abbrev-ref HEAD
}

git_publish_branch() {
  git push --set-upstream origin "$(git_current_branch)"
}

git_remote_list() {
	git remote -v
}

git_stash_show() {
	git stash show -u --full-index "$@"
}

git_fetch_prune() {
	git fetch --prune
}

git_remote_prune() {
	git remote update origin --prune
}

git_stash_push_and_pull() {
    git stash push -m "WIP" --all --include-untracked
    git pull --rebase
    git stash pop
}

# Git branch helper
# By default show tracking info (relationship between local and remote branches)
# man git branch
git_branch() (
	set_flags

	git branch -vv --all --format="%(refname:short) -> %(upstream:short)"
)

git_branch_select() (
	set_flags

	choice=$(git_branch)
	read -r ref rest <<<"$(echo $choice | fzf)"
	echo "$ref"
)

git_commit_select() (
	set_flags

	branch="${1:-}"
	if [[ -z "$branch" ]]; then
		branch=""
	fi
	choice=$(git log --oneline --no-color $branch | fzf)
	read -r commit rest <<<"$choice"
	echo "$commit"
)

# Git worktree_remove helper
git_worktree_remove() (
	set_flags

	git worktree remove "$(git_worktree_select)"
)

git_worktree_select() (
	set_flags

	choice=$(git worktree list | fzf)
	read -r path rest <<<"$choice"
	echo "$path"
)

git_config_personal() {
	git config --local user.name "Sam Sze"
	git config --local user.email "mingsum.sam@gmail.com"
}

git_config_work() {
	git config --local user.name "Sam Sze"
	git config --local user.email "sam.m.sze@accenture.com"
}

# Append settings to `.gitconfig`. Require manual removal of old entries.
git_config_init() {
	cat <<EOT >>~/.gitconfig

[diff]
    tool = nvimdiff

[difftool]
    prompt = false

[difftool "nvimdiff"]
    cmd = "nvim -d \\"\$LOCAL\\" \\"\$REMOTE\\""

[merge]
    tool = nvimdiff

[mergetool]
    prompt = true

[mergetool "nvimdiff"]
    cmd = "nvim -d \\"\$LOCAL\\" \\"\$REMOTE\\" \\"\$MERGED\\" -c 'wincmd w' -c 'wincmd J'"

[interactive]
    diffFilter = delta --color-only

[delta]
    # Tweaked from: https://github.com/maxfangx
    # https://github.com/dandavison/delta/blob/main/themes.gitconfig
    # General appearance
    dark = true
    syntax-theme = base16
    # File
    file-style = "#cbd1da" bold
    file-added-label = [+]
    file-copied-label = [==]
    file-modified-label = [*]
    file-removed-label = [-]
    file-renamed-label = [->]
    file-decoration-style = "#3e4451" ul
    file-decoration-style = "#727b8f" ul
    # No hunk headers
    hunk-header-style = omit
    # Line numbers
    line-numbers = true
    line-numbers-left-style = "#727b8f"
    line-numbers-right-style = "#727b8f"
    line-numbers-minus-style = "#c64d4d"
    line-numbers-plus-style = "#537dcd"
    line-numbers-zero-style = "#727b8f"
    line-numbers-left-format = " {nm:>3} │"
    line-numbers-right-format = " {np:>3} │"
    # Diff contents
    inline-hint-style = syntax
    minus-style = syntax "#2f0f0f"
    minus-emph-style = syntax "#7b2525"
    minus-non-emph-style = syntax auto
    plus-style = syntax "#122241"
    plus-emph-style = syntax "#26498b"
    plus-non-emph-style = syntax auto
    whitespace-error-style = "#7b2525" reverse
    # Commit hash
    commit-decoration-style = normal box
    commit-style = "#cbd1da" bold
    # Blame
    blame-code-style = syntax
    blame-format = "{author:>18} ({commit:>8}) {timestamp:<13} "
    blame-palette = "#000000" "#1d2021" "#282828" "#3c3836"
    # Merge conflicts
    merge-conflict-begin-symbol = ⌃
    merge-conflict-end-symbol = ⌄
    merge-conflict-ours-diff-header-style = "#e9a069" bold
    merge-conflict-theirs-diff-header-style = "#e9a069" bold overline
    merge-conflict-ours-diff-header-decoration-style = ''
    merge-conflict-theirs-diff-header-decoration-style = ''
EOT
}
