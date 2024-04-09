-- In this config file in the plugins folder, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins

return {

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  { import = "lazyvim.plugins.extras.lang.json" },

  -- improve tabline with scope and barbar
  {
    "romgrk/barbar.nvim",
    event = "VimEnter",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      animation = true,
      highlight_inactive_file_icons = false,
      tabpages = true,
      icons = {
        --buffer_index = true,
        buffer_number = true,
        separator = { left = '', right = '▕' },
        separator_at_end = true,
        modified = { button = "" }, -- ●
        pinned = { button = "", filename = true, separator = { left = '', right = '▕'} },
      },
    },
  },

  -- configure persistence.nvim as per barbar docs
  -- NOTE: persistence.nvim saves sessions automatically when quitting Neovim, for usage see https://github.com/folke/persistence.nvim?tab=readme-ov-file#-usage
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { -- ← options go in `opts`
      --options = {'globals'}, -- bare mininum for integration with barbar
      options = {'curdir', 'buffers', 'tabpages', 'winsize', 'globals'}, -- :help sessionoptions
      pre_save = function() vim.api.nvim_exec_autocmds('User', {pattern = 'SessionSavePre'}) end,
    },
  },

  -- improve tabline with scope and barbar
  {
    "tiagovla/scope.nvim",
    event = "VeryLazy", -- IDK if really required
    config = function()
      require("scope").setup({
        hooks = {
          pre_tab_leave = function()
            vim.api.nvim_exec_autocmds('User', {pattern = 'ScopeTabLeavePre'})
            -- [other statements]
          end,
          post_tab_enter = function()
            vim.api.nvim_exec_autocmds('User', {pattern = 'ScopeTabEnterPost'})
            -- [other statements]
          end,
          -- [other hooks]
        },
      })
    end
  },

  -- config telescope to support scope
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("telescope").load_extension("scope") -- this limits telescope buffer listing to the current tab
    end,
  },

  -- show hidden files in file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
        },
      },
    },
  },

--  -- tweak tabline visuals
--  {
--    "nvim-lualine/lualine.nvim",
--    event = "VeryLazy",
--    config = function()
--      local lualine = require('lualine')
--      local opts = lualine.get_config()
--      opts.tabline = {
--        lualine_a = {'buffers'},
--        lualine_z = {'tabs'}
--      }
--      -- make separators a straight line instead of an angled lines
--      opts.options.section_separators = ''
--      opts.options.component_separators = ''
--      lualine.setup(opts)
--    end,
--  },

  -- add additional tools (if it doesn't install automatically then run LazyVim update. You can check installation with :MasonLog)
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "ansible-language-server",
        "terraform-ls",
      },
    },
  },

}

