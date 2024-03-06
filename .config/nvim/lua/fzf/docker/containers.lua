local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local layouts = require("fzf.layouts")
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
    local result = utils.system("docker container ls -a --format json")

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

  local layout, popups, set_preview_content, binds =
    layouts.create_nvim_preview_layout()

  core.fzf(get_entries(), {
    prompt = "Docker-Containers",
    layout = layout,
    main_popup = popups.main,
    binds = fzf_utils.bind_extend(binds, {
      ["+before-start"] = function(state)
        popups.main.border:set_text(
          "bottom",
          " <y> copy id | <left> start | <right> stop | <x> delete "
        )
      end,
      ["focus"] = function(state)
        local container = containers[state.focused_entry_index]

        popups.nvim_preview.border:set_text(
          "top",
          " " .. container.Names .. " "
        )

        set_preview_content(vim.split(vim.inspect(container), "\n"))
        vim.bo[popups.nvim_preview.bufnr].filetype = "lua"
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

        utils.system(string.format([[docker container start %s]], container.ID))
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
      ["right"] = function(state)
        local container = containers[state.focused_entry_index]

        if container.Status == "exited" then
          vim.warn("Container is already stopped")
          return
        end

        utils.system(string.format([[docker container stop %s]], container.ID))
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
      ["ctrl-x"] = function(state)
        local container = containers[state.focused_entry_index]

        if container.Status == "running" then
          vim.error("Cannot delete running container")
          return
        end

        utils.system(string.format([[docker container rm %s]], container.ID))
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
    }),
  })
end

return M
