local M = {}

local config = require("m.fzf.config")
local utils = require("m.utils")
local uv_utils = require("m.uv")

local fzf_on_focus

FZF_PORT = nil
local server_socket, server_socket_path, close_server = uv_utils.create_server(
  function(message)
    if config.debug then
      vim.notify(string.format("Fzf server received: %s", message))
    end

    if string.match(message, "^port") then
      FZF_PORT = string.match(message, "^port (%d+)")
    elseif string.match(message, "^focus") then
      local selection = string.match(message, "^focus (.+)")
      if selection and fzf_on_focus and type(fzf_on_focus) == "function" then
        fzf_on_focus(selection)
      end
    end
  end
)

M.is_fzf_available = function() return vim.fn.executable("fzf") == 1 end
local open_floating_window = require("m.fzf.window").open_floating_window

FZF_BUFFER = nil
vim.g.fzf_opened = 0

local prev_win = -1
local win = -1

local capture_stdout = false
local capture_stderr = false

local selection_path = vim.fn.glob("~/.cache/lf_current_selection")

M.fzf = function(content, on_selection, opts)
  opts = vim.tbl_extend("force", {
    fzf_extra_args = "",
    fzf_preview_window = {},
    fzf_preview_cmd = nil,
    fzf_initial_position = nil,
    fzf_on_focus = nil,
  }, opts or {})

  if M.is_fzf_available() ~= true then
    vim.notify(
      "Please install fzf. Check documentation for more information",
      vim.log.level.ERROR
    )
    return
  end
  prev_win = vim.api.nvim_get_current_win()
  win = open_floating_window()

  vim.g.fzf_opened = 1
  if type(content) == "table" then content = table.concat(content, "\n") end

  local preview_window_arg = string.format(
    [[%s,%s,border-none,%s,nofollow,nocycle]],
    opts.fzf_preview_window.position or "right",
    opts.fzf_preview_window.size or "50%",
    opts.fzf_preview_window.wrap and "wrap" or "nowrap"
  )

  local keybinds_arg = string.format(
    "%s",
    table.concat({
      "shift-up:preview-up+preview-up+preview-up+preview-up+preview-up",
      "shift-down:preview-down+preview-down+preview-down+preview-down+preview-down",
    }, ",")
  )

  fzf_on_focus = opts.fzf_on_focus

  vim.fn.termopen(
    string.format(
      [[echo "%s" | fzf --listen --bind 'start:execute-silent(echo "port $FZF_PORT" | nc -U %s)' --bind 'focus:execute-silent(echo "focus {}" | nc -U %s)' --border=none --height=100%% --preview-window=%s --preview='%s' --bind 'start:pos(%d)' --bind '%s' --delimiter=%s %s > %s]],
      content,
      server_socket_path,
      server_socket_path,
      preview_window_arg,
      opts.fzf_preview_cmd or "",
      opts.fzf_initial_position or 1,
      keybinds_arg,
      string.format("'%s'", utils.nbsp),
      opts.fzf_extra_args,
      selection_path
    ),
    {
      on_exit = function(job_id, code, event)
        FZF_BUFFER = nil
        vim.g.fzf_opened = 0
        vim.cmd("silent! :checktime")

        -- Close Fzf window & restore focus to preview window
        if vim.api.nvim_win_is_valid(prev_win) then
          vim.api.nvim_win_close(win, true)
          vim.api.nvim_set_current_win(prev_win)
          prev_win = -1
          win = -1
        end

        if code == 0 then
          local selection = vim.fn.readfile(selection_path)
          selection = utils.map(
            selection,
            function(_, s) return vim.trim(s) end
          )
          selection = utils.filter(selection, function(s) return s ~= "" end)
          if debug then
            vim.notify(
              string.format(
                "Fzf\nExit code: %s\n%s",
                code,
                table.concat(selection, "\n")
              )
            )
          end

          on_selection(selection)
        end
      end,
      stdout_buffered = false,
      on_stdout = capture_stdout and function(...)
        local args = table.pack(...)
        if config.debug then vim.notify(vim.inspect(args)) end
      end or nil,
      on_stderr = capture_stderr and function(...)
        local args = table.pack(...)
        if config.debug then vim.notify(vim.inspect(args)) end
      end or nil,
    }
  )

  vim.cmd("startinsert")
end

return M
