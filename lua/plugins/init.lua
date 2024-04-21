-- === packer ===
-- :PackerInstall
--      Install Plugins
-- :PackerUpdate
--      Update Plugins
-- :PackerClean
--      Uninstall Plugins
-- :PackerSync
--      PackerClean & PackerUpdate
-- :PackerCompile
--      Compile config files
vim.cmd.packadd "packer.nvim"

require("packer").startup(function()
    -- package manager
    use "wbthomason/packer.nvim"

    -- syntax highlighting
    --use { "nvim-treesitter/nvim-treesitter", opt = true, cmd={ "VimEnter" } }
    use {"nvim-treesitter/nvim-treesitter", opt = false}

    -- language server page
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"
    use "neovim/nvim-lspconfig"
end)


-- === treesitter ===
-- :TSInstall <language>
--      install LSP server
-- :TSEnable highlight
--      enable highlight
require("plugins.treesitter")


-- === lsp ===
require("plugins.lsp")


-- === others ===
require("plugins.netrw")
