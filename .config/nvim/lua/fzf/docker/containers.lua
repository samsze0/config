local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local json = require("utils.json")

-- TODO: listen to / watch container changes

---@param opts? {  }
M.docker_containers = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  ---@type { Command: string, CreatedAt: string, ID: string, Image: string, Labels: string, LocalVolumes: string, Mounts: string, Names: string, Networks: string, Ports: string, RunningFor: string, Size: string, State: string, Status: string }[]
  local containers

  local get_selection = function()
    local index = FZF.current_selection_index

    return containers[index]
  end

  local function get_entries()
    if vim.fn.executable("docker") ~= 1 then
      error("Docker executable not found")
    end
    -- if vim.fn.executable("jq") ~= 1 then
    --   error("jq executable not found")
    -- end
    local result = vim.fn.system("docker container ls -a --format json")
    if vim.v.shell_error ~= 0 then
      vim.error("Fail to retrieve docker containers")
    end

    result = vim.trim(result)

    containers = json.parse_multiple(result)
    ---@cast containers { Command: string, CreatedAt: string, ID: string, Image: string, Labels: string, LocalVolumes: string, Mounts: string, Names: string, Networks: string, Ports: string, RunningFor: string, Size: string, State: string, Status: string }[]

    return utils.map(containers, function(_, c)
      local state
      if c.State == "exited" then
        state = utils.ansi_codes.grey(" ")
      elseif c.State == "running" then
        state = utils.ansi_codes.blue(" ")
      else
        state = utils.ansi_codes.red("??")
      end

      return fzf_utils.create_fzf_entry(
        state,
        utils.ansi_codes.blue(c.Image),
        c.Names
      )
    end)
  end

  local entries = get_entries()

  local win = vim.api.nvim_get_current_win()

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout()

  core.fzf(entries, {
    layout = layout,
    fzf_preview_cmd = nil,
    fzf_prompt = "Docker-Containers",
    fzf_on_select = nil,
    before_fzf = function()
      helpers.set_keymaps_for_nvim_preview(popups.main, popups.nvim_preview)
      helpers.set_keymaps_for_popups_nav({
        { popup = popups.main, key = "<C-s>", is_terminal = true },
        { popup = popups.nvim_preview, key = "<C-f>", is_terminal = false },
      })
    end,
    fzf_on_focus = function()
      set_preview_content(vim.split(vim.inspect(get_selection()), "\n"))
      vim.bo[popups.nvim_preview.bufnr].filetype = "lua"

      -- Switch to preview window and back in order to refresh scrollbar
      -- TODO: Remove this once scrollbar plugin support remote refresh
      vim.api.nvim_set_current_win(popups.nvim_preview.winid)
      vim.api.nvim_set_current_win(popups.main.winid)
    end,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-y"] = function()
        local container = get_selection()
        vim.fn.setreg("+", container.ID)
        vim.notify(string.format([[Copied %s to clipboard]], container.ID))
      end,
      ["left"] = function()
        local container = get_selection()

        if container.Status == "running" then
          vim.warn("Container is already running")
          return
        end

        vim.fn.system(
          string.format([[docker container start %s]], container.ID)
        )
        if vim.v.shell_error ~= 0 then
          vim.error("Fail to start container")
          return
        end
        core.send_to_fzf(fzf_utils.generate_fzf_reload_action(get_entries()))
      end,
      ["right"] = function()
        local container = get_selection()

        if container.Status == "exited" then
          vim.warn("Container is already stopped")
          return
        end

        vim.fn.system(string.format([[docker container stop %s]], container.ID))
        if vim.v.shell_error ~= 0 then
          vim.error("Fail to stop container")
          return
        end
        core.send_to_fzf(fzf_utils.generate_fzf_reload_action(get_entries()))
      end,
      ["ctrl-x"] = function()
        local container = get_selection()

        if container.Status == "running" then
          vim.error("Cannot delete running container")
          return
        end

        vim.fn.system(string.format([[docker container rm %s]], container.ID))
        if vim.v.shell_error ~= 0 then
          vim.error("Fail to delete container")
          return
        end
        core.send_to_fzf(fzf_utils.generate_fzf_reload_action(get_entries()))
      end,
    }),
    nvim_preview = true,
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1.. --preview-window="
      .. helpers.fzf_default_preview_window_args,
  })
end

return M
