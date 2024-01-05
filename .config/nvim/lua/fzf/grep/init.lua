local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local git_utils = require("utils.git")
local utils = require("utils")
local jumplist = require("jumplist")
local fzf_grep_utils = require("fzf.grep.utils")

local event = require("nui.utils.autocmd").event

-- TODO: no-git mode
M.grep = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
    initial_query = "",
  }, opts or {})

  local function parse_selection(selection)
    selection = selection or FZF.current_selection

    local args = vim.split(selection, utils.nbsp)
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

  local layout, popups, get_replacement = fzf_grep_utils.create_layout()

  local function reload_preview()
    fzf_grep_utils.reload_preview(popups, get_replacement(), parse_selection)
  end

  popups.replace_str:on(
    { event.TextChanged, event.TextChangedI },
    reload_preview
  )

  core.fzf({}, {
    layout = layout,
    before_fzf = function()
      helpers.set_keymaps_for_nvim_preview(popups.main, popups.nvim_preview)
      helpers.set_keymaps_for_popups_nav({
        { popup = popups.main, key = "<C-s>", is_terminal = true },
        { popup = popups.nvim_preview, key = "<C-f>", is_terminal = false },
        { popup = popups.replace_str, key = "<C-r>", is_terminal = false },
      })
    end,
    fzf_on_select = function()
      local filepath, line = parse_selection()
      jumplist.save(win)
      vim.cmd(string.format([[e %s]], filepath))
      vim.cmd(string.format([[normal! %sG]], line))
      vim.cmd([[normal! zz]])
    end,
    -- fzf_async = true,
    fzf_preview_cmd = nil,
    fzf_prompt = "Grep",
    fzf_on_focus = reload_preview,
    fzf_on_query_change = function()
      local query = FZF.current_query
      if query == "" then
        core.send_to_fzf("reload()")
        return
      end
      -- Important: most work should be carried out by the preview function
      core.send_to_fzf("reload@" .. get_cmd(query) .. "@")
      reload_preview()
    end,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-y"] = function()
        local filepath = parse_selection()
        vim.fn.setreg("+", filepath)
      end,
      ["ctrl-w"] = function()
        local filepath, line = parse_selection()
        core.abort_and_execute(function()
          vim.cmd(string.format([[vsplit %s]], filepath))
          vim.cmd(string.format([[normal! %sG]], line))
          vim.cmd([[normal! zz]])
        end)
      end,
      ["ctrl-t"] = function()
        local filepath, line = parse_selection()
        core.abort_and_execute(function()
          vim.cmd(string.format([[tabnew %s]], filepath))
          vim.cmd(string.format([[normal! %sG]], line))
          vim.cmd([[normal! zz]])
        end)
      end,
      ["ctrl-l"] = function()
        fzf_grep_utils.actions.send_selections_to_loclist(parse_selection, win)
      end,
      ["ctrl-p"] = function()
        local search = FZF.current_query
        local replacement = get_replacement()
        fzf_grep_utils.actions.send_selections_to_loclist(
          parse_selection,
          win,
          function()
            vim.cmd(string.format([[ldo %%s/%s/%s/g]], search, replacement)) -- Run substitution
          end
        )
      end,
    }),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1,3 --disabled --multi "
      .. string.format("--query='%s' ", opts.initial_query)
      .. string.format(
        "--preview-window='%s,%s'",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{2}", { fixed_header = 4 })
      ),
  })
end

M.grep_file = function(opts)
  opts = vim.tbl_extend("force", { initial_query = "" }, opts or {})

  local current_file = vim.fn.expand("%")

  local function parse_selection(selection)
    selection = selection or FZF.current_selection

    local args = vim.split(selection, utils.nbsp)
    return current_file, unpack(args)
  end

  local get_cmd = function(query)
    -- FIX: order of output is suffled when query ~= empty
    local sed_cmd = {
      string.format("s/:/%s/", utils.nbsp, utils.nbsp), -- Replace first : with nbsp
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
      [[rg %s "%s" %s | sed -E "%s"]],
      helpers.rg_default_opts,
      query,
      current_file,
      table.concat(sed_cmd, ";")
    )
  end

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  local layout, popups, get_replacement = fzf_grep_utils.create_layout()

  local function reload_preview()
    fzf_grep_utils.reload_preview(popups, get_replacement(), parse_selection)
  end

  popups.replace_str:on(
    { event.TextChanged, event.TextChangedI },
    reload_preview
  )

  core.fzf(get_cmd(""), {
    layout = layout,
    before_fzf = function()
      helpers.set_keymaps_for_nvim_preview(popups.main, popups.nvim_preview)
      helpers.set_keymaps_for_popups_nav({
        { popup = popups.main, key = "<C-s>", is_terminal = true },
        { popup = popups.nvim_preview, key = "<C-f>", is_terminal = false },
        { popup = popups.replace_str, key = "<C-r>", is_terminal = false },
      })
    end,
    fzf_on_select = function()
      local line = parse_selection()
      jumplist.save(win)
      vim.cmd(string.format([[normal! %sG]], line))
      vim.cmd([[normal! zz]])
    end,
    fzf_initial_position = vim.fn.line("."), -- Assign to current line number
    -- fzf_async = true,
    fzf_preview_cmd = nil,
    fzf_prompt = "Grep",
    fzf_on_focus = reload_preview,
    fzf_on_query_change = function()
      local query = FZF.current_query
      -- Important: most work should be carried out by the preview function
      core.send_to_fzf("reload@" .. get_cmd(query) .. "@")
      reload_preview()
    end,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-l"] = function()
        fzf_grep_utils.actions.send_selections_to_loclist(parse_selection, win)
      end,
      ["ctrl-p"] = function()
        local search = FZF.current_query
        local replacement = get_replacement()
        fzf_grep_utils.actions.send_selections_to_loclist(
          parse_selection,
          win,
          function()
            vim.cmd(string.format([[ldo %%s/%s/%s/g]], search, replacement)) -- Run substitution
          end
        )
      end,
    }),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1.. --disabled --multi "
      .. string.format("--query='%s' ", opts.initial_query)
      .. string.format(
        "--preview-window='%s,%s'",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{1}", { fixed_header = 4 })
      ),
  })
end

return M
