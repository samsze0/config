-- https://github.com/Rolv-Apneseth/starship.yazi
--
-- MIT License
--
-- Copyright (c) 2024 Rolv Apneseth
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

local save = ya.sync(function(state, cwd, output)
  if cx.active.current.cwd == Url(cwd) then
    state.output = output
    ya.render()
  end
end)

return {
  setup = function(state)
    Header.cwd = function()
      local cwd = cx.active.current.cwd
      if state.cwd ~= cwd then
        state.cwd = cwd
        ya.manager_emit(
          "plugin",
          { state._name, args = ya.quote(tostring(cwd)) }
        )
      end

      return ui.Line.parse(state.output or "")
    end
  end,

  entry = function(_, args)
    local output = Command("starship")
      :arg("prompt")
      :cwd(args[1])
      :env("STARSHIP_SHELL", "")
      :output()
    if output then save(args[1], output.stdout:gsub("^%s+", "")) end
  end,
}
