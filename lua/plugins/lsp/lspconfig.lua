local _M = {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim",                   opts = {} },
    },
    config = function()
        -- import lspconfig
        local lspconfig = require("lspconfig")
        -- import mason-lspconfig
        local mason_lspconfig = require("mason-lspconfig")
        -- import cmp_nvim_lsp
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        -- vim keymap aliase
        local keymap = vim.keymap

        -- TODO LspAttach autocmd
        -- see :h lsp-buf
        keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
        keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.format()<CR>')
        keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
        keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
        -- keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
        -- keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
        keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
        keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
        -- keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
        -- see :h vim-diagnostic
        keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
        keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
        keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')

        --
        --         vim.api.nvim_create_autocmd("LspAttach", {
        --             group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        --             callback = function(e)
        --                 -- see :h vim.lsp.*
        --                 local opts = { buffer = e.buf, silent = true }
        --             end,
        --         })

        -- disable virtual text
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
        )

        -- used to enable autocompletion
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- change the Diagnostic symbls
        local signs = { Error = "", Warn = "", Hint = "", Info = "󰋼" }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        mason_lspconfig.setup_handlers({
            -- default handler
            function(server)
                local opt_default = {
                }
                lspconfig[server].setup(opt_default)
            end,
            -- lua_ls handler
            ["lua_ls"] = function()
                local opt_lua_ls = {
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim", "use" },
                            },
                        },
                    },
                }
                lspconfig.lua_ls.setup(opt_lua_ls)
            end,
            -- clangd handler
            ["clangd"] = function()
                local opt_clangd = {
                    capabilities = capabilities,
                    cmd = {
                        "clangd",
                        "--header-insertion=iwyu",
                        "--function-arg-placeholders",
                        "--clang-tidy"
                    },
                }
                lspconfig.clangd.setup(opt_clangd)
            end,
        })
    end,
}

-- vim.opt.updatetime = 300
-- vim.cmd("highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
-- vim.cmd("highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
-- vim.cmd("highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")

return _M
