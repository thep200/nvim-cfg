-- ============================================================
-- core/colorscheme.lua
-- ============================================================

-- Reset Theme
if vim.g.colors_name then vim.cmd("highlight clear") end
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.g.colors_name = "zed_github_dark"

-- ============================================================
-- 1. Định nghĩa Bảng Màu Chính (Biến số)
-- ============================================================
local colors = require("core.material").colors.theme

-- Hàm tiện ích gán màu nhanh
local function hi(group, spec)
    vim.api.nvim_set_hl(0, group, spec)
end

-- ============================================================
-- 2. Giao diện Cốt lõi (Core UI) - Trong suốt Background
-- ============================================================
hi("CursorLine",   { bg = colors.cursor_line })
hi("Normal",       { fg = colors.fg,      bg = "NONE" })
hi("NonText",      { fg = colors.comment, bg = "NONE" })
hi("EndOfBuffer",  { fg = colors.comment, bg = "NONE" })
hi("VertSplit",    { fg = "NONE",    bg = "NONE" })
hi("WinSeparator", { fg = "NONE",    bg = "NONE" })
hi("SignColumn",   { fg = "NONE",    bg = "NONE" })
hi("LineNr",       { fg = colors.comment, bg = "NONE" })
hi("CursorLineNr", { fg = colors.fg,      bg = "NONE", bold = true })

hi("Search",     { fg = colors.dark_bg, bg = colors.orange })
hi("IncSearch",  { fg = colors.dark_bg, bg = colors.orange })
hi("Visual",     { bg = colors.visual_bg })
hi("MatchParen", { fg = colors.orange,  bg = "NONE", bold = true })

-- ============================================================
-- 3. Cửa sổ Nổi (Floating Windows & Popup Menus)
-- ============================================================
hi("Pmenu",       { fg = colors.fg,      bg = colors.pmenu_bg })
hi("PmenuSel",    { fg = colors.dark_bg, bg = colors.blue })
hi("PmenuSbar",   { bg = colors.pmenu_bg })
hi("PmenuThumb",  { bg = colors.comment })
hi("WildMenu",    { fg = colors.dark_bg, bg = colors.blue })
hi("NormalFloat", { fg = colors.fg,      bg = "NONE" })
hi("FloatBorder", { fg = colors.comment, bg = "NONE" })

-- ============================================================
-- 4. Cú pháp Cơ bản & TreeSitter
-- ============================================================
-- Text & String
hi("Comment",   { fg = colors.comment, italic = true })
hi("@comment",  { link = "Comment" })
hi("String",    { fg = colors.green })
hi("@string",   { link = "String" })
hi("Number",    { fg = colors.orange })
hi("@number",   { link = "Number" })
hi("Boolean",   { fg = colors.orange })
hi("@boolean",  { link = "Boolean" })

-- Ký tự đặc biệt trong chuỗi -> màu cam
hi("SpecialChar",            { fg = colors.orange })
hi("@string.escape",         { fg = colors.orange })
hi("@string.special",        { fg = colors.orange })
hi("@string.special.symbol", { fg = colors.orange })
hi("@string.regexp",         { fg = colors.orange })
hi("@character.special",     { fg = colors.orange })

-- Keyword & Operator
hi("Keyword",           { fg = colors.red })
hi("@keyword",          { fg = colors.red })
hi("@keyword.function", { fg = colors.red })
hi("@keyword.return",   { fg = colors.red })
hi("@conditional",      { fg = colors.red })
hi("Operator",          { fg = colors.light_blue })
hi("@operator",         { fg = colors.light_blue })

-- Functions & Methods
hi("Function",              { fg = colors.purple })
hi("@function",             { fg = colors.purple })
hi("@function.call",        { fg = colors.purple })
hi("@function.method",      { fg = colors.purple })
hi("@function.method.call", { fg = colors.purple })
hi("@function.builtin",     { fg = colors.purple })
hi("@constructor",          { fg = colors.purple })
hi("@method",               { fg = colors.purple })
hi("@method.call",          { fg = colors.purple })

-- Types & Variables
hi("Type",              { fg = colors.blue })
hi("@type",             { fg = colors.blue })
hi("@type.builtin",     { fg = colors.blue })
hi("Identifier",        { fg = colors.fg })
hi("@variable",         { fg = colors.fg })
hi("@property",         { fg = colors.light_blue })
hi("@field",            { fg = colors.light_blue })
hi("Constant",          { fg = colors.blue })
hi("@constant",         { fg = colors.blue })
hi("@constant.builtin", { fg = colors.blue })
hi("@variable.builtin", { fg = colors.blue })

-- Delimiters
hi("Delimiter",              { fg = colors.fg })
hi("@punctuation.delimiter", { fg = colors.fg })
hi("@punctuation.bracket",   { fg = colors.fg })
hi("@punctuation.special",   { fg = colors.orange })

-- ============================================================
-- 5. LSP Diagnostics & Inlay Hint
-- ============================================================
local diag_signs = {
    { name = "DiagnosticSignError", text = "✗", fg = colors.red },
    { name = "DiagnosticSignWarn",  text = "!", fg = colors.orange },
    { name = "DiagnosticSignInfo",  text = "i", fg = colors.blue },
    { name = "DiagnosticSignHint",  text = "?", fg = colors.comment },
}
for _, s in ipairs(diag_signs) do
    vim.fn.sign_define(s.name, { text = s.text, texthl = s.name, numhl = "" })
    hi(s.name, { fg = s.fg, bg = "NONE" })
end

hi("DiagnosticError", { fg = colors.red })
hi("DiagnosticWarn",  { fg = colors.orange })
hi("DiagnosticInfo",  { fg = colors.blue })
hi("DiagnosticHint",  { fg = colors.comment })

-- Underline (Gạch dưới xoắn)
hi("DiagnosticUnderlineError", { undercurl = true, sp = colors.red })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = colors.orange })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = colors.blue })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = colors.comment })

-- Virtual Text (Chữ mờ ở cuối dòng)
hi("DiagnosticVirtualTextError", { fg = colors.comment, italic = true, bg = "NONE" })
hi("DiagnosticVirtualTextWarn",  { fg = colors.comment, italic = true, bg = "NONE" })
hi("DiagnosticVirtualTextInfo",  { fg = colors.comment, italic = true, bg = "NONE" })
hi("DiagnosticVirtualTextHint",  { fg = colors.comment, italic = true, bg = "NONE" })

-- Inlay Hint (Gợi ý kiểu/tham số từ LSP, in nghiêng)
hi("LspInlayHint", { fg = colors.comment, italic = true, bg = "NONE" })

-- LSP Semantic Tokens (gopls)
hi("@lsp.type.function",                   { fg = colors.purple })
hi("@lsp.type.method",                     { fg = colors.purple })
hi("@lsp.typemod.function.defaultLibrary", { fg = colors.purple })
hi("@lsp.typemod.method.defaultLibrary",   { fg = colors.purple })
hi("@lsp.typemod.function.definition",     { fg = colors.purple })
hi("@lsp.typemod.method.definition",       { fg = colors.purple })
hi("@lsp.typemod.function.declaration",    { fg = colors.purple })
hi("@lsp.typemod.method.declaration",      { fg = colors.purple })

-- ============================================================
-- 6. Tích hợp Plugins (Gitsigns, NeoTree, Telescope, Cmp, Dap)
-- ============================================================

-- Gitsigns
hi("GitSignsAdd",          { fg = colors.green,  bg = "NONE" })
hi("GitSignsChange",       { fg = colors.orange, bg = "NONE" })
hi("GitSignsDelete",       { fg = colors.red,    bg = "NONE" })
hi("GitSignsChangedelete", { fg = colors.orange, bg = "NONE" })

-- Neo-tree
hi("NeoTreeDirectoryName", { fg = colors.blue })
hi("NeoTreeFileName",      { fg = colors.fg })
hi("NeoTreeRootName",      { fg = colors.orange,  bold = true })
hi("NeoTreeIndentMarker",  { fg = colors.comment })
hi("NeoTreeExpander",      { fg = colors.blue })
hi("NeoTreeGitAdded",      { fg = colors.green_dark })
hi("NeoTreeGitUntracked",  { fg = colors.green_dark })
hi("NeoTreeGitModified",   { fg = colors.orange })
hi("NeoTreeGitDeleted",    { fg = colors.red })
hi("NeoTreeGitConflict",   { fg = colors.red })

-- Telescope
hi("TelescopeBorder",       { fg = colors.comment, bg = "NONE" })
hi("TelescopePromptBorder", { fg = colors.comment, bg = "NONE" })
hi("TelescopePromptTitle",  { fg = colors.orange,  bold = true })
hi("TelescopeResultsTitle", { fg = colors.blue })
hi("TelescopeSelection",    { fg = colors.fg,      bg = colors.visual_bg })
hi("TelescopeMatching",     { fg = colors.orange,  bold = true })

-- nvim-cmp
hi("CmpItemAbbr",           { fg = colors.fg })
hi("CmpItemAbbrDeprecated", { fg = colors.comment, strikethrough = true })
hi("CmpItemAbbrMatch",      { fg = colors.orange, bold = true })
hi("CmpItemAbbrMatchFuzzy", { fg = colors.orange, bold = true })
hi("CmpItemMenu",           { fg = colors.comment, italic = true })

-- CompletionItemKind (nhom highlight CmpItemKind<Kind>)
local cmp_kind_colors = {
    Text          = colors.green,
    Method        = colors.purple,
    Function      = colors.purple,
    Constructor   = colors.purple,
    Field         = colors.light_blue,
    Variable      = colors.fg,
    Class         = colors.blue,
    Interface     = colors.blue,
    Module        = colors.blue,
    Property      = colors.light_blue,
    Unit          = colors.blue,
    Value         = colors.orange,
    Enum          = colors.blue,
    Keyword       = colors.red,
    Snippet       = colors.green,
    Color         = colors.orange,
    File          = colors.comment,
    Reference     = colors.comment,
    Folder        = colors.blue,
    EnumMember    = colors.blue,
    Constant      = colors.blue,
    Struct        = colors.blue,
    Event         = colors.orange,
    Operator      = colors.light_blue,
    TypeParameter = colors.blue,
}
for kind, fg in pairs(cmp_kind_colors) do
    hi("CmpItemKind" .. kind, { fg = fg })
end

-- nvim-dap
hi("DapStoppedLine",         { bg = colors.line_bg })
hi("DapBreakpoint",          { fg = colors.red,    bg = "NONE" })
hi("DapBreakpointCondition", { fg = colors.orange, bg = "NONE" })
hi("DapStopped",             { fg = colors.green,  bg = "NONE" })
hi("NvimDapVirtualText",     { fg = colors.comment, italic = true, bg = "NONE" })

-- indent-blankline (ibl)
hi("IblIndent", { fg = colors.indent, bg = "NONE", nocombine = true })
hi("IblScope",  { fg = colors.comment, bg = "NONE", nocombine = true })
hi("IblScope",  { fg = colors.comment, bg = "NONE", nocombine = true })

-- Folded & FoldColumn
hi("Folded", { fg = "NONE", bg = "NONE" })
hi("FoldColumn", { fg = colors.comment, bg = "NONE" })
