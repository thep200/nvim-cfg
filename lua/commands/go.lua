-- ============================================================
--  lua/commands/go.lua
--  User command riêng cho Go.
--    :GoTag   -> thêm `json:"snake_case"` cho mọi field CHƯA có tag
--                trong struct đang chứa con trỏ
--    :GoUnTag -> xoá toàn bộ tag của các field trong struct đó
--  Cách dùng: đặt con trỏ trong struct rồi gọi command.
--  Căn lề sẽ do gofumpt chỉnh lại khi save.
-- ============================================================

-- PascalCase/camelCase -> snake_case (UserID -> user_id, HTTPServer -> http_server)
local function snake_case(name)
    local out = name
        :gsub("(%l)(%u)", "%1_%2")
        :gsub("(%u+)(%u%l)", "%1_%2")
        :gsub("(%d)(%u)", "%1_%2")
    return out:lower()
end

-- field_declaration_list của struct gần nhất bao quanh con trỏ
local function struct_field_list()
    pcall(function() vim.treesitter.get_parser(0):parse() end)
    local ok, node = pcall(vim.treesitter.get_node)
    if not ok or not node then return nil end
    while node and node:type() ~= "struct_type" do
        node = node:parent()
    end
    if not node then return nil end
    for child in node:iter_children() do
        if child:type() == "field_declaration_list" then
            return child
        end
    end
end

local function fields_of(list)
    local out = {}
    for child in list:iter_children() do
        if child:type() == "field_declaration" then
            table.insert(out, child)
        end
    end
    return out
end

local function add_json_tags()
    local list = struct_field_list()
    if not list then
        vim.notify("GoTag: con trỏ không nằm trong struct", vim.log.levels.WARN)
        return
    end
    local edits = {}
    for _, fd in ipairs(fields_of(list)) do
        local name_node = fd:field("name")[1]
        -- Bỏ qua field đã có tag và field embedded (không có tên)
        if name_node and not fd:field("tag")[1] then
            local name = vim.treesitter.get_node_text(name_node, 0)
            local _, _, erow, ecol = fd:range()
            table.insert(edits, {
                row  = erow,
                col  = ecol,
                text = (' `json:"%s"`'):format(snake_case(name)),
            })
        end
    end
    -- Sửa từ dưới lên để vị trí các edit phía trên không bị lệch
    table.sort(edits, function(a, b) return a.row > b.row end)
    for _, e in ipairs(edits) do
        vim.api.nvim_buf_set_text(0, e.row, e.col, e.row, e.col, { e.text })
    end
end

local function remove_tags()
    local list = struct_field_list()
    if not list then
        vim.notify("GoUnTag: con trỏ không nằm trong struct", vim.log.levels.WARN)
        return
    end
    local edits = {}
    for _, fd in ipairs(fields_of(list)) do
        local tag = fd:field("tag")[1]
        if tag then
            local srow, scol, erow, ecol = tag:range()
            -- Nuốt luôn khoảng trắng đứng trước tag
            local line = vim.api.nvim_buf_get_lines(0, srow, srow + 1, false)[1] or ""
            while scol > 0 and line:sub(scol, scol):match("%s") do
                scol = scol - 1
            end
            table.insert(edits, { srow = srow, scol = scol, erow = erow, ecol = ecol })
        end
    end
    table.sort(edits, function(a, b) return a.srow > b.srow end)
    for _, e in ipairs(edits) do
        vim.api.nvim_buf_set_text(0, e.srow, e.scol, e.erow, e.ecol, { "" })
    end
end

local function go_only(fn)
    return function()
        if vim.bo.filetype ~= "go" then
            vim.notify("Command chỉ dùng cho file Go", vim.log.levels.WARN)
            return
        end
        fn()
    end
end

vim.api.nvim_create_user_command("GoTag", go_only(add_json_tags), {
    desc = "Add snake_case json tags to struct under cursor",
})

vim.api.nvim_create_user_command("GoUnTag", go_only(remove_tags), {
    desc = "Remove all tags from struct under cursor",
})
