return {
    "rogawa14106/nvim-translator",
    config = function()
        require('nvim-translator').setup({
            keymap = {
                { src = "en", dst = "ja", key = "<Leader>?", },
                { src = "ja", dst = "en", key = "<Leader>g?", },
            }
        })
    end,
}
