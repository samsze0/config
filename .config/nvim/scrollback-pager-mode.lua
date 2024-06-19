-- https://github.com/kovidgoyal/kitty/discussions/6485

vim.wo.number = false
vim.wo.relativenumber = false
vim.wo.statuscolumn = ""
vim.wo.signcolumn = "no"

vim.opt.laststatus = 0 -- hide statusline

local current_buf = vim.api.nvim_get_current_buf()

local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
while #lines > 0 and vim.trim(lines[#lines]) == "" do
  lines[#lines] = nil
end

lines[#lines] = vim.trim(lines[#lines])

local new_buf = vim.api.nvim_create_buf(false, true)
local channel = vim.api.nvim_open_term(new_buf, {})

vim.api.nvim_chan_send(channel, table.concat(lines, "\r\n"))
-- vim.fn.chanclose(channel)
vim.api.nvim_set_current_buf(new_buf)

vim.api.nvim_buf_delete(current_buf, { force = true })

vim.keymap.set("n", "q", "<cmd>q!<cr>", { silent = true, buffer = new_buf })
vim.keymap.set(
  "n",
  "<space>q",
  "<cmd>q!<cr>",
  { silent = true, buffer = new_buf }
)

vim.cmd("normal! G")
