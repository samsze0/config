local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local json = require("utils.json")

-- TODO: listen to / watch container changes

-- Fzf all docker containers
--
---@param opts? {  }
M.docker_containers = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  ---@type { Command: string, CreatedAt: string, ID: string, Image: string, Labels: string, LocalVolumes: string, Mounts: string, Names: string, Networks: string, Ports: string, RunningFor: string, Size: string, State: string, Status: string }[]
  local containers

  local function get_entries()
    if vim.fn.executable("docker") ~= 1 then
      error("Docker executable not found")
    end
    -- if vim.fn.executable("jq") ~= 1 then
    --   error("jq executable not found")
    -- end
    local result = vim.fn.system("docker container ls -a --format json")
    if vim.v.shell_error ~= 0 then
      vim.error("Fail to retrieve docker containers", result)
      return {}
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

      return fzf_utils.join_by_delim(
        state,
        utils.ansi_codes.blue(c.Image),
        c.Names
      )
    end)
  end

  local win = vim.api.nvim_get_current_win()

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout()

  core.fzf(get_entries(), {
    prompt = "Docker-Containers",
    layout = layout,
    binds = {
      ["+before-start"] = function(state)
        helpers.set_keymaps_for_preview_remote_nav(
          popups.main,
          popups.nvim_preview
        )
        helpers.set_keymaps_for_popups_nav({
          { popup = popups.main, key = "<C-s>", is_terminal = true },
          { popup = popups.nvim_preview, key = "<C-f>", is_terminal = false },
        })
      end,
      ["focus"] = function(state)
        local container = containers[state.focused_entry_index]

        popups.nvim_preview.border:set_text(
          "top",
          " " .. container.Names .. " "
        )

        set_preview_content(vim.split(vim.inspect(container), "\n"))
        vim.bo[popups.nvim_preview.bufnr].filetype = "lua"

        -- Switch to preview window and back in order to refresh scrollbar
        -- TODO: Remove this once scrollbar plugin support remote refresh
        vim.api.nvim_set_current_win(popups.nvim_preview.winid)
        vim.api.nvim_set_current_win(popups.main.winid)
      end,
      ["ctrl-y"] = function(state)
        local container = containers[state.focused_entry_index]
        vim.fn.setreg("+", container.ID)
        vim.notify(string.format([[Copied %s to clipboard]], container.ID))
      end,
      ["left"] = function(state)
        local container = containers[state.focused_entry_index]

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
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
      ["right"] = function(state)
        local container = containers[state.focused_entry_index]

        if container.Status == "exited" then
          vim.warn("Container is already stopped")
          return
        end

        vim.fn.system(string.format([[docker container stop %s]], container.ID))
        if vim.v.shell_error ~= 0 then
          vim.error("Fail to stop container")
          return
        end
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
      ["ctrl-x"] = function(state)
        local container = containers[state.focused_entry_index]

        if container.Status == "running" then
          vim.error("Cannot delete running container")
          return
        end

        vim.fn.system(string.format([[docker container rm %s]], container.ID))
        if vim.v.shell_error ~= 0 then
          vim.error("Fail to delete container")
          return
        end
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
    }),
  })
end

return M
