use mine *
use std log
use std "path add"

# https://www.nushell.sh/book/configuration.html#nu-lib-dirs-constant
# $env.NU_LIB_DIRS = $env.NU_LIB_DIRS | append ($nu.config-path | path dirname)

let os = uname | get kernel-name

if $os == "Darwin" {
    let homebrew_prefix = (match (arch) {
        "arm64" => "/opt/homebrew",
        "x86_64" => "/opt/homebrew-x86",
    })
    path add ($homebrew_prefix | path join "bin")
    $env.HOMEBREW_PREFIX = $homebrew_prefix
    $env.HOMEBREW_CELLAR = ($homebrew_prefix | path join "Cellar")

    # Higher precedence than brew
    path add /usr/local/bin
    path add ~/.cargo/bin
    path add ~/.local/bin
    path add ~/bin
    path add ~/miktex/bin

    $env.kitty.session = {
        dir: $"($env.XDG_DATA_HOME)/kitty/sessions"
        date_format: "%Y-%m-%d-%H-%M"
    }

    $env.brew.bundle = {
        dir: $"($env.XDG_CONFIG_HOME)/brew-bundles"
    }

    $env.git.profiles = {
        dir: $"($env.XDG_DATA_HOME)/git-profiles"
    }

    # Zed: enable jupyter notebook feature
    # https://github.com/zed-industries/zed/pull/19756
    $env.LOCAL_NOTEBOOK_DEV = 1

    # https://code.claude.com/docs/en/data-usage
    $env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1
} else if $os == "Linux" {
    $env.XDG_DATA_HOME = ($env.HOME | path join ".local" "share")
    $env.XDG_CONFIG_HOME = ($env.HOME | path join ".config")
}


if (command-exists fzf) {
    let fzf_colors = {
        "bg+": "#23283c",
        "preview-bg": "#0f1118",
        "bg": "#0f1118",
        "border": "#535d6c",
        "spinner": "#549eff",
        "hl": "#549eff",
        "fg": "#687184",
        "header": "#7E8E91",
        "info": "#549eff",
        "pointer": "#549eff",
        "marker": "#687184",
        "fg+": "#95a1b3",
        "prompt": "#549eff",
        "hl+": "#549eff",
        "gutter": "-1"
    }

    let fzf_colors_str = $fzf_colors | transpose key val | each {|kv| $kv.key + ":" + $kv.val} | str join ','

    let fzf_default_opts = [
        "--layout=reverse",
        "--info=inline",
        "--border",
        "--margin=1",
        "--padding=1",
        "--marker='▏'",
        "--pointer='▌'",
        "--prompt=' '",
        "--highlight-line",

        # Join the colors as `key:val,key:val`
        $"--color=($fzf_colors_str)",

        "--bind 'ctrl-a:toggle-all'",
        "--bind 'ctrl-i:toggle'",
    ]

    $env.FZF_DEFAULT_OPTS = $fzf_default_opts | str join ' '
}

let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}

let default_completer = match (command-exists carapace) {
    true => $carapace_completer
    false => ({|spans|
        error make {
            msg: "Default completer not configured"
        }
    })
}

let zoxide_completer = {|spans|
    $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
}

let completer = {|spans|
    match $spans.0 {
        z => $zoxide_completer
        _ => $default_completer
    } | do $in $spans
}

$env.config = {
    show_banner: false
    edit_mode: 'emacs'

    ls: {
        use_ls_colors: false
        clickable_links: true
    }

    rm: {
        always_trash: false
    }

    table: {
        mode: rounded
        index_mode: always
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
        header_on_separator: false
        footer_inheritance: false
    }

    error_style: "fancy"

    display_errors: {
        exit_code: false
        termination_signal: true
    }

    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "plaintext"
        isolation: false
    }

    completions: {
        case_sensitive: false
        quick: false  # turn off auto-selecting completions when only one remains
        partial: false  # turn off partial filling of the prompt
        algorithm: "fuzzy"
        sort: "smart"
        external: {
            enable: true
            max_results: 100
            completer: $default_completer
        }
        use_ls_colors: false
    }

    float_precision: 5
    buffer_editor: "nvim"
    use_ansi_coloring: true

    # Run `keybindings list`
    # Run `keybindings listen`
    # Run `keybindings default`
    keybindings: [
        {
            name: fuzzy_file
            modifier: control
            keycode: char_t
            mode: emacs
            event: {
                send: ExecuteHostCommand
                cmd: "commandline edit --insert (fzf --layout=reverse)"
            }
        }
        # https://github.com/nushell/nushell/issues/1616
        {
            name: fuzzy_history
            modifier: control
            keycode: char_r
            mode: [emacs, vi_normal, vi_insert]
            event: [
                {
                    send: ExecuteHostCommand
                    cmd: "commandline edit --insert (
                    history
                        | get command
                        | reverse
                        | uniq
                        | str join (char -i 0)
                        | fzf
                            --read0
                            --layout reverse
                            --scheme=history
                            --query (commandline)
                        | decode utf-8
                        | str trim
                    )"
                }
            ]
        }
        {
            name: delete_one_word_backward
            modifier: control
            # keycode: backspace
            keycode: char_h
            mode: emacs
            event: { edit: backspaceword }
        }
        {
            name: redo_change
            modifier: control_shift
            keycode: char_z
            mode: emacs
            event: { edit: redo }
        }
        {
            name: undo_change
            modifier: control
            keycode: char_z
            mode: emacs
            event: { edit: undo }
        }
        {
            name: menu_page_previous
            modifier: none
            keycode: pageup
            mode: emacs
            event: { send: MenuPagePrevious }
        }
        {
            name: menu_page_next
            modifier: none
            keycode: pagedown
            mode: emacs
            event: { send: MenuPageNext }
        }
    ]
}

if (command-exists starship) {
    mkdir ($nu.data-dir | path join "vendor/autoload")
    starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
    $env.STARSHIP_CONFIG = $"($env.XDG_CONFIG_HOME)/starship/starship.toml"
}

if (command-exists zoxide) {
    mkdir ($nu.data-dir | path join "vendor/autoload")
    zoxide init nushell | save -f ($nu.data-dir | path join "vendor/autoload/zoxide.nu")
}

if (command-exists pnpm) {
    $env.PNPM_HOME = $"($env.HOME)/.local/share/pnpm"
    path add $env.PNPM_HOME
}

if (command-exists topiary) {
    $env.TOPIARY_CONFIG_FILE = ($env.XDG_CONFIG_HOME | path join topiary languages.ncl)
    $env.TOPIARY_LANGUAGE_DIR = ($env.XDG_CONFIG_HOME | path join topiary queries)
}

if (command-exists bun) {
    path add $"($env.HOME)/.bun/bin"
}

alias w = w-columns
alias f = yazi
alias v = nvim
alias c = zed-preview

alias sshs = env TERM="xterm-256color" sshs
