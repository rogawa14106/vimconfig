vim.g.loaded_mdp = false
local self = {
    last_winid = -1,
    bufnr = -1,
    preview_path = '',
    is_feeding = false,
}

-- MDPに使用するバッファ情報等の初期化
local create_MDP_buf = function()
    -- mdpが初期済みであることを表すフラグを初期化
    vim.g.loaded_mdp = true
    -- mdp用のバッファを作成
    self.bufnr = vim.api.nvim_create_buf(false, true)
    -- terminalを開く
    vim.api.nvim_buf_call(self.bufnr, function()
        vim.cmd('terminal')
    end)

    -- プレビューをスクロールするためのキーマップを設定
    -- 下移動
    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', 'j', '', {

        callback = function()
            self.is_feeding = true
            local key = vim.api.nvim_replace_termcodes("ij<C-\\><C-N>", true, false, true)
            vim.api.nvim_feedkeys(key, 'n', true)
        end
    })
    -- 上移動
    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', 'k', '', {

        callback = function()
            self.is_feeding = true
            local key = vim.api.nvim_replace_termcodes("ik<C-\\><C-N>", true, false, true)
            vim.api.nvim_feedkeys(key, 'n', true)
        end
    })
    -- 下に10行移動
    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<C-d>', '', {

        callback = function()
            self.is_feeding = true
            local key = vim.api.nvim_replace_termcodes("ijjjjjjjjjj<C-\\><C-N>", true, false, true)
            vim.api.nvim_feedkeys(key, 'n', true)
        end
    })
    -- 上に10行移動
    vim.api.nvim_buf_set_keymap(self.bufnr, 'n', '<C-u>', '', {

        callback = function()
            self.is_feeding = true
            local key = vim.api.nvim_replace_termcodes("ikkkkkkkkkk<C-\\><C-N>", true, false, true)
            vim.api.nvim_feedkeys(key, 'n', true)
        end
    })

    -- TODO 今のとこ意味ない。
    -- feedkeyでノーマルモードに戻ったときに呼び出される自動コマンドを定義
    vim.api.nvim_create_autocmd({ "ModeChanged" }, {
        buffer = self.bufnr,
        callback = function()
            -- feedkey実行後に呼び出されていないのであれば、何もしない。
            if self.is_feeding == false then
                return
            end

            -- feedkey実行後にノーマルモードに戻ったときに実行する処理。
            if self.is_feeding and vim.fn.mode() == 'n' then
                -- print("[MDP] mode: ", vim.fn.mode())
                -- vim.fn.win_gotoid(self.last_winid)
                -- local key = vim.api.nvim_replace_termcodes("<C-w>h", true, false, true)
                -- vim.api.nvim_feedkeys(key, 'n', true)
            end

            -- feedkey実行後かどうかのフラグを折っておく
            self.is_feeding = false
        end

    })
end

-- MDP用のウィンドウを新しく開く
local open_MDP_buf = function()
    vim.api.nvim_open_win(self.bufnr, false, {
        vertical = true,
        split = 'right',
    })
    --プレビュー用のウィンドウにはカーソルラインを表示しない。
    vim.api.nvim_set_option_value("cursorline", false, { win = vim.fn.bufwinid(self.bufnr) })
end

-- mdrを起動して、マークダウンのプレビューを表示
local launch_markdown_parser = function(path_preview_target)
    -- MDPのバッファに入る前にいたウィンドウのIDを控えておく。
    self.last_winid = vim.fn.win_getid()

    -- MDPのバッファが開かれているウィンドウに移動
    vim.fn.win_gotoid(vim.fn.bufwinid(self.bufnr))

    -- mdrコマンド実行
    local cmd_mdr = "mdr " .. path_preview_target
    self.is_feeding = true
    local key = vim.api.nvim_replace_termcodes("iq<CR>" .. cmd_mdr .. "<CR><C-\\><C-N>", true, false, true)
    vim.api.nvim_feedkeys(key, 'nx!', true)
    vim.fn.win_gotoid(self.last_winid)
end

-- MDPのバッファを閉じる
local quit_MDP = function()
    if self.bufnr ~= -1 and vim.fn.bufexists(self.bufnr) == 1 then
        vim.api.nvim_buf_delete(self.bufnr, { force = true })
    end
end

-- MDPを初期化
local init_MDP = function()
    -- 現在バッファがmarkdownファイルでない場合は、終了。
    if vim.fn.expand("%:e") ~= "md" then
        vim.notify("[MDP] current file is not a mark down file.", vim.log.levels.WARN)
        return
    end

    -- MDP用のバッファがなかったら、新規バッファ作成
    quit_MDP() --TODO mdrの更新のワークアラウンド
    if self.bufnr == -1 or vim.fn.bufexists(self.bufnr) == 0 then
        create_MDP_buf()
    end

    -- MDP用のバッファが表示されていない場合、バッファを左に表示する
    local is_mdp_shown = (vim.fn.bufwinid(self.bufnr) == -1)
    if is_mdp_shown then
        open_MDP_buf()
    end

    -- プレビュー対象のファイルのパス
    local path_preview_target = vim.fn.expand("%:p")

    -- マークダウンをプレビューする
    launch_markdown_parser(path_preview_target)
end



vim.api.nvim_set_keymap('n', '<Leader>mdp', '', {
    noremap = true,
    desc = "Open markdown preview",
    callback = function()
        init_MDP()
    end,
})
vim.api.nvim_set_keymap('n', '<Leader>mdc', '', {
    noremap = true,
    desc = "Open markdown preview",
    callback = function()
        quit_MDP()
    end,
})
