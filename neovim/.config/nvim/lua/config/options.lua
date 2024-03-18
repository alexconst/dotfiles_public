-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- disable auto format on file save, https://vi.stackexchange.com/questions/42597/how-to-disable-autoformating-on-save-on-lazyvim
vim.g.autoformat = false

-- provide a `:Mksession` command to save buffer order, as per https://github.com/romgrk/barbar.nvim?tab=readme-ov-file#custom
vim.opt.sessionoptions:append 'globals'
vim.api.nvim_create_user_command(
  'Mksession',
  function(attr)
    vim.api.nvim_exec_autocmds('User', {pattern = 'SessionSavePre'})
    vim.cmd.mksession {bang = attr.bang, args = attr.fargs}
  end,
  {bang = true, complete = 'file', desc = 'Save barbar with :mksession', nargs = '?'}
)

