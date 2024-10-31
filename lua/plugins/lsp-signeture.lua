return {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    config = function()
        local cfg = {
            bind = true,
            handler_opts = {
                border = "rounded",
            },
        }
        require('lsp_signature').setup(cfg)

        -- attach lsp_signature on buffer enter.
        vim.api.nvim_create_autocmd({ "BufEnter" }, {
            pattern = { "*.lua", "*.c", "*.py" },
            callback = function()
                require('lsp_signature').on_attach()
            end,
        })
    end,
}
