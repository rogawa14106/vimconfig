-- my colorpalets
local my_colors = {
    unspec = {},
    hl_mono1 = { cterm = "234", gui = "18181c" },
    hl_mono2 = { cterm = "235", gui = "1e1e26" },
    hl_mono3 = { cterm = "236", gui = "303038" },
    hl_mono5 = { cterm = "236", gui = "3d3d50" },
    hl_mono6 = { cterm = "243", gui = "5c5c68" },
    hl_mono7 = { cterm = "250", gui = "787888" },
    hl_mono8 = { cterm = "253", gui = "c0c0d8" },
    hl_mono9 = { cterm = "253", gui = "d8d8e8" },

    hl_blue0 = { cterm = "24", gui = "102038" },
    hl_blue1 = { cterm = "111", gui = "9ba2f3" },
    hl_blue2 = { cterm = "117", gui = "95d0f0" },
    hl_blue3 = { cterm = "75", gui = "439bbc" },

    hl_erro0 = { cterm = "124", gui = "481010" },
    hl_erro1 = { cterm = "9", gui = "c03838" },
    hl_warn0 = { cterm = "3", gui = "505018" },
    hl_safe0 = { cterm = "22", gui = "104810" },

    --hl_emph0 = { cterm="62", gui="74607c" } -- CursorSearch
    hl_emph0 = { cterm = "85", gui = "95f0d0" },  -- Sign, MatchParen, etc
    hl_search = { cterm = "60", gui = "5f5030" }, -- Search

    hl_mnorm = { cterm = "24", gui = "304070" },
    hl_mcomm = { cterm = "58", gui = "583058" },
    --hl_mvisu = { cterm="23", gui="307040" },
    hl_minse = { cterm = "95", gui = "803030" },
    hl_mvisu = { cterm = "23", gui = "15504e" },
    hl_mterm = { cterm = "0", gui = "080810" },
    hl_mtjob = { cterm = "0", gui = "080810" },

    hl_sep01 = { cterm = "237", gui = "282830" },

    hl_str01 = { cterm = "223", gui = "f3c29b" },
    hl_num01 = { cterm = "114", gui = "abddb6" },
    hl_idf02 = { cterm = "229", gui = "f0f0ae" },
    hl_stm02 = { cterm = "218", gui = "f39bbc" },
    hl_prp01 = { cterm = "168", gui = "e69bf3" },
    hl_typ01 = { cterm = "43", gui = "77c89e" },
    hl_spe01 = { cterm = "229", gui = "fff9b3" },
    hl_more0 = { cterm = "140", gui = "c29bf3" },
}

-- highlight configurator
local function set_my_colors(group, fg, bg, attr)
    if (fg['cterm'] ~= nil) then
        vim.cmd("hi!" .. group .. " ctermfg=" .. fg.cterm)
    end

    if (bg['cterm'] ~= nil) then
        vim.cmd("hi!" .. group .. " ctermbg=" .. bg.cterm)
    end

    if (fg['gui'] ~= nil) then
        vim.cmd("hi!" .. group .. " guifg=#" .. fg.gui)
    end

    if (bg['gui'] ~= nil) then
        vim.cmd("hi!" .. group .. " guibg=#" .. bg.gui)
    end
    --attribute
    if (attr ~= "") then
        vim.cmd("hi!" .. group .. " gui=" .. attr .. " cterm=" .. attr)
    end
end
local M = {
    -- tokyonight
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require('tokyonight').setup({
            style = "night",
            transparent = true,
            styles = {
                sidebars = "transparent",
                -- floats = "transparent",
            },
            on_colors = function(colors)
                -- colors.blue = "#" .. my_colors.hl_blue2.gui
                colors.border = colors.blue
            end,
            on_highlights = function(highlights, colors)
                set_my_colors("mModeNormal", my_colors.hl_mono9, my_colors.hl_mnorm, "none")
                set_my_colors("mModeInsert", my_colors.hl_mono9, my_colors.hl_minse, "none")
                set_my_colors("mModeCommand", my_colors.hl_mono9, my_colors.hl_mcomm, "none")
                set_my_colors("mModeVisual", my_colors.hl_mono9, my_colors.hl_mvisu, "none")
                set_my_colors("mModeTerm", my_colors.hl_mono9, my_colors.hl_mterm, "none")
                set_my_colors("mModeTJob", my_colors.hl_mono9, my_colors.hl_mtjob, "none")
            end,
        })
        vim.cmd("colorscheme tokyonight")
    end,
}

return M
