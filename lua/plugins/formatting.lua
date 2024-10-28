-- manage code fomatter
return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                yaml = { "prettier" },
                json = { "prettier" },
                markdown = { "prettier" },
                make = { "prettier" },
                -- lua = { "stylua" },
                python = { "isort", "black" },
                c = { "clang-format" },
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            },
        })

        vim.keymap.set({ "n", "v" }, "gf", function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            })
        end, { desc = "Format the file or range (on visual mode)." })
    end,
}
