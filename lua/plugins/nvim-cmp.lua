local _M =  {
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
        --         local lspkind = require("lspkind")
        cmp.setup({
            completion = {
                completeopt = "menu,menuone,preview,noselect",
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                --                 ["<C-Space>"] = cmp.mapping.complete(),
--                 ["<Tab>"] = cmp.mapping.select_next_item(),
--                 ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                ["<C-n>"] = cmp.mapping.select_next_item(),
                ["<C-p>"] = cmp.mapping.select_prev_item(),
                ["<C-k>"] = cmp.mapping.scroll_docs(-1),
                ["<C-j>"] = cmp.mapping.scroll_docs(1),
                ["<Tab>"] = cmp.mapping.confirm({ select = false }),
            }),
            -- spec completion source
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            }),
            --             formatting = {
            --                 format = lspkind.cmp_format({
            --                     maxwidth = 50,
            --                     ellipsis_char = "...",
            --                 }),
            --                 fields = {},
            --                 expandable_indicator = true,
            --             },
        })
    end,
}

return _M
