-- Brain: AI-powered code assistant for Neovim
-- Usage: Select code in visual mode, then run :Brain

if vim.g.loaded_brain then
  return
end
vim.g.loaded_brain = 1

-- Define the Brain commands
vim.api.nvim_create_user_command('Brain', function()
  require('brain').think()
end, {
  range = true,
  desc = 'Brain: Ask AI to modify selected code',
})

vim.api.nvim_create_user_command('BrainModel', function()
  require('brain').select_model()
end, {
  desc = 'Brain: Select AI model',
})

-- Default keymaps (can be overridden by user)
vim.keymap.set('v', '<leader>ai', function()
  require('brain').think()
end, { desc = 'Brain: Ask AI to modify selected code' })

vim.keymap.set('n', '<leader>am', function()
  require('brain').select_model()
end, { desc = 'Brain: Select AI model' })

-- Define highlight groups
vim.api.nvim_set_hl(0, 'BrainSelected', { link = 'PmenuSel' })
vim.api.nvim_set_hl(0, 'BrainThrobberActive', { fg = '#61afef', bold = true })  -- Blue, bold
vim.api.nvim_set_hl(0, 'BrainThrobberMargin', { fg = '#98c379', bold = true })  -- Green, bold

-- Clean up any throbbers on VimLeave
vim.api.nvim_create_autocmd('VimLeave', {
  group = vim.api.nvim_create_augroup('BrainCleanup', { clear = true }),
  callback = function()
    require('brain.throbber').stop_all_throbbers()
  end,
})
