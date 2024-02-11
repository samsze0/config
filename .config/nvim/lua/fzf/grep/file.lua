local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local jumplist = require("jumplist")
local shared = require("fzf.grep.shared")

local event = require("nui.utils.autocmd").event

-- Grep current file
--
---@param opts? { initial_query?: string }
local grep_file = function(opts)
  opts = vim.tbl_extend("force", { initial_query = "" }, opts or {})

  local current_file = vim.fn.expand("%")

  local function parse_entry(entry)
    local args = vim.split(entry, utils.nbsp)
    return current_file, unpack(args)
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

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

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
          { popup = popups.replace_str, key = "<C-r>", is_terminal = false },
        })

        popups.replace_str:on(
          { event.TextChanged, event.TextChangedI },
          function() reload_preview(state) end
        )
      end,
      ["+select"] = function(state)
        local line = parse_entry(state.focused_entry)
        jumplist.save(win)
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
        shared.actions.send_current_selections_to_loclist(
          state.id,
          parse_entry,
          win
        )
      end,
      ["ctrl-p"] = function(state)
        local search = state.query
        local replacement = get_replacement()
        shared.actions.send_current_selections_to_loclist(
          state.id,
          parse_entry,
          win,
          function()
            vim.cmd(string.format([[ldo %%s/%s/%s/g]], search, replacement)) -- Run substitution
          end
        )
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
