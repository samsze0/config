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

local pub_event = function(payload) ps.pub("preview", payload) end

local function entry(state)
  if state.prev_layout then
    Manager.layout, state.prev_layout = state.prev_layout, nil
    pub_event({ visible = true })
  else
    state.prev_layout = Manager.layout
    Manager.layout = function(self, area)
      self.area = area

      local all = MANAGER.ratio.parent + MANAGER.ratio.current
      return ui.Layout()
        :direction(ui.Layout.HORIZONTAL)
        :constraints({
          ui.Constraint.Ratio(MANAGER.ratio.parent, all),
          ui.Constraint.Ratio(MANAGER.ratio.current, all),
          ui.Constraint.Length(0),
        })
        :split(area)
    end
    pub_event({ visible = false })
  end
  ya.app_emit("resize", {})
end

return { entry = entry }
