-- :h treesitter-highlight-groups
require('nvim-treesitter.configs').setup{
    --ensure_installed = {"lua", "vim"}

    highlight = {
        enable = true,
        --additional_vim_regex_highlighting = false
    },
    indent = {
        enable = true,
    }
}

--[[
vim.cmd [[
    "set foldmethod=expr
    set foldexpr=nvim_treesitter#foldexpr()
    "set nofoldenable   
]]

--[[
vim.opt.foldmethod = 'expr'
vim.opt.foldenable = false
]]
