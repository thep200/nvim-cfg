-- ============================================================
-- core/projects.lua
-- ============================================================

local M = {}

-- Marker để nhận diện gốc project (đi ngược lên cây thư mục)
M.root_markers = {
    ".git", "go.mod", "go.work", "Makefile",
    "package.json", "Cargo.toml", "pyproject.toml",
    ".hg", ".svn",
}

-- Trả về danh sách thư mục gốc project (gần đây nhất trước, đã lọc trùng)
function M.list()
    local projects = {}
    local seen     = {}

    for _, path in ipairs(vim.v.oldfiles or {}) do
        if path ~= "" and vim.fn.filereadable(path) == 1 then
            local root = vim.fs.root(path, M.root_markers) -- Neovim >= 0.10
            if root and not seen[root] then
                seen[root] = true
                projects[#projects + 1] = root
            end
        end
        if #projects >= 20 then break end -- giới hạn cho gọn dropdown
    end

    return projects
end

-- File mở gần đây nhất nằm trong project (oldfiles đã sắp mới nhất trước)
local function most_recent_file_in(root)
    local prefix = root:gsub("/$", "") .. "/"
    for _, path in ipairs(vim.v.oldfiles or {}) do
        if path ~= ""
            and vim.startswith(path, prefix)
            and vim.fn.filereadable(path) == 1 then
            return path
        end
    end
    return nil
end

-- Lưu (nếu cần) rồi đóng toàn bộ buffer file đang mở, để bắt đầu project mới sạch sẽ.
-- Chỉ động vào buffer file bình thường (bỏ qua neo-tree, terminal, quickfix...).
local function close_all_file_buffers()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf)
            and vim.bo[buf].buflisted
            and vim.bo[buf].buftype == "" then
            local name = vim.api.nvim_buf_get_name(buf)
            -- Lưu trước nếu có thay đổi và file ghi được (tránh mất dữ liệu)
            if vim.bo[buf].modified and name ~= "" and vim.fn.filewritable(name) == 1 then
                pcall(vim.api.nvim_buf_call, buf, function()
                    vim.cmd("silent! write")
                end)
            end
            -- force = false: nếu vẫn còn thay đổi chưa lưu được thì giữ lại, không xoá ép
            pcall(vim.api.nvim_buf_delete, buf, { force = false })
        end
    end
end

-- Mở file vào cửa sổ soạn thảo (không phải neo-tree / floating)
local function open_in_editor(file)
    local target
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local b   = vim.api.nvim_win_get_buf(win)
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg.relative == "" and vim.bo[b].filetype ~= "neo-tree" then
            target = win
            break
        end
    end

    if target then
        vim.api.nvim_set_current_win(target)
    elseif vim.bo.filetype == "neo-tree" then
        -- Chỉ còn cửa sổ neo-tree: tạo split mới để không đè lên cây
        vim.cmd("vsplit")
    end

    vim.cmd("edit " .. vim.fn.fnameescape(file))
end

-- Mở popup chọn project qua vim.ui.select (telescope-ui-select), rồi cd vào project đó
function M.open()
    local projects = M.list()

    if vim.tbl_isempty(projects) then
        vim.notify("Không tìm thấy project gần đây", vim.log.levels.INFO)
        return
    end

    vim.ui.select(projects, {
        prompt      = "Recent projects",
        kind        = "recent_projects",
        format_item = function(dir)
            return vim.fn.fnamemodify(dir, ":~")
        end,
    }, function(choice)
        if not choice then return end

        -- Tìm file gần đây nhất của project TRƯỚC khi đóng buffer
        local recent_file = most_recent_file_in(choice)

        -- Đóng hết buffer hiện tại trước khi sang project mới
        close_all_file_buffers()

        -- Đổi cwd toàn cục. Đổi 'cd' -> 'tcd' nếu muốn cwd riêng theo từng tab.
        vim.cmd("cd " .. vim.fn.fnameescape(choice))

        -- Mở lại neo-tree với root là project mới
        vim.cmd("Neotree dir=" .. vim.fn.fnameescape(choice) .. " reveal=false")

        -- Tự mở file gần đây nhất của project (nếu có) vào cửa sổ soạn thảo
        if recent_file then
            open_in_editor(recent_file)
        end

        vim.notify("Project: " .. vim.fn.fnamemodify((choice:gsub("/$", "")), ":t"), vim.log.levels.INFO)

        -- (Tuỳ chọn) thay vì mở file gần nhất, mở fuzzy find file trong project:
        -- require("telescope.builtin").find_files({ cwd = choice })
    end)
end

return M
