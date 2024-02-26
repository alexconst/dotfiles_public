-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here


--vim.api.nvim_set_keymap('n', '<C-n>', '<cmd>bnext<cr>', {desc = "Next buffer", noremap = true, silent = false})
--vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>bprevious<cr>', {desc = "Prev buffer", noremap = true, silent = false})
--vim.api.nvim_set_keymap('n', 'gl', '<C-^>', {desc = "Last buffer", noremap = true, silent = false})
--vim.api.nvim_set_keymap('n', '<C-c>', '<cmd>bdelete<cr>', {desc = "Close buffer", noremap = true, silent = false})

vim.api.nvim_set_keymap('n', '<C-n>', '<cmd>tabnext<cr>', {desc = "Next tab", noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>tabprevious<cr>', {desc = "Prev tab", noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<C-c>', '<cmd>tabclose<cr>', {desc = "Close tab", noremap = true, silent = false})
local lastTab = vim.api.nvim_create_augroup("LastTab", { clear = true })
vim.api.nvim_create_autocmd("TabLeave", { pattern = "*", command = "let g:lasttab = tabpagenr()", group = lastTab })
vim.api.nvim_set_keymap('n', 'gl', ':exe "tabn ".g:lasttab<CR>', {noremap = true, silent = true})


