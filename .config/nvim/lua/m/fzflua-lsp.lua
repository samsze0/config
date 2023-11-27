local utils = require("m.utils")
local config = require("m.config")
local timeago = require('m.timeago')
local actions = require("fzf-lua.actions")

return {
  prompt_postfix     = '❯ ',
  cwd_only           = true,
  -- :lua vim.lsp.buf.references({includeDeclaration = ?})
  includeDeclaration = true,
  symbols            = {
    symbol_style = 1, -- false = disable; 1 = icon + kind; 2 = icon; 3 = kind
  },
  -- colorize using Treesitter '@' highlight groups ("@function", etc).
  symbol_hl          = function(s) return "@" .. s:lower() end,
  symbol_fmt         = function(s, opts) return "[" .. s .. "]" end,
  fzf_opts           = {
    ["--tiebreak"] = "begin",
    ["--info"]     = "default",
  },
  code_actions       = {
    prompt = "CodeActions❯ ",
  },
  document_symbols   = {
    prompt = "DocumentSymbols❯ ",
  },
  workspace_symbols  = {
    prompt = "WorkspaceSymbols❯ ",
  },
  implementations    = {
    prompt = "Implementations❯ ",
  },
  references         = {
    prompt = "References❯ ",
  },
  -- TODO: LSP finder,   declarations, typedefs,  incoming/outgoing calls
}
