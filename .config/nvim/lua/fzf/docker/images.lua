local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local json = require("utils.json")

-- TODO: listen to / watch image changes

---@param opts? {  }
M.docker_images = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  ---@type { Containers: string, CreatedAt: string, CreatedSince: string, Digest: string, ID: string, Repository: string, SharedSize: string, Size: string, Tag: string, UniqueSize: string, VirtualSize: string }[]
  local images

  local get_selection = function()
    local index = FZF.current_selection_index

    return images[index]
  end

  local function get_entries()
    if vim.fn.executable("docker") ~= 1 then
      error("Docker executable not found")
    end
    -- if vim.fn.executable("jq") ~= 1 then
    --   error("jq executable not found")
    -- end
    local result = vim.fn.system("docker image ls -a --format json")
    if vim.v.shell_error ~= 0 then
      vim.error("Fail to retrieve docker images")
    end

    result = vim.trim(result)

    images = json.parse_multiple(result)
    ---@cast images { Containers: string, CreatedAt: string, CreatedSince: string, Digest: string, ID: string, Repository: string, SharedSize: string, Size: string, Tag: string, UniqueSize: string, VirtualSize: string }[]

    return utils.map(
      images,
      function(_, c)
        return fzf_utils.create_fzf_entry(
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
    layout = layout,
    fzf_preview_cmd = nil,
    fzf_prompt = "Docker-Images",
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
        local image = get_selection()
        vim.fn.setreg("+", image.ID)
        vim.notify(string.format([[Copied %s to clipboard]], image.ID))
      end,
      ["ctrl-x"] = function()
        local image = get_selection()

        vim.fn.system(string.format([[docker image rm %s]], image.ID))
        if vim.v.shell_error ~= 0 then
          vim.error("Fail to delete image")
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
