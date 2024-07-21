-- https://github.com/yazi-rs/plugins/blob/main/hide-preview.yazi/init.lua
--
-- MIT License
--
-- Copyright (c) 2023 yazi-rs
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local pub_event = function(payload) ps.pub("preview-visibility", payload) end
local show = function(state)
  if not state.prev_layout then
    ya.err("preview is already shown")
    return
  end
  Tab.layout, state.prev_layout = state.prev_layout, nil
  ya.app_emit("resize", {})
  pub_event({ visible = true })
end
local hide = function(state)
  if state.prev_layout then
    ya.err("preview is already hidden")
    return
  end
  state.prev_layout = Tab.layout
  Tab.layout = function(self, area)
    self.area = area

    local all = MANAGER.ratio.parent + MANAGER.ratio.current
    self._chunks = ui.Layout()
      :direction(ui.Layout.HORIZONTAL)
      :constraints({
        ui.Constraint.Ratio(MANAGER.ratio.parent, all),
        ui.Constraint.Ratio(MANAGER.ratio.current, all),
        ui.Constraint.Length(0),
      })
      :split(self._area)
  end
  ya.app_emit("resize", {})
  pub_event({ visible = false })
end

local function entry(state, args)
  local action = args[1]
  if not action then
    ya.err("action not given")
    return
  end

  ---@type boolean
  local should_show
  if action == "show" then
    should_show = true
  elseif action == "hide" then
    should_show = false
  elseif action == "toggle" then
    should_show = state.prev_layout ~= nil
  else
    ya.err("unknown action: " .. action)
    return
  end

  local is_shown = state.prev_layout == nil
  if should_show ~= is_shown then
    if should_show then
      show(state)
    else
      hide(state)
    end
  end
end

return {
  entry = entry,
  setup = function() pub_event({ visible = true }) end,
}
