# Bash scripting

## Tips

- `{}` runs group of commands
- `()` spawns a new subshell an run group of commands. Note `$()` is not `$` + `()`
- Command substitution w/ `$()`. Like `()`, it runs in its own subshell. And returns the output (stdout)
- `${}` for variable expansion; `y=${x:-}` sets `y` to empty string if `x` doesn't exist
- `set -euo pipefail` makes scripts more safe (exits on error; error if expand unset var; exit codes propagated in pipe)
- `[[]]` is the modern alternative to `[]`
- `-n` and `-z` to check of variable is set/non-empty of unset/empty
- `shift` to shift positional arg. Pair with `while`
- Add `""` to heredoc delimiter e.g. `<<"EOF"` to disable `$` expansion inside heredoc
- Use `local` variables
- Each part of the pipeline `|` are executed isolated in a subshell
- Heredoc string `foo <<< "some string"`. Generally can replace `$(echo "some string" | foo)`
- Use `read -r word rest <<< "Hello world"` to retrieve the first word of a string. This is different than using `echo` and pipe due to above and variables inside subshell would be lost. Pair it with `local word rest`
- Surround with `""` to avoid variable splitting (variable with spaces in-between)
- "Return" a value from a bash function/script by either: give exit status meanings, or stdout. Use `echo` in subshell with `$()`
- `$?` to get exit code of most recent command
- `$#` to get no. arguments
- `()` depending on context can be a way to initialize array. Array can be indexed as `"${array[n]}"`. Iterated with `for v in "${array[@]}"`. Get size w/ `"${#array[@]}"`
- `declare -n` for creating nameref (like pointers). `declare` when used in function scope is the same as `local`
