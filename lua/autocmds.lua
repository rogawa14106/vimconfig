vim.cmd[[
"{{{ save and load fold state
function! SaveFold() abort
    try
        mkview
    catch
    endtry
endfunction

function! LoadFold() abort
    try
        loadview
        "call HighlightEcho("info", "load fold view")
    catch
    endtry
endfunction

augroup AutoSaveFold
    autocmd!
    autocmd BufWinLeave * call SaveFold()
    autocmd BufReadPost * call LoadFold()
augroup END
"}}}
]]

-- vim.api.nvim_create_augroup( "detectft", {} )
-- vim.api.nvim_create_autocmd('bufwinenter', {
    -- group = 'detectft',
    -- callback = function() 
        -- vim.cmd('filetype detect')
    -- end,
-- })
