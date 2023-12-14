-- System dependencies: netcat-openbsd on osx and socat on linux

local M = {}

local config = require("fzf.config")
local utils = require("utils")
local window_utils = require("utils.window")
local fzf_utils = require("fzf.utils")
local uv_utils = require("utils.uv")
local os_utils = require("utils.os")
local uv = vim.loop

local fzf_port
local fzf_on_focus
local fzf_on_prompt_change
local fzf_event_callback_map = {}

FZF_STATE = {
  event_callback_map = {},
  current_selection = nil,
  current_selection_index = nil,
  prev_window = nil,
  window = nil,
  buffer = nil,
  border_buffer = nil,
  preview_window = nil,
  preview_buffer = nil,
  preview_border_buf = nil,
  channel = nil,
}

local reset_state = function()
  fzf_on_focus = nil
  fzf_on_prompt_change = nil
  fzf_event_callback_map = {}

  FZF_STATE = {
    current_selection = nil,
    current_selection_index = nil,
    prev_window = nil,
    window = nil,
    buffer = nil,
    border_buffer = nil,
    preview_window = nil,
    preview_buffer = nil,
    preview_border_buf = nil,
    channel = nil,
  }
end

reset_state()

local server_socket, server_socket_path, close_server = uv_utils.create_server(
  function(message)
    if config.debug then
      vim.notify(string.format("Fzf server received: %s", message))
    end

    if string.match(message, "^port") then
      fzf_port = string.match(message, "^port (%d+)")
    elseif string.match(message, "^focus") then
      local index, selection = string.match(message, "^focus (%d+) '(.*)'")
      if not index or not selection then
        vim.notify(
          string.format("Invalid fzf focus message: %s", vim.inspect(message)),
          vim.log.levels.ERROR
        )
        return
      end
      FZF_STATE.current_selection_index = selection ~= ""
          and tonumber(index) + 1
        or -1
      FZF_STATE.current_selection = selection
      if selection and fzf_on_focus then vim.schedule(fzf_on_focus) end
    elseif string.match(message, "^change") then
      local query = string.match(message, "^change '(.+)'")
      if query and fzf_on_prompt_change then
        vim.schedule(function() fzf_on_prompt_change(query) end)
      end
    elseif string.match(message, "^event") then
      local event = string.match(message, "^event ([^\n]+)")
      if event and fzf_event_callback_map[event] then
        local callback = fzf_event_callback_map[event]
        vim.schedule(callback)
      else
        vim.notify(
          string.format("Invalid fzf event: %s", event),
          vim.log.levels.ERROR
        )
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
  if not fzf_port then
    vim.notify("Fzf server not ready", vim.log.levels.ERROR)
    return
  end
  vim.fn.system(
    string.format([[curl -X POST localhost:%s -d '%s']], fzf_port, message)
  )
  if config.debug then vim.notify("Sent message to fzf " .. message) end
end

M.abort_and_execute = function(callback)
  M.send_to_fzf("abort")
  fzf_event_callback_map["abort"] = callback
end

M.is_fzf_available = function() return vim.fn.executable("fzf") == 1 end

M.fzf = function(input, opts)
  reset_state()

  opts = vim.tbl_extend("force", {
    fzf_extra_args = "",
    fzf_prompt = "",
    fzf_preview_window = {},
    fzf_preview_cmd = nil,
    fzf_initial_position = 0,
    fzf_on_focus = nil,
    fzf_on_select = nil,
    fzf_binds = {},
    nvim_preview = false,
    before_fzf = nil,
    after_fzf = nil,
    fzf_async = false, -- Doesn't work well with start:pos
  }, opts or {})

  fzf_on_focus = opts.fzf_on_focus
  fzf_on_prompt_change = opts.fzf_on_prompt_change

  if config.debug then vim.notify(vim.inspect(opts)) end

  if M.is_fzf_available() ~= true then
    vim.notify(
      "Please install fzf. Check documentation for more information",
      vim.log.level.ERROR
    )
    return
  end

  if not type(input) == "table" then
    vim.notify(
      string.format("Invalid input type: %s", vim.inspect(input)),
      vim.log.levels.ERROR
    )
    return
  end

  if opts.nvim_preview then
    FZF_STATE.prev_window = vim.api.nvim_get_current_win()

    FZF_STATE.preview_window, FZF_STATE.preview_buffer, _, FZF_STATE.preview_border_buf =
      window_utils.open_floating_window({
        buffer = FZF_STATE.preview_buffer,
        buffiletype = "fzf_preview",
        position = "right",
        style = "code",
        main_win_extra_opts = {},
      })

    FZF_STATE.window, FZF_STATE.buffer, _, FZF_STATE.border_buffer =
      window_utils.open_floating_window({
        buffer = FZF_STATE.buffer,
        buffiletype = "fzf",
        position = "left",
      })

    window_utils.create_autocmd_close_all_windows_together({
      {
        window = FZF_STATE.window,
        buffer = FZF_STATE.buffer,
        border_buffer = FZF_STATE.border_buffer,
      },
      {
        window = FZF_STATE.preview_window,
        buffer = FZF_STATE.preview_buffer,
        border_buffer = FZF_STATE.preview_border_buf,
      },
    })
  else
    FZF_STATE.prev_window = vim.api.nvim_get_current_win()
    FZF_STATE.window, FZF_STATE.buffer, _, FZF_STATE.border_buffer =
      window_utils.open_floating_window({
        buffer = FZF_STATE.buffer,
        buffiletype = "fzf",
      })
    window_utils.create_autocmd_close_all_windows_together({
      {
        window = FZF_STATE.window,
        buffer = FZF_STATE.buffer,
        border_buffer = FZF_STATE.border_buffer,
      },
    })
  end

  local function parse_fzf_bind(event, action)
    if type(action) == "function" then
      fzf_event_callback_map[event] = action
      opts.fzf_binds[event] = string.format(
        [[execute-silent(echo "event %s" | %s)]],
        event,
        os_utils.get_unix_sock_cmd(server_socket_path)
      )
    elseif type(action) == "string" then
    elseif type(action) == "table" then
      for _, v in ipairs(action) do
        parse_fzf_bind(event, v)
      end
    else
      vim.notify(
        string.format(
          "Invalid fzf bind type %s: %s",
          event,
          vim.inspect(action)
        ),
        vim.log.levels.ERROR
      )
    end
  end

  for event, action in pairs(opts.fzf_binds) do
    parse_fzf_bind(event, action)
  end

  if opts.fzf_binds.focus then
    opts.fzf_binds.focus = opts.fzf_binds.focus .. "+"
  else
    opts.fzf_binds.focus = ""
  end
  opts.fzf_binds.focus = opts.fzf_binds.focus
    .. string.format(
      [[execute-silent(echo "focus {n} {}" | %s)]], -- TODO: support multi with +
      os_utils.get_unix_sock_cmd(server_socket_path)
    )

  if opts.fzf_binds.start then
    opts.fzf_binds.start = opts.fzf_binds.start .. "+"
  else
    opts.fzf_binds.start = ""
  end
  opts.fzf_binds.start = opts.fzf_binds.start
    .. string.format(
      [[execute-silent(echo "port $FZF_PORT" | %s)+pos(%d)]],
      os_utils.get_unix_sock_cmd(server_socket_path),
      opts.fzf_initial_position -- Async can mess with setting pos on start. So make sure --sync is supplied to fzf
    )

  if opts.fzf_binds.change then
    opts.fzf_binds.change = opts.fzf_binds.change .. "+"
  else
    opts.fzf_binds.change = ""
  end
  opts.fzf_binds.change = opts.fzf_binds.change
    .. string.format(
      [[execute-silent(echo "change {q}" | %s)]],
      os_utils.get_unix_sock_cmd(server_socket_path)
    )

  local binds_arg = table.concat(
    utils.map(
      opts.fzf_binds,
      function(k, v) return string.format([[%s:%s]], k, v) end
    ),
    ","
  )

  if opts.before_fzf then opts.before_fzf() end

  if config.debug then
    vim.notify(string.format([[binds_arg\n%s]], vim.inspect(binds_arg)))
  end

  local channel = vim.fn.termopen(
    string.format(
      [[cat <<"EOF" | fzf --listen --ansi %s --prompt='%s❯ ' --border=none --height=100%% %s --bind '%s' --delimiter=%s %s
%s
EOF
        ]],
      opts.fzf_async and "" or "--sync",
      opts.fzf_prompt,
      opts.fzf_preview_cmd
          and string.format([[--preview='%s']], opts.fzf_preview_cmd)
        or "",
      binds_arg,
      string.format("'%s'", utils.nbsp),
      opts.fzf_extra_args, -- TODO: put in front and throw warning if contains already existing args
      table.concat(input, "\n")
    ),
    {
      on_exit = function(job_id, code, event)
        vim.cmd("silent! :checktime")

        -- Restore focus to preview window (causes window group to close)
        if vim.api.nvim_win_is_valid(FZF_STATE.prev_window) then
          vim.api.nvim_win_close(FZF_STATE.window, true)
          vim.api.nvim_set_current_win(FZF_STATE.prev_window)
        else
          vim.notify(
            string.format(
              "Invalid preview window: %s",
              vim.inspect(FZF_STATE.prev_window)
            ),
            vim.log.levels.ERROR
          )
        end

        if code == 0 then
          opts.fzf_on_select()
        elseif code == 130 then
          -- On abort
          local abort_callback = fzf_event_callback_map["abort"]
          if abort_callback then abort_callback() end
        else
          vim.notify(
            string.format(
              "Unexpected exit code on Fzf\nExit code: %s\nEvent: %s",
              code,
              vim.inspect(event)
            ),
            vim.log.levels.ERROR
          )
        end

        if opts.after_fzf then opts.after_fzf() end
      end,
    }
  )
  if channel <= 0 then
    vim.notify(
      string.format("Error opening fzf terminal: %s", channel),
      vim.log.levels.ERROR
    )
    return
  end
  FZF_STATE.channel = channel

  vim.cmd("startinsert")
end

return M
