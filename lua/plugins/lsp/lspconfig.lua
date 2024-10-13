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

        -- setup each lsp
        local setup_handlers = {
            -- c lang
            clangd = {
                capabilities = capabilities,
                cmd = {
                    "clangd",
                    "--header-insertion=iwyu",
                    "--function-arg-placeholders",
                    "--clang-tidy"
                },
            },
            -- python
            pylsp = {
                capabilities = capabilities,
            },
            -- terraform
            terraformls = {
                capabilities = capabilities,
                -- root_dir = lspconfig.util.root_pattern('.terraform', '.git'),
                filetypes = { "tf", "terraform", "terraform-vars" }
            },
            -- yaml
            yamlls = {
                capabilities = capabilities,
                on_attach = function(client)
                    client.server_capabilities.documentFormattingProvider = true
                end,
            },
            -- markdown
            marksman = {
                capabilities = capabilities,
                root_dir = require('lspconfig').util.root_pattern('README.md', '*.MD')
            },
            -- lua
            lua_ls = {
                capabilities = capabilities,
                on_init = function(client)
                    if client.workspace_folders then
                        local path = client.workspace_folders[1].name
                        if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
                            return
                        end
                    end

                    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                        runtime = {
                            -- Tell the language server which version of Lua you're using
                            -- (most likely LuaJIT in the case of Neovim) See $nvim -v
                            version = 'LuaJIT'
                        },
                        -- Make the server aware of Neovim runtime files
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME,
                                -- Depending on the usage, you might want to add additional paths here.
                                -- "${3rd}/luv/library",
                                -- "${3rd}/busted/library",
                            }
                            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                            -- library = vim.api.nvim_get_runtime_file("", true)
                        }
                    })
                end,
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim", "use" },
                        },
                    },
                },
            },
        }

        -- default setup
        local setup_handler_default = {
            capabilities = capabilities
        }

        -- attach lsp setup handlers
        mason_lspconfig.setup_handlers({
            function(server)
                if setup_handlers[server] then
                    lspconfig[server].setup(setup_handlers[server])
                else
                    lspconfig[server].setup(setup_handler_default)
                end
            end,
        })
    end,
}

-- define autocmd to detect filetype
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    pattern = { "*.tf" },
    group = vim.api.nvim_create_augroup("DetectFiletype", {}),
    callback = function()
        vim.opt.filetype = "terraform"
    end,
})

-- vim.opt.updatetime = 300
-- vim.cmd("highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
-- vim.cmd("highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
-- vim.cmd("highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
return _M
