local unused_keymap = {
  "w",
  "<Space>",
  "l",
  "b"
}

for _, keymap in ipairs(unused_keymap) do
  vim.api.nvim_set_keymap("n", keymap, "<Nop>", {silent = true, noremap = true})
  vim.api.nvim_set_keymap("v", keymap, "<Nop>", {silent = true, noremap = true})
end
