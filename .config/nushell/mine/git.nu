export def git-profile-set [] {
    let profile_dir = $env.git.profiles.dir
    mkdir $profile_dir

    let profile_name = ls --short-names $profile_dir | get name | input list
    let profile = ([$profile_dir, $profile_name] | path join) | open | from yaml

    git config --local user.name $profile.name
    git config --local user.email $profile.email
}

export def git-profile-list [] {
    let profile_dir = $env.git.profiles.dir
    ls --short-names $profile_dir | get name
}

export def git-profile-create [profile_name] {
    let profile_dir = $env.git.profiles.dir
    mkdir $profile_dir

    mut profile = {}

    $profile.name = (input "Name: ") | str trim
    $profile.email = (input "Email: ") | str trim

    $profile | to yaml | save --force ([$profile_dir, $profile_name] | path join)
}

export def git-profile-show [] {
    let profile_dir = $env.git.profiles.dir
    let profile_name = git-profile-list | input list
    ([$profile_dir, $profile_name] | path join) | open | from yaml
}

export def git-tooling-config-update [
  --local
  --global
  --system
] {
  let scope = if $local { "--local" } else if $system { "--system" } else { "--global" }

  def gc [key: string, value: string] {
    # Use --replace-all so re-running is idempotent.
    # (If you prefer to preserve multi-values, change this to --add for specific keys.)
    ^git config $scope --replace-all $key $value | ignore
  }

  # --- diff / difftool ---
  gc "diff.tool" "nvimdiff"
  gc "difftool.prompt" "false"
  gc "difftool.nvimdiff.cmd" 'nvim -d "$LOCAL" "$REMOTE"'

  # --- merge / mergetool ---
  gc "merge.tool" "nvimdiff"
  gc "mergetool.prompt" "true"
  gc "mergetool.nvimdiff.cmd" "nvim -d \"$LOCAL\" \"$REMOTE\" \"$MERGED\" -c 'wincmd w' -c 'wincmd J'"

  # --- interactive ---
  gc "interactive.diffFilter" "delta --color-only"

  # --- delta theme ---
  gc "delta.dark" "true"
  gc "delta.syntax-theme" "base16"

  gc "delta.file-style" "#cbd1da bold"
  gc "delta.file-added-label" "[+]"
  gc "delta.file-copied-label" "[==]"
  gc "delta.file-modified-label" "[*]"
  gc "delta.file-removed-label" "[-]"
  gc "delta.file-renamed-label" "[->]"

  # last one wins; set it once to your intended value:
  gc "delta.file-decoration-style" "#727b8f ul"

  gc "delta.hunk-header-style" "omit"

  gc "delta.line-numbers" "true"
  gc "delta.line-numbers-left-style" "#727b8f"
  gc "delta.line-numbers-right-style" "#727b8f"
  gc "delta.line-numbers-minus-style" "#c64d4d"
  gc "delta.line-numbers-plus-style" "#537dcd"
  gc "delta.line-numbers-zero-style" "#727b8f"
  gc "delta.line-numbers-left-format" " {nm:>3} │"
  gc "delta.line-numbers-right-format" " {np:>3} │"

  gc "delta.inline-hint-style" "syntax"
  gc "delta.minus-style" "syntax #2f0f0f"
  gc "delta.minus-emph-style" "syntax #7b2525"
  gc "delta.minus-non-emph-style" "syntax auto"
  gc "delta.plus-style" "syntax #122241"
  gc "delta.plus-emph-style" "syntax #26498b"
  gc "delta.plus-non-emph-style" "syntax auto"
  gc "delta.whitespace-error-style" "#7b2525 reverse"

  gc "delta.commit-decoration-style" "normal box"
  gc "delta.commit-style" "#cbd1da bold"

  gc "delta.blame-code-style" "syntax"
  gc "delta.blame-format" "{author:>18} ({commit:>8}) {timestamp:<13} "
  gc "delta.blame-palette" "#000000 #1d2021 #282828 #3c3836"

  # merge conflict settings (unicode symbols are fine)
  gc "delta.merge-conflict-begin-symbol" "⌃"
  gc "delta.merge-conflict-end-symbol" "⌄"
  gc "delta.merge-conflict-ours-diff-header-style" "#e9a069 bold"
  gc "delta.merge-conflict-theirs-diff-header-style" "#e9a069 bold overline"
  gc "delta.merge-conflict-ours-diff-header-decoration-style" "''"
  gc "delta.merge-conflict-theirs-diff-header-decoration-style" "''"

  print $"git tooling config updated ($scope)"
}

export alias git-wip = git stash push -m "WIP" --all --include-untracked
export alias git-branch-publish = do {
    let branch = git branch --show-current
    git push --set-upstream origin $branch
}
