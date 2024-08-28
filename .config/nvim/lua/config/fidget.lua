-- https://github.com/j-hui/fidget.nvim

require("fidget").setup({
  -- LSP progress config
  progress = {
    poll_rate = 0,
    suppress_on_insert = false,
    ignore_done_already = false,
    ignore_empty_message = false,
    clear_on_detach = function(client_id)
      local client = vim.lsp.get_client_by_id(client_id)
      return client and client.name or nil
    end,
    notification_group = function(msg) return msg.lsp_client.name end,
    ignore = {}, -- List of LSP servers to ignore

    display = {
      render_limit = 16,

      done_ttl = 3, -- How long a message should persist after completion
      done_icon = "✔",
      done_style = "Constant", -- Highlight group for completed LSP tasks

      progress_ttl = math.huge,
      progress_icon = { pattern = "dots", period = 1 },
      progress_style = "WarningMsg",

      group_style = "Title", -- Highlight group for group name (LSP server name)
      icon_style = "Question", -- Highlight group for group icons

      priority = 30, -- Ordering priority for LSP notification group
      skip_history = true, -- Whether progress notifications should be omitted from history

      format_message = require("fidget.progress.display").default_format_message,
      format_annote = function(msg) return msg.title end,
      format_group_name = function(group) return tostring(group) end,

      overrides = {
        rust_analyzer = { name = "rust-analyzer" },
      },
    },
  },

  notification = {
    poll_rate = 10,
    filter = vim.log.levels.INFO,
    history_size = 128,
    override_vim_notify = false,
    view = {
      stack_upwards = false,
      icon_separator = " ",
      group_separator = "---",
      group_separator_hl = "Comment",
      render_message = function(msg, cnt)
        return cnt == 1 and msg or string.format("(%dx) %s", cnt, msg)
      end,
    },

    window = {
      normal_hl = "Comment",
      winblend = 100,
      border = "none",
      zindex = 250,
      max_width = 0,
      max_height = 0,
      x_padding = 1,
      y_padding = 0,
      align = "top",
      relative = "editor",
    },
  },

  integration = {
    ["xcodebuild-nvim"] = {
      enable = true,
    },
  },

  logger = {
    level = vim.log.levels.INFO,
    max_size = 10000, -- Maximum log file size, in KB
    path = string.format("%s/nvim.log", vim.fn.stdpath("cache")),
  },
})
