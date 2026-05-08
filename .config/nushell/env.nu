export use mine *

const local_env = "~/.config/nushell/local.env.nu"
source-env (if ($local_env | path expand | path exists) { ($local_env | path expand) } else { null })
