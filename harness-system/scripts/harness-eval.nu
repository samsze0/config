#!/usr/bin/env nu

const SCRIPT_DIR = (path self | path dirname | path expand)
const ROOT = ($SCRIPT_DIR | path dirname)

def add-failure [failures: list, message: string] {
  $failures | append $message
}

def rel [path: string] {
  $path | path relative-to $ROOT
}

def skill-files [] {
  glob ($ROOT | path join "skills/*/SKILL.md")
}

def skill-names [] {
  skill-files | each {|path| $path | path dirname | path basename }
}

def check-skills [failures: list] {
  mut out = $failures

  for file in (skill-files) {
    let raw = (open --raw $file)
    let name = ($file | path dirname | path basename)
    let parsed = ($raw | parse -r "(?m)^name:\\s*(?P<name>[a-z0-9-]+)")
    let words = ($raw | split words | length)

    if not ($raw | str starts-with "---") {
      $out = (add-failure $out $"(rel $file) is missing frontmatter")
    }
    if ($parsed | is-empty) {
      $out = (add-failure $out $"(rel $file) is missing a name field")
    } else if (($parsed | get 0).name != $name) {
      $out = (add-failure $out $"(rel $file) name does not match directory")
    }
    if not ($raw | str contains "description:") {
      $out = (add-failure $out $"(rel $file) is missing a description")
    }
    if not ($raw | str contains "is-custom: true") {
      $out = (add-failure $out $"(rel $file) is missing metadata.is-custom: true")
    }
    if ($words > 500) {
      $out = (add-failure $out $"(rel $file) has ($words) words; keep skills under 500 words")
    }
  }

  $out
}

def check-agents [failures: list] {
  mut out = $failures
  let agent_files = [
    "AGENTS.md"
    "templates/AGENTS.md"
  ]
  let names = (skill-names)

  for file in $agent_files {
    let raw = (open --raw ($ROOT | path join $file))
    let refs = ($raw | parse -r "`(?P<name>[a-z0-9-]+)`" | get name | uniq)

    for ref in $refs {
      if ($ref not-in $names) {
        $out = (add-failure $out $"($file) references missing skill `($ref)`")
      }
    }
  }

  let root_agents = (open --raw ($ROOT | path join "AGENTS.md"))
  if not ($root_agents | str contains "improving-harness-system") {
    $out = (add-failure $out "root AGENTS.md must reference improving-harness-system")
  }
  if not ($root_agents | str contains "researcher/") {
    $out = (add-failure $out "root AGENTS.md must mention researcher/")
  }

  let downstream_agents = (open --raw ($ROOT | path join "templates/AGENTS.md"))
  if ($downstream_agents | str contains "researcher/") {
    $out = (add-failure $out "templates/AGENTS.md must not mention researcher/")
  }
  if ($downstream_agents | str contains "researcher/templates/source-intake.md") {
    $out = (add-failure $out "templates/AGENTS.md must not mention researcher source intake")
  }

  let manager = (open --raw ($ROOT | path join "manager.nu"))
  if not ($manager | str contains "<!-- BEGIN harness-system managed block: source=harness-system/templates/AGENTS.md -->") {
    $out = (add-failure $out "manager.nu must define the harness managed block begin marker")
  }
  if not ($manager | str contains "<!-- END harness-system managed block -->") {
    $out = (add-failure $out "manager.nu must define the harness managed block end marker")
  }
  if ($manager | str contains '^ln -s $agents_link "AGENTS.md"') {
    $out = (add-failure $out "manager.nu must not symlink downstream AGENTS.md")
  }
  if not ($manager | str contains 'def skills-runner') {
    $out = (add-failure $out "manager.nu must select a skills runner")
  }
  if not ($manager | str contains '^bunx skills add $skill_dir --skill $skill_name --yes') {
    $out = (add-failure $out "manager.nu must prefer bunx for skills install")
  }
  if not ($manager | str contains '^deno run -A npm:skills add $skill_dir --skill $skill_name --yes') {
    $out = (add-failure $out "manager.nu must support deno for skills install")
  }
  if not ($manager | str contains '^npx --yes skills add $skill_dir --skill $skill_name --yes') {
    $out = (add-failure $out "manager.nu must install skills non-interactively")
  }
  if not ($manager | str contains 'def "main pull"') {
    $out = (add-failure $out "manager.nu must expose a pull subcommand")
  }
  if not ($manager | str contains 'def "main push"') {
    $out = (add-failure $out "manager.nu must expose a push subcommand")
  }

  $out
}

def check-known-paths [failures: list] {
  mut out = $failures
  let readme = (open --raw ($ROOT | path join "README.md"))
  let paths = [
    "AGENTS.md"
    "templates/AGENTS.md"
    "README.md"
    "researcher/"
    "researcher/instructions.md"
    "researcher/digests"
    "researcher/.env.example"
    "researcher/templates/source-intake.md"
    "manager.nu"
    "templates/task-brief.md"
    "templates/handoff.md"
    "scripts/harness-eval.nu"
  ]

  for path in $paths {
    if (($readme | str contains $path) and not (($ROOT | path join $path) | path exists)) {
      $out = (add-failure $out $"README.md references missing path ($path)")
    }
  }

  $out
}

def check-json [failures: list] {
  mut out = $failures

  for file in [mcp.json researcher/.acpxrc.json] {
    let path = ($ROOT | path join $file)
    let result = (try { open $path | ignore; true } catch { false })
    if not $result {
      $out = (add-failure $out $"($file) is not valid JSON")
    }
  }

  $out
}

def check-nushell [failures: list] {
  mut out = $failures
  let files = (glob ($ROOT | path join "**/*.nu"))

  for file in $files {
    ^nu -c $"source '($file)'"
    if ($env.LAST_EXIT_CODE != 0) {
      $out = (add-failure $out $"(rel $file) failed Nushell parse check")
    }
  }

  $out
}

def check-secret-ignore [failures: list] {
  mut out = $failures
  ^git -C $ROOT check-ignore -q researcher/.env
  if ($env.LAST_EXIT_CODE != 0) {
    $out = (add-failure $out "researcher/.env is not ignored")
  }
  $out
}

def run-static [] {
  mut failures = []
  $failures = (check-skills $failures)
  $failures = (check-agents $failures)
  $failures = (check-known-paths $failures)
  $failures = (check-json $failures)
  $failures = (check-nushell $failures)
  $failures = (check-secret-ignore $failures)

  if ($failures | is-empty) {
    print "harness static eval passed"
  } else {
    print "harness static eval failed:"
    for failure in $failures {
      print $"- ($failure)"
    }
    exit 1
  }
}

def main [
  mode: string = "static"
] {
  match $mode {
    "static" => { run-static }
    _ => {
      print "Usage: nu scripts/harness-eval.nu static"
      exit 1
    }
  }
}
