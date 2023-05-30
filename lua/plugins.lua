vim.cmd.packadd "packer.nvim"

require("packer").startup(function()
    -- package manager
    use "wbthomason/packer.nvim"

    -- syntax highlighting
    use "nvim-treesitter/nvim-treesitter"

    -- language server page
    use "neovim/nvim-lspconfig"
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"
end)

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

-- === treesitter ===
-- :TSInstall <language>
--      install LSP server
-- :TSEnable highlight
--      enable highlight

-- === lsp ===
