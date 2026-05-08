#!/usr/bin/env nu

# Manager CLI for harness-system git subtree installs.
# Run from the downstream project root: nu <subtree-path>/manager.nu <command>

const SCRIPT_DIR = (path self | path dirname)
const BEGIN_MARKER = "<!-- BEGIN harness-system managed block: source=harness-system/templates/AGENTS.md -->"
const END_MARKER = "<!-- END harness-system managed block -->"

def managed-agents-block [] {
  let template = (open --raw ($SCRIPT_DIR | path join "templates/AGENTS.md"))
  let body = ($template | str replace --regex "^# AGENTS\\.md\\n\\n" "" | str trim --right)

  [$BEGIN_MARKER "" $body "" $END_MARKER ""] | str join "\n"
}

def managed-agents-file [] {
  ["# AGENTS.md" "" (managed-agents-block)] | str join "\n"
}

def git-config [key: string] {
  let result = (^git config --get $key | complete)
  if $result.exit_code == 0 {
    $result.stdout | str trim
  } else {
    ""
  }
}

def env-string [name: string] {
  if ($name in $env) {
    let value = ($env | get $name)
    if ($value | describe) == "string" {
      $value | str trim
    } else {
      ""
    }
  } else {
    ""
  }
}

def resolve-repo [repo] {
  if ($repo != null) and (not (($repo | str trim) | is-empty)) {
    return ($repo | str trim)
  }

  let from_env = (env-string "HARNESS_SYSTEM_REPO")
  if not ($from_env | is-empty) {
    return $from_env
  }

  let from_config = (git-config "harness-system.repo")
  if not ($from_config | is-empty) {
    return $from_config
  }

  print "Error: missing harness upstream repo."
  print "Pass --repo, set HARNESS_SYSTEM_REPO, or run: git config harness-system.repo <repo-url>"
  exit 1
}

def resolve-ref [ref] {
  if ($ref != null) and (not (($ref | str trim) | is-empty)) {
    return ($ref | str trim)
  }

  let from_config = (git-config "harness-system.ref")
  if not ($from_config | is-empty) {
    return $from_config
  }

  "main"
}

def resolve-prefix [prefix] {
  if ($prefix != null) and (not (($prefix | str trim) | is-empty)) {
    let value = ($prefix | str trim)
    if ($value == ".") {
      print "Error: prefix cannot be '.'. Run from the downstream repository root or pass the subtree path."
      exit 1
    }

    return $value
  }

  let value = (try {
    $SCRIPT_DIR | path relative-to $env.PWD
  } catch {
    print "Error: run manager.nu from the downstream repository root, or pass --prefix."
    exit 1
  })

  if ($value == ".") {
    print "Error: manager.nu must be run from the downstream repository root, not the harness subtree root."
    exit 1
  }

  $value
}

def ensure-git-repo [] {
  let result = (^git rev-parse --show-toplevel | complete)
  if $result.exit_code != 0 {
    print "Error: this command must run inside a git repository."
    exit 1
  }
}

def ensure-prefix-clean [prefix: string] {
  let result = (^git status --porcelain -- $prefix | complete)
  if $result.exit_code != 0 {
    print $"Error: failed to inspect git status for ($prefix)."
    exit $result.exit_code
  }

  if not (($result.stdout | str trim) | is-empty) {
    print $"Error: ($prefix) has uncommitted changes. Commit or stash them before pull/push."
    exit 1
  }
}

def preflight-agents [subtree: string] {
  let agents_link = $"($subtree)/templates/AGENTS.md"

  if not ("AGENTS.md" | path exists) {
    return
  }

  let type = ("AGENTS.md" | path type)
  if $type == "symlink" {
    let target = (^readlink "AGENTS.md" | str trim)
    if $target == $agents_link {
      return
    }

    print $"Error: AGENTS.md is a symlink to ($target), not ($agents_link)."
    print "Resolve this manually before rerunning setup; setup will not replace it."
    exit 1
  }

  if $type != "file" {
    print $"Error: AGENTS.md exists as ($type). Setup only manages missing files, known harness template symlinks, or regular files."
    exit 1
  }

  let raw = (open --raw "AGENTS.md")
  let has_begin = ($raw | str contains $BEGIN_MARKER)
  let has_end = ($raw | str contains $END_MARKER)

  if ($has_begin xor $has_end) {
    print "Error: AGENTS.md contains only one harness managed block marker."
    print "Repair the managed block markers manually before rerunning setup."
    exit 1
  }
}

def preflight-mcp [subtree: string] {
  let mcp_link = $"($subtree)/mcp.json"

  if not (".mcp.json" | path exists) {
    return
  }

  let type = (".mcp.json" | path type)
  if $type == "symlink" {
    let target = (^readlink ".mcp.json" | str trim)
    if $target == $mcp_link {
      return
    }

    print $"Error: .mcp.json is a symlink to ($target), not ($mcp_link)."
    print "Resolve this manually before rerunning setup; setup will not replace it."
    exit 1
  }

  print "Error: .mcp.json already exists."
  print $"Merge MCP settings from ($mcp_link) manually before rerunning setup."
  exit 1
}

def setup-agents [subtree: string] {
  let agents_link = $"($subtree)/templates/AGENTS.md"

  if not ("AGENTS.md" | path exists) {
    managed-agents-file | save "AGENTS.md"
    print "  AGENTS.md created with managed harness block"
    return
  }

  let type = ("AGENTS.md" | path type)
  if $type == "symlink" {
    let target = (^readlink "AGENTS.md" | str trim)
    if $target == $agents_link {
      rm "AGENTS.md"
      managed-agents-file | save "AGENTS.md"
      print "  AGENTS.md migrated from symlink to managed regular file"
      return
    }

    print $"Error: AGENTS.md is a symlink to ($target), not ($agents_link)."
    print "Resolve this manually before rerunning setup; setup will not replace it."
    exit 1
  }

  if $type != "file" {
    print $"Error: AGENTS.md exists as ($type). Setup only manages missing files, known harness template symlinks, or regular files."
    exit 1
  }

  let raw = (open --raw "AGENTS.md")
  let has_begin = ($raw | str contains $BEGIN_MARKER)
  let has_end = ($raw | str contains $END_MARKER)
  let block = (managed-agents-block)

  if ($has_begin and $has_end) {
    let pattern = "(?s)<!-- BEGIN harness-system managed block: source=harness-system/templates/AGENTS\\.md -->.*?<!-- END harness-system managed block -->"
    $raw | str replace --regex --no-expand $pattern ($block | str trim --right) | save --force "AGENTS.md"
    print "  AGENTS.md managed harness block updated"
    return
  }

  if ($has_begin or $has_end) {
    print "Error: AGENTS.md contains only one harness managed block marker."
    print "Repair the managed block markers manually before rerunning setup."
    exit 1
  }

  let content = if ($raw | str trim | is-empty) {
    managed-agents-file
  } else {
    let separator = if ($raw | str ends-with "\n") {
      "\n"
    } else {
      "\n\n"
    }

    $"($raw)($separator)($block)"
  }

  $content | save --force "AGENTS.md"
  print "  AGENTS.md managed harness block appended"
}

def setup-mcp [subtree: string] {
  let mcp_link = $"($subtree)/mcp.json"

  if not (".mcp.json" | path exists) {
    ^ln -s $mcp_link ".mcp.json"
    print $"  .mcp.json -> ($mcp_link)"
    return
  }

  let type = (".mcp.json" | path type)
  if $type == "symlink" {
    let target = (^readlink ".mcp.json" | str trim)
    if $target == $mcp_link {
      print $"  .mcp.json already points to ($mcp_link)"
      return
    }

    print $"Error: .mcp.json is a symlink to ($target), not ($mcp_link)."
    print "Resolve this manually before rerunning setup; setup will not replace it."
    exit 1
  }

  print "Error: .mcp.json already exists."
  print $"Merge MCP settings from ($mcp_link) manually before rerunning setup."
  exit 1
}

def run-setup [subtree: string] {
  if ("CLAUDE.md" | path exists) {
    print "Error: CLAUDE.md already exists. Remove it before running setup."
    exit 1
  }

  if (which npx | is-empty) {
    print "Error: npx is required to install skills with Vercel's skills tool."
    exit 1
  }

  preflight-agents $subtree
  preflight-mcp $subtree

  print "Configuring harness files:"
  setup-agents $subtree
  setup-mcp $subtree

  print "Installing harness skills with Vercel's skills tool:"
  for skill in (glob ($SCRIPT_DIR | path join "skills/*/SKILL.md")) {
    let skill_dir = ($skill | path dirname)
    let skill_name = ($skill_dir | path basename)
    print $"  ($skill_name) <- ($skill_dir)"
    ^npx skills add $skill_dir --skill $skill_name
  }

  print $"Optional: run 'nu ($subtree)/scripts/harness-eval.nu static' from this repository to validate the harness package."
  print "Note: AGENTS.md is a regular file. Setup manages only the marked harness block; put project-specific instructions outside that block."
}

def "main setup" [
  --prefix: string
] {
  run-setup (resolve-prefix $prefix)
}

def "main pull" [
  --repo: string
  --ref: string
  --prefix: string
] {
  ensure-git-repo
  let subtree = (resolve-prefix $prefix)
  let upstream = (resolve-repo $repo)
  let branch = (resolve-ref $ref)

  ensure-prefix-clean $subtree

  print $"Pulling harness subtree from ($upstream) ($branch) into ($subtree)"
  ^git subtree pull --prefix $subtree $upstream $branch --squash
  if $env.LAST_EXIT_CODE != 0 {
    exit $env.LAST_EXIT_CODE
  }

  print $"Pulled harness subtree. Run 'nu ($subtree)/manager.nu setup' to refresh AGENTS.md and installed skills."
}

def "main push" [
  --repo: string
  --ref: string
  --prefix: string
] {
  ensure-git-repo
  let subtree = (resolve-prefix $prefix)
  let upstream = (resolve-repo $repo)
  let branch = (resolve-ref $ref)

  ensure-prefix-clean $subtree

  print $"Pushing committed harness subtree changes from ($subtree) to ($upstream) ($branch)"
  ^git subtree push --prefix $subtree $upstream $branch
  if $env.LAST_EXIT_CODE != 0 {
    exit $env.LAST_EXIT_CODE
  }
}

def main [] {
  print "Usage:"
  print "  nu harness-system/manager.nu setup"
  print "  nu harness-system/manager.nu pull --repo <repo-url> [--ref main]"
  print "  nu harness-system/manager.nu push --repo <repo-url> [--ref main]"
  print ""
  print "Repo may also come from HARNESS_SYSTEM_REPO or git config harness-system.repo."
}
