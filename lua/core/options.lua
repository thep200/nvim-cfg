-- ============================================================
--  core/options.lua
--  Port từ: general.vim + editor.vim + search.vim
-- ============================================================

local opt = vim.opt
local g   = vim.g

-- ============================================================
--  Leader key - đặt SỚM trước khi plugin load để các keymap
--  dạng <leader>x của plugin map đúng
-- ============================================================
g.mapleader      = " "  -- Space làm leader (chuẩn modern Neovim)
g.maplocalleader = " "

-- ============================================================
--  General - hiển thị & soạn thảo cơ bản
-- ============================================================
opt.mouse       = "a"           -- dùng được chuột (click, scroll, select)
opt.clipboard   = "unnamedplus" -- copy/paste chung với system clipboard
                                -- (unnamedplus dùng cho macOS/Linux X11/Wayland,
                                --  tương đương 'unnamed' trên macOS)
opt.encoding    = "utf-8"
opt.fileencoding = "utf-8"
opt.backspace   = { "indent", "eol", "start" }

-- Quality of life
opt.wildmenu    = true
opt.showcmd     = true
opt.wrap        = false
opt.scrolloff   = 5             -- giữ 5 dòng trên/dưới khi cuộn

-- Line numbers
opt.number         = true
opt.relativenumber = true

-- Status line
-- laststatus = 3: dùng MỘT statusline global cho toàn Neovim
-- (khớp với globalstatus = true của lualine). Lualine cũng tự set, nhưng
-- set ở đây để rõ ý đồ và phòng khi lualine load chậm.
opt.laststatus = 3
opt.showmode   = false          -- ẩn "-- INSERT --" vì lualine đã hiển thị mode

-- Sign column - luôn hiện cột bên trái (cho gitsigns & LSP diagnostics)
opt.signcolumn = "yes"

-- Tốc độ phản hồi - quan trọng cho gitsigns + CursorHold (mặc định 4000ms quá lâu)
opt.updatetime = 250

-- Tắt swap / backup / undo files (giữ nguyên hành vi cũ)
opt.swapfile    = false
opt.backup      = false
opt.writebackup = false
opt.undofile    = false

-- ============================================================
--  Editor - indent
-- ============================================================
opt.tabstop     = 4
opt.shiftwidth  = 4
opt.expandtab   = true
opt.autoindent  = true
opt.smartindent = true

-- ============================================================
--  Search
-- ============================================================
opt.incsearch  = true
opt.hlsearch   = true
opt.ignorecase = true
opt.smartcase  = true           -- nhưng nếu gõ chữ HOA thì lại phân biệt

-- ============================================================
--  Appearance prerequisites
--  (highlight cụ thể nằm ở core/colorscheme.lua)
-- ============================================================
opt.termguicolors = true        -- bật true color (BẮT BUỘC cho hex colors)
opt.background    = "dark"

-- cursorline CHỈ highlight số dòng (giống cấu hình Vim cũ)
opt.cursorline    = true
opt.cursorlineopt = "number"

-- Ẩn các ký tự fillchars để không thấy vạch dọc/eob
opt.fillchars = { vert = " ", eob = " " }

-- ============================================================
--  Completion - hành vi popup autocomplete
--  (nvim-cmp sẽ tận dụng những option này)
-- ============================================================
opt.completeopt = { "menuone", "noinsert", "noselect" }
opt.shortmess:append("c")       -- bỏ thông báo "match N of M"

-- ============================================================
--  Auto-read - kiểm tra file thay đổi từ bên ngoài
--  (logic checktime đặt ở autocmds.lua)
-- ============================================================
opt.autoread = true
opt.showtabline = 2

-- ============================================================
--  Timeout cho chuỗi phím tắt
--  Mặc định 1000ms khiến mỗi prefix-key bị "đợi" 1s
--  -> hạ xuống 300ms cho cảm giác snappy
-- ============================================================
opt.timeoutlen  = 300       -- chờ tối đa 300ms cho next-key của 1 chuỗi
opt.ttimeoutlen = 10        -- timeout cho key code (vd: <Esc>) - ngắn nhất


-- ============================================================
--  FIX: Neovim 0.12 + nvim-treesitter (master branch)
--  match[id] giờ là list of nodes, không phải single node nữa.
--  Wrap get_node_text() để unwrap list -> node đầu tiên.
--  Tham khảo: https://github.com/nvim-treesitter/nvim-treesitter/issues/8636
-- ============================================================
do
    local orig_get_node_text = vim.treesitter.get_node_text
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.treesitter.get_node_text = function(node, source, opts)
        -- TSNode thật là userdata; nếu là table tức là list từ match[id]
        if type(node) == "table" then
            node = node[1]
            if node == nil then return "" end
        end
        return orig_get_node_text(node, source, opts)
    end
end
