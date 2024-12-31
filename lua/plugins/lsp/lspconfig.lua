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
                keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
                -- keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
                keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
                keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
                keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
                keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
                keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                -- see :h vim-diagnostic
                keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
                keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
                keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
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
            float = { border = "rounded" },
        })

        -- hover window ui settings
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
            vim.lsp.handlers.hover,
            {
                border = "rounded", -- "shadow" , "none", "single"
                -- border = border
                -- width = 100,
            }
        )
        -- used to enable autocompletion
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- setup each lsp
        -- default setup
        local default_setup_handler = {
            capabilities = capabilities,
        }
        -- attach lsp setup handlers
        mason_lspconfig.setup_handlers({
            -- default
            function(server)
                lspconfig[server].setup(default_setup_handler)
            end,
            -- lua
            ["lua_ls"] = function(server)
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
                lspconfig[server].setup(opt)
            end,
            -- clangd
            ["clangd"] = function(server)
                local opt = {
                    capabilities = capabilities,
                }
                lspconfig[server].setup(opt)
            end,
            -- python
            ["pylsp"] = function(server)
                local opt = {
                    capabilities = capabilities,
                }
                lspconfig[server].setup(opt)
            end,
            -- terraform
            ["terraformls"] = function(server)
                local opt = {
                    capabilities = capabilities,
                    -- root_dir = lspconfig.util.root_pattern('.terraform', '.git'),
                    -- -- disable highlight by the lsp
                    -- on_attach = function(client, bufnr)
                    -- client.server_capabilities.semanticTokensProvider = nil
                    -- end,
                }
                lspconfig[server].setup(opt)
                -- print(vim.inspect(lspconfig.terraformls))
            end,
            -- yaml
            ["yamlls"] = function(server)
                local opt = {
                    on_attach = function(client)
                        client.server_capabilities.documentFormattingProvider = true
                    end,
                }
                lspconfig[server].setup(opt)
            end,
            -- markdown
            ["marksman"] = function(server)
                local opt = {
                    root_dir = lspconfig.util.root_pattern("README.md", "*.MD"),
                }
                lspconfig[server].setup(opt)
            end,
            -- openscad
            ["openscad_lsp"] = function(server)
                local opt = {
                    capabilities = capabilities,
                }
                lspconfig[server].setup(opt)
            end,
        })
    end,
    opts = {
        servers = {
            -- Ensure mason installs the server
            clangd = {
                keys = {
                    { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
                },
                root_dir = function(fname)
                    return require("lspconfig.util").root_pattern(
                        "Makefile",
                        "configure.ac",
                        "configure.in",
                        "config.h.in",
                        "meson.build",
                        "meson_options.txt",
                        "build.ninja"
                    )(fname) or require("lspconfig.util").root_pattern(
                        "compile_commands.json",
                        "compile_flags.txt"
                    )(fname) or require("lspconfig.util").find_git_ancestor(fname)
                end,
                capabilities = {
                    offsetEncoding = { "utf-16" },
                },
                cmd = {
                    "clangd",
                    "--enable-config",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                    "--fallback-style=llvm",
                },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true,
                },
            },
        },
        setup = {
            clangd = function(_, opts)
                local clangd_ext_opts = LazyVim.opts("clangd_extensions.nvim")
                require("clangd_extensions").setup(
                    vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts })
                )
                return false
            end,
        },
        inlay_hints = { enabled = true },
    },
}
-- vim.opt.updatetime = 300
-- vim.cmd("highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
-- vim.cmd("highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
