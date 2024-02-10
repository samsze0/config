local core = require("fzf.core")
local fzf_utils = require("fzf.utils")
local helpers = require("fzf.helpers")
local utils = require("utils")

local fn = vim.fn

-- Fzf buffers
return function()
  local initial_pos = fn.bufnr()

  local function get_entries()
    local current_buf = fn.bufnr()

    local entries = utils.map(fn.getbufinfo({ buflisted = 1 }), function(i, buf)
      local bufnr = buf.bufnr
      local full_bufname = buf.name
      local bufname = vim.fn.fnamemodify(full_bufname, ":~:.")
      local modified = buf.changed == 1
      local readonly = buf.readonly == 1
      local buftype = buf.buftype
      local modified_icon = modified and "  " or ""

      local readonly_icon = readonly and "  " or ""
      local icon = modified_icon .. readonly_icon

      if bufnr == current_buf then initial_pos = i end

      return fzf_utils.join_by_delim(
        bufnr,
        full_bufname,
        utils.ansi_codes.blue(bufname .. icon)
      )
    end)

    return entries
  end

  local parse_entry = function(entry)
    return unpack(vim.split(entry, utils.nbsp))
  end

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout({
      preview_popup_win_options = {},
    })

  core.fzf(get_entries(), {
    prompt = "Buffers",
    layout = layout,
    initial_position = initial_pos,
    binds = {
      ["+before-start"] = function(state)
        helpers.set_keymaps_for_preview_remote_nav(
          popups.main,
          popups.nvim_preview
        )
        helpers.set_keymaps_for_popups_nav({
          { popup = popups.main, key = "<C-s>", is_terminal = true },
          {
            popup = popups.nvim_preview,
            key = "<C-f>",
            is_terminal = false,
          },
        })
      end,
      ["focus"] = function(state)
        local bufnr, filepath = parse_entry(state.focused_entry)

        popups.nvim_preview.border:set_text(
          "top",
          " " .. vim.fn.fnamemodify(filepath, ":t") .. " "
        )

        helpers.preview_file(filepath, popups.nvim_preview)
      end,
      ["ctrl-x"] = function(state)
        local bufnr = parse_entry(state.focused_entry)

        vim.cmd(string.format([[bdelete %s]], bufnr))
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
      ["+select"] = function(state)
        local bufnr = parse_entry(state.focused_entry)

        vim.cmd(string.format([[buffer %s]], bufnr))
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1,3",
    }),
  })
end
