-- ============================================================
--  lua/animation/wave.lua
--  Hiệu ứng sóng radar: dải sóng tròn đồng tâm MÀU TÍM phát từ
--  vị trí con trỏ lan ra toàn bộ vùng file đang hiển thị, lặp
--  liên tục cho tới khi stop(). Dùng trong lúc flash đang chờ
--  chọn điểm nhảy.
--
--  API:
--    require("animation.wave").start()  -- phát sóng từ con trỏ hiện tại
--    require("animation.wave").stop()   -- dừng ngay + dọn sạch
-- ============================================================

local M = {}

local api  = vim.api
local ring = require("animation.ring")
local ns   = api.nvim_create_namespace("jump_wave")

-- Hằng chỉnh hiệu ứng
local STEP_MS = 15          -- ms mỗi bước lan (rất nhanh)
local TRAIL   = 1           -- 1 vành duy nhất, không đuôi
local ALPHAS  = { 0.22 }    -- hơi sáng hơn nền/chữ, không chói

-- Tạo hl group JumpWave1..TRAIL (tím pha nền), 1 lần khi module load
do
    local theme = require("core.material").colors.theme
    for k = 1, TRAIL do
        api.nvim_set_hl(0, "JumpWave" .. k, {
            bg = ring.blend(theme.purple, theme.dark_bg, ALPHAS[k]),
        })
    end
end

local generation = 0  -- tăng mỗi lần start/stop để giết chuỗi defer cũ
local active_buf = nil

function M.stop()
    generation = generation + 1
    if active_buf and api.nvim_buf_is_valid(active_buf) then
        api.nvim_buf_clear_namespace(active_buf, ns, 0, -1)
    end
    active_buf = nil
end

function M.start()
    M.stop()
    generation = generation + 1
    local gen   = generation
    local bufnr = api.nvim_get_current_buf()
    active_buf  = bufnr

    -- Tâm sóng = ô con trỏ RENDER thật (screenpos tính cả inlay hint, tab)
    local win  = api.nvim_get_current_win()
    local pos  = api.nvim_win_get_cursor(win)
    local row0 = pos[1] - 1
    local ctx  = ring.win_ctx(win)
    local sp   = vim.fn.screenpos(win, pos[1], pos[2] + 1)
    if not ctx or sp.col == 0 then return end
    local center = sp.curscol - ctx.base - 1

    -- Bán kính đủ phủ tới góc viewport xa nhất (cùng metric với ring.offsets)
    local top, bot = vim.fn.line("w0") - 1, vim.fn.line("w$") - 1
    local max_dr = math.max(row0 - top, bot - row0)
    local max_dc = math.max(center, ctx.tmax - center)
    local R = math.ceil(math.sqrt(max_dr * max_dr + (max_dc / 2) * (max_dc / 2))) + TRAIL

    -- Mỗi bước vẽ lại cả dải: vành r là mép (đậm), r-1, r-2 là đuôi nhạt
    -- dần. Vẽ lại mới đổi được màu vành theo vị trí trong đuôi.
    local function step(r)
        if gen ~= generation then return end -- đã stop/start lại
        if not api.nvim_buf_is_valid(bufnr) then return end

        api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        for k = 1, TRAIL do
            local rr = r - k + 1
            if rr >= 1 then
                ring.draw_ring(bufnr, ns, row0, center, rr, "JumpWave" .. k, ctx)
            end
        end

        -- Đuôi đã ra khỏi viewport: phát đợt sóng mới từ tâm
        local next_r = (r - TRAIL > R) and 1 or (r + 1)
        vim.defer_fn(function() step(next_r) end, STEP_MS)
    end

    step(1)
end

return M
