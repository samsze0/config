use lib.nu *
use std log
use std "path add"

path add /usr/local/bin
path add ~/.cargo/bin

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
        }
        use_ls_colors: false
    }

    float_precision: 5
    buffer_editor: "nvim"
    use_ansi_coloring: true

    # Run `keybindings list`
    keybindings: [
        {
            name: delete_one_word_backward
            modifier: control
            keycode: backspace
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
    ]
}

if (command-exists starship) {
    mkdir ($nu.data-dir | path join "vendor/autoload")
    starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
}

if (command-exists zoxide) {
    source ~/.zoxide.nu
}

let os = uname | get kernel-name

if $os == "Darwin" {
    let homebrew_prefix = (match (arch) {
        "arm64" => "/opt/homebrew",
        "x86_64" => "/opt/homebrew-x86",
    })
    path add ($homebrew_prefix | path join "bin")
    $env.HOMEBREW_PREFIX = $homebrew_prefix
    $env.HOMEBREW_CELLAR = ($homebrew_prefix | path join "Cellar")
}

alias w = w-columns
alias f = yazi
alias c = code
