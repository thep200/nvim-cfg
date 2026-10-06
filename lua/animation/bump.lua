-- ============================================================
--  lua/animation/bump.lua
--  Hiệu ứng "bump" kiểu anime: các vòng đồng tâm bung ra quanh
--  một vị trí (gradient đậm dần ra ngoài) rồi tắt dần từ trong
--  ra như sóng lan. Dùng cho flash jump (điểm đi + điểm đáp).
--
--  API: require("animation.bump").bump(bufnr, row, col, opts)
--       row 1-based, col 0-based (khớp nvim_win_get_cursor).
--       opts.interval: ms mỗi bước (mặc định INTERVAL).
-- ============================================================

local M        = {}

local api      = vim.api
local ring     = require("animation.ring")
local ns       = api.nvim_create_namespace("jump_bump")

-- Hằng chỉnh hiệu ứng
local FRAMES   = 3  -- số vòng đồng tâm
local INTERVAL = 25 -- ms giữa các bước (mặc định, override qua opts.interval)
-- Độ đậm từng vòng (pha với nền), gradient TĂNG dần từ trong ra ngoài
local ALPHAS   = { 0.25, 0.45, 0.65 }

-- Tạo hl group JumpBump1..FRAMES từ màu theme, chạy 1 lần khi module load
do
    local theme = require("core.material").colors.theme
    for k = 1, FRAMES do
        api.nvim_set_hl(0, "JumpBump" .. k, {
            bg = ring.blend(theme.green_dark, theme.dark_bg, ALPHAS[k]),
        })
    end
end

-- Bung 1 phát tại (row, col byte).
--  - Mặc định (điểm đến): vòng NỞ ra giữ lại thành FRAMES vòng đồng tâm
--    (ngoài đậm hơn trong), rồi tắt dần từ vòng trong ra vòng ngoài.
--  - opts.reverse = true (điểm xuất phát): đảo ngược — vòng CO từ ngoài
--    vào tâm, càng vào tâm càng đậm, tắt dần từ vòng ngoài vào trong.
-- Mỗi bump quản lý extmark id riêng nên 2 bump chồng nhau không xoá nhầm nhau.
function M.bump(bufnr, row, col, opts)
    opts                  = opts or {}
    local interval        = opts.interval or INTERVAL
    local row0            = row - 1
    -- Tâm fallback khi buffer không hiển thị: cột hiển thị tính từ text
    -- buffer (không biết inlay hint). Đứng trên tab thì lấy ô CUỐI của
    -- tab vì nvim vẽ block cursor ở đó.
    local line            = api.nvim_buf_get_lines(bufnr, row0, row0 + 1, false)[1] or ""
    local prefix_w        = vim.fn.strdisplaywidth(line:sub(1, col))
    local ch              = vim.fn.strcharpart(line:sub(col + 1), 0, 1)
    local ch_w            = ch ~= "" and vim.fn.strdisplaywidth(ch, prefix_w) or 1
    local fallback_center = prefix_w + ch_w - 1
    local ids             = {}

    -- Bước k: các vòng còn sống là [k-FRAMES+1 .. k] chặn trong [1..FRAMES]
    -- (nở ra giữ vòng, rồi tắt dần từ trong ra). VẼ LẠI toàn bộ mỗi bước,
    -- tâm + ctx đọc lại tại chỗ qua screenpos để khớp render thật (inlay
    -- hint, tab, cuộn ngang) kể cả khi view đổi giữa chừng animation.
    local function step(k)
        if not api.nvim_buf_is_valid(bufnr) then return end
        ring.clear_ids(bufnr, ns, ids)
        ids = {}
        local lo = math.max(1, k - FRAMES + 1)
        local hi = math.min(k, FRAMES)
        if lo > hi then return end

        local ctx, center
        local win = api.nvim_get_current_win()
        if api.nvim_win_get_buf(win) == bufnr then
            ctx = ring.win_ctx(win)
            local sp = vim.fn.screenpos(win, row, col + 1)
            if ctx and sp.col ~= 0 then
                center = sp.curscol - ctx.base - 1
            end
        end
        if not center then
            ctx    = { leftcol = 0 }
            center = fallback_center
        end

        for i = lo, hi do
            local radius = opts.reverse and (FRAMES + 1 - i) or i
            vim.list_extend(ids, ring.draw_ring(bufnr, ns, row0, center, radius, "JumpBump" .. i, ctx))
        end
        vim.defer_fn(function() step(k + 1) end, interval)
    end

    step(1)
end

return M
