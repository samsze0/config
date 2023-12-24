local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local uv = vim.loop
local uv_utils = require("utils.uv")
local jumplist = require("jumplist")

-- TODO: no-git mode
M.grep = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = fzf_utils.git_root_dir(),
  }, opts or {})

  local function get_info_from_selection()
    local selection = FZF_STATE.current_selection

    local args = vim.split(selection, utils.nbsp)
    return unpack(args)
  end

  local files = fzf_utils.git_files(
    opts.git_dir,
    { return_as_cmd = false, convert_gitpaths_to_relpaths = true }
  )
  files = utils.map(files, function(_, e) return [["]] .. e .. [["]] end)
  local files_str = table.concat(files, " ")

  local get_cmd = function(query)
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
      [[rg %s "%s" %s | sed "%s"]],
      helpers.rg_default_opts,
      query,
      files_str,
      table.concat(sed_cmd, ";")
    )
  end

  local win_id = vim.api.nvim_get_current_win()

  core.fzf({}, {
    fzf_on_select = function()
      local filepath, line = get_info_from_selection()
      jumplist.save(win_id)
      vim.cmd(string.format([[e %s]], filepath))
      vim.cmd(string.format([[normal! %sG]], line))
      vim.cmd([[normal! zz]])
    end,
    -- fzf_async = true,
    fzf_preview_cmd = string.format(
      [[bat %s --highlight-line {2} {1}]],
      helpers.bat_default_opts
    ),
    fzf_prompt = "Grep",
    fzf_on_focus = function() end,
    fzf_on_query_change = function()
      local query = FZF_STATE.current_query
      if query == "" then
        core.send_to_fzf("reload()")
        return
      end
      -- Important: most work should be carried out by the preview function
      core.send_to_fzf("reload@" .. get_cmd(query) .. "@")
    end,
    before_fzf = helpers.set_custom_keymaps_for_fzf_preview,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-y"] = function()
        local filepath = get_info_from_selection()
        vim.fn.setreg("+", filepath)
      end,
      ["ctrl-w"] = function()
        local filepath, line = get_info_from_selection()
        core.abort_and_execute(function()
          vim.cmd(string.format([[vsplit %s]], filepath))
          vim.cmd(string.format([[normal! %sG]], line))
          vim.cmd([[normal! zz]])
        end)
      end,
      ["ctrl-t"] = function()
        local filepath, line = get_info_from_selection()
        core.abort_and_execute(function()
          vim.cmd(string.format([[tabnew %s]], filepath))
          vim.cmd(string.format([[normal! %sG]], line))
          vim.cmd([[normal! zz]])
        end)
      end,
    }),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1,3 --disabled "
      .. string.format(
        "--preview-window='%s,%s'",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{2}", { fixed_header = 4 })
      ),
  })
end

M.grep_file = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local current_file = vim.fn.expand("%")

  local function get_info_from_selection()
    local selection = FZF_STATE.current_selection

    local args = vim.split(selection, utils.nbsp)
    return unpack(args)
  end

  local get_cmd = function(query)
    return string.format(
      -- Custom delimiters & strip out ANSI color codes with sed
      [[rg %s "%s" "%s" | sed "%s"]], -- TODO: order of output is suffled
      helpers.rg_default_opts,
      query,
      current_file,
      string.format(
        string.rep("%s", 3, ";"),
        [[s/\x1b\[[0-9;]*m//g]], -- Strip out ANSI color codes
        string.format(
          [[s/^\([^:]*\):/%s\1%s:/]],
          utils.ansi_escseq.grey,
          utils.ansi_escseq.clear
        ), -- Highlight first part with grey
        string.format("s/:/%s/", utils.nbsp, utils.nbsp) -- Replace first : with nbsp
      )
    )
  end

  local win_id = vim.api.nvim_get_current_win()

  core.fzf(get_cmd(""), {
    fzf_on_select = function()
      local line = get_info_from_selection()
      jumplist.save(win_id)
      vim.cmd(string.format([[normal! %sG]], line))
      vim.cmd([[normal! zz]])
    end,
    fzf_initial_position = vim.fn.line("."), -- Assign to current line number
    -- fzf_async = true,
    fzf_preview_cmd = string.format(
      [[bat %s --highlight-line {1} %s]],
      helpers.bat_default_opts,
      current_file
    ),
    fzf_prompt = "Grep",
    fzf_on_focus = function() end,
    fzf_on_query_change = function()
      local query = FZF_STATE.current_query
      -- Important: most work should be carried out by the preview function
      core.send_to_fzf("reload@" .. get_cmd(query) .. "@")
    end,
    before_fzf = helpers.set_custom_keymaps_for_fzf_preview,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {}),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1.. "
      .. string.format(
        "--preview-window='%s,%s'",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{1}", { fixed_header = 4 })
      ),
  })
end

return M
