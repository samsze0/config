export def w-columns [] {
    w | tail -n +2 | detect columns
}

export def command-exists [c] {
    (which $c | length) > 0
}