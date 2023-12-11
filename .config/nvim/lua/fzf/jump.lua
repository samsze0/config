local M = {}

local core = require("fzf.core")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")

local fn = vim.fn

M.jumps = function()
  local fzf_initial_pos

  local function get_entries()
    -- Get all jumps
    local jumplist_extra_info = fn.getjumplist()
    local jumps_extra = jumplist_extra_info[1]
    -- local jumps_extra = utils.reverse(jumplist_extra_info[1]) -- Doesn't contain jump no.
    local current_jump = jumplist_extra_info[2]

    local jumplist_info = vim.split(vim.fn.execute("jumps"), "\n")
    -- jumplist_info = utils.reverse(jumplist_info)
    -- Remove first two lines
    table.remove(jumplist_info, 1)
    table.remove(jumplist_info, 1)
    local jumps = utils.map(jumplist_info, function(i, e)
      local match = string.match(e, "^>(.*)$")
      if match and match == "" then
        current_jump = -1
        return nil
      elseif match and #match > 0 then
        e = string.sub(e, 2) -- Remove > and continue
      end
      local selected = match

      e = vim.trim(e)
      local parts = utils.split_string_n(e, 3)
      if parts then
        local jump_nr = tonumber(parts[1])
        if jump_nr == current_jump then fzf_initial_pos = i end

        local row = tonumber(parts[2])
        local col = tonumber(parts[3])

        if row ~= jumps_extra[i].lnum or col ~= jumps_extra[i].col then
          vim.notify(
            string.format(
              "Jump list entry mismatch: row %s ~= %s ; col %s ~= %s",
              row,
              jumps_extra[i].lnum,
              col,
              jumps_extra[i].col
            ),
            vim.log.levels.ERROR
          )
          return nil
        end

        return {
          jump = jump_nr,
          row = row,
          col = col,
          bufnr = jumps_extra[i].bufnr,
          -- file_or_text = parts[4],
        }
      else
        vim.notify("Unexpected jump list entry: " .. e, vim.log.levels.ERROR)
        return nil
      end
    end)

    utils.filter(jumps, function(e) return e ~= nil end)

    local entries = utils.map(jumps, function(_, j)
      -- TODO: show lsp context e.g. foo > bar
      local bufname = fn.bufname(j.bufnr)
      local filepath = fn.fnamemodify(bufname, ":~:.")

      return string.format(
        "%s%s%s%s%s%s%s%s%s",
        j.jump,
        utils.nbsp,
        j.bufnr,
        utils.nbsp,
        j.row,
        utils.nbsp,
        j.col,
        utils.nbsp,
        utils.ansi_codes.blue(filepath)
      )
    end)
    return entries
  end

  core.fzf(table.concat(get_entries(), "\n"), function(selection)
    local bufnr = vim.split(selection[1], utils.nbsp)[2]
    local lnum = vim.split(selection[1], utils.nbsp)[3]
    local col = vim.split(selection[1], utils.nbsp)[4]
    vim.cmd(string.format([[buffer %s]], bufnr))
    vim.cmd(string.format([[normal! %sG%s|]], lnum, col))
  end, {
    fzf_preview_cmd = nil,
    fzf_extra_args = "--with-nth=3..",
    fzf_prompt = "Jumps",
    fzf_initial_position = fzf_initial_pos,
    fzf_binds = {},
    fzf_on_focus = function(selection)
      local args = vim.split(selection, utils.nbsp)
      local bufnr = args[2]
      local lnum = args[3]
      local col = args[4]
      local filepath = args[5]
      core.send_to_fzf(
        string.format(
          [[change-preview:%s]],
          string.format([[bat %s %s]], config.bat_default_opts, filepath)
        )
      )
    end,
  })
end

return M
