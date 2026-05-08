#!/usr/bin/env nu

const SCRIPT_DIR = (path self | path dirname | path expand)
const ENV_FILE = ($SCRIPT_DIR | path join ".env")
const CONFIG_FILE = ($SCRIPT_DIR | path join ".acpxrc.json")

def load-dotenv [path: string] {
  if not ($path | path exists) {
    print $"Error: missing ($path). Copy researcher/.env.example to researcher/.env and choose RESEARCHER_AGENT."
    exit 1
  }

  open --raw $path
  | lines
  | each {|line| $line | str trim }
  | where {|line| $line != "" and not ($line | str starts-with "#") }
  | each {|line|
      let parts = ($line | split row -n 2 "=")
      if (($parts | length) == 2) {
        let key = ($parts | get 0 | str trim)
        mut value = ($parts | get 1 | str trim)

        if (($value | str starts-with '"') and ($value | str ends-with '"')) {
          $value = ($value | str substring 1..-2)
        } else if (($value | str starts-with "'") and ($value | str ends-with "'")) {
          $value = ($value | str substring 1..-2)
        }

        load-env {($key): $value}
      }
    }
}

def env-default [name: string, fallback: string] {
  let value = (do -i { $env | get $name } | default "")
  if ($value == "") { $fallback } else { $value }
}

def permission-flag [mode: string] {
  match $mode {
    "approve-reads" => "--approve-reads",
    "approve-all" => "--approve-all",
    "deny-all" => "--deny-all",
    _ => {
      print $"Error: unsupported RESEARCHER_PERMISSION=($mode). Use approve-reads, approve-all, or deny-all."
      exit 1
    }
  }
}

def main [] {
  load-dotenv $ENV_FILE

  if (which acpx | is-empty) {
    print "Error: acpx is not installed or not on PATH. Install openclaw/acpx first, for example: npm install -g acpx"
    exit 1
  }

  let digest_date = (env-default "RESEARCHER_OUTPUT_DATE" (date now | format date "%Y-%m-%d"))
  let agent = (env-default "RESEARCHER_AGENT" "codex")
  let permission = (env-default "RESEARCHER_PERMISSION" "approve-reads")
  let timeout = (env-default "RESEARCHER_TIMEOUT" "1800")
  let model = (env-default "RESEARCHER_MODEL" "")
  let extra_focus = (env-default "RESEARCHER_EXTRA_FOCUS" "agentic software engineering, coding agents, harness design, context management, evaluation, and multi-agent workflows")
  let digest_rel = $"digests/($digest_date).md"
  let digest_abs = ($SCRIPT_DIR | path join $digest_rel)
  let perm_flag = (permission-flag $permission)

  mkdir ($SCRIPT_DIR | path join "digests")

  if not ($CONFIG_FILE | path exists) {
    print $"Error: missing ($CONFIG_FILE)."
    exit 1
  }

  let prompt = $"
Read ../README.md, instructions.md, and existing digests/*.md, then research the latest credible updates about AI with emphasis on ($extra_focus).

Write exactly one Markdown digest to: ($digest_rel)

Requirements:
- Inspect previous digests before external research and build a ledger of reviewed source URLs/articles.
- Prioritize new URLs/articles; do not re-evaluate old sources unless they have material updates after their prior digest date.
- Previously reviewed sources may appear only as continuity/recap citations and must be labeled as previously reviewed.
- Fully cite sources for every substantive claim.
- Prefer dated primary sources and current engineering/research posts.
- Include concrete implications for this harness, plus watch-only and do-not-incorporate-yet items.
- Do not modify ../README.md, ../AGENTS.md, ../skills, or any file outside ($digest_rel).
- If ($digest_rel) already exists, replace it with a fresh digest for ($digest_date).
"

  print $"Writing researcher digest to ($digest_abs)"
  print $"Using ACPX agent: ($agent)"

  if ($model == "") {
    ^acpx --cwd $SCRIPT_DIR --format text --timeout $timeout --non-interactive-permissions fail $perm_flag $agent exec --file instructions.md $prompt
  } else {
    ^acpx --cwd $SCRIPT_DIR --format text --timeout $timeout --non-interactive-permissions fail --model $model $perm_flag $agent exec --file instructions.md $prompt
  }
}
