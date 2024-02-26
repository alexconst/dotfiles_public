-- In this config file in the plugins folder, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins

return {

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  { import = "lazyvim.plugins.extras.lang.json" },

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

  -- tweak tabline visuals
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      local lualine = require('lualine')
      local opts = lualine.get_config()
      opts.tabline = {
        lualine_a = {'buffers'},
        lualine_z = {'tabs'}
      }
      -- make separators a straight line instead of an angled lines
      opts.options.section_separators = ''
      opts.options.component_separators = ''
      lualine.setup(opts)
    end,
  },

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

