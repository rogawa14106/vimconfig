-- manage lsp packages
return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim", -- npm required
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        -- import plugins
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

        -- setup mason
        mason.setup({})

        -- setup mason_lspconfig
        mason_lspconfig.setup({
            -- A list of servers to automatically install if they're not already installed.
            ensure_installed = {
                "lua_ls",
                "vimls",
                "bashls",
                "clangd",
                "pylsp",
                "terraformls",
                "yamlls",
                "marksman",
            },
            automatic_installation = true,
        })

        mason_tool_installer.setup({
            ensure_installed = {
                "prettier",
                -- "stylua",
                "isort",
                "black",
                "clang-format",
            },
        })
    end,
}
