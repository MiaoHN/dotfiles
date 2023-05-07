-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

map("n", "<leader>h", "<c-w>h", { desc = "Move to left window" })
map("n", "<leader>j", "<c-w>j", { desc = "Move to bottom window" })
map("n", "<leader>k", "<c-w>k", { desc = "Move to up window" })
map("n", "<leader>l", "<c-w>l", { desc = "Move to right window" })
