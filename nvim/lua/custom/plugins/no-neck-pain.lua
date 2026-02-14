-- stable version
return {
  'shortcuts/no-neck-pain.nvim',
  version = '*',
  -- lazy = false,
  config = function()
    require('no-neck-pain').setup {
      vim.keymap.set('n', '<leader>cb', '<cmd>NoNeckPain<CR>', { desc = 'toggle [C]enter [B]uffer' }),
    }
  end,
}
