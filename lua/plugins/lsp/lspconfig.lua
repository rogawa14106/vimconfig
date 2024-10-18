return {
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

        -- keymapping
        local keymap = vim.keymap
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(e)
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

        -- diagnostic setup
        vim.diagnostic.config({
            -- disable virtual text
            virtual_text = false,
            -- change the Diagnostic symbls
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "",
                    [vim.diagnostic.severity.WARN] = "",
                    [vim.diagnostic.severity.HINT] = "",
                    [vim.diagnostic.severity.INFO] = "󰋼",
                },
            },
        })

        -- used to enable autocompletion
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- define autocmd to detect filetype
        vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
            pattern = { "*.tf" },
            group = vim.api.nvim_create_augroup("DetectFiletype", {}),
            callback = function()
                vim.opt.filetype = "terraform"
            end,
        })

        -- setup each lsp
        -- default setup
        local default_setup_handler = {
            capabilities = capabilities
        }
        -- attach lsp setup handlers
        mason_lspconfig.setup_handlers({
            -- default
            function(server)
                lspconfig[server].setup(default_setup_handler)
            end,
            -- lua
            ["lua_ls"] = function()
                local opt = {
                    capabilities = capabilities,
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
            -- clang
            ["clangd"] = function()
                local opt = {
                    capabilities = capabilities,
                    cmd = {
                        "clangd",
                        "--header-insertion=iwyu",
                        "--function-arg-placeholders",
                        "--clang-tidy"
                    },
                }
                lspconfig["clangd"].setup(opt)
            end,
            -- python
            ["pylsp"] = function()
                local opt = {
                    capabilities = capabilities,
                }
                lspconfig["pylsp"].setup(opt)
            end,
            -- terraform
            ["terraformls"] = function()
                local opt = {
                    capabilities = capabilities,
                    -- root_dir = lspconfig.util.root_pattern('.terraform', '.git'),
                    -- -- disable highlight by the lsp
                    -- on_attach = function(client, bufnr)
                    -- client.server_capabilities.semanticTokensProvider = nil
                    -- end,
                }
                lspconfig["terraformls"].setup(opt)
                -- print(vim.inspect(lspconfig.terraformls))
            end,
            -- yaml
            ["yamlls"] = function()
                local opt = {
                    on_attach = function(client)
                        client.server_capabilities.documentFormattingProvider = true
                    end,
                }
                lspconfig["yamlls"].setup(opt)
            end,
            -- markdown
            ["marksman"] = function()
                local opt = {
                    root_dir = lspconfig.util.root_pattern('README.md', '*.MD')
                }
                lspconfig["marksman"].setup(opt)
            end,
        })
    end,
}
-- vim.opt.updatetime = 300
-- vim.cmd("highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
-- vim.cmd("highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
-- vim.cmd("highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
