-- enable highlighting
--vim.cmd("TSEnable highlight")
require('nvim-treesitter.configs').setup{
    --ensure_installed = {"lua", "vim"}

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
    }
}
