return {
  {
    "codota/tabnine-nvim",
    build = "./dl_binaries.sh",
    config = function()
      require("tabnine").setup({
        disable_auto_comment = true,
        accept_keymap = "<c-n>",
        dismiss_keymap = "<c-]>",
        debounce_ms = 300,
        suggestion_color = { gui = "#808080", cterm = 244 },
        execlude_filetypes = { "TelescopePrompt" },
      })
    end,
  },
}
