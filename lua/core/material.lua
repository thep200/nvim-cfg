local icons = {
    diagnostics = {
        error = ' ',
        warn  = ' ',
        info  = '󱧢 ',
        hint  = '󰌶 ',
    },

    git = {
        added     = "",
        modified  = "",
        deleted   = "",
        renamed   = "",
        untracked = "",
        conflict  = "",
        ignored   = "",
        unstaged  = "",
        staged    = "",
    },

    git_diff = {
        added    = '+',
        modified = '~',
        removed  = '-',
    },

    git_sign = {
        add          = "+",
        change       = "~",
        delete       = "_",
        topdelete    = "‾",
        changedelete = "~_",
        untracked    = "+",
    },

    doc = {
        func          = "󰊕",
        method        = "",
        struct        = "",
        interface     = "",
        class         = "",
        constructor   = "",
        enum          = "",
        enumMember    = "",
        field         = "",
        property      = "",
        constant      = "",
        variable      = "",
        package       = "",
        module        = "󰏗",
        namespace     = "",
        typeParameter = "",
        string        = "",
        number        = "",
        boolean       = "",
        array         = "",
        object        = "",
    },

    lualine_sep = {
        arrow = {
            component = { left = '', right = '' },
            section   = { left = '', right = '' },
        },
        slant = {
            component = { left = '', right = '' },
            section   = { left = '', right = '' },
        },
        slant_up = {
            component = { left = '', right = '' },
            section   = { left = '', right = '' },
        },
    }
}

local ascii = {
    expand = "▼",
    collapse = "▶",

    line = "│",
    line_dash = "╎",
    line_dash_extended = "┊",

    line_last_corner = "╰",
    line_last_square = "└",
}

local TERMINAL_BG = "#1d1d1d"

local colors = {
    theme = {
        fg         = "#f0f6fc",  -- Mặc định (Biến, Văn bản)
        comment    = "#9198a1",  -- Xám (Comment, Viền, Gợi ý)
        red        = "#ff7b72",  -- Đỏ (Lỗi, Từ khóa, Từ khóa điều kiện)
        green      = "#7ee787",  -- Xanh lá (Chuỗi, Thêm mới, Điểm dừng)
        green_dark = "#22c55e",
        orange     = "#ffa657",  -- Cam (Số, Cảnh báo, Thay đổi)
        purple     = "#d2a8ff",  -- Tím (Hàm, Phương thức)
        blue       = "#79c0ff",  -- Xanh dương (Kiểu dữ liệu, Hằng số)
        light_blue = "#a5d6ff",  -- Xanh nhạt (Toán tử, Thuộc tính)

        -- Màu Background Đặc thù (Popup, Dòng đang chọn)
        pmenu_bg   = "#161b22",  -- Nền Popup Autocomplete
        dark_bg    = "#1c1c1c",  -- Nền Highlight tìm kiếm
        visual_bg  = "#264f78",  -- Nền Bôi đen chữ
        line_bg    = "#1f2937",  -- Nền Dòng Code nổi bật (Debug)
        indent     = "#30363d",  -- Màu Đường Indent (ibl)
    },

    lualine = {
        none      = TERMINAL_BG,
        dark      = "#0d1117",
        fg_med    = "#c9d1d9",

        normal    = "#22c55e",
        insert    = "#ff7b72",
        visual    = "#818cf8",
        replace   = "#3b82f6",
        command   = "#d2a8ff",

        diag_err  = "#ef4444",
        diag_warn = "#fef08a",
        diag_info = "#79c0ff",
        diag_hint = "#fefce8",

        bg_by           = "#1e293b",
        bg_tag_inactive = "#1e293b",
        bg_tag_active   = "#334155",
    }
}

return {
    icons = icons,
    colors = colors,
    ascii = ascii,
}


