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
    },
    orange = {
        "fad7a0",
        "f8c471",
        "f5b041",
        "f39c12",
        "d68910",
        "b9770e",
        "9c640c",
        "7e5109",
    },
    green = {
        "7ccff4",
        "6cbfe4",
        "5cafd4",
        "4c9fb4",
        "3c8fa4",
        "2c7f94",
        "1c6f84",
        "0c5f74",
    },
    purple = {
        "d7bde2",
        "c39bd3",
        "af7ac5",
        "9b59b6",
        "884ea0",
        "76448a",
        "633974",
        "512e5f",
    },
    mono = {
        "81829h",
        "797a8c",
        "616274",
        "515264",
        "414254",
        "313244",
        "212234",
        "111224",
    },
    mode = {
        normal = "4c70c3",
        insert = "c34c70",
        command = "9b59b6",
        visual = "3c8fa4",
        terminal = "797a8c",
    },
    dev = {
        ft = {
            text = "fdfdfd",
            lua = "55a2ff",
            vim = "199f4b",
            json = "fdfd55",
            markdown = "fdfdfd",
            c = "55a2ff",
            python = "3572a5",
            terraform = "7b42bb",
            hcl = "844fba",
            gitignore = "ff6500",
            conf = "989888",
            tmux = "199f4b",
            make = "a32d2a",
        }
    }
}
M.icons = {
    status = {
        add = " ",
        ok = " ",
        ng = "",
    },
    signs = {
        dot = ""
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
            text      = " ",
            lua       = " ",
            vim       = " ",
            json      = " ",
            markdown  = " ",
            c         = " ",
            python    = " ",
            terraform = "󱁢 ",
            hcl       = "󱁢 ",
            gitignore = "󰊤 ",
            sh        = " ",
            conf      = " ",
            tmux      = " ",
            make      = " ",
        }
    }
}

M.set_icon_hi_ft = function(self)
    local icons_ft = self.icons.dev.ft
    local colors_ft = self.colors.dev.ft
    for key, _ in pairs(icons_ft) do
        if colors_ft[key] then
            vim.cmd("hi uFtIcon" .. key .. " guifg=#" .. colors_ft[key] .. " guibg=none")
        end
    end
end
return M
