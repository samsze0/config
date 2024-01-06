local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local git_utils = require("utils.git")
local utils = require("utils")
local jumplist = require("jumplist")
local shared = require("fzf.grep.shared")

local event = require("nui.utils.autocmd").event

-- TODO: no-git mode

-- Grep all git files
--
---@param opts? { git_dir?: string, initial_query?: string }
local grep = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
    initial_query = "",
  }, opts or {})

  local function parse_entry(entry)
    local args = vim.split(entry, utils.nbsp)
    return unpack(args)
  end

  local get_cmd = function(query)
    local files_cmd = git_utils.git_files(
      opts.git_dir,
      { return_as_cmd = true, filter_directories = false }
    ) -- FIX: filter_directories

    local sed_cmd = {
      string.format("s/:/%s/;s/:/%s/", utils.nbsp, utils.nbsp), -- Replace first two : with nbsp
    }

    if not helpers.use_rg_colors then
      table.insert(
        sed_cmd,
        1,
        string.format(
          [[s/^\([^:]*\):/%s\1%s:/]],
          utils.ansi_escseq.grey,
          utils.ansi_escseq.clear
        ) -- Highlight first part with grey
      )
    end

    return string.format(
      -- Custom delimiters & strip out ANSI color codes with sed
      -- TODO: only support when pwd == git_dir
      [[rg %s "%s" $(%s) | sed -E "%s"]],
      helpers.rg_default_opts,
      query,
      files_cmd,
      table.concat(sed_cmd, ";")
    )
  end

  local win = vim.api.nvim_get_current_win()

  local layout, popups, get_replacement = shared.create_layout()

  local function reload_preview(state)
    shared.reload_preview(
      popups,
      get_replacement(),
      parse_entry,
      state.focused_entry,
      state.query
    )
  end

  popups.replace_str:on(
    { event.TextChanged, event.TextChangedI },
    function() reload_preview(core.get_state()) end
  )

  core.fzf({}, {
    prompt = "Grep",
    layout = layout,
    binds = vim.tbl_extend("force", helpers.default_fzf_keybinds, {
      ["+before-start"] = function(state)
        helpers.set_keymaps_for_preview_remote_nav(
          popups.main,
          popups.nvim_preview
        )
        helpers.set_keymaps_for_popups_nav({
          { popup = popups.main, key = "<C-s>", is_terminal = true },
          { popup = popups.nvim_preview, key = "<C-f>", is_terminal = false },
          { popup = popups.replace_str, key = "<C-r>", is_terminal = false },
        })
      end,
      ["+select"] = function(state)
        local filepath, line = parse_entry(state.focused_entry)
        jumplist.save(win)
        vim.cmd(string.format([[e %s]], filepath))
        vim.cmd(string.format([[normal! %sG]], line))
        vim.cmd([[normal! zz]])
      end,
      ["focus"] = function(state) reload_preview(state) end,
      ["change"] = function(state)
        local query = state.query
        if query == "" then
          core.send_to_fzf("reload()")
          return
        end
        -- Important: most work should be carried out by the preview function
        core.send_to_fzf("reload@" .. get_cmd(query) .. "@")
        reload_preview(state)
      end,
      ["ctrl-y"] = function(state)
        local filepath = parse_entry(state.focused_entry)
        vim.fn.setreg("+", filepath)
        vim.info(string.format([[Copied %s to clipboard]], filepath))
      end,
      ["ctrl-w"] = function(state)
        local filepath, line = parse_entry(state.focused_entry)
        core.abort_and_execute(function()
          vim.cmd(string.format([[vsplit %s]], filepath))
          vim.cmd(string.format([[normal! %sG]], line))
          vim.cmd([[normal! zz]])
        end)
      end,
      ["ctrl-t"] = function(state)
        local filepath, line = parse_entry(state.focused_entry)
        core.abort_and_execute(function()
          vim.cmd(string.format([[tabnew %s]], filepath))
          vim.cmd(string.format([[normal! %sG]], line))
          vim.cmd([[normal! zz]])
        end)
      end,
      ["ctrl-l"] = function()
        shared.actions.send_selections_to_loclist(parse_entry, win)
      end,
      ["ctrl-p"] = function(state)
        local search = state.query
        local replacement = get_replacement()
        shared.actions.send_selections_to_loclist(parse_entry, win, function()
          vim.cmd(string.format([[ldo %%s/%s/%s/g]], search, replacement)) -- Run substitution
        end)
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1,3..",
      ["--disabled"] = true,
      ["--multi"] = true,
      ["--query"] = string.format([['%s']], opts.initial_query),
      ["--preview-window"] = string.format(
        [['%s,%s']],
        helpers.fzf_default_preview_window_args,
        fzf_utils.preview_offset("{2}", { fixed_header = 4 })
      ),
    }),
  })
end

return grep
