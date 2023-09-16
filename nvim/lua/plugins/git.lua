return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { hl = "GitSignsAdd", text = "A|", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
          change = { hl = "GitSignsChange", text = "C|", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
          delete = { hl = "GitSignsDelete", text = "D_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
          topdelete = { hl = "GitSignsDelete", text = "D‾", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
          changedelete = { hl = "GitSignsChange", text = "D~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
        },
      })
      vim.keymap.set("n", "<leader>g-", ":Gitsigns prev_hunk<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>g=", ":Gitsigns next_hunk<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "H", ":Gitsigns preview_hunk_inline<CR>", { noremap = true, silent = true })
    end
  },
  {
    "kdheepak/lazygit.nvim",
    keys = { "<leader>g" },
    config = function()
      vim.g.lazygit_floating_window_scaling_factor = 1.0
      vim.g.lazygit_floating_window_winblend = 0
      vim.g.lazygit_use_neovim_remote = true
      vim.keymap.set("n", "<leader>g", ":LazyGit<CR>", { noremap = true, silent = true })
    end
  },
}
