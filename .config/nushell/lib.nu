export def w-columns [] {
    w | tail -n +2 | detect columns
}

export def command-exists [c] {
    try {
        command -v $c
        true
    } catch {
        false
    }
}
