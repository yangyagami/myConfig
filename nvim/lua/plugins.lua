-- This file can be loaded by calling `lua require('plugins')` from your init.vim

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
  'nvim-tree/nvim-tree.lua',
  requires = {
    'nvim-tree/nvim-web-devicons', -- optional
  },
  use { "catppuccin/nvim", as = "catppuccin" },
  use "neovim/nvim-lspconfig",
  use 'hrsh7th/cmp-nvim-lsp',
  use 'hrsh7th/cmp-buffer',
  use 'hrsh7th/cmp-path',
  use 'hrsh7th/cmp-cmdline',
  use 'hrsh7th/nvim-cmp',
  use 'hrsh7th/cmp-vsnip',
  use 'hrsh7th/vim-vsnip'
}
end)
