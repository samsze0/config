#!/usr/bin/env bash

# Git diff helper
# man git diff
git_diff() {
  mode=$(cat <<EOF | fzf
--full-index
--name-only
--stat
EOF
  )

  lhs=$(cat <<EOF | fzf
working tree (implicit)
index (--staged / --cached)
branch
commit
EOF
  )

  if [[ "$lhs" == "index (--staged / --cached)" ]]; then
    rhs_options=$(cat <<EOF
HEAD~1 (implicit)
branch
commit
EOF
    )
    lhs="--staged"
  elif [[ "$lhs" == "working tree (implicit)" ]]; then
    rhs_options=$(cat <<EOF
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
    rhs_options=$(cat <<EOF
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
}

# Git branch helper
# By default show tracking info (relationship between local and remote branches)
# man git branch
git_branch() {
  git branch -vv --all --format="%(refname:short) -> %(upstream:short)"
}

git_select_branch() {
  git branch -vv --all --format="%(refname:short)" | fzf
}

git_select_commit() {
  choice=$(git log --oneline --no-color | fzf)
  read -r commit rest <<< "$choice"
  echo "$commit"
}
