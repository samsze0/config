-- https://github.com/yazi-rs/plugins/blob/main/chmod.yazi/LICENSE
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

local selected_or_hovered = ya.sync(function()
  local tab, paths = cx.active, {}
  for _, u in pairs(tab.selected) do
    paths[#paths + 1] = tostring(u)
  end
  if #paths == 0 and tab.current.hovered then
    paths[1] = tostring(tab.current.hovered.url)
  end
  return paths
end)

return {
  entry = function()
    ya.manager_emit("escape", { visual = true })

    local urls = selected_or_hovered()
    if #urls == 0 then
      return ya.notify({
        title = "Chmod",
        content = "No file selected",
        level = "warn",
        timeout = 5,
      })
    end

    local value, event = ya.input({
      title = "Chmod:",
      position = { "top-center", y = 3, w = 40 },
    })
    if event ~= 1 then return end

    local status, err = Command("chmod"):arg(value):args(urls):spawn():wait()
    if not status or not status.success then
      ya.notify({
        title = "Chmod",
        content = string.format(
          "Chmod with selected files failed, exit code %s",
          status and status.code or err
        ),
        level = "error",
        timeout = 5,
      })
    end
  end,
}
