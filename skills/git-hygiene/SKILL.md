---
name: git-hygiene
description: Use when making git changes, choosing worktrees, moving changes between branches, or preparing changes for integration.
metadata:
  is-custom: true
---

# Git Hygiene

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching. It is very common to run into merge conflicts when bringing the work from worktrees onto the main branch, please follow the following checklist

## Checklist

- Before editing, inspect the current branch, status, and staged changes.
- Ask where changes should go only when worktree or branch ownership is
  ambiguous.
- If creating a worktree, ask for the base branch and worktree name/path unless
  already specified.
- Check if the worktree directory is ignored using the `git check-ignore` command
- By default store the worktrees under `.worktree/`
- Do not mix unrelated changes in one worktree or branch.
- Before committing or handing off, inspect the worktree and staging area; keep only intentional task changes, and exclude incidental formatting, rearranging, or unrelated edits. The goal is to make code reviewing easy for human.
- When asked to bring completed changes to a main or target branch, prefer cherry-picking the completed commit(s) onto that branch.
- When resolving merge, rebase, or cherry-pick conflicts, first understand both sides before editing conflict markers: read the relevant commit messages, inspect the incoming commit diff/content, and inspect the current branch changes touching the conflicted files.
- Resolve conflicts by preserving the intent of both current and incoming changes wherever possible; do not pick one side mechanically unless the commit history/content makes that correct.
- After resolving conflicts, review the resolved diff against both sides before continuing the merge/rebase/cherry-pick.
- After cherry-picking, verify the target branch and report conflicts or follow-up steps.
