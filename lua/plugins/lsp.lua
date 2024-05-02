--   ========================= --
--  //      LSP CONFIG     //  --
-- =========================   --

-- {{{ initial setup
-- see :h mason.setup()
require('mason').setup()

-- see :h mason-lspconfig.setup()
require('mason-lspconfig').setup({
    -- A list of servers to automatically install if they're not already installed.
    ensure_insatlled = { "lua_ls", "vimls", "pyright", "clangd" },
})

-- see :h mason-lspconfig.setup_handlers()
require('mason-lspconfig').setup_handlers({
    -- default handler
    function(server)
        local opt_default = {
        }
        require('lspconfig')[server].setup(opt_default)
    end,
    -- lua_ls handler
    ["lua_ls"] = function()
        local opt_lua_ls = {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "use" },
                    },
                },
            },
        }
        require("lspconfig").lua_ls.setup(opt_lua_ls)
    end,
    -- clangd handler
    ["clangd"] = function()
        local opt_clangd = {
--             cmd = {
--                 "clang-format",
--                 "--style={ IndentWidth: 4 }"
--             },
        }
        require("lspconfig").clangd.setup(opt_clangd)
    end,
})
-- }}}
--
-- {{{ key mapping
-- see :h lsp-buf
vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.format()<CR>')
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
-- vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
-- vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
-- vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
-- see :h vim-diagnostic
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
-- }}}
--
-- {{{ disable virtual text
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)
-- }}}
--
-- {{{ vim config
vim.opt.updatetime = 300
vim.cmd("highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
vim.cmd("highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
vim.cmd("highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
-- }}}
--
-- {{{ TODO
-- vim.api.nvim_create_augroup('lsp_document_highlight', {})
-- vim.api.nvim_create_autocmd('CursorHold,CursorHoldI', {
-- group = 'lsp_document_highlight',
-- callback = (function()
-- vim.lsp.buf.document_highlight()
-- end)
-- })
-- vim.api.nvim_create_autocmd('CursorMoved,CursorMovedI', {
-- group = 'lsp_document_highlight',
-- callback = (function()
-- vim.lsp.buf.clear_references()
-- end)
-- })
--}}}
