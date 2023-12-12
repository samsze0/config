local M = {}

local config = require("fzf.config")
local utils = require("utils")
local window_utils = require("utils.window")
local fzf_utils = require("fzf.utils")
local uv_utils = require("utils.uv")

local fzf_on_focus
local fzf_on_prompt_change

FZF_PORT = nil
FZF_EVENT_CALLBACK_MAP = {}

FZF_INITIAL_POS = nil
FZF_CURRENT_SELECTION = nil

FZF_PREV_WINDOW = nil
FZF_WINDOW = nil
FZF_BUFFER = nil
FZF_BORDER_BUFFER = nil
FZF_PREVIEW_WINDOW = nil
FZF_PREVIEW_BUFFER = nil
FZF_PREVIEW_BORDER_BUF = nil

local reset_state = function()
  fzf_on_focus = nil
  fzf_on_prompt_change = nil

  FZF_PORT = nil
  FZF_EVENT_CALLBACK_MAP = {}

  FZF_INITIAL_POS = nil
  FZF_CURRENT_SELECTION = nil

  FZF_PREV_WINDOW = -1
  FZF_WINDOW = -1
  FZF_BUFFER = nil
  FZF_BORDER_BUFFER = nil
  FZF_PREVIEW_WINDOW = -1
  FZF_PREVIEW_BUFFER = nil
  FZF_PREVIEW_BORDER_BUF = nil
end

reset_state()

local server_socket, server_socket_path, close_server = uv_utils.create_server(
  function(message)
    if config.debug then
      vim.notify(string.format("Fzf server received: %s", message))
    end

    if string.match(message, "^port") then
      FZF_PORT = string.match(message, "^port (%d+)")
      -- Set initial position here rather than binds to `load` event as reload would also trigger `load` event
      -- `start` event not applicable because input would still be being prepared (async)
      vim.schedule(
        function() M.send_to_fzf(string.format([[pos(%d)]], FZF_INITIAL_POS)) end
      )
    elseif string.match(message, "^focus") then
      local selection = string.match(message, "^focus '(.+)'")
      FZF_CURRENT_SELECTION = selection
      if selection and fzf_on_focus and type(fzf_on_focus) == "function" then
        vim.schedule(function() fzf_on_focus(selection) end)
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
      if event and FZF_EVENT_CALLBACK_MAP[event] then
        local callback = FZF_EVENT_CALLBACK_MAP[event]
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
  if not FZF_PORT then
    vim.notify("Fzf server not ready", vim.log.levels.ERROR)
    return
  end
  vim.fn.system(
    string.format([[curl -X POST localhost:%s -d '%s']], FZF_PORT, message)
  )
  if config.debug then vim.notify("Sent message to fzf " .. message) end
end

M.is_fzf_available = function() return vim.fn.executable("fzf") == 1 end

local capture_stdout = false
local capture_stderr = false

local selection_path = vim.fn.glob("~/.cache/lf_current_selection")

M.fzf = function(content, on_selection, opts)
  -- TODO: content can be a function that returns a string. Invoked whenever "reload"

  reset_state()

  opts = vim.tbl_extend("force", {
    fzf_extra_args = "",
    fzf_prompt = "",
    fzf_preview_window = {},
    fzf_preview_cmd = nil,
    fzf_initial_position = 1,
    fzf_on_focus = nil,
    fzf_binds = {},
    nvim_preview = false,
  }, opts or {})

  FZF_INITIAL_POS = opts.fzf_initial_position
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

  if opts.nvim_preview then
    FZF_PREV_WINDOW = vim.api.nvim_get_current_win()

    FZF_PREVIEW_WINDOW, FZF_PREVIEW_BUFFER, _, FZF_PREVIEW_BORDER_BUF =
      window_utils.open_floating_window({
        buffer = FZF_PREVIEW_BUFFER,
        buffiletype = "fzf_preview",
        position = "right",
        style = "code",
        main_win_extra_opts = {},
      })

    FZF_WINDOW, FZF_BUFFER, _, FZF_BORDER_BUFFER =
      window_utils.open_floating_window({
        buffer = FZF_BUFFER,
        buffiletype = "fzf",
        position = "left",
      })

    window_utils.create_autocmd_close_all_windows_together({
      {
        window = FZF_WINDOW,
        buffer = FZF_BUFFER,
        border_buffer = FZF_BORDER_BUFFER,
      },
      {
        window = FZF_PREVIEW_WINDOW,
        buffer = FZF_PREVIEW_BUFFER,
        border_buffer = FZF_PREVIEW_BORDER_BUF,
      },
    })

    window_utils.create_float_window_nav_keymaps({
      is_terminal = true,
      window = FZF_WINDOW,
      buffer = FZF_BUFFER,
    }, {
      is_terminal = false,
      window = FZF_PREVIEW_WINDOW,
      buffer = FZF_PREVIEW_BUFFER,
    })
  else
    FZF_PREV_WINDOW = vim.api.nvim_get_current_win()
    FZF_WINDOW, FZF_BUFFER, _, FZF_BORDER_BUFFER =
      window_utils.open_floating_window({
        buffer = FZF_BUFFER,
        buffiletype = "fzf",
      })
    window_utils.create_autocmd_close_all_windows_together({
      {
        window = FZF_WINDOW,
        buffer = FZF_BUFFER,
        border_buffer = FZF_BORDER_BUFFER,
      },
    })
  end

  if type(content) == "table" then content = table.concat(content, "\n") end

  local preview_window_arg = string.format(
    [[%s,%s,border-none,%s,nofollow,nocycle]],
    opts.fzf_preview_window.position or "right",
    opts.fzf_preview_window.size or "50%",
    opts.fzf_preview_window.wrap and "wrap" or "nowrap"
  )

  for k, v in pairs(opts.fzf_binds) do
    if type(v) == "function" then
      FZF_EVENT_CALLBACK_MAP[k] = v
      opts.fzf_binds[k] = string.format(
        [[execute-silent(echo "event %s" | nc -U %s)]],
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
      [[execute-silent(echo "port $FZF_PORT" | nc -U %s)]],
      server_socket_path
    )

  if opts.fzf_binds.change then
    opts.fzf_binds.change = opts.fzf_binds.change .. "+"
  else
    opts.fzf_binds.change = ""
  end
  opts.fzf_binds.change = opts.fzf_binds.change
    .. string.format(
      [[execute-silent(echo "change {q}" | nc -U %s)]],
      server_socket_path
    )

  -- Default keybinds
  opts.fzf_binds["shift-up"] =
    "preview-up+preview-up+preview-up+preview-up+preview-up"
  opts.fzf_binds["shift-down"] =
    "preview-down+preview-down+preview-down+preview-down+preview-down"

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
      [[echo "%s" | fzf --listen --ansi --prompt='%s❯ ' --border=none --height=100%% --preview-window=%s %s --bind '%s' --delimiter=%s %s > %s]],
      content,
      opts.fzf_prompt,
      preview_window_arg,
      opts.fzf_preview_cmd
          and string.format([[--preview='%s']], opts.fzf_preview_cmd)
        or "",
      binds_arg,
      string.format("'%s'", utils.nbsp),
      opts.fzf_extra_args,
      selection_path
    ),
    {
      on_exit = function(job_id, code, event)
        vim.cmd("silent! :checktime")

        -- Restore focus to preview window (causes window group to close)
        if vim.api.nvim_win_is_valid(FZF_PREV_WINDOW) then
          vim.api.nvim_win_close(FZF_WINDOW, true)
          vim.api.nvim_set_current_win(FZF_PREV_WINDOW)
        else
          vim.notify(
            string.format(
              "Invalid preview window: %s",
              vim.inspect(FZF_PREV_WINDOW)
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
