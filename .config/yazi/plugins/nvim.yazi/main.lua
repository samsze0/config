local is_active = os.getenv("NVIM_YAZI")

local pub_event = function(payload) ps.pub("to-nvim", payload) end

local function entry(state, args)
  local action = args[1]
  if not action then
    ya.err("action not given")
    return
  end

  if action == "quit" then
    if is_active then
      pub_event({ type = "quit" })
    else
      ya.manager_emit("quit", {})
    end
    return
  elseif action == "open" then
    if is_active then
      pub_event({ type = "open" })
    else
      ya.manager_emit("open", {})
    end
    return
  elseif action == "scroll-preview" then
    local scroll_units = tonumber(args[2])
    if not scroll_units then
      ya.err("scroll units not given or is invalid")
      return
    end

    if is_active then
      pub_event({ type = "scroll-preview", value = scroll_units })
    else
      ya.manager_emit("seek", { scroll_units })
    end
    return
  end

  ya.err("unknown action: " .. action)
end

return {
  entry = entry,
  setup = function(state)
    ps.sub_remote("from-nvim", function(payload)
      if type(payload.type) ~= "string" then
        ya.err("invalid payload. invalid event type")
        return
      end

      if payload.type == "preview-visibility" then
        if
          type(payload.value) ~= "string"
          or (
            payload.value ~= "show"
            and payload.value ~= "hide"
            and payload.value ~= "toggle"
          )
        then
          ya.err(
            ("invalid payload. invalid value for preview-visibility: '%s'"):format(
              payload.value
            )
          )
          return
        end
        ya.manager_emit(
          "plugin",
          { "preview-visibility", sync = true, args = payload.value }
        )
        return
      elseif payload.type == "reveal" then
        if type(payload.path) ~= "string" then
          ya.err("invalid payload for reveal event")
          return
        end
        -- TODO: validate path
        ya.manager_emit("reveal", { payload.path })
        return
      end

      ya.err("unknown event type: " .. payload.type)
    end)
  end,
}
