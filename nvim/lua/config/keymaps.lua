function keymap(kmap)
  for _, map in pairs(kmap) do
    vim.api.nvim_set_keymap(map[1], map[2], map[3], map[4])
  end
end

keymap({
  { 'i', 'jj', '<esc>', { noremap = true } },
  { 'n', '<tab>', ':bnext<cr>', { noremap = true } },
  { 'n', '<s-tab>', ':bprevious<cr>', { noremap = true } },
  -- { 'n', '<leader>e', ':NvimTreeToggle<cr>', { noremap = true } },
  { 'n', '<leader>h', '<c-w>h', { noremap = true } },
  { 'n', '<leader>j', '<c-w>j', { noremap = true } },
  { 'n', '<leader>k', '<c-w>k', { noremap = true } },
  { 'n', '<leader>l', '<c-w>l', { noremap = true } }
})
