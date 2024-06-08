-- https://github.com/kovidgoyal/kitty/discussions/6485

vim.wo.number = false
vim.wo.relativenumber = false
vim.wo.statuscolumn = ""
vim.wo.signcolumn = "no"

vim.opt.laststatus = 0 -- hide statusline

local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
while #lines > 0 and vim.trim(lines[#lines]) == "" do
  lines[#lines] = nil
end

local buf = vim.api.nvim_create_buf(false, true)
local channel = vim.api.nvim_open_term(buf, {})

vim.api.nvim_chan_send(channel, table.concat(lines, "\r\n"))
vim.api.nvim_set_current_buf(buf)

vim.keymap.set("n", "q", "<cmd>qa!<cr>", { silent = true, buffer = buf })
vim.keymap.set("n", "<space>q", "<cmd>qa!<cr>", { silent = true, buffer = buf })

vim.cmd("normal! G")