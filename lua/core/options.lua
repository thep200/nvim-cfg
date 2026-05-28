-- ============================================================
-- core/options.lua
-- ============================================================

local opt = vim.opt
local g   = vim.g

-- ============================================================
-- 1. Phím tắt toàn cục (Leader Key)
-- ============================================================
g.mapleader      = " "  -- Dùng phím Space làm phím Leader (Chuẩn hiện đại)
g.maplocalleader = " "

-- ============================================================
-- 2. Giao diện & Trải nghiệm (UI / UX)
-- ============================================================
opt.termguicolors  = true       -- Bắt buộc: Kích hoạt True Color (hỗ trợ mã màu Hex)
opt.background     = "dark"     -- Chế độ nền tối
opt.number         = true       -- Hiển thị số dòng bên trái
opt.relativenumber = true       -- Số dòng tương đối (Giúp tính toán nhảy dòng j/k cực nhanh)
opt.cursorline     = true       -- Highlight dòng con trỏ đang đứng...
opt.cursorlineopt  = "number"   -- ...nhưng chỉ highlight số dòng để đỡ rối mắt
opt.scrolloff      = 5          -- Khi cuộn màn hình, luôn giữ lề 5 dòng ở trên/dưới con trỏ
opt.wrap           = false      -- Không tự động bẻ dòng dài (Giữ nguyên cấu trúc code)
opt.signcolumn     = "yes"      -- Luôn mở cột rìa trái (Dành chỗ cho điểm dừng Debug và Lỗi LSP)
opt.fillchars      = { vert = " ", eob = " " } -- Ẩn ký hiệu đường viền và ký hiệu ~ ở cuối file

-- ============================================================
-- 3. Thanh trạng thái & Không gian làm việc
-- ============================================================
opt.laststatus  = 3      -- Dùng một thanh Statusline duy nhất dưới đáy (Global Status)
opt.showmode    = false  -- Ẩn chữ "-- INSERT --" mặc định (Vì Lualine đã hiện rồi)
opt.showcmd     = true   -- Hiển thị tổ hợp phím đang gõ dở ở góc phải dưới
opt.wildmenu    = true   -- Bật menu gợi ý lệnh khi nhấn phím Tab ở Command Mode
opt.showtabline = 2      -- Luôn luôn hiện thanh Tabline ở trên cùng màn hình

-- ============================================================
-- 4. Thao tác & Bộ nhớ
-- ============================================================
opt.mouse        = "a"           -- Cho phép dùng chuột (click, scroll, select)
opt.clipboard    = "unnamedplus" -- Đồng bộ bộ nhớ (Copy/Paste) với hệ điều hành máy tính
opt.backspace    = { "indent", "eol", "start" }
opt.encoding     = "utf-8"
opt.fileencoding = "utf-8"

-- Tắt tính năng tự tạo file rác (swap, backup) của Vim cũ
opt.swapfile    = false
opt.backup      = false
opt.writebackup = false
opt.undofile    = false

-- ============================================================
-- 5. Định dạng Text & Căn lề (Indent)
-- ============================================================
opt.tabstop     = 4      -- Chiều rộng của 1 phím Tab = 4 khoảng trắng
opt.shiftwidth  = 4      -- Số khoảng trắng thụt vào khi bấm >> hoặc <<
opt.expandtab   = true   -- Chuyển phím Tab thành khoảng trắng
opt.autoindent  = true   -- Tự động thụt lề theo dòng phía trên
opt.smartindent = true   -- Thụt lề thông minh khi mở ngoặc nhọn {}

-- ============================================================
-- 6. Tìm kiếm (Search)
-- ============================================================
opt.incsearch  = true  -- Vừa gõ từ khóa vừa tự động di chuyển đến kết quả
opt.hlsearch   = true  -- Highlight màu vàng tất cả kết quả tìm được
opt.ignorecase = true  -- Không phân biệt hoa/thường khi tìm kiếm...
opt.smartcase  = true  -- ...Nhưng NẾU có gõ chữ Hoa thì sẽ tự động chuyển sang phân biệt

-- ============================================================
-- 7. Autocomplete & Phản hồi hệ thống
-- ============================================================
opt.completeopt = { "menuone", "noinsert", "noselect" } -- Tối ưu hành vi popup của nvim-cmp
opt.shortmess:append("csaIWOoF")                        -- Thu gọn log hệ thống (Fix lỗi đòi nhấn Enter)

opt.autoread    = true  -- Tự động load lại file nếu file bị sửa từ bên ngoài (ví dụ git pull)
opt.updatetime  = 250   -- Thời gian chờ cập nhật (Tính bằng ms). Tối quan trọng cho Git để load nhanh thay đổi
opt.timeoutlen  = 300   -- Thời gian chờ chuỗi phím tắt (Ví dụ gõ Space + f thì chờ chữ f 300ms)
opt.ttimeoutlen = 10    -- Thời gian chờ mã phím hệ thống (Giúp bấm phím ESC không bị khựng)

-- ============================================================
-- 8. Compat patch cho Neovim 0.12+
-- ============================================================
do
    local orig_get_node_text = vim.treesitter.get_node_text
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.treesitter.get_node_text = function(node, source, opts)
        if type(node) == "table" then
            node = node[1]
            if node == nil then return "" end
        end
        return orig_get_node_text(node, source, opts)
    end
end
