-- System dependencies: netcat-openbsd on osx and socat on linux and perl

local M = {}

local config = require("fzf.config")
local utils = require("utils")
local fzf_utils = require("fzf.utils")
local uv_utils = require("utils.uv")

---@alias state { id: string, parent?: string, port: string, query: string, focused_entry?: string, focused_entry_index?: integer, layout: NuiLayout, main_popup: NuiPopup, prompt: string, _event_callback_map: table, _response_callback_map: table, _request_count: number }
---@type table<string, state>
local states = {}

-- Create state
--
---@param parent_state_id? string
---@return string stateId, state
local create_state = function(parent_state_id)
  local state_id = utils.uuid()
  local state = {
    id = state_id,
    parent = parent_state_id,
    port = nil, ---@diagnostic disable-line: assign-type-mismatch
    query = nil, ---@diagnostic disable-line: assign-type-mismatch
    focused_entry = nil, ---@diagnostic disable-line: assign-type-mismatch
    focused_entry_index = nil, ---@diagnostic disable-line: assign-type-mismatch
    layout = nil, ---@diagnostic disable-line: assign-type-mismatch
    main_popup = nil, ---@diagnostic disable-line: assign-type-mismatch
    _event_callback_map = {},
    _response_callback_map = {},
    _request_count = 0, -- For generating unique ID for requests to fzf
  }
  states[state_id] = state
  return state_id, state
end

-- Destroy state
--
---@param state_id string
local destroy_state = function(state_id)
  if not states[state_id] then error("State doesn't exist") end
  states[state_id] = nil
end

-- Get state
--
---@return state
local get_state = function(state_id)
  local state = states[state_id]
  if not state then error("State doesn't exist") end
  return state
end

-- Invoke event callback
--
---@param state_id string
---@param event string
local invoke_event_callback = function(state_id, event)
  local state = get_state(state_id)

  local action = state._event_callback_map[event]
  if not action then error("Event doesn't exist in map") end

  if type(action) == "function" then
    vim.schedule(function() action(state) end)
  elseif type(action) == "table" then
    for _, a in ipairs(action) do
      vim.schedule(function() a(state) end)
    end
  else
    error("Invalid fzf event callback type")
  end
end

local server_socket, server_socket_path, close_server = uv_utils.create_server(
  function(full_message)
    if config.debug then vim.info("Fzf server received", full_message) end

    local state_id, message = string.match(full_message, "^([%w-]+) (.*)$")
    if not state_id or not message then
      vim.error("Invalid fzf message", full_message)
      return
    end
    local state = get_state(state_id)

    if string.match(message, "^port") then
      local port = string.match(message, "^port (%d+)")
      if not port then
        vim.error("Invalid fzf port message", message)
        return
      end
      state.port = port
    elseif string.match(message, "^focus") then
      local index, entry = string.match(message, "^focus (%d+) '(.*)'")
      if not index or not entry then
        vim.error("Invalid fzf focus message", message)
        return
      end
      state.focused_entry_index = tonumber(index) + 1
      state.focused_entry = entry
    elseif string.match(message, "^query") then
      local query = string.match(message, "^query '(.*)'")
      if not query then
        vim.error("Invalid fzf query message", message)
        return
      end
      state.query = query
    elseif string.match(message, "^event") then
      local event = string.match(message, "^event (.*)\n")
      if not event then
        vim.error("Invalid fzf event", event)
        return
      end
      if state._event_callback_map[event] then
        invoke_event_callback(state_id, event)
      else
        vim.error("Received fzf event but no callback was provided", event)
        return
      end
    elseif string.match(message, "^request") then
      local req, content = string.match(message, "^request (%d+) (.*)$")
      if not req or not content then
        vim.error("Invalid fzf request message", message)
        return
      end
      if state._response_callback_map[req] then
        vim.schedule(function()
          state._response_callback_map[req](content)
          state._response_callback_map[req] = nil
        end)
      else
        vim.error("Received fzf request but no callback was provided", message)
        return
      end
    else
      vim.error("Fzf server received invalid message", message)
      return
    end
  end
)

-- Generate a send to lua server action string for fzf
--
---@param state_id string
---@param message string
---@param opts? { var_expansion?: boolean }
---@return string
M.send_to_lua_action = function(state_id, message, opts)
  return fzf_utils._send_to_lua_action(
    string.format("%s %s", state_id, message),
    server_socket_path,
    opts ---@diagnostic disable-line: param-type-mismatch
  )
end

-- Send message to current Fzf instance
--
---@param state_id string
---@param message string
---@return nil
M.send_to_fzf = function(state_id, message)
  local state = get_state(state_id)

  if not state.port then
    vim.error("Fzf server not ready")
    return
  end
  local output = vim.fn.system(
    string.format([[curl -X POST localhost:%s -d '%s']], state.port, message)
  )
  if vim.v.shell_error ~= 0 then
    error("Fail to send message to fzf" .. output)
  end
  if config.debug then vim.info("Sent message to fzf", message) end
end

-- Request content from current Fzf instance
--
---@param state_id string
---@param to_fzf? string
---@param to_lua? string
---@param callback fun(response: string): ...any
M.request_fzf = function(state_id, to_fzf, to_lua, callback)
  local state = get_state(state_id)

  if not to_fzf and not to_lua then
    vim.error("Either to_fzf or to_lua must be provided")
    return
  end

  if not state.port then
    vim.error("Fzf server not ready")
    return
  end
  state._request_count = state._request_count + 1
  state._response_callback_map[tostring(state._request_count)] = callback

  local tbl = {}
  if to_fzf then table.insert(tbl, to_fzf) end
  table.insert(
    tbl,
    M.send_to_lua_action(
      state_id,
      string.format([[request %d %s]], state._request_count, to_lua or "")
    )
  )

  M.send_to_fzf(state_id, table.concat(tbl, "+"))
end

-- Get current selected entries
--
---@param state_id string
---@param callback fun(indices: integer[], selections: string[]): nil
---@return nil
M.get_current_selections = function(state_id, callback)
  M.request_fzf(state_id, nil, "{+n} {+}", function(response)
    local indices = {}
    local selections = {}
    local mode = "numbers"
    local current_word = nil

    for word in string.gmatch(response, "[^%s]+") do
      if mode == "numbers" and string.match(word, "^%d+$") then
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
              "Invalid fzf selection response. Unable to parse word:",
              word,
              "in response:",
              response,
              "Expected word to start with '"
            )
            return
          end
        end
      else
        vim.error(
          "Invalid fzf selection response. Unable to parse word:",
          word,
          "in response:",
          response
        )
        return
      end
    end

    if #indices ~= #selections then
      vim.error("Invalid fzf selection response", response)
      return
    end

    vim.schedule(function() callback(indices, selections) end)
  end)
end

-- Abort current fzf instance and execute callback
--
---@param state_id string
---@param callback function
---@return nil
M.abort_and_execute = function(state_id, callback)
  local state = get_state(state_id)

  M.send_to_fzf(state_id, "abort")

  local event_callback_map = state._event_callback_map
  if type(event_callback_map["+abort"]) == "nil" then
    event_callback_map["+abort"] = callback
  elseif type(event_callback_map["+abort"]) == "function" then
    event_callback_map["+abort"] = { event_callback_map["+abort"], callback }
  elseif type(event_callback_map["+abort"]) == "table" then
    table.insert(event_callback_map["+abort"], callback) ---@diagnostic disable-line: param-type-mismatch
  else
    error("Invalid fzf abort callback type")
  end
end

---@param state_id string
M.get_root_state = function(state_id)
  local state = get_state(state_id)
  if not state.parent then return state end
  return M.get_root_state(state.parent)
end

---@return boolean
M.is_fzf_available = function() return vim.fn.executable("fzf") == 1 end

---@alias event_callback fun(state: state): nil
---@alias bind_type string | event_callback | (string | event_callback)[]
---@param input string[] | string
---@param opts { layout: NuiLayout, main_popup: NuiPopup, other_popups?: NuiPopup[], extra_args?: table<string, string>, prompt: string, preview_cmd?: string, initial_position?: integer, binds?: table<string, bind_type> }
---@param parent_state_id? string
---@return state
M.fzf = function(input, opts, parent_state_id)
  local state_id, state = create_state(parent_state_id)

  opts = vim.tbl_extend("force", {
    extra_args = {},
    initial_position = 0,
    binds = {},
    other_popups = {},
  }, opts or {})
  ---@cast opts { layout: NuiLayout, main_popup: NuiPopup, other_popups: NuiPopup[], extra_args: table<string, string>, prompt: string, preview_cmd: string, initial_position: integer, binds: table<string, bind_type> }

  if not M.is_fzf_available() then error("Fzf executable not found") end

  if not type(input) == "table" and not type(input) == "string" then
    error("Invalid input type " .. type(input))
  end

  local prev_win = vim.api.nvim_get_current_win()

  local layout = opts.layout
  local main_popup = opts.main_popup
  state.layout = layout
  state.main_popup = main_popup

  state.prompt = opts.prompt

  if parent_state_id then
    local parent_state = get_state(parent_state_id)
    parent_state.layout:hide()
  end

  local build_statusline = function()
    -- Loop over each ancestor and construct the statusline
    local statusline = ""

    ---@type state[]
    local stages = {}

    local current_state = state
    while current_state do
      table.insert(stages, 1, current_state)
      current_state = states[current_state.parent]
    end

    statusline = statusline
      .. table.concat(
        utils.map(stages, function(_, stage) return stage.prompt end),
        " > "
      )
    return statusline
  end

  main_popup.border:set_text("top", " " .. build_statusline() .. " ", "left")
  layout:mount()

  local on_buf_leave = function(ctx)
    local success, current_buf_root_state_id = pcall(
      function() return vim.b[0].fzf_root_state_id end ---@diagnostic disable-line undefined-field
    )
    if not success then return end
    local success, prev_buf_root_state_id = pcall(
      function() return vim.b[ctx.bufnr].fzf_root_state_id end
    )
    if not success then
      vim.error(
        "Unable to get `fzf_root_state_id` buffer variable from fzf popup"
      )
      return
    end
    if current_buf_root_state_id ~= prev_buf_root_state_id then
      layout:unmount()
    end
  end

  local root_state = M.get_root_state(state_id)

  local extended_binds = fzf_utils.bind_extend({
    focus = M.send_to_lua_action(state_id, "focus {n} {}"),
    start = {
      M.send_to_lua_action(
        state_id,
        "port $FZF_PORT",
        { var_expansion = true }
      ),
      string.format("pos(%d)", opts.initial_position),
    },
    change = M.send_to_lua_action(state_id, "query {q}"),
  }, opts.binds)

  -- FIX
  -- extended_binds = fzf_utils.bind_extend(extended_binds, {
  --   ["+before-start"] = function()
  --     for _, popup in ipairs({ main_popup, unpack(opts.other_popups) }) do
  --       vim.b[popup.bufnr].fzf_root_state_id = root_state.id
  --       popup:on("BufLeave", on_buf_leave)
  --     end
  --   end,
  -- })

  if config.debug then
    vim.info(opts.binds)
    vim.info(extended_binds)
  end

  local processed_binds = {}
  local event_callback_map = state._event_callback_map

  local function parse_fzf_bind(event, action)
    if type(action) == "function" then
      event_callback_map[event] = action
      processed_binds[event] =
        M.send_to_lua_action(state_id, string.format("event %s", event))
    elseif type(action) == "string" then
      processed_binds[event] = action
    elseif type(action) == "table" then
      local actions = {}
      local event_callback_action_added = false
      event_callback_map[event] = {}
      for _, v in ipairs(action) do
        if type(v) == "function" then
          table.insert(event_callback_map[event], v)
          if not event_callback_action_added then
            table.insert(
              actions,
              M.send_to_lua_action(state_id, string.format("event %s", event))
            )
            event_callback_action_added = true
          end
        elseif type(v) == "string" then
          table.insert(actions, v)
        else
          error("Invalid fzf bind type: " .. type(v) .. " for event " .. event)
        end
      end
      processed_binds[event] = table.concat(actions, "+")
    else
      error("Invalid fzf bind type: " .. type(action) .. " for event " .. event)
    end
  end

  for event, action in pairs(extended_binds) do
    parse_fzf_bind(event, action)
  end
  if config.debug then vim.info(event_callback_map) end

  local binds_fzf_arg = table.concat(
    utils.map(
      utils.filter(
        processed_binds,
        function(k, v) return string.sub(k, 1, 1) ~= "+" end
      ),
      function(k, v) return string.format([[%s:%s]], k, v) end
    ),
    ","
  )
  if config.debug then vim.info(binds_fzf_arg) end

  local extra_args = table.concat(
    utils.map(opts.extra_args, function(k, v)
      if type(v) == "string" then
        return string.format([[%s=%s]], k, v)
      elseif type(v) == "boolean" and v == true then
        return k
      else
        return nil
      end
    end),
    " "
  )

  if event_callback_map["+before-start"] then
    invoke_event_callback(state_id, "+before-start")
  end

  -- Async will mess up the "start:pos" trigger
  local fzf_cmd = string.format(
    [[fzf --sync --listen --ansi --prompt='❯ ' --border=none --height=100%% %s --bind='%s' --delimiter='%s' %s]],
    opts.preview_cmd and string.format([[--preview='%s']], opts.preview_cmd)
      or "",
    binds_fzf_arg,
    utils.nbsp,
    extra_args -- TODO: throw warning if contains already existing args
  )

  vim.fn.termopen(
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

        local finally = function() destroy_state(state_id) end

        layout:unmount()

        if parent_state_id then
          local parent_state = get_state(parent_state_id)
          parent_state.layout:show()
          -- `enter` option of NuiPopup doesn't cater show/hide
          vim.api.nvim_set_current_win(parent_state.main_popup.winid)
          vim.defer_fn(function() vim.cmd("startinsert") end, 100) -- FIX: fragile solution
        else
          -- Restore focus to preview window
          if vim.api.nvim_win_is_valid(prev_win) then
            vim.api.nvim_set_current_win(prev_win)
          else
            vim.error("Invalid previous window", prev_win)
            finally()
            return
          end
        end

        if code == 0 then
          if event_callback_map["+select"] then
            invoke_event_callback(state_id, "+select")
          end
        elseif code == 130 then
          -- On abort
          if event_callback_map["+abort"] then
            invoke_event_callback(state_id, "+abort")
          end
        else
          vim.error(
            "Unexpected exit code on Fzf",
            "Exit code:",
            code,
            "Event:",
            event
          )
          finally()
          return
        end

        if event_callback_map["+after-exit"] then
          invoke_event_callback(state_id, "+after-exit")
        end

        finally()
      end,
    }
  )

  return state
end

return M
