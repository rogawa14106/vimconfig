return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 500
    end,
    opts = {
        -- use default settings
        win = {
            border = "rounded", -- none, single, double, shadow
            -- position = "bottom",      -- bottom, top
            -- margin = { 1, 0, 1, 0 },  -- extra window margin [top, right, bottom, left]
            -- padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
            -- winblend = 0,
        },
    }
}
