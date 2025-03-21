return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
        "windwp/nvim-ts-autotag",
    },
    -- main = "nvim-treesitter.configs",
    config = function()
        local treesitter = require("nvim-treesitter.configs")
        -- local opt =
        treesitter.setup({
            highlight = {
                enable = true,
                -- list of language that will be disabled
                disable = { "" },
                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                -- additional_vim_regex_highlighting = true,
            },
            indent = {
                enable = true,
            },
            autotag = {
                enable = true
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "gs", -- set to `false` to disable one of the mappings
                    node_incremental = "<Tab>",
                    node_decremental = "<S-Tab>",
                    -- node_incremental = "ga",
                    -- scope_incremental = "grc",
                    -- node_decremental = "gd",
                },
            },
            ensure_installed = {
                "lua",
                "vim",
                "cpp", --clang, cpp
                "python",
                "hcl",
                "terraform",
                "markdown",
                "yaml",
                --"bash",
                "json",
                "gitignore",
            },
            modules = {},
            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = true,
            -- Automatically install missing parsers when entering buffer
            auto_install = false,
            -- List of parsers to ignore installing (for "all")
            ignore_install = { "" },

            -- rainbow = {
            -- enable = true,
            -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
            -- extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
            -- max_file_lines = nil, -- Do not enable for files with more than n lines, int
            -- colors = {}, -- table of hex strings
            -- termcolors = {} -- table of colour name strings
            -- }
        })
        -- vim.opt.runtimepath:append("/some/path/to/store/parsers")
    end,
}
