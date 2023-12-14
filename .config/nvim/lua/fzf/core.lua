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
      if selection and fzf_on_focus and type(fzf_on_focus) == "function" then
        vim.schedule(fzf_on_focus)
      end
    elseif string.match(message, "^change") then
      local query = string.match(message, "^change '(.+)'")
      if
        query
        and fzf_on_prompt_change
        and type(fzf_on_prompt_change) == "function"
      then
        vim.schedule(function() fzf_on_prompt_change(query) end)
      end
    elseif string.match(message, "^event") then
      local event = string.match(message, "^event ([^\n]+)")
      if event and fzf_event_callback_map[event] then
        local callback = fzf_event_callback_map[event]
        if type(callback) == "function" then
          vim.schedule(callback)
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

M.is_fzf_available = function() return vim.fn.executable("fzf") == 1 end

local capture_stdout = false
local capture_stderr = false

local selection_path = os.tmpname() .. "fzf-selection"
vim.fn.writefile({}, selection_path) -- Create temp file for fzf to write output to

M.fzf = function(input, on_selection, opts)
  reset_state()

  opts = vim.tbl_extend("force", {
    fzf_extra_args = "",
    fzf_prompt = "",
    fzf_preview_window = {},
    fzf_preview_cmd = nil,
    fzf_initial_position = 0,
    fzf_on_focus = nil,
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

  for k, v in pairs(opts.fzf_binds) do
    if type(v) == "function" then
      fzf_event_callback_map[k] = v
      opts.fzf_binds[k] = string.format(
        [[execute-silent(echo "event %s" | %s)]],
        k,
        os_utils.get_unix_sock_cmd(server_socket_path)
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

  if opts.before_fzf ~= nil and type(opts.before_fzf) == "function" then
    opts.before_fzf()
  end

  if config.debug then
    vim.notify(string.format([[binds_arg\n%s]], vim.inspect(binds_arg)))
  end

  local channel = vim.fn.termopen(
    string.format(
      [[cat <<"EOF" | fzf --listen --ansi %s --prompt='%s❯ ' --border=none --height=100%% %s --bind '%s' --delimiter=%s %s > %s
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
      selection_path,
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
          local selection = vim.fn.readfile(selection_path)
          selection = utils.map(
            selection,
            function(_, s) return vim.trim(s) end
          )
          selection = utils.filter(selection, function(s) return s ~= "" end)
          if config.debug then
            vim.notify(
              string.format(
                "Fzf\nExit code: %s\n%s",
                code,
                table.concat(selection, "\n")
              )
            )
          end

          on_selection(selection)
        elseif code == 130 then
          -- 130 means no selections
          if config.debug then
            vim.notify(
              string.format(
                "Fzf\nExit code: %s\nEvent: %s",
                code,
                vim.inspect(event)
              )
            )
          end
        else
          vim.notify(
            string.format(
              "Fzf\nExit code: %s\nEvent: %s",
              code,
              vim.inspect(event)
            ),
            vim.log.levels.ERROR
          )
        end

        if opts.after_fzf and type(opts.after_fzf) == "function" then
          opts.after_fzf()
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
