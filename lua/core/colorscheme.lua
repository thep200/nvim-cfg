-- ============================================================
-- core/colorscheme.lua
-- Bảng màu Custom (Zed GitHub Dark) với Background trong suốt
-- ============================================================

-- Reset Theme
if vim.g.colors_name then vim.cmd("highlight clear") end
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.g.colors_name = "zed_github_dark"

-- ============================================================
-- 1. Định nghĩa Bảng Màu Chính (Biến số)
-- ============================================================
local c = {
    fg         = "#f0f6fc",  -- Mặc định (Biến, Văn bản)
    comment    = "#9198a1",  -- Xám (Comment, Viền, Gợi ý)
    red        = "#ff7b72",  -- Đỏ (Lỗi, Từ khóa, Từ khóa điều kiện)
    green      = "#7ee787",  -- Xanh lá (Chuỗi, Thêm mới, Điểm dừng)
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
}

-- Hàm tiện ích gán màu nhanh
local function hi(group, spec)
    vim.api.nvim_set_hl(0, group, spec)
end

-- ============================================================
-- 2. Giao diện Cốt lõi (Core UI) - Trong suốt Background
-- ============================================================
hi("Normal",       { fg = c.fg,      bg = "NONE" })
hi("NonText",      { fg = c.comment, bg = "NONE" })
hi("EndOfBuffer",  { fg = c.comment, bg = "NONE" })
hi("VertSplit",    { fg = "NONE",    bg = "NONE" })
hi("WinSeparator", { fg = "NONE",    bg = "NONE" })
hi("SignColumn",   { fg = "NONE",    bg = "NONE" })
hi("LineNr",       { fg = c.comment, bg = "NONE" })
hi("CursorLineNr", { fg = c.fg,      bg = "NONE", bold = true })
hi("CursorLine",   { bg = "NONE" })

hi("Search",     { fg = c.dark_bg, bg = c.orange })
hi("IncSearch",  { fg = c.dark_bg, bg = c.orange })
hi("Visual",     { bg = c.visual_bg })
hi("MatchParen", { fg = c.orange,  bg = "NONE", bold = true })

-- ============================================================
-- 3. Cửa sổ Nổi (Floating Windows & Popup Menus)
-- ============================================================
hi("Pmenu",       { fg = c.fg,      bg = c.pmenu_bg })
hi("PmenuSel",    { fg = c.dark_bg, bg = c.blue })
hi("PmenuSbar",   { bg = c.pmenu_bg })
hi("PmenuThumb",  { bg = c.comment })
hi("WildMenu",    { fg = c.dark_bg, bg = c.blue })
hi("NormalFloat", { fg = c.fg,      bg = "NONE" })
hi("FloatBorder", { fg = c.comment, bg = "NONE" })

-- ============================================================
-- 4. Cú pháp Cơ bản & TreeSitter
-- ============================================================
-- Text & String
hi("Comment",   { fg = c.comment, italic = true })
hi("@comment",  { link = "Comment" })
hi("String",    { fg = c.green })
hi("@string",   { link = "String" })
hi("Number",    { fg = c.orange })
hi("@number",   { link = "Number" })
hi("Boolean",   { fg = c.orange })
hi("@boolean",  { link = "Boolean" })

-- Keyword & Operator
hi("Keyword",           { fg = c.red })
hi("@keyword",          { fg = c.red })
hi("@keyword.function", { fg = c.red })
hi("@keyword.return",   { fg = c.red })
hi("@conditional",      { fg = c.red })
hi("Operator",          { fg = c.light_blue })
hi("@operator",         { fg = c.light_blue })

-- Functions & Methods
hi("Function",              { fg = c.purple })
hi("@function",             { fg = c.purple })
hi("@function.call",        { fg = c.purple })
hi("@function.method",      { fg = c.purple })
hi("@function.method.call", { fg = c.purple })
hi("@function.builtin",     { fg = c.purple })
hi("@constructor",          { fg = c.purple })
hi("@method",               { fg = c.purple })
hi("@method.call",          { fg = c.purple })

-- Types & Variables
hi("Type",              { fg = c.blue })
hi("@type",             { fg = c.blue })
hi("@type.builtin",     { fg = c.blue })
hi("Identifier",        { fg = c.fg })
hi("@variable",         { fg = c.fg })
hi("@property",         { fg = c.light_blue })
hi("@field",            { fg = c.light_blue })
hi("Constant",          { fg = c.blue })
hi("@constant",         { fg = c.blue })
hi("@constant.builtin", { fg = c.blue })
hi("@variable.builtin", { fg = c.blue })

-- Delimiters
hi("Delimiter",              { fg = c.fg })
hi("@punctuation.delimiter", { fg = c.fg })
hi("@punctuation.bracket",   { fg = c.fg })
hi("@punctuation.special",   { fg = c.orange })

-- ============================================================
-- 5. LSP Diagnostics & Inlay Hint
-- ============================================================
local diag_signs = {
    { name = "DiagnosticSignError", text = "✗", fg = c.red },
    { name = "DiagnosticSignWarn",  text = "!", fg = c.orange },
    { name = "DiagnosticSignInfo",  text = "i", fg = c.blue },
    { name = "DiagnosticSignHint",  text = "?", fg = c.comment },
}
for _, s in ipairs(diag_signs) do
    vim.fn.sign_define(s.name, { text = s.text, texthl = s.name, numhl = "" })
    hi(s.name, { fg = s.fg, bg = "NONE" })
end

hi("DiagnosticError", { fg = c.red })
hi("DiagnosticWarn",  { fg = c.orange })
hi("DiagnosticInfo",  { fg = c.blue })
hi("DiagnosticHint",  { fg = c.comment })

-- Underline (Gạch dưới xoắn)
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.orange })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.blue })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = c.comment })

-- Virtual Text (Chữ mờ ở cuối dòng)
hi("DiagnosticVirtualTextError", { fg = c.comment, italic = true, bg = "NONE" })
hi("DiagnosticVirtualTextWarn",  { fg = c.comment, italic = true, bg = "NONE" })
hi("DiagnosticVirtualTextInfo",  { fg = c.comment, italic = true, bg = "NONE" })
hi("DiagnosticVirtualTextHint",  { fg = c.comment, italic = true, bg = "NONE" })

-- Inlay Hint (Gợi ý kiểu/tham số từ LSP, in nghiêng)
hi("LspInlayHint", { fg = c.comment, italic = true, bg = "NONE" })

-- LSP Semantic Tokens (gopls)
hi("@lsp.type.function",                   { fg = c.purple })
hi("@lsp.type.method",                     { fg = c.purple })
hi("@lsp.typemod.function.defaultLibrary", { fg = c.purple })
hi("@lsp.typemod.method.defaultLibrary",   { fg = c.purple })
hi("@lsp.typemod.function.definition",     { fg = c.purple })
hi("@lsp.typemod.method.definition",       { fg = c.purple })
hi("@lsp.typemod.function.declaration",    { fg = c.purple })
hi("@lsp.typemod.method.declaration",      { fg = c.purple })

-- ============================================================
-- 6. Tích hợp Plugins (Gitsigns, NeoTree, Telescope, Cmp, Dap)
-- ============================================================

-- Gitsigns
hi("GitSignsAdd",          { fg = c.green,  bg = "NONE" })
hi("GitSignsChange",       { fg = c.orange, bg = "NONE" })
hi("GitSignsDelete",       { fg = c.red,    bg = "NONE" })
hi("GitSignsChangedelete", { fg = c.orange, bg = "NONE" })

-- Neo-tree
hi("NeoTreeDirectoryName", { fg = c.blue })
hi("NeoTreeFileName",      { fg = c.fg })
hi("NeoTreeRootName",      { fg = c.orange,  bold = true })
hi("NeoTreeIndentMarker",  { fg = c.comment })
hi("NeoTreeExpander",      { fg = c.blue })
hi("NeoTreeGitAdded",      { fg = c.green })
hi("NeoTreeGitModified",   { fg = c.orange })
hi("NeoTreeGitDeleted",    { fg = c.red })

-- Telescope
hi("TelescopeBorder",       { fg = c.comment, bg = "NONE" })
hi("TelescopePromptBorder", { fg = c.comment, bg = "NONE" })
hi("TelescopePromptTitle",  { fg = c.orange,  bold = true })
hi("TelescopeResultsTitle", { fg = c.blue })
hi("TelescopeSelection",    { fg = c.fg,      bg = c.visual_bg })
hi("TelescopeMatching",     { fg = c.orange,  bold = true })

-- nvim-cmp
hi("CmpItemAbbr",           { fg = c.fg })
hi("CmpItemAbbrMatch",      { fg = c.orange, bold = true })
hi("CmpItemAbbrMatchFuzzy", { fg = c.orange, bold = true })
hi("CmpItemKindFunction",   { fg = c.purple })
hi("CmpItemKindVariable",   { fg = c.fg })
hi("CmpItemKindKeyword",    { fg = c.red })
hi("CmpItemKindClass",      { fg = c.blue })

-- nvim-dap
hi("DapBreakpoint",          { fg = c.red,    bg = "NONE" })
hi("DapBreakpointCondition", { fg = c.orange, bg = "NONE" })
hi("DapStopped",             { fg = c.green,  bg = "NONE" })
hi("DapStoppedLine",         { bg = c.line_bg })
hi("NvimDapVirtualText",     { fg = c.comment, italic = true, bg = "NONE" })

-- indent-blankline (ibl)
hi("IblIndent", { fg = c.indent, bg = "NONE", nocombine = true })
hi("IblScope",  { fg = c.comment, bg = "NONE", nocombine = true })
