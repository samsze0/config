local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local undo_utils = require("utils.undo")
local uv_utils = require("utils.uv")

M.lsp_implementations = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})

  local function get_entries()
    return utils.map(
      {},
      function(i, undo)
        return string.format(
          string.rep("%s", 2, utils.nbsp),
          undo.seq,
          undo.time
        )
      end
    )
  end
end

return M
