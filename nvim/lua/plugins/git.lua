return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = "A|" },
          change = { text = "C|" },
          delete = { text = "D_" },
          topdelete = { text = "D‾" },
          changedelete = { text = "D~" },
        },
      })
      vim.keymap.set("n", "<leader>g-", ":Gitsigns prev_hunk<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>g=", ":Gitsigns next_hunk<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "H", ":Gitsigns preview_hunk_inline<CR>", { noremap = true, silent = true })
    end
  },
}
