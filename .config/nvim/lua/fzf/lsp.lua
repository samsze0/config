local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local undo_utils = require("utils.undo")
local uv_utils = require("utils.uv")

M.lsp_implementations = function(opts)
  -- TODO
  opts = vim.tbl_extend("force", {}, opts or {})

  vim.lsp.buf_request(
    0,
    "textDocument/implementation",
    vim.lsp.util.make_position_params(),
    function(err, _, result)
      if err then
        print("Error: " .. err)
        return
      end

      local entries = utils.map(
        result,
        function(i, impl)
          return string.format(
            string.rep("%s", 2, utils.nbsp),
            impl.uri,
            impl.range.start.line
          )
        end
      )

      core.fzf(entries, {
        fzf_prompt = "LSP Implementations",
        fzf_on_select = function()
          local selection = FZF_STATE.current_selection
          local uri, line = selection:match("^(.+)%s+(%d+)$")

          vim.lsp.util.jump_to_location({
            uri = uri,
            range = {
              start = { line = line, character = 0 },
              ["end"] = { line = line, character = 0 },
            },
          })
        end,
      })
    end
  )

  local function get_entries()
    -- Get all implementations
    local implementations = vim.lsp.buf_request_sync(
      0,
      "textDocument/implementation",
      vim.lsp.util.make_position_params()
    )

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
