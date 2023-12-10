local M = {}

local config = require("m.fzf.config")
local utils = require("m.utils")
local uv_utils = require("m.uv")

local fzf_on_focus

FZF_EVENT_CALLBACK_MAP = {}
FZF_PORT = nil
FZF_CURRENT_SELECTION = nil
local server_socket, server_socket_path, close_server = uv_utils.create_server(
  function(message)
    if config.debug then
      vim.notify(string.format("Fzf server received: %s", message))
    end

    if string.match(message, "^port") then
      FZF_PORT = string.match(message, "^port (%d+)")
    elseif string.match(message, "^focus") then
      local selection = string.match(message, "^focus '(.+)'")
      FZF_CURRENT_SELECTION = selection
      if selection and fzf_on_focus and type(fzf_on_focus) == "function" then
        vim.schedule(function() fzf_on_focus(selection) end)
      end
    elseif string.match(message, "^event") then
      local event = string.match(message, "^event (.+)")
      if event and FZF_EVENT_CALLBACK_MAP[event] then
        local callback = FZF_EVENT_CALLBACK_MAP[event]
        if type(callback) == "function" then
          callback()
        else
          vim.notify(
            string.format(
              "Invalid fzf event callback for event %s: %s",
              event,
              vim.inspect(callback)
            ),
            vim.log.levels.ERROR
          )
        end
      end
    else
      vim.notify(
        string.format("Fzf server received invalid message: %s", message),
        vim.log.levels.ERROR
      )
    end
  end
)

M.send_to_fzf = function(message)
  if not FZF_PORT then
    vim.notify("Fzf server not ready", vim.log.levels.ERROR)
    return
  end
  vim.fn.system(
    string.format([[curl -X POST localhost:%s -d '%s']], FZF_PORT, message)
  )
end

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
    fzf_prompt = "",
    fzf_preview_window = {},
    fzf_preview_cmd = nil,
    fzf_initial_position = 1,
    fzf_on_focus = nil,
    fzf_binds = {},
  }, opts or {})

  if debug then vim.notify(vim.inspect(opts)) end

  -- Reset state
  FZF_EVENT_CALLBACK_MAP = {}
  FZF_PORT = nil
  FZF_CURRENT_SELECTION = nil

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

  for k, v in pairs(opts.fzf_binds) do
    if type(v) == "function" then
      FZF_EVENT_CALLBACK_MAP[k] = v
      opts.fzf_binds[k] = string.format(
        [[execute-silent(echo "trigger %s" | nc -U %s)]],
        k,
        server_socket_path
      )
    elseif type(v) == "string" then
    elseif type(v) == "table" then
      -- TODO: support list type and recursive parsing
    else
      vim.notify(
        string.format(
          "Invalid fzf bind value for key %s: %s",
          k,
          vim.inspect(v)
        ),
        vim.log.levels.ERROR
      )
    end
  end

  if opts.fzf_binds.focus then
    opts.fzf_binds.focus = opts.fzf_binds.focus .. "+"
  else
    opts.fzf_binds.focus = ""
  end
  opts.fzf_binds.focus = opts.fzf_binds.focus
    .. string.format(
      [[execute-silent(echo "focus {}" | nc -U %s)]],
      server_socket_path
    )

  if opts.fzf_binds.start then
    opts.fzf_binds.start = opts.fzf_binds.start .. "+"
  else
    opts.fzf_binds.start = ""
  end
  opts.fzf_binds.start = opts.fzf_binds.start
    .. string.format(
      [[execute-silent(echo "port $FZF_PORT" | nc -U %s)+pos(%d)]],
      server_socket_path,
      opts.fzf_initial_position
    )

  local binds_arg = table.concat(
    utils.map(
      opts.fzf_binds,
      function(k, v) return string.format([[%s:%s]], k, v) end
    ),
    ","
  )

  if config.debug then
    vim.notify(string.format([[binds_arg\n%s]], vim.inspect(binds_arg)))
  end

  vim.fn.termopen(
    string.format(
      [[echo "%s" | fzf --listen --ansi --prompt='%s❯ ' --border=none --height=100%% --preview-window=%s %s --bind '%s' --bind '%s' --delimiter=%s %s > %s]],
      content,
      opts.fzf_prompt,
      preview_window_arg,
      opts.fzf_preview_cmd
          and string.format([[--preview='%s']], opts.fzf_preview_cmd)
        or "",
      keybinds_arg,
      binds_arg,
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
