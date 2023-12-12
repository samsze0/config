local M = {}

local core = require("fzf.core")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local fzf_git = require("fzf.git")
local fzf_files = require("fzf.files")
local fzf_jump = require("fzf.jump")

local fn = vim.fn

M.tabs = function()
  local function get_entries()
    local entries = utils.map(fn.gettabinfo(), function(_, tab)
      local tabnr = tab.tabnr

      return string.format(
        "%s%s%s",
        tabnr,
        utils.nbsp,
        utils.ansi_codes.blue(
          (true and _G.tabs[tabnr].full or _G.tabs[tabnr].display) or "  "
        )
      )
    end)
    return entries
  end

  local current_tabnr = fn.tabpagenr()

  core.fzf(table.concat(get_entries(), "\n"), function(selection)
    local tabnr = vim.split(selection[1], utils.nbsp)[1]
    vim.cmd(string.format([[tabnext %s]], tabnr))
  end, {
    fzf_preview_cmd = nil,
    fzf_extra_args = "--with-nth=1..",
    fzf_prompt = "Tabs",
    fzf_initial_position = current_tabnr,
    fzf_binds = {
      ["ctrl-x"] = function()
        local current_selection = FZF_CURRENT_SELECTION

        local tabnr = vim.split(current_selection, utils.nbsp)[1]
        vim.cmd(string.format([[tabclose %s]], tabnr))
        core.send_to_fzf(
          string.format(
            "track+reload(%s)",
            string.format(
              [[cat <<EOF
%s
EOF]],
              table.concat(get_entries(), "\n")
            )
          )
        )
      end,
    },
    fzf_on_focus = function(selection) end,
  })
end

M.buffers = function()
  local fzf_initial_pos = fn.bufnr()

  local function get_entries()
    local current_bufnr = fn.bufnr()

    -- Get all buffers
    local entries = utils.map(fn.getbufinfo({ buflisted = 1 }), function(i, buf)
      local bufnr = buf.bufnr
      local bufname = buf.name
      local modified = buf.changed == 1
      local readonly = buf.readonly == 1
      local buftype = buf.buftype
      local modified_icon = modified and "  " or ""

      local readonly_icon = readonly and "  " or ""
      local icon = modified_icon .. readonly_icon

      if bufnr == current_bufnr then fzf_initial_pos = i end

      return string.format(
        "%s%s%s",
        bufnr,
        utils.nbsp,
        utils.ansi_codes.blue(bufname .. icon)
      )
    end)
    return entries
  end

  core.fzf(table.concat(get_entries(), "\n"), function(selection)
    local bufnr = vim.split(selection[1], utils.nbsp)[1]
    vim.cmd(string.format([[buffer %s]], bufnr))
  end, {
    fzf_preview_cmd = nil,
    fzf_extra_args = "--with-nth=1..",
    fzf_prompt = "Buffers",
    fzf_initial_position = fzf_initial_pos,
    fzf_binds = {
      ["ctrl-x"] = function()
        local current_selection = FZF_CURRENT_SELECTION

        local tabnr = vim.split(current_selection, utils.nbsp)[1]
        -- Bufdelete
        vim.cmd(string.format([[bdelete %s]], tabnr))
        core.send_to_fzf(
          string.format(
            "track+reload(%s)",
            string.format(
              [[cat <<EOF
%s
EOF]],
              table.concat(get_entries(), "\n")
            )
          )
        )
      end,
    },
    fzf_on_focus = function(selection) end,
  })
end

M.all = function()
  local config = {
    ["Tabs"] = M.tabs,
    ["Buffers"] = M.buffers,
    ["Files"] = fzf_files.files,
    ["Git submodule files"] = false,
    ["Git stash"] = fzf_git.git_stash,
    ["Git submodule stash"] = false,
    ["Git status"] = fzf_git.git_status,
    ["Git submodule status"] = false,
    ["Git commits"] = fzf_git.git_commits,
    ["Git submodule commits"] = false,
    ["Git submodules"] = fzf_git.git_submodules,
    ["Jumps"] = fzf_jump.jumps,
    ["Notifications"] = false,
    ["Undo"] = false,
    ["Grep"] = false,
    ["Backups"] = false,
    ["LSP symbols"] = false,
    ["LSP references"] = false,
    ["LSP definitions"] = false,
    ["LSP implementations"] = false,
  }

  local entries = utils.keys(config)
  -- Sort in alphabetical order, in-place
  table.sort(entries, function(a, b) return a:lower() < b:lower() end)

  core.fzf(table.concat(entries, "\n"), function(selection)
    local entry = selection[1]
    local action = config[entry]
    if action then action() end
  end, {
    fzf_preview_cmd = nil,
    fzf_extra_args = "--with-nth=1..",
    fzf_prompt = "All",
    fzf_initial_position = 1,
    fzf_binds = {},
    fzf_on_focus = function(selection) end,
  })
end

return M
