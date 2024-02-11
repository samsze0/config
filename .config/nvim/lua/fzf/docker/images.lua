local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local json = require("utils.json")

-- TODO: listen to / watch image changes

-- Fzf all docker images
--
---@param opts? {  }
M.docker_images = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  ---@type { Containers: string, CreatedAt: string, CreatedSince: string, Digest: string, ID: string, Repository: string, SharedSize: string, Size: string, Tag: string, UniqueSize: string, VirtualSize: string }[]
  local images

  local function get_entries()
    if vim.fn.executable("docker") ~= 1 then
      error("Docker executable not found")
    end
    -- if vim.fn.executable("jq") ~= 1 then
    --   error("jq executable not found")
    -- end
    local result = vim.fn.system("docker image ls -a --format json")
    if vim.v.shell_error ~= 0 then
      vim.error("Fail to retrieve docker images", result)
      return {}
    end

    result = vim.trim(result)

    images = json.parse_multiple(result)
    ---@cast images { Containers: string, CreatedAt: string, CreatedSince: string, Digest: string, ID: string, Repository: string, SharedSize: string, Size: string, Tag: string, UniqueSize: string, VirtualSize: string }[]

    return utils.map(
      images,
      function(_, c)
        return fzf_utils.join_by_delim(
          utils.ansi_codes.blue(c.Repository),
          utils.ansi_codes.grey(c.Tag)
        )
      end
    )
  end

  local entries = get_entries()

  local win = vim.api.nvim_get_current_win()

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout()

  core.fzf(entries, {
    prompt = "Docker-Images",
    layout = layout,
    main_popup = popups.main,
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
        local image = images[state.focused_entry_index]

        popups.nvim_preview.border:set_text(
          "top",
          " " .. image.Repository .. ":" .. image.Tag .. " "
        )

        set_preview_content(vim.split(vim.inspect(image), "\n"))
        vim.bo[popups.nvim_preview.bufnr].filetype = "lua"
      end,
      ["ctrl-y"] = function(state)
        local image = images[state.focused_entry_index]
        vim.fn.setreg("+", image.ID)
        vim.notify(string.format([[Copied %s to clipboard]], image.ID))
      end,
      ["ctrl-x"] = function(state)
        local image = images[state.focused_entry_index]

        vim.fn.system(string.format([[docker image rm %s]], image.ID))
        if vim.v.shell_error ~= 0 then
          vim.error("Fail to delete image")
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
