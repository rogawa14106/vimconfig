return {
    'lewis6991/gitsigns.nvim',
    config = function()
        require('gitsigns').setup({
            on_attach                    = function(bufnr)
                local gitsigns = require('gitsigns')

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end
                -- Navigation
                map('n', '<Leader>hn', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ '<Leader>hn', bang = true })
                    else
                        gitsigns.nav_hunk('next')
                    end
                end, { desc = "Go to next hunk" })

                map('n', '<Leader>hp', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ '<Leader>hp', bang = true })
                    else
                        gitsigns.nav_hunk('prev')
                    end
                end, { desc = "Go to previous hunk" })
                -- Actions
                map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Stage buffer" })
                map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Reset stage buffer" })
                map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Preview hunk" })
                map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = "Undo stage" })
                map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end,
                    { desc = "See blame on current line" })
                map('n', '<leader>hd', gitsigns.diffthis, { desc = "See diff" })
            end,
            attach_to_untracked          = true,
            current_line_blame           = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
            current_line_blame_opts      = {
                virt_text_pos = 'right_align',   -- 'eol' | 'overlay' | 'right_align'
                delay = 500,
            },
            current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
            preview_config               = {
                border = 'rounded',
            },
        })
    end,
}
