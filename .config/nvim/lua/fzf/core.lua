-- System dependencies: netcat-openbsd on osx and socat on linux and perl
-- FIX: opening 1 fzf after another would not startinsert

local M = {}

local config = require("fzf.config")
local utils = require("utils")
local fzf_utils = require("fzf.utils")
local uv_utils = require("utils.uv")
local helpers = require("fzf.helpers")
local uv = vim.loop

local fzf_port
local on_focus
local on_query_change
local on_selections
local event_callback_map = {}

FZF = {
  current_query = nil,
  current_selection = nil,
  current_selection_index = nil,
  channel = nil,
  popups = nil,
}

local reset_state = function()
  on_focus = nil
  on_query_change = nil
  event_callback_map = {}

  FZF = {
    current_query = nil,
    current_selection = nil,
    current_selection_index = nil,
    channel = nil,
    popups = nil,
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
      if not fzf_port then
        vim.notify(
          string.format("Invalid fzf port message: %s", message),
          vim.log.levels.ERROR
        )
        return
      end
    elseif string.match(message, "^focus") then
      local index, selection = string.match(message, "^focus (%d+) '(.*)'")
      if not index or not selection then
        vim.notify(
          string.format("Invalid fzf focus message: %s", vim.inspect(message)),
          vim.log.levels.ERROR
        )
        return
      end
      FZF.current_selection_index = tonumber(index) + 1
      FZF.current_selection = selection
      if on_focus then vim.schedule(on_focus) end
    elseif string.match(message, "^selections") then
      if not on_selections then
        vim.notify(
          string.format(
            "Received fzf selections message but no callback was provided: %s",
            vim.inspect(message)
          ),
          vim.log.levels.ERROR
        )
        return
      end

      local indices = {}
      local selections = {}
      local mode = "protocol"
      local current_word = nil

      for word in string.gmatch(message, "[^%s]+") do
        if mode == "protocol" and word == "selections" then
          mode = "numbers"
        elseif mode == "numbers" and string.match(word, "^%d+$") then
          table.insert(indices, tonumber(string.match(word, "^%d+$")) + 1)
        elseif mode == "numbers" or mode == "strings" then
          mode = "strings"
          if current_word then
            if word:sub(#word, #word) ~= "'" then
              current_word = current_word .. " " .. word
            else
              current_word = current_word .. " " .. word
              table.insert(selections, string.match(current_word, "^'(.*)'$"))
              current_word = nil
            end
          else
            if word:sub(1, 1) == "'" and word:sub(#word, #word) == "'" then
              table.insert(selections, string.match(word, "^'(.*)'$"))
            elseif word:sub(1, 1) == "'" then
              current_word = word
            else
              vim.error(
                "Invalid fzf selection message. Unable to parse word:",
                word,
                "in message:",
                message,
                "Expected word to start with '"
              )
              return
            end
          end
        else
          vim.error(
            "Invalid fzf selection message. Unable to parse word:",
            word,
            "in message:",
            message
          )
          return
        end
      end

      if #indices ~= #selections then
        vim.notify(
          string.format(
            "Invalid fzf selection message: %s",
            vim.inspect(message)
          ),
          vim.log.levels.ERROR
        )
        return
      end

      vim.schedule(function() on_selections(indices, selections) end)
    elseif string.match(message, "^change") then
      local query = string.match(message, "^change '(.*)'")
      if not query then
        vim.notify(
          string.format("Invalid fzf change message: %s", message),
          vim.log.levels.ERROR
        )
        return
      end

      FZF.current_query = query
      if on_query_change then vim.schedule(on_query_change) end
    elseif string.match(message, "^event") then
      local event = string.match(message, "^event ([^\n]+)")
      if not event then
        vim.notify(
          string.format("Invalid fzf event: %s", event),
          vim.log.levels.ERROR
        )
        return
      end
      if event_callback_map[event] then
        vim.schedule(event_callback_map[event])
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
  event_callback_map["abort"] = callback
end

M.get_current_selections = function(callback)
  on_selections = callback
  M.send_to_fzf(
    fzf_utils.generate_fzf_send_to_server_action(
      "selections {+n} {+}",
      server_socket_path
    )
  )
end

M.is_fzf_available = function() return vim.fn.executable("fzf") == 1 end

M.fzf = function(input, opts)
  reset_state()

  opts = vim.tbl_extend("force", {
    layout = nil,
    fzf_extra_args = "",
    fzf_prompt = "",
    fzf_preview_cmd = nil,
    fzf_initial_position = 0,
    fzf_on_query_change = nil,
    fzf_on_focus = nil,
    fzf_on_select = nil,
    fzf_binds = {},
    before_fzf = nil,
    after_fzf = nil,
    fzf_async = false, -- Doesn't work well with start:pos
  }, opts or {})

  on_focus = opts.fzf_on_focus
  on_query_change = opts.fzf_on_query_change

  if M.is_fzf_available() ~= true then
    vim.notify(
      "Please install fzf. Check documentation for more information",
      vim.log.level.ERROR
    )
    return
  end

  if not type(input) == "table" and not type(input) == "string" then
    vim.notify(
      string.format("Invalid input type: %s", vim.inspect(input)),
      vim.log.levels.ERROR
    )
    return
  end

  local prev_win = vim.api.nvim_get_current_win()

  local layout = opts.layout
  if not layout then
    layout, _ = helpers.create_simple_layout()
  end

  layout:mount()

  local function parse_fzf_bind(event, action)
    if type(action) == "function" then
      event_callback_map[event] = action
      opts.fzf_binds[event] = fzf_utils.generate_fzf_send_to_server_action(
        string.format("event %s", event),
        server_socket_path
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
    .. fzf_utils.generate_fzf_send_to_server_action(
      "focus {n} {}",
      server_socket_path
    )

  if opts.fzf_binds.start then
    opts.fzf_binds.start = opts.fzf_binds.start .. "+"
  else
    opts.fzf_binds.start = ""
  end
  opts.fzf_binds.start = opts.fzf_binds.start
    .. fzf_utils.generate_fzf_send_to_server_action(
      "port $FZF_PORT",
      server_socket_path,
      { var_expansion = true }
    )
    -- Async can mess with setting pos on start. So make sure --sync is supplied to fzf
    .. string.format("+pos(%d)", opts.fzf_initial_position)

  if opts.fzf_binds.change then
    opts.fzf_binds.change = opts.fzf_binds.change .. "+"
  else
    opts.fzf_binds.change = ""
  end
  opts.fzf_binds.change = opts.fzf_binds.change
    .. fzf_utils.generate_fzf_send_to_server_action(
      "change {q}",
      server_socket_path
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

  local fzf_cmd = string.format(
    [[fzf --listen --ansi %s --prompt='%s❯ ' --border=none --height=100%% %s --bind '%s' --delimiter='%s' %s]],
    opts.fzf_async and "" or "--sync",
    opts.fzf_prompt,
    opts.fzf_preview_cmd
        and string.format([[--preview='%s']], opts.fzf_preview_cmd)
      or "",
    binds_arg,
    utils.nbsp,
    opts.fzf_extra_args -- TODO: throw warning if contains already existing args
  )

  local channel = vim.fn.termopen(
    type(input) == "table"
        and string.format(
          [[cat <<"EOF" | perl -pe "chomp if eof" | %s
%s
EOF
          ]],
          fzf_cmd,
          #input > 0 and table.concat(input, "\n") or ""
        )
      or string.format([[%s | %s]], input, fzf_cmd),
    {
      on_exit = function(job_id, code, event)
        vim.cmd("silent! :checktime")

        -- Restore focus to preview window
        if vim.api.nvim_win_is_valid(prev_win) then
          layout:unmount()
          vim.api.nvim_set_current_win(prev_win)
        else
          vim.notify(
            string.format("Invalid previous window: %s", vim.inspect(prev_win)),
            vim.log.levels.ERROR
          )
        end

        if code == 0 then
          opts.fzf_on_select()
        elseif code == 130 then
          -- On abort
          local abort_callback = event_callback_map["abort"]
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
  FZF.channel = channel

  vim.cmd("startinsert")
end

return M
