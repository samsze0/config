export def brew-bundle-path-interactive-select [] {
    let bundle_dir = $env.brew.bundle.dir
    mkdir $bundle_dir

    [$bundle_dir, (ls --short-names $bundle_dir | get name | input list)] | path join
}

export def brew-formula-list-by-size [] {
    # Get a list of all installed formula names
    let packages = (brew list --formula | lines)

    # For each package, get its info, extract the size line
    $packages | par-each { |p|
        let info = (brew info $p | lines | str join "")
        let matches = ($info | parse --regex ".*files, (?<size>.*)\\)\\s*$")

        if ($matches | is-empty) {
            # Handle cases where size info isn't in the standard format
            { name: $p, size: "N/A" }
        } else {
            let size = $matches.0.size | str trim
            { name: $p, size: $size }
        }
    }
        | where size != "N/A" # Filter out packages without size info (e.g., those installed from source without a bottle)
        | sort-by size | reverse # Sort from smallest to largest size, then reverse for largest first
}

export alias brew-bundle-formula-list = brew bundle list --formula --file=(brew-bundle-path-interactive-select)
export alias brew-bundle-install = brew bundle install --no-upgrade --file=(brew-bundle-path-interactive-select)
export alias brew-bundle-dump = brew bundle dump --describe --force --no-vscode --file=($env.brew.bundle.dir | path join full)
export alias brew-bundle-check = brew bundle check --file=(brew-bundle-path-interactive-select)
export alias brew-bundle-cleanup = brew bundle cleanup --force --file=(brew-bundle-path-interactive-select)
export alias brew-bundle-cask-list = brew bundle list --casks --file=(brew-bundle-path-interactive-select)
