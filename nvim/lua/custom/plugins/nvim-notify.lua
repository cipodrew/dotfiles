return {
  'rcarriga/nvim-notify',
  version = '*',
  -- lazy = false,
  config = function()
    local notify = require('notify').setup {
      timeout = 10000,
    }
    local moduleNotify = require 'notify'
    local opts = { pending = true, silent = true }
    vim.keymap.set('n', '<leader>nc', moduleNotify.dismiss, { desc = '[N]otifications [C]lear' }) -- focus file explorer - alternatively use Ctrl-w w to alternate windows
  end,
}
