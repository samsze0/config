local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local git_utils = require("utils.git")
local utils = require("utils")
local jumplist = require("jumplist")
local shared = require("fzf.grep.shared")
local fzf_misc = require("fzf.misc")

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

  local layout, popups, get_replacement, set_preview_content, binds =
    shared.create_layout()

  ---@param state state
  local function reload_preview(state)
    local current_win = vim.api.nvim_get_current_win()

    if state.focused_entry == nil or state.focused_entry == "" then
      set_preview_content({})
      return
    end

    local filepath, row = parse_entry(state.focused_entry)
    local filename = vim.fn.fnamemodify(filepath, ":t")
    local filecontent = vim.fn.readfile(filepath)

    local ft = vim.filetype.match({
      filename = filename,
      contents = filecontent,
    })

    local replacement = get_replacement()

    if #replacement > 0 then
      local filecontent_after = utils.systemlist(
        string.format(
          [[cat "%s" | sed -E "%ss/%s/%s/g"]],
          filepath,
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

    if ft then vim.bo[popups.nvim_preview.bufnr].filetype = ft end

    -- Switch to preview window and back in order to refresh scrollbar
    vim.api.nvim_set_current_win(popups.nvim_preview.winid)
    vim.fn.cursor({ row, 0 })
    vim.cmd([[normal! zz]])
    vim.api.nvim_set_current_win(current_win)
  end

  core.fzf(
    get_cmd(""),
    { -- FIX: if input is empty {} (or just simple things like {'a', 'b', 'c'} or "a\nb\nc") then the BufEnter event doesn't trigger
      prompt = "Grep",
      layout = layout,
      main_popup = popups.main,
      binds = fzf_utils.bind_extend(binds, {
        ["+before-start"] = function(state)
          popups.replace:on(
            { event.TextChanged, event.TextChangedI },
            function() reload_preview(state) end
          )

          popups.main.border:set_text(
            "bottom",
            " <select> goto | <w> goto (window) | <t> goto (tab) "
          )
          popups.nvim_preview.border:set_text(
            "bottom",
            " <l> loclist | <p> replace | <y> copy path "
          )
        end,
        ["+select"] = function(state)
          local filepath, line = parse_entry(state.focused_entry)
          local current_win = vim.api.nvim_get_current_win()
          jumplist.save(current_win)
          vim.cmd(string.format([[e %s]], filepath))
          vim.cmd(string.format([[normal! %sG]], line))
          vim.cmd([[normal! zz]])
        end,
        ["focus"] = function(state) reload_preview(state) end,
        ["change"] = function(state)
          local query = state.query
          if query == "" then
            core.send_to_fzf(state.id, "reload()")
            return
          end
          -- Important: most work should be carried out by the preview function
          core.request_fzf(
            state.id,
            "reload@" .. get_cmd(query) .. "@",
            nil,
            function(response)
              core.send_to_fzf(
                state.id,
                core.send_to_lua_action(state.id, "focus {n} {}")
              )
            end
          )
        end,
        ["ctrl-y"] = function(state)
          local filepath = parse_entry(state.focused_entry)
          vim.fn.setreg("+", filepath)
          vim.info(string.format([[Copied %s to clipboard]], filepath))
        end,
        ["ctrl-w"] = function(state)
          local filepath, line = parse_entry(state.focused_entry)
          core.abort_and_execute(state.id, function()
            vim.cmd(string.format([[vsplit %s]], filepath))
            vim.cmd(string.format([[normal! %sG]], line))
            vim.cmd([[normal! zz]])
          end)
        end,
        ["ctrl-t"] = function(state)
          local filepath, line = parse_entry(state.focused_entry)
          core.abort_and_execute(state.id, function()
            vim.cmd(string.format([[tabnew %s]], filepath))
            vim.cmd(string.format([[normal! %sG]], line))
            vim.cmd([[normal! zz]])
          end)
        end,
        ["ctrl-l"] = function(state)
          core.get_current_selections(state.id, function(indices, selections)
            local entries = utils.map(selections, function(_, s)
              local filepath, line, text = parse_entry(s)

              -- :h setqflist
              return {
                filename = filepath,
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
              local filepath, line, text = parse_entry(s)

              -- :h setqflist
              return {
                filename = filepath,
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
      }),
      extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
        ["--with-nth"] = "1,3..",
        ["--disabled"] = true,
        ["--multi"] = true,
        ["--query"] = string.format([['%s']], opts.initial_query),
      }),
    }
  )
end

return grep
