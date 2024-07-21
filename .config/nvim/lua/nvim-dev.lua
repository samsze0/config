local command_utils = require("utils.command")
local tbl_utils = require("utils.table")
local terminal_utils = require("utils.terminal")

local M = {}

function M.generate_luarc_workspace_library_config_for_nvim_plugins()
  local plugins = terminal_utils.systemlist_unsafe(
    "eza --oneline ~/.local/share/nvim/lazy",
    { trim_endline = true, keepempty = false }
  )
  if not vim.fn.filereadable(".luarc.json") then
    vim.warn("No .luarc.json file found")
    return
  end
  local existing_config =
    vim.json.decode(table.concat(vim.fn.readfile(".luarc.json"), "\n"))
  if not existing_config.workspace then existing_config.workspace = {} end
  if not existing_config.workspace.library then
    existing_config.workspace.library = {}
  end
  local plugin_paths = tbl_utils.map(
    plugins,
    function(_, p) return ("~/.local/share/nvim/lazy/%s/lua"):format(p) end
  )
  for _, path in ipairs(plugin_paths) do
    local exists = tbl_utils.contains(existing_config.workspace.library, path)
    if not exists then table.insert(existing_config.workspace.library, path) end
  end
  vim.fn.writefile(
    vim.split(vim.fn.json_encode(existing_config.workspace.library), "\n"),
    ".luarc.workspace.library.json"
  )
end

---@param opts? {}
M.setup = function(opts)
  opts = opts or {}

  command_utils.create(
    "GenerateLuarcWorkspaceLibraryConfigForNvimPlugins",
    M.generate_luarc_workspace_library_config_for_nvim_plugins
  )
end

return M
