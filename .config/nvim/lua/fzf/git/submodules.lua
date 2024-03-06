local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local layouts = require("fzf.layouts")
local utils = require("utils")
local git_utils = require("utils.git")

-- Fzf all git submodules
--
---@param on_submodule function
local git_submodules = function(on_submodule)
  local submodules =
    utils.systemlist([[git submodule --quiet foreach 'echo $path']])

  submodules = utils.map(submodules, function(_, e) return vim.trim(e) end)

  local git_dir = git_utils.current_git_dir()

  local function parse_entry(entry)
    local submodule_path = entry
    submodule_path = git_dir .. "/" .. submodule_path

    return submodule_path
  end

  local layout, popups, set_preview_content, binds =
    layouts.create_nvim_preview_layout({ preview_in_terminal_mode = true })

  core.fzf(submodules, {
    prompt = "Git-Submodules",
    layout = layout,
    main_popup = popups.main,
    binds = fzf_utils.bind_extend(binds, {
      ["+before-start"] = function(state)
        popups.main.border:set_text("bottom", " <y> copy path ")
      end,
      ["focus"] = function(state)
        local submodule_path = parse_entry(state.focused_entry)

        popups.nvim_preview.border:set_text(
          "top",
          " " .. git_utils.convert_filepath_to_gitpath(submodule_path) .. " "
        )

        local log = utils.systemlist(
          string.format("git -C %s log --color --decorate", submodule_path)
        )
        set_preview_content(log)
      end,
      ["+select"] = function(state)
        local submodule_path = parse_entry(state.focused_entry)
        on_submodule(submodule_path)
      end,
      ["ctrl-y"] = function(state)
        local submodule_path = parse_entry(state.focused_entry)

        vim.fn.setreg("+", submodule_path)
        vim.info(string.format([[Copied to clipboard: %s]], submodule_path))
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
    }),
  })
end

return git_submodules
