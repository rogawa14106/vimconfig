return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim",                   opts = {} },
    },
    opts = function()
        ---@class PluginLspOpts
        local options = {
            -- options for vim.diagnostic.config()
            ---@type vim.diagnostic.Opts
            diagnostics = {
                underline = true,
                update_in_insert = false,
                -- virtual_text = false,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    virt_text_pos = 'right_align'
                    -- prefix = "●",
                },
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "",
                        [vim.diagnostic.severity.WARN] = "",
                        [vim.diagnostic.severity.HINT] = "",
                        [vim.diagnostic.severity.INFO] = "󰋼",
                    },
                },
                float = { border = "rounded" },
            },

            --[[
            -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the inlay hints.
            inlay_hints = {
                enabled = true,
                -- exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
            },
            -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the code lenses.
            codelens = {
                enabled = false,
            },
            -- ]] --
            -- add any global capabilities here
            capabilities = {
                -- offsetEncoding = { "utf-8", "utf-16" },
                workspace = {
                    fileOperations = {
                        didRename = true,
                        willRename = true,
                    },
                },
            },
            -- options for vim.lsp.buf.format
            -- `bufnr` and `filter` is handled by the LazyVim formatter,
            -- but can be also overridden when specified
            format = {
                formatting_options = nil,
                timeout_ms = nil,
            },
            -- LSP Server Settings
            servers = {
                lua_ls = {
                    -- mason = false, -- set to false if you don't want this server to be installed with mason
                    -- Use this to add any additional keymaps
                    -- for specific lsp servers
                    -- ---@type LazyKeysSpec[]
                    -- keys = {},
                    on_attach = function(_, bufnr)
                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    end,
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim", "use" },
                            },
                            workspace = {
                                checkThirdParty = false,
                            },
                            codeLens = {
                                enable = true,
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                            doc = {
                                privateName = { "^_" },
                            },
                            hint = {
                                enable = true,
                                setType = false,
                                paramType = true,
                                paramName = "Disable",
                                semicolon = "Disable",
                                arrayIndex = "Disable",
                            },
                        },
                    },
                },
                clangd = {
                    on_attach = function(_, bufnr)
                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    end,
                }
            },
            -- you can do any additional lsp server setup here
            -- return true if you don't want this server to be setup with lspconfig
            ----@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
            setup = {
                -- example to setup with typescript.nvim
                -- tsserver = function(_, opts)
                --   require("typescript").setup({ server = opts })
                --   return true
                -- end,
                -- Specify * to use this function as a fallback for any server
                -- ["*"] = function(server, opts) end,
            },
        }
        return options
    end,

    ---@param opts PluginLspOpts
    config = function(_, opts)
        local lspconfig = require("lspconfig")
        -- local mason_lspconfig = require("mason-lspconfig")

        -- keymapping
        local keymap = vim.keymap
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(e)
                -- Buffer local keymapping
                -- see :h lsp-buf
                keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover({border='rounded', with=100})<CR>",
                    { buffer = e.buf, silent = true })
                keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.format()<CR>",
                    { buffer = e.buf, silent = true, desc = "vim.lsp.buf.format()" })
                keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { buffer = e.buf, silent = true })
                keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { buffer = e.buf, silent = true })
                keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', { buffer = e.buf, silent = true })
                keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', { buffer = e.buf, silent = true })
                keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", { buffer = e.buf, silent = true })
                keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>", { buffer = e.buf, silent = true })
                keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', { buffer = e.buf, silent = true })
                -- see :h vim-diagnostic
                keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>", { buffer = e.buf, silent = true })
                keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>", { buffer = e.buf, silent = true })
                keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { buffer = e.buf, silent = true })
            end,
        })

        -- TODO inlay_hints
        -- TODO codelens

        -- diagnostic setup
        vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

        -- used to enable autocompletion
        local servers = opts.servers
        local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        local has_blink, blink = pcall(require, "blink.cmp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            has_cmp and cmp_nvim_lsp.default_capabilities() or {},
            has_blink and blink.get_lsp_capabilities() or {},
            opts.capabilities or {}
        )

        -- setup function
        local function setup(server)
            local server_opts = vim.tbl_deep_extend(
                "force", {
                    capabilities = vim.deepcopy(capabilities),
                },
                servers[server] or {}
            )
            if server_opts.enabled == false then
                return
            end

            if opts.setup[server] then
                if opts.setup[server](server, server_opts) then
                    return
                end
            elseif opts.setup["*"] then
                if opts.setup["*"](server, server_opts) then
                    return
                end
            end
            lspconfig[server].setup(server_opts)
            -- print(vim.inspect(server_opts))
        end

        local have_mason, mlsp = pcall(require, "mason-lspconfig")
        local all_mslp_servers = {}
        if have_mason then
            all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
        end

        local ensure_installed = {} ---@type string[]
        for server, server_opts in pairs(servers) do
            if server_opts then
                server_opts = server_opts == true and {} or server_opts
                if server_opts.enabled ~= false then
                    -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
                    if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
                        setup(server)
                    else
                        ensure_installed[#ensure_installed + 1] = server
                    end
                end
            end
        end

        if have_mason then
            mlsp.setup({
                ensure_installed = ensure_installed,
                automatic_installation = { exclude = {} },
                handlers = { setup },
            })
        end
    end,
}
-- vim.opt.updatetime = 300
-- vim.cmd("highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
-- vim.cmd("highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")

--[[
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
            capabilities = capabilities,
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
    -- java(jdtls)
    -- lombokのアノテーションが効かないときは以下実施
    -- 1. lombok.jarをインストールして以下に配置
    --    $HOME/.local/share/java/lombok.jar
    -- 2. .bashrcに以下追記
    --    export JDTLS_JVM_ARGS="-javaagent:$HOME/.local/share/java/lombok.jar"
})
-- ]] --
