return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim", -- npm required
    },
    config = function()
        -- import mason
        local mason = require('mason')
        -- import mason-lspconfig
        local mason_lspconfig = require('mason-lspconfig')

        -- setup mason
        mason.setup()

        -- setup mason_lspconfig
        mason_lspconfig.setup({
            -- A list of servers to automatically install if they're not already installed.
            ensure_installed = { "lua_ls", "clangd", "vimls", "pyright" },
            automatic_installation = true
        })
    end,
--     "neovim/nvim-lspconfig"
}
