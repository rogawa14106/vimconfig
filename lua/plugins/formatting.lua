-- manage code fomatter
return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        conform.setup({
            -- [[
            formatters_by_ft = {
                yaml = { "prettier" },
                json = { "prettier" },
                markdown = { "prettier" },
                make = { "prettier" },
                -- lua = { "stylua" },
                -- python = { "isort", "black" },
                python = {},
                -- c = { "clang-format" },
            },
            --]] --

            -- Set this to change the default values when calling conform.format()
            -- This will also affect the default values for format_on_save/format_after_save
            default_format_opts = {
                lsp_format = "fallback",
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            },
            -- Conform will notify you when a formatter errors
            notify_on_error = true,
            -- Conform will notify you when no formatters are available for the buffer
            notify_no_formatters = true,

        })
    end,
}
