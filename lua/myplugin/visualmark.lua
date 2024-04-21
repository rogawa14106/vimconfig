-- usage
-- # create mark(vim std features)
--   see :h mark
-- # delete mark
--   <leader>md

local visualMark = function()
    vim.fn.sign_unplace('marks')
    local bufnr = vim.fn.bufnr()
    local marklist = vim.fn.getmarklist()
    local marklist_buf = vim.fn.getmarklist(bufnr)
    -- if the mark is in the current buffer, add mark to the 'marklist_buf'
    for i = 1, #marklist do
        if marklist[i].pos[1] == bufnr then
            marklist_buf[#marklist_buf + 1] = marklist[i]
        end
    end

    -- if the markchar match regex, add mark to the 'marklist_target'
    local marklist_target = {}
    for i = 1, #marklist_buf do
        local markchar = marklist_buf[i].mark
        local reg_display_mark = '[a-zA-Z0-9]'
        if string.match(markchar, reg_display_mark) then
            table.insert(marklist_target, marklist_buf[i])
        end
    end

    -- display mark
    for i = 1, #marklist_target do
        local mark = marklist_target[i].mark
        local markchar = mark:sub(2, 2)
        -- if sign was not defined, define mark
        if vim.fn.sign_getdefined(markchar)[1] == nil then
            local sign_opt = {
                text = "'" .. markchar,
                texthl = "Title",
            }
            vim.fn.sign_define(markchar, sign_opt)
        end

        local id = vim.fn.char2nr(markchar)
        vim.fn.sign_place(
            id,                                  --id
            "marks",                             --group
            markchar,                            --name
            bufnr,                               --buf
            { lnum = marklist_target[i].pos[2] } --line nr
        )
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
    for i = 1, #marklist_buf do
        local is_curline = marklist_buf[i].pos[2] == cur_pos[2]
        local is_valid = string.match(marklist_buf[i].mark, '^.[a-zA-Z0-9]$') ~= nil
        if is_curline and is_valid then
            vim.cmd("delmark " .. marklist_buf[i].mark:sub(2, 2))
        end
    end
end

-- show signcolumn
vim.opt.signcolumn = "yes:2"

-- display mark as sign when cursor moved
vim.api.nvim_create_augroup("visualmark", {})
vim.api.nvim_create_autocmd('CursorMoved', {
    group = 'visualmark',
    callback = visualMark,
})

-- delete mark
vim.api.nvim_set_keymap("n", "<leader>md", "", {
    noremap = true,
    callback = delMark,
})

-- # debug
-- lua print(vim.inspect(vim.api.nvim_get_autocmds({group="visualmark"})))
-- lua vim.api.nvim_del_autocmd(vim.api.nvim_get_autocmds({group="visualmark"})[0].id)
