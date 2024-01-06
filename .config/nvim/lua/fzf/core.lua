-- System dependencies: netcat-openbsd on osx and socat on linux and perl
-- FIX: opening 1 fzf after another would not startinsert

local M = {}

local config = require("fzf.config")
local utils = require("utils")
local fzf_utils = require("fzf.utils")
local uv_utils = require("utils.uv")
local helpers = require("fzf.helpers")

local request_number = 1 -- For generating unique ID for requests to fzf

local running -- There can at most be one fzf session running
local event_callback_map = {}
local response_callback_map = {}

---@alias state { port: string, query: string, focused_entry?: string, focused_entry_index?: integer, popups: NuiPopup[] }
---@type state
local state = nil

local reset_state = function()
  event_callback_map = {}
  response_callback_map = {}

  state = {
    port = nil, ---@diagnostic disable-line: assign-type-mismatch
    query = nil, ---@diagnostic disable-line: assign-type-mismatch
    focused_entry = nil, ---@diagnostic disable-line: assign-type-mismatch
    focused_entry_index = nil, ---@diagnostic disable-line: assign-type-mismatch
    popups = nil, ---@diagnostic disable-line: assign-type-mismatch
  }
end

---@return state?
M.get_state = function()
  if not running then
    vim.error("Fzf is not running")
    return
  end
  return state
end

local call_event_callback = function(event)
  local action = event_callback_map[event]
  if not action then error("Event doesn't exist in map") end

  if type(action) == "function" then
    vim.schedule(function() event_callback_map[event](state) end)
  elseif type(action) == "table" then
    for _, a in ipairs(action) do
      vim.schedule(function() a(state) end)
    end
  else
    error("Invalid fzf event callback type")
  end
end

local server_socket, server_socket_path, close_server = uv_utils.create_server(
  function(message)
    if config.debug then vim.info("Fzf server received", message) end

    if string.match(message, "^port") then
      local port = string.match(message, "^port (%d+)")
      if not port then
        vim.error("Invalid fzf port message", message)
        return
      end
      state.port = port
    elseif string.match(message, "^focus") then
      local index, selection = string.match(message, "^focus (%d+) '(.*)'")
      if not index or not selection then
        vim.error("Invalid fzf focus message", message)
        return
      end
      state.focused_entry_index = tonumber(index) + 1
      state.focused_entry = selection
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
      if event_callback_map[event] then
        call_event_callback(event)
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
      if response_callback_map[req] then
        vim.schedule(function() response_callback_map[req](content) end)
        response_callback_map[req] = nil
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

-- Send message to current Fzf instance
--
---@param message string
---@return nil
M.send_to_fzf = function(message)
  if not running then
    vim.error("Fzf is not running")
    return
  end
  if not state.port then
    vim.error("Fzf server not ready")
    return
  end
  vim.fn.system(
    string.format([[curl -X POST localhost:%s -d '%s']], state.port, message)
  )
  if vim.v.shell_error ~= 0 then error("Fail to send message to fzf") end
  if config.debug then vim.info("Sent message to fzf", message) end
end

-- Request content from current Fzf instance
--
---@param content string
---@param callback fun(response: string): nil
M.request_fzf = function(content, callback)
  if not running then
    vim.error("Fzf is not running")
    return
  end
  if not state.port then
    vim.error("Fzf server not ready")
    return
  end
  response_callback_map[tostring(request_number)] = callback
  M.send_to_fzf(
    fzf_utils.send_to_lua_action(
      string.format([[request %d %s]], request_number, content),
      server_socket_path
    )
  )
  request_number = request_number + 1
end

-- Get current selected entries
--
---@param callback fun(indices: integer[], selections: string[]): nil
---@return nil
M.get_current_selections = function(callback)
  M.request_to_fzf(fzf_utils.send_to_lua("{+n} {+}"), function(response)
    if not response then
      vim.error("Received empty fzf selections message")
      return
    end

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
---@param callback function
---@return nil
M.abort_and_execute = function(callback)
  M.send_to_fzf("abort")
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

---@return boolean
M.is_fzf_available = function() return vim.fn.executable("fzf") == 1 end

---@alias event_callback fun(state: state): nil
---@alias bind_type string | event_callback | (string | event_callback)[]
---@param input string[] | string
---@param opts? { layout?: NuiLayout, extra_args?: table<string, string>, prompt?: string, preview_cmd?: string, initial_position?: integer, binds?: table<string, bind_type> }
M.fzf = function(input, opts)
  if running then
    vim.error("Fzf is already running")
    return
  end

  reset_state()

  opts = vim.tbl_extend("force", {
    layout = nil,
    extra_args = {},
    prompt = "",
    preview_cmd = nil,
    initial_position = 0,
    binds = {},
  }, opts or {})
  ---@cast opts { layout: NuiLayout, extra_args: table<string, string>, prompt: string, preview_cmd: string, initial_position: integer, binds: table<string, bind_type> }

  if not M.is_fzf_available() then error("Fzf executable not found") end

  if not type(input) == "table" and not type(input) == "string" then
    error("Invalid input type " .. type(input))
  end

  local prev_win = vim.api.nvim_get_current_win()

  local layout = opts.layout
  if not layout then
    layout, _ = helpers.create_simple_layout()
  end

  layout:mount()

  local function prepend_actions_to_fzf_binds(event, ...)
    local new_actions = { ... }

    local action_type = type(opts.binds[event])
    if action_type == "nil" then
      opts.binds[event] = new_actions
    elseif action_type == "string" or action_type == "function" then
      opts.binds[event] = {
        unpack(new_actions),
        opts.binds[event], ---@diagnostic disable-line: assign-type-mismatch
      }
    elseif action_type == "table" then
      for i, a in pairs(new_actions) do
        table.insert(opts.binds[event], i, a) ---@diagnostic disable-line: param-type-mismatch
      end
    else
      error("Invalid fzf bind action type " .. action_type)
    end
  end

  prepend_actions_to_fzf_binds(
    "focus",
    fzf_utils.send_to_lua_action("focus {n} {}", server_socket_path)
  )
  prepend_actions_to_fzf_binds(
    "start",
    fzf_utils.send_to_lua_action(
      "port $FZF_PORT",
      server_socket_path,
      { var_expansion = true }
    ),
    string.format("pos(%d)", opts.initial_position)
  )
  prepend_actions_to_fzf_binds(
    "change",
    fzf_utils.send_to_lua_action("query {q}", server_socket_path)
  )

  local fzf_binds = {}

  local function parse_fzf_bind(event, action)
    if type(action) == "function" then
      event_callback_map[event] = action
      fzf_binds[event] = fzf_utils.send_to_lua_action(
        string.format("event %s", event),
        server_socket_path
      )
    elseif type(action) == "string" then
      fzf_binds[event] = action
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
              fzf_utils.send_to_lua_action(
                string.format("event %s", event),
                server_socket_path
              )
            )
            event_callback_action_added = true
          end
        elseif type(v) == "string" then
          table.insert(actions, v)
        else
          error("Invalid fzf bind type: " .. type(v) .. " for event " .. event)
        end
      end
      fzf_binds[event] = table.concat(actions, "+")
    else
      error("Invalid fzf bind type: " .. type(action) .. " for event " .. event)
    end
  end

  if config.debug then vim.info(opts.binds) end
  for event, action in pairs(opts.binds) do
    parse_fzf_bind(event, action)
  end
  if config.debug then vim.info(event_callback_map) end

  local binds_arg = table.concat(
    utils.map(
      utils.filter(
        fzf_binds,
        function(k, v) return string.sub(k, 1, 1) ~= "+" end
      ),
      function(k, v) return string.format([[%s:%s]], k, v) end
    ),
    ","
  )
  if config.debug then vim.info(binds_arg) end

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
    call_event_callback("+before-start")
  end

  local fzf_cmd = string.format(
    [[fzf --sync --listen --ansi --prompt='%s❯ ' --border=none --height=100%% %s --bind='%s' --delimiter='%s' %s]],
    opts.prompt, -- Async will mess up the "start:pos" trigger
    opts.preview_cmd and string.format([[--preview='%s']], opts.preview_cmd)
      or "",
    binds_arg,
    utils.nbsp,
    extra_args -- TODO: throw warning if contains already existing args
  )

  running = true

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
        running = false

        vim.cmd("silent! :checktime")

        -- Restore focus to preview window
        if vim.api.nvim_win_is_valid(prev_win) then
          layout:unmount()
          vim.api.nvim_set_current_win(prev_win)
        else
          error("Invalid previous window " .. prev_win)
        end

        if code == 0 then
          if event_callback_map["+select"] then
            call_event_callback("+select")
          end
        elseif code == 130 then
          -- On abort
          if event_callback_map["+abort"] then call_event_callback("+abort") end
        else
          vim.error(
            "Unexpected exit code on Fzf",
            "Exit code:",
            code,
            "Event:",
            event
          )
        end

        if event_callback_map["+after-exit"] then
          call_event_callback("+after-exit")
        end
      end,
    }
  )

  vim.cmd("startinsert")
end

return M
