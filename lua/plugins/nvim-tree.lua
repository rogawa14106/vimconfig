return {
    'nvim-tree/nvim-tree.lua',
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local nvimtree = require('nvim-tree')
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        local api = require("nvim-tree.api")

        nvimtree.setup({
            view = {
                width = 30,
                -- relativenumber = false,
            },
            renderer = {
                group_empty = false,
                indent_markers = {
                    enable = true,
                },
                icons = {
                    glyphs = {
                        git = {
                            unstaged = "󰰐",
                            staged = "󰯬",
                            -- unmerged = "",
                            -- renamed = "➜",
                            untracked = "󰰓",
                            deleted = "󰯵",
                            ignored = "󰰄",
                        }
                    }
                }
            },
            actions = {
                open_file = {
                    window_picker = {
                        enable = false,
                    }
                },
                file_popup = {
                    open_win_config = {
                        border = "rounded",
                    },
                }
            },
            filters = {
                -- dotfiles = true,
                custom = {},
            },
            git = {
                ignore = false,
            },
            on_attach = function(bufnr)
                local function opts(desc)
                    return {
                        desc = "nvim-tree: " .. desc,
                        buffer = bufnr,
                        noremap = true,
                        silent = true,
                        nowait = true
                    }
                end

                -- default mappings
                api.config.mappings.default_on_attach(bufnr)

                -- custom mappings
                vim.keymap.set('n', '<C-[>', api.tree.change_root_to_parent, opts('Up'))
                -- toggle help
                vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
                -- open in image viewr
                vim.keymap.set('n', 'i', function()
                    -- カーソル下のノード取得
                    local node = api.tree.get_node_under_cursor()
                    -- パス取得
                    local abs_path = node.absolute_path

                    -- 画像ファイルでない場合は終了
                    -- TODO luaの正規表現でパイプが使えない。いままでどうしてたっけ。
                    local ext = string.match(abs_path, "%..+$") or ""               -- 対象ファイルの拡張子
                    local image_ext_list = { "jpeg", "jpg", "png", "svg", "webp", } -- 画像ファイル拡張子の一覧
                    local is_image_file = false                                     -- 画像ファイルかどうか

                    for _, image_ext in ipairs(image_ext_list) do
                        if "." .. image_ext == ext then
                            is_image_file = true
                            break
                        end
                    end
                    -- 画像ファイルではない場合は、メッセージを出して終了。
                    if is_image_file == false then
                        vim.notify(
                            "'" .. ext .. "' is not a image file. " ..
                            "if you want to open this file as an image file, add this file extension to image_ext_list.",
                            vim.log.levels.WARN)
                        return
                    end

                    -- osごとに画像ビュワーを変更
                    local cmd = ""
                    if vim.fn.has('linux') then
                        cmd = "eog " .. abs_path
                    elseif vim.fn.has('win32') or vim.fn.has('win64') then
                        cmd = ""
                        -- cmd = 'powershell -Command Invoke-Item " ' .. abs_path .. '"'
                    end
                    -- コマンドを設定していないOSは何もしない
                    if cmd == "" then
                        vim.notify("the cmd to open image viewer is not configured on this OS.", vim.log.levels.ERROR)
                        return
                    end

                    -- 画像ビュワーを非同期で開く
                    vim.fn.jobstart(cmd)
                end, opts('Open: Image viewer'))
            end,
        })

        -- keymap settings
        local keymap = vim.keymap
        -- open explorer in cwd
        keymap.set('n', '<Leader>e', "<CMD>NvimTreeFocus<CR>")
        -- keymap.set('n', '<Leader>e', function()
        -- local path = vim.fn.getcwd()
        -- api.tree.focus()
        -- api.tree.change_root(path)
        -- end)

        -- Open explorer in file path of current file.
        -- keymap.set('n', '<Leader>E', function()
        -- local path = vim.fn.expand("%:p:h")
        -- api.tree.focus()
        -- api.tree.change_root(path)
        -- end)

        -- highlihght settings
        vim.cmd("hi NvimTreeGitDirty guifg=#f39c12")
        vim.cmd("hi NvimTreeGitStagedIcon guifg=#1acd94")
        vim.cmd("hi NvimTreeGitNew guifg=#1a9dc4")
    end
}
