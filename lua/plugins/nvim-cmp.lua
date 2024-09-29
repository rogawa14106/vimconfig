local _M = {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        { "L3MON4D3/LuaSnip", version = "v2.*", ild = "make install_jsregexp" },
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
        "onsails/lspkind.nvim",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")
        -- loads vscode style snippets from installed plugins
        require("luasnip.loaders.from_vscode").lazy_load()

        -- define nvim_cmp options
        local cmp_opt = {
            window = {
                completion = cmp.config.window.bordered({ border = 'single' }),
                documentation = cmp.config.window.bordered({ border = 'single' }),
            },
            completion = {
                completeopt = "menu,menuone,preview,noselect",
                --                 col_offset = -3,
                --                 side_padding = 0,
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-k>"] = cmp.mapping.scroll_docs(-1),
                ["<C-j>"] = cmp.mapping.scroll_docs(1),
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
                -- ["<Tab>"] = cmp.mapping.select_next_item(),
            }),
            -- spec completion source
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            }),
            formatting = {
                -- kind: kind of completion text, abbr: completion text, menu: completion menu
                fields = { cmp.ItemField.Kind, cmp.ItemField.Abbr, cmp.ItemField.Menu },
                format = lspkind.cmp_format({
                    -- mode = "synbol",
                    maxwidth = 50,
                    ellipsis_char = "...",
                }),
            },
        }
        -- attach option
        cmp.setup(cmp_opt)

        -- customize highlight settings of cmp_kind
        local kind_highlights = {
            Text = "White",
            Method = "Purple",
            -- Function = "",
            -- Constructor = "",
            Field = "SlateBlue",
            Variable = "LightBlue",
            -- Class = "",
            Interface = "LightGreen",
            -- Module = "",
            -- Property = "",
            -- Unit = "",
            -- Value = "",
            -- Enum = "",
            Keyword = "LightGreen",
            -- Snippet = "",
            -- Color = "",
            -- File = "",
            -- Reference = "",
            -- Folder = "",
            -- EnumMember = "",
            -- Constant = "",
            -- Struct = "",
            -- Event = "",
            -- Operator = "",
            -- TypeParameter = "Green",
        }
        for kind, guifg in pairs(kind_highlights) do
            vim.cmd("highlight CmpItemKind" .. kind .. " guifg=" .. guifg)
        end
    end,
}

return _M
-- Is there a way to change the color for the icon without changing the abbr color as well?
