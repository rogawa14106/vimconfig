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

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(e)
                -- print("Lsp attached")
                -- Buffer local keymapping
                local opts = { buffer = e.buf, silent = true }
                -- see :h lsp-buf
                keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.format()<CR>', opts)
                keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                -- keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                -- keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
                keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                -- keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                -- see :h vim-diagnostic
                keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
                keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
                keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
            end,
        })

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
                    capabilities = capabilities,
                }
                lspconfig[server].setup(opt_default)
            end,
            -- lua_ls handler
            ["lua_ls"] = function()
                local opt = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim", "use" },
                            },
                        },
                    },
                }
                lspconfig["lua_ls"].setup(opt)
            end,
            -- clangd handler
            ["clangd"] = function()
                local opt = {
                    cmd = {
                        "clangd",
                        "--header-insertion=iwyu",
                        "--function-arg-placeholders",
                        "--clang-tidy"
                    },
                }
                lspconfig["clangd"].setup(opt)
            end,
            -- pyright
            ["pylsp"] = function()
                local opt = {}
                lspconfig["pylsp"].setup(opt)
            end,
            -- terraformls
            ["terraformls"] = function()
                local opt = {
                    root_dir = lspconfig.util.root_pattern('.terraform', '.git', 'main.tf')
                }
                lspconfig["terraformls"].setup(opt)
            end,
            -- yamlls
            ["yamlls"] = function()
                local opt = {
                    on_attach = function(client)
                        client.server_capabilities.documentFormattingProvider = true
                        vim.lsp.buf.format() -- TODO: Syntax highlights are not applied unless formatting
                    end,
                    --                     settings = {
                    --                         yaml = {
                    --                             completion = true,
                    --                             schemaStore = {
                    --                                 enable = true,
                    --                             },
                    --                         },
                    --                     },
                }
                lspconfig["yamlls"].setup(opt)
            end,
        })
    end,
}

-- vim.opt.updatetime = 300
-- vim.cmd("highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
-- vim.cmd("highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
-- vim.cmd("highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
vim.lsp.buf.format()
return _M
