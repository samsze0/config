export use kitty.nu *
export use homebrew.nu *
export use git.nu *
export use osx.nu *
export use image.nu *

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

export def which-all [command] {
    for $dir in ($env.PATH) {
        fd --maxdepth 1 --type executable --type symlink --glob $command $dir
    }
}

export def "from env" []: string -> record {
lines
    | where { |line| ($line | str trim) != "" and not ($line | str starts-with "#") }
    | parse "{key}={value}"
    | each {|row|
        let k = ($row.key | str trim)

        let v = (
            $row.value
            | str trim
            | str trim -c '"'
        )

        { $k: (if $v == "" { null } else { $v }) }
    }
    | reduce --fold {} {|it, acc| $acc | merge $it }
}

export alias du-ranked-by-largest = do {
    du | sort-by physical | reverse
}
