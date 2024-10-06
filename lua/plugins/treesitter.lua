local _M = {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
        local treesitter = require("nvim-treesitter.configs")
        local opt = {
            ensure_installed = {
                "lua",
                "vim",
                "c",
                "terraform",
                "python",
                "terraform",
                "hcl"
                --"yaml",
                --"bash",
            },
            highlight = {
                enable = true,
                -- additional_vim_regex_highlighting = true
            },
            indent = {
                enable = true,
            }
        }
        treesitter.setup(opt)
    end,
}

return _M
