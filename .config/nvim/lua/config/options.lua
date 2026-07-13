-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.conceallevel = 0

vim.diagnostic.config({
  severity = { min = vim.diagnostic.severity.ERROR },
})

vim.g.ai_cmp = false

require("noice").setup({
  routes = {
    {
      filter = {
        event = "lsp",
        kind = "progress",
      },
      opts = { skip = true }, -- Hides all LSP progress notifications
    },
  },
})
