return {
    'skanehira/preview-markdown.vim',
    cmd = { 'PreviewMarkdown' },

    config = function()
        vim.cmd("let g:preview_markdown_auto_update=1")
        if vim.fn.has('linux') then
            vim.cmd("!export PATH=$PATH:~/.config/nvim/bin")
        elseif vim.fn.has('win32') then
            vim.cmd("!set PATH=%PATH%;%USERPROFILE%\\AppData\\Local\\nvim\\bin")
        else
            print("ERROR: lua/plugins/preview-markdown.lua: this system does not supported.\n:h feature")
        end
    end,
}
