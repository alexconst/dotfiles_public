-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here


-- neovim workflow is centered on buffers
-- `shift+L` for next buffer
-- `shift+H` for prev buffer
vim.api.nvim_set_keymap('n', '<C-b>', '<cmd>BufferClose<cr>', {desc = "Close tab", noremap = true, silent = false}) -- using BufferClose as per barbar; another shortcut is `<leader>bd`
vim.api.nvim_set_keymap('n', '<leader>bl', '<C-^>', {desc = "Last buffer", noremap = true, silent = false})
vim.keymap.set("n", "gb", function() return "<cmd>buffer " .. vim.v.count .. "<cr>" end, {desc = "Jump to buffer", expr = true})

-- but having tab navigation is still useful (ToDo: check tiagovla/scope.nvim which may increase use of tabs)
vim.api.nvim_set_keymap('n', '<C-n>', '<cmd>tabnext<cr>', {desc = "Next tab", noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>tabprevious<cr>', {desc = "Prev tab", noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<C-t>', '<cmd>tabclose<cr>', {desc = "Close tab", noremap = true, silent = false})
local lastTab = vim.api.nvim_create_augroup("LastTab", { clear = true })
vim.api.nvim_create_autocmd("TabLeave", { pattern = "*", command = "let g:lasttab = tabpagenr()", group = lastTab })
vim.api.nvim_set_keymap('n', '<leader>tl', ':exe "tabn ".g:lasttab<CR>', {desc = "Last tab", noremap = true, silent = true})
-- `number gt` to to to tab number

-- other buffer shortcuts
--vim.api.nvim_set_keymap('n', '<C-S-h>', '<Cmd>BufferMovePrevious<CR>', {desc = 'Move buffer to left', noremap = true, silent = false}) -- TODO: C-S-h
--vim.api.nvim_set_keymap('n', '<C-S-l>', '<Cmd>BufferMoveNext<CR>', {desc = 'Move buffer to right', noremap = true, silent = false})    -- TODO: C-S-l

