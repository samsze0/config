require("fidget").setup({
  -- LSP progress
  progress = {
    display = {
      render_limit = 10,
      done_icon = "",
      done_style = "DiagnosticInfo",
      progress_style = "NonText",
      group_style = "StatusLine",
      icon_style = "Question",
    },
  },

  -- Notifications
  notification = {
    override_vim_notify = false,
  },
})
