vim.g.mapleader = " "

local mappings = {
  { mode = "i", from = "jj", to = "<esc>" },
  { mode = "n", from = "<leader>h", to ="<c-w>h" },
  { mode = "n", from = "<leader>j", to ="<c-w>j" },
  { mode = "n", from = "<leader>k", to ="<c-w>k" },
  { mode = "n", from = "<leader>l", to ="<c-w>l" },
}

for _, mapping in ipairs(mappings) do
  vim.keymap.set(mapping.mode, mapping.from, mapping.to, { noremap = true })
end

