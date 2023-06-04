require('mason').setup()
require('mason-lspconfig').setup_handlers({ function(server)
    --ensure_insatlled = { "lua_ls", "vimls", "pyright" }
    local lspconfig = require('lspconfig')
    local lua_ls_opt = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = {
                        'vim',
                        'require',
                    },
                },
            },
        },
    }
    lspconfig.lua_ls.setup(lua_ls_opt)

    local opt = {
    }
    require('lspconfig')[server].setup(opt)
end })

vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
--vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
--vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
--vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
--vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
--vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
--vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
--vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)

vim.opt.updatetime = 300
vim.cmd("highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
vim.cmd("highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")
vim.cmd("highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guibg=#104040")

vim.api.nvim_create_augroup('lsp_document_highlight', {})
vim.api.nvim_create_autocmd('CursorHold,CursorHoldI', {
    group = 'lsp_document_highlight',
    callback = (function()
        vim.lsp.buf.document_highlight()
    end)
})
vim.api.nvim_create_autocmd('CursorMoved,CursorMovedI', {
    group = 'lsp_document_highlight',
    callback = (function()
        vim.lsp.buf.clear_references()
    end)
})
