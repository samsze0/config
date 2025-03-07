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
    let session_dir = $env.kitty.session.dir
    mkdir $session_dir
    let date_format = $env.kitty.session.date_format

    let current_os_window = kitten @ls | from json | where is_focused | first
    let path = [$session_dir, (date now | format date $date_format)] | path join
    let path_last_session = [$session_dir, "last-session"] | path join

    mut session_str = []

    let tabs = $current_os_window.tabs
    for $tab in $tabs {
        $session_str = $session_str | append ""
        $session_str = $session_str | append $"new_tab ($tab.title)"
        # $session_str = $session_str | append $"layout ($tab.layout)"
        $session_str = $session_str | append $"layout fat"

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
    $session_str | str join "\n" | save --force $path_last_session

    open $path
}

export def kitty-session-load [--interactive(-i)] {
    let session_dir = $env.kitty.session.dir
    let date_format = $env.kitty.session.date_format

    let all_sessions = ls --short-names $session_dir | where name != "last-session" | get name | into datetime --format $date_format | sort --reverse | format date $date_format
    let session = match $interactive {
        true => { if ($all_sessions | length) > 0 { $all_sessions | input list } else { error make { msg: "No sessions found" } } }
        false => { $all_sessions | first }
    }

    let path = [$session_dir, $session] | path join
    kitty --session $path
}

export def kitty-session-path [] {
    let session_dir = $env.kitty.session.dir
    let path_last_session = [$session_dir, "last-session"] | path join

    $path_last_session
}
