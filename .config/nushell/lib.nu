export def w-columns [] {
    w | tail -n +2 | detect columns
}

export def command-exists [c] {
    (which $c | length) > 0
}

export def install-plugins [] {
    let plugins = [
      nu_plugin_polars
      nu_plugin_gstat
      nu_plugin_formats
      nu_plugin_query
    ]

    $plugins | each { cargo install $in --locked } | ignore
    for $plugin in $plugins {
        plugin add $"~/.cargo/bin/(plugin)"
    }
}

export def kitty-session-save [] {
    let current_os_window = kitten @ls | from json | where is_focused | first
    mkdir $"($env.XDG_DATA_HOME)/kitty/sessions/"
    let path = $"($env.XDG_DATA_HOME)/kitty/sessions/(date now | format date "%Y-%m-%d-%H-%M")"

    mut session_str = ["new_os_window"]

    let tabs = $current_os_window.tabs
    for $tab in $tabs {
        $session_str = $session_str | append ""
        $session_str = $session_str | append $"new_tab ($tab.title)"
        $session_str = $session_str | append $"layout ($tab.layout)"

        let windows = $tab.windows
        if ($windows | length) > 0 {
            $session_str = $session_str | append $"cd ($windows.0.cwd)"
        }

        for $window in $windows {
            $session_str = $session_str | append $"title ($window.title)"
            $session_str = $session_str | append $"launch ($window.cmdline.0)"
        }
    }

    $session_str | str join "\n" | save --force $path

    open $path
}

export def kitty-session-load [] {
    let session_dir = $"($env.XDG_DATA_HOME)/kitty/sessions"
    let date_format = "%Y-%m-%d-%H-%M"

    let all_sessions = ls --short-names $session_dir | get name | into datetime --format $date_format | sort --reverse | format date $date_format
    let latest_session = $all_sessions | first

    let path = [$session_dir, $latest_session] | path join
    kitty --session $path
}
