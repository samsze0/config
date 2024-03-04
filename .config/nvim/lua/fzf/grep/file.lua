local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local jumplist = require("jumplist")
local shared = require("fzf.grep.shared")
local fzf_misc = require("fzf.misc")

local event = require("nui.utils.autocmd").event

-- Grep current file
--
---@param opts? { initial_query?: string }
local grep_file = function(opts)
  opts = vim.tbl_extend("force", { initial_query = "" }, opts or {})

  local current_file = vim.fn.expand("%")
  local filename = vim.fn.fnamemodify(current_file, ":t")
  local filecontent = vim.fn.readfile(current_file)

  local function parse_entry(entry)
    local args = vim.split(entry, utils.nbsp)
    return unpack(args)
  end

  local get_cmd = function(query)
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

  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()

  local layout, popups, get_replacement, set_preview_content =
    shared.create_layout()

  ---@param state state
  local function reload_preview(state)
    local row = parse_entry(state.focused_entry)

    local replacement = get_replacement()

    if #replacement > 0 then
      local filecontent_after = utils.systemlist(
        string.format(
          [[cat "%s" | sed -E "%ss/%s/%s/g"]],
          current_file,
          row,
          state.query,
          replacement
        )
      )

      vim.api.nvim_buf_set_lines(
        popups.nvim_preview.bufnr,
        0,
        -1,
        false,
        filecontent_after
      )
    else
      vim.api.nvim_buf_set_lines(
        popups.nvim_preview.bufnr,
        0,
        -1,
        false,
        filecontent
      )
    end

    local current_win = vim.api.nvim_get_current_win()

    -- Switch to preview window and back in order to refresh scrollbar
    vim.api.nvim_set_current_win(popups.nvim_preview.winid)
    vim.fn.cursor({ row, 0 })
    vim.cmd([[normal! zz]])
    vim.api.nvim_set_current_win(current_win)
  end

  core.fzf(get_cmd(""), {
    prompt = "Grep-File",
    layout = layout,
    main_popup = popups.main,
    initial_position = vim.fn.line("."), -- Assign to current line number
    binds = {
      ["+before-start"] = function(state)
        helpers.set_keymaps_for_preview_remote_nav(
          popups.main,
          popups.nvim_preview
        )
        helpers.set_keymaps_for_popups_nav({
          { popup = popups.main, key = "<C-s>", is_terminal = true },
          { popup = popups.nvim_preview, key = "<C-f>", is_terminal = false },
          { popup = popups.replace, key = "<C-r>", is_terminal = false },
        })

        local ft = vim.filetype.match({
          filename = filename,
          contents = filecontent,
        })

        if ft then vim.bo[popups.nvim_preview.bufnr].filetype = ft end

        popups.replace:on(
          { event.TextChanged, event.TextChangedI },
          function() reload_preview(state) end
        )

        popups.main.border:set_text(
          "bottom",
          " <select> goto | <l> loclist | <p> replace "
        )
      end,
      ["+select"] = function(state)
        local line = parse_entry(state.focused_entry)

        jumplist.save(current_win)
        vim.cmd(string.format([[normal! %sG]], line))
        vim.cmd([[normal! zz]])
      end,
      ["focus"] = function(state) reload_preview(state) end,
      ["change"] = function(state)
        local query = state.query

        -- Important: most work should be carried out by the preview function
        core.send_to_fzf(state.id, "reload@" .. get_cmd(query) .. "@")
        reload_preview(state)
      end,
      ["ctrl-l"] = function(state)
        core.get_current_selections(state.id, function(indices, selections)
          local entries = utils.map(selections, function(_, s)
            local line, text = parse_entry(s)

            -- :h setqflist
            return {
              filename = current_file,
              lnum = line,
              col = 0,
              text = text,
            }
          end)

          core.abort_and_execute(state.id, function()
            local current_win = vim.api.nvim_get_current_win()
            vim.fn.setloclist(current_win, entries)
            fzf_misc.loclist()
          end)
        end)
      end,
      ["ctrl-p"] = function(state)
        local search = state.query
        local replacement = get_replacement()

        core.get_current_selections(state.id, function(indices, selections)
          local entries = utils.map(selections, function(_, s)
            local line, text = parse_entry(s)

            -- :h setqflist
            return {
              filename = current_file,
              lnum = line,
              col = 0,
              text = text,
            }
          end)

          core.abort_and_execute(state.id, function()
            local current_win = vim.api.nvim_get_current_win()
            vim.fn.setloclist(current_win, entries)
            vim.cmd(string.format([[ldo %%s/%s/%s/g]], search, replacement)) -- Run substitution
            fzf_misc.loclist()
          end)
        end)
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
      ["--disabled"] = true,
      ["--multi"] = true,
      ["--query"] = string.format([['%s']], opts.initial_query),
    }),
  })
end

return grep_file
