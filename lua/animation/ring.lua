-- ============================================================
--  lua/animation/ring.lua
--  Helper dùng chung cho các hiệu ứng vòng tròn (bump, wave):
--  sinh offset vòng tròn, trộn màu, vẽ/xoá một vành trên buffer.
--  Toạ độ làm việc theo CỘT MÀN HÌNH (display col) để thẳng hàng
--  khi dòng có tab indent.
-- ============================================================

local M = {}

local api = vim.api

-- Trộn 2 màu hex, alpha = tỷ lệ màu thứ nhất
function M.blend(hex1, hex2, alpha)
    local r1, g1, b1 = hex1:match("#(%x%x)(%x%x)(%x%x)")
    local r2, g2, b2 = hex2:match("#(%x%x)(%x%x)(%x%x)")
    local function mix(a, b)
        return math.floor(tonumber(a, 16) * alpha + tonumber(b, 16) * (1 - alpha) + 0.5)
    end
    return ("#%02x%02x%02x"):format(mix(r1, r2), mix(g1, g2), mix(b1, b2))
end

-- Offset vòng tròn bán kính r: { dr (dòng), dc (cột màn hình) }.
-- Khoảng cách sqrt(dr^2 + (dc/2)^2): ngang chia 2 bù tỷ lệ ô terminal
-- (cao ~2x rộng). Vòng = vành khăn (r-0.5, r+0.5]. Cache theo r.
local ring_cache = {}
function M.offsets(r)
    if ring_cache[r] then return ring_cache[r] end
    local cells = {}
    for dr = -r, r do
        for dc = -2 * r - 1, 2 * r + 1 do
            local d = math.sqrt(dr * dr + (dc / 2) * (dc / 2))
            if d > r - 0.5 and d <= r + 0.5 then
                table.insert(cells, { dr, dc })
            end
        end
    end
    ring_cache[r] = cells
    return cells
end

-- Tìm ký tự nằm tại cột màn hình sc trong line.
-- Trả về (byte bắt đầu 0-based, độ dài byte, độ rộng màn hình)
-- hoặc nil nếu sc sau EOL.
function M.char_at_scol(line, sc)
    local scol, byte = 0, 0
    for _, ch in ipairs(vim.fn.split(line, "\\zs")) do
        local w = vim.fn.strdisplaywidth(ch, scol)
        if sc < scol + w then
            return byte, #ch, w
        end
        scol = scol + w
        byte = byte + #ch
    end
    return nil
end

-- Ngữ cảnh vẽ theo cửa sổ: toạ độ là CỘT TEXT-AREA đúng như đang render
-- (screenpos tự tính inlay hint, tab, cuộn ngang). base = cột màn hình
-- 0-based nơi text area bắt đầu (vị trí cửa sổ + gutter).
function M.win_ctx(win)
    local info = vim.fn.getwininfo(win)[1]
    if not info then return nil end
    return {
        win  = win,
        base = api.nvim_win_get_position(win)[2] + info.textoff,
        tmax = info.width - info.textoff - 1,
    }
end

-- Tìm ký tự RENDER tại cột text-area tcol của dòng lnum (1-based).
-- Trả về (byte 0-based, độ dài byte, độ rộng ô) / nil nếu rơi vào khe
-- không có ký tự (sau EOL, giữa inlay hint) / "offscreen" nếu dòng
-- không hiển thị.
local function char_at_tcol(ctx, lnum, line, tcol)
    local function sp(b) return vim.fn.screenpos(ctx.win, lnum, b) end
    local s1 = sp(1)
    if s1.col == 0 then return "offscreen" end
    if #line == 0 or tcol < s1.col - ctx.base - 1 then return nil end

    -- Nhị phân: byte lớn nhất có cột bắt đầu <= tcol (screenpos đơn điệu)
    local lo, hi = 1, #line
    while lo < hi do
        local mid = math.ceil((lo + hi) / 2)
        if sp(mid).col - ctx.base - 1 <= tcol then lo = mid else hi = mid - 1 end
    end
    -- Lùi về byte đầu của ký tự (byte nối multibyte có cùng col)
    local c0 = sp(lo).col
    while lo > 1 and sp(lo - 1).col == c0 do lo = lo - 1 end

    local m  = sp(lo)
    local tc = m.col - ctx.base - 1
    local te = m.endcol - ctx.base - 1
    if tcol > te then return nil end -- khe inlay hint hoặc sau EOL

    local nb = lo + 1
    while nb <= #line and sp(nb).col == m.col do nb = nb + 1 end
    return lo - 1, nb - lo, te - tc + 1
end

-- Vẽ 1 vành quanh (row0, center), trả về list extmark id.
--  - Ô có ký tự rộng 1 cột: highlight range (giữ nguyên chữ).
--  - Ô trúng ký tự rộng >1 cột (tab/CJK), khe inlay hint, hoặc sau EOL:
--    overlay 1 ô khoảng trắng ảo đúng vị trí — không loang.
-- ctx từ M.win_ctx(win): toạ độ text-area theo render thật; dòng ngoài
-- màn hình tự bị bỏ. Fallback ctx = { leftcol, top, bot, width }: toạ độ
-- cột hiển thị của buffer (không tính inlay hint) khi buffer không có
-- cửa sổ nào hiện nó.
function M.draw_ring(bufnr, ns, row0, center, radius, hl, ctx)
    local ids = {}
    local line_count = api.nvim_buf_line_count(bufnr)

    for _, off in ipairs(M.offsets(radius)) do
        local r  = row0 + off[1]
        local tc = center + off[2]
        if r >= 0 and r < line_count and tc >= 0 then
            local line = api.nvim_buf_get_lines(bufnr, r, r + 1, false)[1] or ""
            local b, blen, w, win_col, skip

            if ctx.win then
                if tc > ctx.tmax then
                    skip = true
                else
                    b, blen, w = char_at_tcol(ctx, r + 1, line, tc)
                    if b == "offscreen" then
                        skip = true
                        b = nil
                    end
                    win_col = tc
                end
            else
                local top = math.max(ctx.top or 0, 0)
                local bot = math.min(ctx.bot or (line_count - 1), line_count - 1)
                local lc  = ctx.leftcol or 0
                if r < top or r > bot or tc < lc
                    or (ctx.width and tc > lc + ctx.width - 1) then
                    skip = true
                else
                    b, blen, w = M.char_at_scol(line, tc)
                    win_col = tc - lc
                end
            end

            if not skip then
                local ok, id
                if type(b) == "number" and w == 1 then
                    ok, id = pcall(api.nvim_buf_set_extmark, bufnr, ns, r, b, {
                        end_col  = b + blen,
                        hl_group = hl,
                        priority = 300, -- nổi lên trên CursorLine/Visual
                    })
                else
                    ok, id = pcall(api.nvim_buf_set_extmark, bufnr, ns, r,
                        type(b) == "number" and b or #line, {
                        virt_text         = { { " ", hl } },
                        virt_text_pos     = "overlay",
                        virt_text_win_col = win_col,
                        priority          = 300,
                    })
                end
                if ok then table.insert(ids, id) end
            end
        end
    end
    return ids
end

function M.clear_ids(bufnr, ns, ids)
    if not api.nvim_buf_is_valid(bufnr) then return end
    for _, id in ipairs(ids) do
        pcall(api.nvim_buf_del_extmark, bufnr, ns, id)
    end
end

return M
