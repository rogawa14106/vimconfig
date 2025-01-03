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
