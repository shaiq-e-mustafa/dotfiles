require('nvim-treesitter').setup({})

require('nvim-treesitter').install({ 'cpp', 'c', 'lua', 'rust', 'javascript', 'typescript' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'cpp', 'c', 'lua', 'rust', 'javascript', 'typescript' },
  callback = function()
    vim.treesitter.start()
  end,
})
