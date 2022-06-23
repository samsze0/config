-- Window (pane) {{{
  -- Switch
  vim.api.nvim_set_keymap("n", "<C-E>", "<cmd>wincmd k<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "<C-D>", "<cmd>wincmd j<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "<C-S>", "<cmd>wincmd h<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "<C-F>", "<cmd>wincmd l<CR>", {silent = true, noremap = true})

  -- Close
  vim.api.nvim_set_keymap("n", "<C-X>", "<cmd>clo<CR>", {silent = true, noremap = true})

  -- New
  -- consider using new for blank pane?
  vim.api.nvim_set_keymap("n", "wd", "<cmd>split<CR><cmd>wincmd j<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "wf", "<cmd>vsplit<CR><cmd>wincmd l<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "we", "<cmd>split<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "ws", "<cmd>vsplit<CR>", {silent = true, noremap = true})

  -- Rotate
  vim.api.nvim_set_keymap("n", "w<Down>", "<cmd>windo wincmd K<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "w<Right>", "<cmd>windo wincmd H<CR>", {silent = true, noremap = true})

  -- Zoom
  vim.api.nvim_set_keymap("n", "<C-Z>", "<cmd>resize<CR>", {silent = true, noremap = true})

  -- Window resizing
  vim.api.nvim_set_keymap("n", "w<Space>", "<C-W>=", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "<C-S-e>", "<cmd>resize -1<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "<C-S-d>", "<cmd>resize +1<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "<C-S-f>", "<cmd>vertical resize +3<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "<C-S-s>", "<cmd>vertical resize -3<CR>", {silent = true, noremap = true})

  -- Previous pane
  vim.api.nvim_set_keymap("n", "wq", "<C-W>p", {silent = true, noremap = true})
-- }}}

--- Tab {{{
  -- Switch
  vim.api.nvim_set_keymap("n", "<C-J>", "<cmd>tabp<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "<C-L>", "<cmd>tabn<CR>", {silent = true, noremap = true})

  -- New
  vim.api.nvim_set_keymap("n", "<C-T>", "<cmd>tabnew<CR>", {silent = true, noremap = true})

  -- Close
  vim.api.nvim_set_keymap("n", "<C-W>", "<cmd>tabclose<CR>", {silent = true, noremap = true})

  -- Move
  vim.api.nvim_set_keymap("n", "w-", "<cmd>tabmove -1<CR>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("n", "w=", "<cmd>tabmove +1<CR>", {silent = true, noremap = true})
-- }}}
