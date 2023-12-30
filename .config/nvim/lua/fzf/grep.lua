local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local uv = vim.loop
local uv_utils = require("utils.uv")
local jumplist = require("jumplist")
local fzf_misc = require("fzf.misc")

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local function create_layout()
  local main_popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
    },
    buf_options = {
      modifiable = false,
      filetype = "fzf",
    },
    win_options = {
      winblend = 0,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    },
  })

  local nvim_preview_popup = Popup({
    enter = false,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = " Preview ",
      },
    },
    buf_options = {
      modifiable = true,
    },
    win_options = {
      winblend = 0,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      number = true,
      cursorline = true,
    },
  })

  local replace_str_popup = Popup({
    enter = false,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = " Replacement ",
      },
    },
    buf_options = {
      modifiable = true,
    },
    win_options = {
      winblend = 0,
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      number = true,
    },
  })

  local popups = {
    main = main_popup,
    nvim_preview = nvim_preview_popup,
    replace_str = replace_str_popup,
  }

  local layout = Layout(
    {
      position = "50%",
      relative = "editor",
      size = {
        width = "90%",
        height = "90%",
      },
    },
    Layout.Box({
      Layout.Box(main_popup, { size = "50%" }),
      Layout.Box({
        Layout.Box(replace_str_popup, { size = "20%" }),
        Layout.Box(nvim_preview_popup, { grow = 1 }),
      }, { size = "50%", dir = "col" }),
    }, { dir = "row" })
  )

  for _, popup in pairs(popups) do
    popup:on("BufLeave", function()
      vim.schedule(function()
        local curr_bufnr = vim.api.nvim_get_current_buf()
        for _, p in pairs(popups) do
          if p.bufnr == curr_bufnr then return end
        end
        layout:unmount()
      end)
    end)
  end

  return layout, popups
end

-- TODO: no-git mode
M.grep = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = fzf_utils.git_root_dir(),
    initial_query = "",
  }, opts or {})

  local function parse_selection(selection)
    selection = selection or FZF.current_selection

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

  local layout, popups = create_layout()

  local function reload_preview()
    if not FZF.current_selection then return end

    local filepath, row, _ = parse_selection()
    local filename = vim.fn.fnamemodify(filepath, ":t")
    local filecontent = vim.fn.readfile(filepath)
    local replacement = table.concat(
      -- Retrieve all lines (possibly modified)
      vim.fn.getbufline(popups.replace_str.bufnr, 1, "$"),
      "\r"
    )
    local current_win = vim.api.nvim_get_current_win()

    local ft = vim.filetype.match({
      filename = filename,
      contents = filecontent,
    })

    local filecontent_after
    if #replacement > 0 then
      filecontent_after = vim.fn.systemlist(
        string.format(
          [[cat "%s" | sed -E "%ss/%s/%s/g"]],
          filepath,
          row,
          FZF.current_query,
          replacement
        )
      )
      if vim.v.shell_error ~= 0 then
        vim.notify(
          "Error while trying to perform sed substitution",
          vim.log.levels.ERROR
        )
        return
      end
    end

    vim.api.nvim_buf_set_lines(
      popups.nvim_preview.bufnr,
      0,
      -1,
      false,
      #replacement > 0 and filecontent_after or filecontent
    )
    vim.bo[popups.nvim_preview.bufnr].filetype = ft

    -- Switch to preview window and back in order to refresh scrollbar
    vim.api.nvim_set_current_win(popups.nvim_preview.winid)
    vim.fn.cursor({ row, 0 })
    vim.cmd([[normal! zz]])
    vim.api.nvim_set_current_win(current_win)
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
      jumplist.save(win_id)
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
      ["ctrl-p"] = function()
        core.get_current_selections(function(indices, selections)
          local entries = utils.map(selections, function(_, s)
            local filepath, line, text = parse_selection(s)

            -- :h setqflist
            return {
              filename = filepath,
              lnum = line,
              col = 0,
              text = text,
            }
          end)

          core.abort_and_execute(function()
            vim.fn.setloclist(win_id, entries)
            -- vim.cmd([[ldo]])
            fzf_misc.loclist()
          end)
        end)
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

  local function parse_selection()
    local selection = FZF.current_selection

    local args = vim.split(selection, utils.nbsp)
    return unpack(args)
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
      [[rg %s "%s" %s | sed "%s"]],
      helpers.rg_default_opts,
      query,
      current_file,
      table.concat(sed_cmd, ";")
    )
  end

  local win_id = vim.api.nvim_get_current_win()

  local layout, popups = create_layout()

  local function reload_preview()
    local row, _ = parse_selection()
    local filename = vim.fn.fnamemodify(current_file, ":t")
    local filecontent = vim.fn.readfile(current_file)
    local replacement = table.concat(
      -- Retrieve all lines (possibly modified)
      vim.fn.getbufline(popups.replace_str.bufnr, 1, "$"),
      "\r"
    )
    local current_win = vim.api.nvim_get_current_win()

    local ft = vim.filetype.match({
      filename = filename,
      contents = filecontent,
    })

    local filecontent_after
    if #replacement > 0 then
      filecontent_after = vim.fn.systemlist(
        string.format(
          [[cat "%s" | sed -E "%ss/%s/%s/g"]],
          current_file,
          row,
          FZF.current_query,
          replacement
        )
      )
      if vim.v.shell_error ~= 0 then
        vim.notify(
          "Error while trying to perform sed substitution " .. vim.v.shell_error,
          vim.log.levels.ERROR
        )
        return
      end
    end

    vim.api.nvim_buf_set_lines(
      popups.nvim_preview.bufnr,
      0,
      -1,
      false,
      #replacement > 0 and filecontent_after or filecontent
    )
    vim.bo[popups.nvim_preview.bufnr].filetype = ft

    -- Switch to preview window and back in order to refresh scrollbar
    vim.api.nvim_set_current_win(popups.nvim_preview.winid)
    vim.fn.cursor({ row, 0 })
    vim.cmd([[normal! zz]])
    vim.api.nvim_set_current_win(current_win)
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
      jumplist.save(win_id)
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
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {}),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1.. "
      .. string.format("--query='%s' ", opts.initial_query)
      .. string.format(
        "--preview-window='%s,%s'",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{1}", { fixed_header = 4 })
      ),
  })
end

return M
