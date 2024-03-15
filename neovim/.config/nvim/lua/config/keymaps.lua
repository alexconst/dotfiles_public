-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here


-- neovim workflow is centered on buffers
vim.api.nvim_set_keymap('n', '<S-H>', '<Cmd>BufferPrevious<CR>', {desc = 'Go to buffer on left side', noremap = true, silent = false}) -- override lazyvim so we have proper buffer navigation
vim.api.nvim_set_keymap('n', '<S-L>', '<Cmd>BufferNext<CR>', {desc = 'Go to buffer on right side', noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<C-H>', '<Cmd>BufferMovePrevious<CR>', {desc = 'Move buffer pane to the left', noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<C-L>', '<Cmd>BufferMoveNext<CR>', {desc = 'Move buffer pane to the right', noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<C-c>', '<cmd>BufferClose<cr>', {desc = "Close buffer", noremap = true, silent = false}) -- using BufferClose as per barbar; other shortcut is `<leader>bd`
vim.api.nvim_set_keymap('n', '<leader>bl', '<C-^>', {desc = "Go back to last used buffer", noremap = true, silent = false})
vim.api.nvim_set_keymap('n', 'gl', '<C-^>', {desc = "Go back to last used buffer", noremap = true, silent = false}) -- another binding for same thing because old habits die hard
vim.keymap.set("n", "gb", function() return "<cmd>buffer " .. vim.v.count .. "<cr>" end, {desc = "Jump to buffer", expr = true})
-- to open a new buffer :edit somename

-- but having tab navigation is still useful
vim.api.nvim_set_keymap('n', '<C-n>', '<cmd>tabnext<cr>', {desc = "Next tab", noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>tabprevious<cr>', {desc = "Prev tab", noremap = true, silent = false})
-- vim.api.nvim_set_keymap('n', '<C-t>', '<cmd>tabclose<cr>', {desc = "Close tab", noremap = true, silent = false}) -- close tab the slow way with :q, also ctrl+t is such bad key for this
local lastTab = vim.api.nvim_create_augroup("LastTab", { clear = true })
vim.api.nvim_create_autocmd("TabLeave", { pattern = "*", command = "let g:lasttab = tabpagenr()", group = lastTab })
vim.api.nvim_set_keymap('n', '<leader>tl', ':exe "tabn ".g:lasttab<CR>', {desc = "Go back to last used tab", noremap = true, silent = true})
-- use `number gt` to to to tab number
-- to open a new tab :tabe somename


