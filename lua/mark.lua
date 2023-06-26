local visualMark = function()
    vim.fn.sign_unplace('marks')
    local bufnr = vim.fn.bufnr()
    local marklist = vim.fn.getmarklist(bufnr)
    local marklist2 = vim.fn.getmarklist()
    for i = 1, #marklist2 do
        if marklist2[i].pos[1] == bufnr then
            marklist[#marklist + 1] = marklist2[i]
        end
    end

    for i = 1, #marklist do
        local mark = marklist[i].mark
        local markchar = mark:sub(2, 2)
        if vim.fn.sign_getdefined(markchar)[1] == nil then
            local hl = "Title"
            if string.match(markchar, '[a-z]') == nil then
                hl = "MoreMsg"
            end
            local sign_opt = {
                text = '›' .. markchar,
                texthl = hl,
            }
            vim.fn.sign_define(markchar, sign_opt)
        end
        local id = vim.fn.char2nr(markchar)
        vim.fn.sign_place(
            id,                            --id
            "marks",                       --group
            markchar,                      --name
            bufnr,                         --buf
            { lnum = marklist[i].pos[2] }) --line nr
    end
end

local delMark = function()
    local bufnr = vim.fn.bufnr()
    local cur_pos = vim.fn.getpos(".")
    local marklist_buf = vim.fn.getmarklist(bufnr)
    local marklist = vim.fn.getmarklist()
    for i = 1, #marklist do
        local mark_bufnr = marklist[i].pos[1]
        if mark_bufnr == bufnr then
            marklist_buf[#marklist_buf + 1] = marklist[i]
        end 
    end
    for i = 1,#marklist_buf do
        local is_curline = marklist_buf[i].pos[2] == cur_pos[2]
        local is_valid = string.match(marklist_buf[i].mark, '^.[a-zA-Z0-9]$') ~= nil
        if is_curline and is_valid then
            vim.cmd("delmark " .. marklist_buf[i].mark:sub(2, 2))
        end
    end
end

vim.opt.signcolumn = "auto:2"

vim.api.nvim_create_augroup("visualmark", {})
vim.api.nvim_create_autocmd('CursorMoved', {
    group = 'visualmark',
    callback = visualMark,
})

vim.api.nvim_set_keymap("n", "<leader>md", "", {
    noremap = true,
    callback = delMark,
})


