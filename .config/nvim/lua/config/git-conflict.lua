require("git-conflict").setup({
  default_mappings = false,
  default_commands = true,
  disable_diagnostics = true,
  list_opener = "copen", -- command or function to open the conflicts list
  highlights = {
    incoming = "DiffAdd",
    current = "DiffText",
  },
})
