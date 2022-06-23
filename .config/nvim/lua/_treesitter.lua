require('nvim-treesitter.configs').setup({
  ensure_installed = {
    "fish",
    "markdown",
    "vim",
    "java",
    "cpp",
    "c",
    "c_sharp",
    "cpp",
    "lua",
    "latex",
    "json5",
    "html",
    "hcl",
    "css",
    "yaml",
    "typescript",
    "toml",
    "swift",
    "python",
    "rust",
    "javascript"
  },

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },

  -- Commentstring
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  }
})
