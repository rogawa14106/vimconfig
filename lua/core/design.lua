local M = {}
M.colors = {
    blue = {
        "7ca0f3",
        "6c90e3",
        "5c80d3",
        "4c70c3",
        "3c60b3",
        "2c50a3",
        "1c4093",
        "0c3083",
        -- "3c60b3",
        -- "4c70c3",
        -- "5c80d3",
        -- "6c90e3",
        -- "7ca0f3",
        -- "0c3083",
        -- "1c4093",
        -- "2c50a3",
    },
    mono = {
        "81829h",
        "717284",
        "616274",
        "515264",
        "414254",
        "313244",
        "212234",
        "111224",
    },
    dev = {
        ft = {
            txt = "fdfdfd",
            lua = "fdfdfd",
            vim = "fdfdfd",
            json = "fdfdfd",
            md = "fdfdfd",
        }
    }
}
M.icons = {
    status = {
        add = " ",
        ok = " ",
        ng = ""
    },
    separator = {
        slant_fill_r = "◣",
        slant_fill_l = "◢",
        flat_fill = "█",
        half_fill_l = "▌",
        half_fill_r = "▐",
        slant_out_r = "╲",
        slant_out_l = "╱",
    },
    dev = {
        git = "󰊤 ",
        ft = {
            txt = " ",
            lua = " ",
            vim = " ",
            json = " ",
            md = " ",
        }
    }
}

return M
