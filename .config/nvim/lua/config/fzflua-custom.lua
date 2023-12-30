local utils = require("utils")
local actions = require("fzf-lua.actions")
local ansi_codes = require("fzf-lua").utils.ansi_codes

local M = {}

M.git_reflog = function()
  local entries = {}
  local function get_ref_from_str(str)
    local s = utils.strip_ansi_coloring(str)
    local parts = vim.split(s, utils.nbsp)
    local index = tonumber(parts[1])
    return entries[index]
  end

  require("fzf-lua").fzf_exec(function(fzf_cb)
    local output = vim.fn.system("git reflog")
    for line in output:gmatch("[^\n]+") do
      local sha, ref, action, description =
        line:match("(%w+) (%w+@{%d+}): ([^:]+): (.+)")
      if sha and ref and action and description then
        table.insert(
          entries,
          { sha = sha, ref = ref, action = action, description = description }
        )
      else
        vim.notify(
          "Failed to parse git reflog entry: " .. line,
          vim.log.levels.WARN
        )
      end
      fzf_cb(
        string.format(
          "%d %s %s %s",
          #entries,
          utils.nbsp,
          ansi_codes.blue(action),
          description
        )
      )
    end
    fzf_cb()
  end, {
    prompt = "GitReflog❯ ",

    preview = require("fzf-lua").shell.raw_preview_action_cmd(
      function(selected)
        local ref = get_ref_from_str(selected[1]).ref
        return string.format([[git diff "%s" | delta]], ref) -- TODO: $FZF_PREVIEW_COLUMNS undefined
      end
    ),
    actions = {
      ["ctrl-y"] = {
        function(selected)
          local ref = get_ref_from_str(selected[1]).ref
          vim.fn.setreg("+", ref)
          vim.notify(string.format("Copied %s", ref))
        end,
        actions.resume, -- TODO: still see a splash even with resume
      },
    },
    fzf_opts = {
      ["--delimiter"] = string.format("'%s'", utils.nbsp),
      ["--with-nth"] = "2..",
      ["--header"] = "'Action Description'",
      ["--no-multi"] = "",
    },
  })
end

return M
