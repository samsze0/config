-- Tweaked from:
-- folke/persistence.nvim
-- pocco81/auto-save.nvim

local config = require("m.persist.config")
local persist_utils = require("m.persist.utils")
local debug = true

local M = {}
---@type string?
M.cwd_session = nil

local e = vim.fn.fnameescape

function M.get_cwd_session()
  local pattern = "/"
  if vim.fn.has("win32") == 1 then pattern = "[\\:]" end
  local name = vim.fn.getcwd():gsub(pattern, "%%")
  return config.sessions_dir .. name .. ".vim"
end

function M.get_last_session()
  local sessions = M.list_sessions()
  table.sort(sessions, function(a, b) return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec end)
  return sessions[1]
end

function M.setup()
  vim.cmd([[set backupdir=~/.cache/nvim/backup]])
  vim.opt.backup = true

  vim.cmd([[set directory=~/.cache/nvim/swap]])
  vim.opt.swapfile = false

  vim.cmd([[set undodir=~/.cache/nvim/undo]])
  vim.opt.undofile = true

  vim.bo.bufhidden = "hide"

  vim.opt.sessionoptions = table.concat({ "buffers", "curdir", "tabpages", "winsize", "skiprtp" }, ",")

  M.start()
end

function M.start()
  -- Session
  M.cwd_session = M.get_cwd_session()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("persist-session", { clear = true }),
    desc = "Save session",
    callback = function()
      local bufs = vim.tbl_filter(function(b)
        if vim.bo[b].buftype ~= "" then return false end
        if vim.bo[b].filetype == "gitcommit" then return false end
        return vim.api.nvim_buf_get_name(b) ~= ""
      end, vim.api.nvim_list_bufs())

      if #bufs == 0 then return end

      M.save_session()
    end,
  })

  -- Backup
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("persist-backup", { clear = true }),
    desc = "Add timestamp to backup extension",
    pattern = "*",
    callback = function() vim.opt.backupext = "-" .. vim.fn.strftime("%Y%m%d%H%M") end,
  })

  -- Autowrite
  if config.autowrite then
    vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
      group = vim.api.nvim_create_augroup("persist-autowrite", { clear = true }),
      desc = "Autowrite",
      pattern = "*",
      callback = function(ctx)
        persist_utils.buf_debounce(function(buf)
          if not vim.api.nvim_buf_get_option(buf, "modified") then return end
          if vim.api.nvim_buf_get_option(buf, "readonly") then return end
          if vim.bo[buf].buftype ~= "" then return end -- Filter special buf

          if vim.bo[buf].filetype == "gitcommit" then return end -- Filter file types
          if vim.api.nvim_buf_get_name(buf) == "" then return end -- Filter unnamed buf

          if debug then vim.notify(string.format("Autowriting %s @ %s", vim.api.nvim_buf_get_name(0), vim.fn.strftime("%H:%M:%S"))) end

          vim.api.nvim_buf_call(buf, function() vim.cmd("silent! write") end)
        end, config.autowrite_debounce_delay, ctx.buf)
      end,
    })
  end

  -- Delete hidden buffer
  vim.api.nvim_create_autocmd("BufHidden", {
    group = vim.api.nvim_create_augroup("persist-delete-hidden", { clear = true }),
    desc = "Delete hidden buffer",
    pattern = "*",
    callback = function(ctx)
      local buf = ctx.buf
      if vim.api.nvim_buf_get_option(buf, "buftype") ~= "" then return end
      if vim.api.nvim_buf_get_option(buf, "readonly") then return end
      if vim.api.nvim_buf_get_name(buf) == "" then return end

      if vim.api.nvim_buf_get_option(buf, "modified") then
        vim.ui.input({ prompt = string.format("Attempting to delete hidden buffer %s. Write changes? [y/n] ", vim.api.nvim_buf_get_name(buf)) }, function(val)
          if val == "y" then
              vim.api.nvim_buf_call(buf, function() vim.cmd("silent! write") end)
          end
        end)
      end

      vim.defer_fn(function()
        vim.api.nvim_buf_delete(buf, { force = true })
      end, 500)
    end,
  })
end

function M.stop()
  -- Session
  M.cwd_session = nil
  pcall(vim.api.nvim_del_augroup_by_name, "persist-session")
  pcall(vim.api.nvim_del_augroup_by_name, "persist-autowrite")
  pcall(vim.api.nvim_del_augroup_by_name, "persist-delete-hidden")
end

function M.save_session() vim.cmd("mks! " .. e(M.cwd_session or M.get_cwd_session())) end

function M.load_session(opt)
  opt = opt or {}
  local sfile = opt.last and M.get_last_session() or M.get_cwd_session()
  if sfile and vim.fn.filereadable(sfile) ~= 0 then vim.cmd("silent! source " .. e(sfile)) end
end

function M.list_sessions() return vim.fn.glob(config.sessions_dir .. "*.vim") end

return M
