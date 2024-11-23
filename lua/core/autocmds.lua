-- change filetypes
local augrp_ft = vim.api.nvim_create_augroup("UserFiletype", {})
-- clang header file{{{
vim.api.nvim_create_autocmd('BufEnter', {
    group = augrp_ft,
    pattern = { "*.h" },
    callback = function()
        vim.cmd('set filetype=c')
    end,
})
-- }}}

-- terraform satte file{{{
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augrp_ft,
    pattern = { "*.tfstate", "*.tfstate.backup" },
    callback = function()
        vim.bo.filetype = "json"
    end
})
-- }}}

-- folding
local augrp_fold = vim.api.nvim_create_augroup("KeepFoldState", {})
-- save and load folding state{{{
vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
    group = augrp_fold,
    callback = function()
        vim.cmd [[
            try
                mkview
            catch
            endtry
        ]]
    end,
})
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    group = augrp_fold,
    callback = function()
        vim.cmd [[
            try
                loadview
            catch
            endtry
        ]]
    end,
})
-- }}}
