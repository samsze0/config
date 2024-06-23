-- https://github.com/yazi-rs/plugins/tree/main/smart-filter.yazi
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

local hovered = ya.sync(function()
  local h = cx.active.current.hovered
  if not h then return {} end

  return {
    url = h.url,
    is_dir = h.cha.is_dir,
    unique = #cx.active.current.files == 1,
  }
end)

local function prompt()
  return ya.input({
    title = "Smart filter:",
    position = { "center", w = 50 },
    realtime = true,
    debounce = 0.1,
  })
end

local function entry()
  local input = prompt()

  while true do
    local value, event = input:recv()
    if event ~= 1 and event ~= 3 then
      ya.manager_emit("escape", { filter = true })
      break
    end

    ya.manager_emit("filter_do", { value, smart = true })

    local h = hovered()
    if h.unique and h.is_dir then
      ya.manager_emit("escape", { filter = true })
      ya.manager_emit("enter", { h.url })
      input = prompt()
    elseif event == 1 then
      ya.manager_emit("escape", { filter = true })
      ya.manager_emit(h.is_dir and "enter" or "open", { h.url })
    end
  end
end

return { entry = entry }
