local config = require("m.persist.config")

local M = {}
---@type string?
M.cwd_session = nil

local e = vim.fn.fnameescape

function M.get_cwd_session()
  local pattern = "/"
  if vim.fn.has("win32") == 1 then
    pattern = "[\\:]"
  end
  local name = vim.fn.getcwd():gsub(pattern, "%%")
  return config.dir .. name .. ".vim"
end

function M.get_last_session()
  local sessions = M.list_sessions()
  table.sort(sessions, function(a, b)
    return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec
  end)
  return sessions[1]
end

function M.setup()
  M.start()
end

function M.start()
  M.cwd_session = M.get_cwd_session()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("persist", { clear = true }),
    callback = function()
      local bufs = vim.tbl_filter(function(b)
        if vim.bo[b].buftype ~= "" then
          return false
        end
        if vim.bo[b].filetype == "gitcommit" then
          return false
        end
        return vim.api.nvim_buf_get_name(b) ~= ""
      end, vim.api.nvim_list_bufs())

      if #bufs == 0 then
        return
      end

      M.save_session()
    end,
  })
end

function M.stop()
  M.cwd_session = nil
  pcall(vim.api.nvim_del_augroup_by_name, "persist")
end

function M.save_session()
  vim.cmd("mks! " .. e(M.cwd_session or M.get_cwd_session()))
end

function M.load_session(opt)
  opt = opt or {}
  local sfile = opt.last and M.get_last_session() or M.get_cwd_session()
  if sfile and vim.fn.filereadable(sfile) ~= 0 then
    vim.cmd("silent! source " .. e(sfile))
  end
end

function M.list_sessions()
  return vim.fn.glob(config.dir .. "*.vim")
end

return M
