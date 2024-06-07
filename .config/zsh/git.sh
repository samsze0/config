#!/usr/bin/env bash

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

# Git diff helper
# man git diff
git_diff() (
	set_flags

	mode=$(
		cat <<EOF | fzf
--full-index
--name-only
--stat
EOF
	)

	lhs=$(
		cat <<EOF | fzf
working tree (implicit)
index (--staged / --cached)
branch
commit
EOF
	)

	if [[ "$lhs" == "index (--staged / --cached)" ]]; then
		rhs_options=$(
			cat <<EOF
HEAD~1 (implicit)
branch
commit
EOF
		)
		lhs="--staged"
	elif [[ "$lhs" == "working tree (implicit)" ]]; then
		rhs_options=$(
			cat <<EOF
HEAD (implicit)
branch
commit
EOF
		)
		lhs=""
	else
		if [[ "$lhs" == "branch" ]]; then
			lhs=$(git_select_branch)
		elif [[ "$lhs" == "commit" ]]; then
			lhs=$(git_select_commit)
		fi
		rhs_options=$(
			cat <<EOF
branch
commit
EOF
		)
	fi

	rhs=$(echo "$rhs_options" | fzf)

	if [[ "$rhs" == "branch" ]]; then
		rhs=$(git_select_branch)
	elif [[ "$rhs" == "commit" ]]; then
		rhs=$(git_select_commit)
	elif [[ "$rhs" == "HEAD~1 (implicit)" ]]; then
		rhs=""
	elif [[ "$rhs" == "HEAD (implicit)" ]]; then
		rhs=""
	fi

	git diff $mode $lhs $rhs
)

# Git branch helper
# By default show tracking info (relationship between local and remote branches)
# man git branch
git_branch() (
	set_flags

	git branch -vv --all --format="%(refname:short) -> %(upstream:short)"
)

git_select_branch() (
	set_flags

	choice=$(git_branch)
	read -r ref rest <<<"$(echo $choice | fzf)"
	echo "$ref"
)

git_select_commit() (
	set_flags

	branch="${1:-}"
	if [[ -z "$branch" ]]; then
		branch=""
	fi
	choice=$(git log --oneline --no-color $branch | fzf)
	read -r commit rest <<<"$choice"
	echo "$commit"
)

# Git worktree_add helper
# man git worktree
git_worktree_add() (
	set_flags

	ref=""
	commit_mode=false

	while (("$#")); do
		case "$1" in
		--commit)
			echo "Commit option specified"
			commit_mode=true
			shift
			;;
		*)
			if [[ -z "$ref" ]]; then
				ref="$1"
				shift
				continue
			fi
			echo "Invalid option: $1" >&2
			return 1
			;;
		esac
	done

	if [[ -z "$ref" ]]; then
		branch=$(git_select_branch)
		if $commit_mode; then
			ref=$(git_select_commit $branch)
		else
			ref=$branch
		fi
	fi
	git worktree add $ref
)

# Git clone helper
git_clone() (
	set_flags

	local repo_url="${1:-}"
	if [[ -n "$repo_url" ]]; then
		shift
	fi
	repo_name="${2:-}"
	if [[ -n "$repo_name" ]]; then
		shift
	fi

	mode=$(
		cat <<EOF | fzf
normal (implicit)
worktree (--bare)
EOF
	)
	if [[ "$mode" == "normal (implicit)" ]]; then
		opts=""
	elif [[ "$mode" == "worktree (--bare)" ]]; then
		opts="--bare"
	fi
	git clone $opts $repo_url $repo_name

	if [[ -z "$repo_name" ]]; then
		if [[ "$mode" == "normal (implicit)" ]]; then
			repo_name=$(basename "$repo_url" .git)
		elif [[ "$mode" == "worktree (--bare)" ]]; then
			repo_name=$(basename "$repo_url")
		fi
	fi
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
