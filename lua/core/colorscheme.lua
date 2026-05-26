-- ============================================================
--  core/colorscheme.lua
--  Port từ: appearance.vim
--
--  Theme custom "zed_github_dark" - lấy bảng màu từ Zed editor.
--  Background TRONG SUỐT để kế thừa màu terminal (không set bg).
--
--  CHÚ Ý:
--    - File này được require() ở CUỐI init.lua, sau khi plugin load.
--      Vì vậy các highlight group plugin-specific (NeoTree*, GitSigns*,
--      TelescopeXxx, lualine_*) đều đã tồn tại và có thể override.
--    - Treesitter sẽ ưu tiên capture group mới (vd: @function, @type)
--      hơn group cũ (Function, Type). Ta map CẢ HAI để bật/tắt treesitter
--      đều ổn.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Reset colorscheme cũ (nếu có) - tránh highlight cũ rò rỉ
-- ------------------------------------------------------------
if vim.g.colors_name then
    vim.cmd("highlight clear")
end
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end
vim.g.colors_name = "zed_github_dark"

-- ------------------------------------------------------------
-- 2. Bảng màu (trích từ Zed syntax config) - giữ NGUYÊN tên biến
-- ------------------------------------------------------------
local c = {
    fg         = "#f0f6fc",  -- text mặc định (primary / variable / punctuation)
    comment    = "#9198a1",  -- comment / hint / predictive
    red        = "#ff7b72",  -- keyword / preproc / variable.special
    green      = "#7ee787",  -- string / tag
    orange     = "#ffa657",  -- number / boolean / enum / variant
    purple     = "#d2a8ff",  -- function / function.method
    blue       = "#79c0ff",  -- constant / constructor / type / title / label
    light_blue = "#a5d6ff",  -- operator / property / link_text

    pmenu_bg   = "#161b22",  -- background popup menu (cần bg cụ thể)
    dark_bg    = "#1c1c1c",  -- giả-lập "background tối" cho Search/PmenuSel
    visual_bg  = "#264f78",  -- selection background
}

-- Helper: set highlight ngắn gọn, dùng API native của Neovim
local function hi(group, spec)
    vim.api.nvim_set_hl(0, group, spec)
end

-- ------------------------------------------------------------
-- 3. UI groups - dùng bg = "NONE" để trong suốt (kế thừa terminal)
-- ------------------------------------------------------------
hi("Normal",      { fg = c.fg,      bg = "NONE" })
hi("NonText",     { fg = c.comment, bg = "NONE" })
hi("EndOfBuffer", { fg = c.comment, bg = "NONE" })

-- Ẩn thanh dọc split
hi("VertSplit",    { fg = "NONE", bg = "NONE" })
hi("WinSeparator", { fg = "NONE", bg = "NONE" })

-- Line numbers
hi("LineNr",       { fg = c.comment, bg = "NONE" })
hi("CursorLineNr", { fg = "#d4d4d8", bg = "NONE", bold = true })
hi("CursorLine",   { bg = "NONE" })  -- chỉ highlight số dòng, không bôi cả dòng
hi("SignColumn",   { fg = "NONE", bg = "NONE" })

-- Search / Visual / Match
hi("Search",     { fg = c.dark_bg, bg = c.orange })
hi("IncSearch",  { fg = c.dark_bg, bg = c.orange })
hi("Visual",     { bg = c.visual_bg })
hi("MatchParen", { fg = c.orange,  bg = "NONE", bold = true })

-- Popup menu (autocomplete, wildmenu) - cần bg cụ thể để nổi bật
hi("Pmenu",     { fg = c.fg,      bg = c.pmenu_bg })
hi("PmenuSel",  { fg = c.dark_bg, bg = c.blue })
hi("WildMenu",  { fg = c.dark_bg, bg = c.blue })
hi("PmenuSbar", { bg = c.pmenu_bg })
hi("PmenuThumb",{ bg = c.comment })

-- Float window (telescope, lsp hover, gitsigns preview...)
hi("NormalFloat", { fg = c.fg, bg = "NONE" })
hi("FloatBorder", { fg = c.comment, bg = "NONE" })

-- ------------------------------------------------------------
-- 4. Syntax groups CŨ - giữ tương thích khi treesitter tắt
-- ------------------------------------------------------------
-- comment
hi("Comment",        { fg = c.comment, italic = true })
hi("SpecialComment", { fg = c.comment, italic = true })

-- string
hi("String",      { fg = c.green })
hi("Character",   { fg = c.green })
hi("SpecialChar", { fg = c.orange, italic = true })

-- number / boolean
hi("Number",  { fg = c.orange })
hi("Float",   { fg = c.orange })
hi("Boolean", { fg = c.orange })

-- keyword / preproc / variable.special
hi("Keyword",     { fg = c.red })
hi("Statement",   { fg = c.red })
hi("Conditional", { fg = c.red })
hi("Repeat",      { fg = c.red })
hi("Label",       { fg = c.blue })
hi("Operator",    { fg = c.light_blue })
hi("Exception",   { fg = c.red })
hi("PreProc",     { fg = c.red })
hi("Include",     { fg = c.red })
hi("Define",      { fg = c.red })
hi("Macro",       { fg = c.red })
hi("PreCondit",   { fg = c.red })

-- type / constant / constructor / title
hi("Type",         { fg = c.blue })
hi("StorageClass", { fg = c.red })
hi("Structure",    { fg = c.red })
hi("Typedef",      { fg = c.red })
hi("Constant",     { fg = c.blue })
hi("Title",        { fg = c.blue, bold = true })

-- function
hi("Function", { fg = c.purple })

-- variable / punctuation
hi("Identifier", { fg = c.fg })
hi("Delimiter",  { fg = c.fg })

-- tag
hi("Tag",        { fg = c.green })
hi("htmlTag",    { fg = c.green })
hi("htmlEndTag", { fg = c.green })
hi("xmlTag",     { fg = c.green })

-- special / link
hi("Special",    { fg = c.orange })
hi("Underlined", { fg = c.light_blue, italic = true, underline = true })

-- diff / error / warning
hi("DiffAdd",    { fg = c.green,  bg = "NONE" })
hi("DiffChange", { fg = c.orange, bg = "NONE" })
hi("DiffDelete", { fg = c.red,    bg = "NONE" })
hi("DiffText",   { fg = c.fg,     bg = c.visual_bg, bold = true })
hi("Error",      { fg = c.red,    bg = "NONE", bold = true })
hi("WarningMsg", { fg = c.orange })
hi("ErrorMsg",   { fg = c.red })

-- todo
hi("Todo", { fg = c.orange, bg = "NONE", bold = true, italic = true })

-- ------------------------------------------------------------
-- 5. Treesitter capture groups - map sang theme
--    Đây là điểm khác biệt LỚN nhất với appearance.vim cũ.
--    Treesitter parse Go (và mọi ngôn ngữ khác) chính xác hơn regex,
--    nên ta map từng capture sang đúng màu Zed.
-- ------------------------------------------------------------
hi("@comment",                   { link = "Comment" })
hi("@string",                    { link = "String" })
hi("@string.escape",             { fg = c.orange, italic = true })
hi("@string.regex",              { fg = c.orange, italic = true })
hi("@string.special",            { fg = c.orange, italic = true })
hi("@character",                 { link = "Character" })
hi("@number",                    { link = "Number" })
hi("@float",                     { link = "Float" })
hi("@boolean",                   { link = "Boolean" })

hi("@keyword",                   { fg = c.red })
hi("@keyword.function",          { fg = c.red })   -- "func"
hi("@keyword.return",            { fg = c.red })
hi("@keyword.operator",          { fg = c.red })
hi("@keyword.import",            { fg = c.red })   -- "import" trong Go
hi("@conditional",               { fg = c.red })
hi("@repeat",                    { fg = c.red })
hi("@exception",                 { fg = c.red })
hi("@operator",                  { fg = c.light_blue })
hi("@label",                     { fg = c.blue })
hi("@include",                   { fg = c.red })

hi("@type",                      { fg = c.blue })
hi("@type.builtin",              { fg = c.blue })  -- int, string, bool...
hi("@type.definition",           { fg = c.blue })
hi("@constructor",               { fg = c.blue })
hi("@constant",                  { fg = c.blue })
hi("@constant.builtin",          { fg = c.blue })  -- nil, true, false
hi("@constant.macro",            { fg = c.blue })

hi("@function",                  { fg = c.purple })
hi("@function.call",             { fg = c.purple })  -- gọi hàm
hi("@function.builtin",          { fg = c.purple })
hi("@function.macro",            { fg = c.purple })
hi("@method",                    { fg = c.purple })
hi("@method.call",               { fg = c.purple })

hi("@variable",                  { fg = c.fg })
hi("@variable.builtin",          { fg = c.red })
hi("@parameter",                 { fg = c.fg })
hi("@field",                     { fg = c.light_blue })  -- struct field
hi("@property",                  { fg = c.light_blue })

hi("@punctuation.delimiter",     { fg = c.fg })
hi("@punctuation.bracket",       { fg = c.fg })
hi("@punctuation.special",       { fg = c.orange })

hi("@tag",                       { fg = c.green })
hi("@tag.attribute",             { fg = c.light_blue })
hi("@tag.delimiter",             { fg = c.fg })

-- Một số node Neovim 0.10+ dùng namespace mới (không có @ đầu)
hi("@lsp.type.namespace",        { fg = c.blue })
hi("@lsp.type.type",             { fg = c.blue })
hi("@lsp.type.struct",           { fg = c.blue })
hi("@lsp.type.interface",        { fg = c.blue })
hi("@lsp.type.parameter",        { fg = c.fg })
hi("@lsp.type.property",         { fg = c.light_blue })
hi("@lsp.type.variable",         { fg = c.fg })

-- ------------------------------------------------------------
-- 6. LSP diagnostics - icons & màu
--    Thay thế block g:lsp_diagnostics_signs_* của vim-lsp cũ
-- ------------------------------------------------------------
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

-- Highlight text trong code khi có diagnostic
hi("DiagnosticError", { fg = c.red })
hi("DiagnosticWarn",  { fg = c.orange })
hi("DiagnosticInfo",  { fg = c.blue })
hi("DiagnosticHint",  { fg = c.comment })
-- Tắt underline mặc định của diagnostic (giảm noise)
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.orange })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.blue })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = c.comment })

-- ------------------------------------------------------------
-- 7. Gitsigns (thay GitGutter) - màu cho dấu +/~/- ở sign column
-- ------------------------------------------------------------
hi("GitSignsAdd",          { fg = c.green,  bg = "NONE" })
hi("GitSignsChange",       { fg = c.orange, bg = "NONE" })
hi("GitSignsDelete",       { fg = c.red,    bg = "NONE" })
hi("GitSignsChangedelete", { fg = c.orange, bg = "NONE" })
hi("GitSignsTopdelete",    { fg = c.red,    bg = "NONE" })
hi("GitSignsUntracked",    { fg = c.purple, bg = "NONE" })

-- ------------------------------------------------------------
-- 8. Neo-tree (thay NERDTree) - đồng bộ màu file explorer
-- ------------------------------------------------------------
hi("NeoTreeNormal",        { fg = c.fg,      bg = "NONE" })
hi("NeoTreeNormalNC",      { fg = c.fg,      bg = "NONE" })
hi("NeoTreeDirectoryName", { fg = c.blue })
hi("NeoTreeDirectoryIcon", { fg = c.blue })
hi("NeoTreeFileName",      { fg = c.fg })
hi("NeoTreeRootName",      { fg = c.orange,  bold = true })
hi("NeoTreeIndentMarker",  { fg = c.comment })
hi("NeoTreeExpander",      { fg = c.blue })

-- Git status indicators (Neo-tree đọc git diff sẵn, không cần plugin riêng)
hi("NeoTreeGitAdded",     { fg = c.green })
hi("NeoTreeGitModified",  { fg = c.orange })
hi("NeoTreeGitDeleted",   { fg = c.red })
hi("NeoTreeGitUntracked", { fg = c.purple })
hi("NeoTreeGitRenamed",   { fg = c.blue })
hi("NeoTreeGitConflict",  { fg = c.red })
hi("NeoTreeGitIgnored",   { fg = c.comment })

-- ------------------------------------------------------------
-- 9. Telescope - đồng bộ màu với theme
-- ------------------------------------------------------------
hi("TelescopeNormal",       { fg = c.fg,      bg = "NONE" })
hi("TelescopeBorder",       { fg = c.comment, bg = "NONE" })
hi("TelescopePromptNormal", { fg = c.fg,      bg = "NONE" })
hi("TelescopePromptBorder", { fg = c.comment, bg = "NONE" })
hi("TelescopePromptTitle",  { fg = c.orange,  bold = true })
hi("TelescopeResultsTitle", { fg = c.blue })
hi("TelescopePreviewTitle", { fg = c.purple })
hi("TelescopeSelection",    { fg = c.fg,      bg = c.visual_bg })
hi("TelescopeMatching",     { fg = c.orange,  bold = true })

-- ------------------------------------------------------------
-- 10. nvim-cmp - popup autocomplete
-- ------------------------------------------------------------
hi("CmpItemAbbr",           { fg = c.fg })
hi("CmpItemAbbrMatch",      { fg = c.orange, bold = true })
hi("CmpItemAbbrMatchFuzzy", { fg = c.orange, bold = true })
hi("CmpItemKindFunction",   { fg = c.purple })
hi("CmpItemKindMethod",     { fg = c.purple })
hi("CmpItemKindVariable",   { fg = c.fg })
hi("CmpItemKindField",      { fg = c.light_blue })
hi("CmpItemKindKeyword",    { fg = c.red })
hi("CmpItemKindClass",      { fg = c.blue })
hi("CmpItemKindInterface",  { fg = c.blue })
hi("CmpItemKindStruct",     { fg = c.blue })
hi("CmpItemKindSnippet",    { fg = c.green })
hi("CmpItemMenu",           { fg = c.comment, italic = true })
