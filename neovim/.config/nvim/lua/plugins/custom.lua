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

  -- add any tools you want to have installed below
  -- (if it doesn't install automatically then run LazyVim update. You can check installation with :MasonLog)
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

