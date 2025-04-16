return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-buffer",           -- source for text in buffer
        "hrsh7th/cmp-path",             -- source for file system path
        { "L3MON4D3/LuaSnip", version = "v2.*", ild = "make install_jsregexp" },
        "saadparwaiz1/cmp_luasnip",     -- for auto completion
        "rafamadriz/friendly-snippets", -- usefule snippets
        "onsails/lspkind.nvim",         -- vs-code like pictograms
        -- "tseemann/snippy",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")
        -- local snippy = require("snippy")

        -- loads vscode style snippets from installed plugins
        require("luasnip.loaders.from_vscode").lazy_load()

        -- define nvim_cmp options
        cmp.setup({
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
            -- mapping = cmp.mapping.preset.insert({
            -- ["<C-k>"] = cmp.mapping.scroll_docs(-1),
            -- ["<C-j>"] = cmp.mapping.scroll_docs(1),
            -- ["<CR>"] = cmp.mapping.confirm({ select = false }),
            -- ["<Tab>"] = cmp.mapping.select_next_item(),
            -- }),
            mapping = {
                ["<C-n>"] = cmp.mapping(function() cmp.select_next_item() end),
                ["<C-p>"] = cmp.mapping(function() cmp.select_prev_item() end),
                ["<C-k>"] = cmp.mapping(function() cmp.scroll_docs(-1) end),
                ["<C-j>"] = cmp.mapping(function() cmp.scroll_docs(1) end),
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                        -- fallback()
                    elseif luasnip.locally_jumpable(1) then
                        luasnip.jump(1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                        -- fallback()
                    elseif luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            },
            -- spec completion source
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            }),
            formatting = {
                -- kind: kind of completion text, abbr: completion text, menu: completion menu
                expandable_indicator = true,
                fields = { cmp.ItemField.Kind, cmp.ItemField.Abbr, cmp.ItemField.Menu },
                format = lspkind.cmp_format({
                    -- mode = "synbol",
                    maxwidth = 50,
                    ellipsis_char = "...",
                }),
            },
        }
        )

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
    -- opts = function(_, opts)
    -- table.insert(opts.sorting.comparators, 1, require("clangd_extensions.cmp_scores"))
    -- end,
}
