vim.g.mapleader = " "

local mappings = {
  { mode = "i", from = "jj", to = "<esc>" },
  { mode = "n", from = "<leader>h", to ="<c-w>h" },
  { mode = "n", from = "<leader>j", to ="<c-w>j" },
  { mode = "n", from = "<leader>k", to ="<c-w>k" },
  { mode = "n", from = "<leader>l", to ="<c-w>l" },
  { mode = "n", from = "<tab>", to =":bnext<cr>" },
  { mode = "n", from = "<s-tab>", to =":bprev<cr>" },
  { mode = "n", from = "<up>", to =":horizontal res -5<cr>" },
  { mode = "n", from = "<down>", to =":horizontal res +5<cr>" },
  { mode = "n", from = "<right>", to =":vertical res +5<cr>" },
  { mode = "n", from = "<left>", to =":vertical res -5<cr>" },
}

for _, mapping in ipairs(mappings) do
  vim.keymap.set(mapping.mode, mapping.from, mapping.to, { noremap = true })
end

