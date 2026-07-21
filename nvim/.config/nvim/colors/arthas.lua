-- arthas.lua — colorscheme "Arthas / Lich King"
-- Estetica helada: noche glacial, hielo palido, cian escarcha y purpura de Frostmourne.
-- Runtime colorscheme: se activa con `:colorscheme arthas`.

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "arthas"

-- ── Paleta ────────────────────────────────────────────────────────────────
local c = {
  bg        = "#0b1017", -- fondo: noche congelada
  bg_dark   = "#080c12", -- floats / sidebars
  bg_alt    = "#111a26", -- CursorLine / ColorColumn
  bg_sel    = "#1c2c3d", -- Visual / seleccion de menu
  bg_hl     = "#16222f", -- resaltados suaves

  fg        = "#c7d7e6", -- texto: hielo palido
  fg_dim    = "#8fa3b8", -- texto atenuado
  comment   = "#4f6377", -- comentarios: pizarra fria
  gutter    = "#33475a", -- numeros de linea

  cyan      = "#6fd3e6", -- escarcha: funciones / acento primario
  ice       = "#57a7dd", -- azul glacial: keywords
  pale      = "#9ec7e8", -- azul palido: variables / parametros
  teal      = "#5fbfb0", -- teal frio: strings
  rune      = "#9b93e0", -- purpura runa (Frostmourne): tipos / constantes
  frost     = "#e6f0f8", -- blanco escarcha: numeros / titulos

  red       = "#e07a8b", -- necrotico: errores
  amber     = "#d8c58c", -- oro frio: warnings
  green     = "#7fcf9f", -- menta helada: add / ok
  none      = "NONE",
}

-- ── Helper ────────────────────────────────────────────────────────────────
local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ── UI base ───────────────────────────────────────────────────────────────
hi("Normal",        { fg = c.fg, bg = c.bg })
hi("NormalNC",      { fg = c.fg, bg = c.bg })
hi("NormalFloat",   { fg = c.fg, bg = c.bg_dark })
hi("FloatBorder",   { fg = c.ice, bg = c.bg_dark })
hi("FloatTitle",    { fg = c.cyan, bg = c.bg_dark, bold = true })
hi("ColorColumn",   { bg = c.bg_alt })
hi("Cursor",        { fg = c.bg, bg = c.cyan })
hi("CursorLine",    { bg = c.bg_alt })
hi("CursorColumn",  { bg = c.bg_alt })
hi("CursorLineNr",  { fg = c.cyan, bold = true })
hi("LineNr",        { fg = c.gutter })
hi("SignColumn",    { fg = c.gutter, bg = c.none })
hi("Folded",        { fg = c.fg_dim, bg = c.bg_hl })
hi("FoldColumn",    { fg = c.gutter })
hi("VertSplit",     { fg = c.bg_sel })
hi("WinSeparator",  { fg = c.bg_sel })
hi("Visual",        { bg = c.bg_sel })
hi("VisualNOS",     { bg = c.bg_sel })
hi("Search",        { fg = c.bg, bg = c.ice })
hi("IncSearch",     { fg = c.bg, bg = c.cyan })
hi("CurSearch",     { fg = c.bg, bg = c.cyan })
hi("MatchParen",    { fg = c.frost, bold = true, underline = true })
hi("NonText",       { fg = c.gutter })
hi("Whitespace",    { fg = c.bg_sel })
hi("SpecialKey",    { fg = c.gutter })
hi("Directory",     { fg = c.cyan })
hi("Title",         { fg = c.frost, bold = true })
hi("ErrorMsg",      { fg = c.red })
hi("WarningMsg",    { fg = c.amber })
hi("ModeMsg",       { fg = c.fg_dim })
hi("MoreMsg",       { fg = c.cyan })
hi("Question",      { fg = c.cyan })
hi("WildMenu",      { fg = c.bg, bg = c.cyan })

-- Menus / status / tabs
hi("Pmenu",         { fg = c.fg, bg = c.bg_dark })
hi("PmenuSel",      { fg = c.frost, bg = c.bg_sel, bold = true })
hi("PmenuSbar",     { bg = c.bg_dark })
hi("PmenuThumb",    { bg = c.gutter })
hi("StatusLine",    { fg = c.fg, bg = c.bg_dark })
hi("StatusLineNC",  { fg = c.fg_dim, bg = c.bg_dark })
hi("TabLine",       { fg = c.fg_dim, bg = c.bg_dark })
hi("TabLineFill",   { bg = c.bg_dark })
hi("TabLineSel",    { fg = c.cyan, bg = c.bg, bold = true })

-- ── Sintaxis (legacy) ─────────────────────────────────────────────────────
hi("Comment",       { fg = c.comment, italic = true })
hi("Constant",      { fg = c.frost })
hi("String",        { fg = c.teal })
hi("Character",     { fg = c.teal })
hi("Number",        { fg = c.frost })
hi("Float",         { fg = c.frost })
hi("Boolean",       { fg = c.rune })
hi("Identifier",    { fg = c.pale })
hi("Function",      { fg = c.cyan })
hi("Statement",     { fg = c.ice, bold = false })
hi("Conditional",   { fg = c.ice })
hi("Repeat",        { fg = c.ice })
hi("Label",         { fg = c.ice })
hi("Operator",      { fg = c.fg_dim })
hi("Keyword",       { fg = c.ice })
hi("Exception",     { fg = c.ice })
hi("PreProc",       { fg = c.cyan })
hi("Include",       { fg = c.cyan })
hi("Define",        { fg = c.cyan })
hi("Macro",         { fg = c.cyan })
hi("Type",          { fg = c.rune })
hi("StorageClass",  { fg = c.rune })
hi("Structure",     { fg = c.rune })
hi("Typedef",       { fg = c.rune })
hi("Special",       { fg = c.cyan })
hi("SpecialChar",   { fg = c.amber })
hi("Delimiter",     { fg = c.fg_dim })
hi("Tag",           { fg = c.cyan })
hi("Underlined",    { fg = c.cyan, underline = true })
hi("Error",         { fg = c.red, bold = true })
hi("Todo",          { fg = c.bg, bg = c.amber, bold = true })

-- ── Treesitter ────────────────────────────────────────────────────────────
hi("@comment",              { link = "Comment" })
hi("@variable",             { fg = c.fg })
hi("@variable.builtin",     { fg = c.rune, italic = true })
hi("@variable.parameter",   { fg = c.pale })
hi("@variable.member",      { fg = c.fg })
hi("@constant",             { fg = c.frost })
hi("@constant.builtin",     { fg = c.rune })
hi("@constant.macro",       { fg = c.cyan })
hi("@string",               { fg = c.teal })
hi("@string.escape",        { fg = c.amber })
hi("@string.special",       { fg = c.amber })
hi("@character",            { fg = c.teal })
hi("@number",               { fg = c.frost })
hi("@boolean",              { fg = c.rune })
hi("@float",                { fg = c.frost })
hi("@function",             { fg = c.cyan })
hi("@function.builtin",     { fg = c.cyan, italic = true })
hi("@function.call",        { fg = c.cyan })
hi("@function.method",      { fg = c.cyan })
hi("@function.method.call", { fg = c.cyan })
hi("@constructor",          { fg = c.rune })
hi("@keyword",              { fg = c.ice })
hi("@keyword.function",     { fg = c.ice })
hi("@keyword.operator",     { fg = c.ice })
hi("@keyword.return",       { fg = c.ice, italic = true })
hi("@conditional",          { fg = c.ice })
hi("@repeat",               { fg = c.ice })
hi("@exception",            { fg = c.ice })
hi("@type",                 { fg = c.rune })
hi("@type.builtin",         { fg = c.rune, italic = true })
hi("@type.definition",      { fg = c.rune })
hi("@attribute",            { fg = c.amber })
hi("@property",             { fg = c.fg })
hi("@field",                { fg = c.fg })
hi("@parameter",            { fg = c.pale })
hi("@operator",             { fg = c.fg_dim })
hi("@punctuation.delimiter",{ fg = c.fg_dim })
hi("@punctuation.bracket",  { fg = c.fg_dim })
hi("@punctuation.special",  { fg = c.cyan })
hi("@tag",                  { fg = c.ice })
hi("@tag.attribute",        { fg = c.pale })
hi("@tag.delimiter",        { fg = c.fg_dim })
hi("@namespace",            { fg = c.rune })
hi("@module",               { fg = c.rune })
hi("@text.title",           { fg = c.frost, bold = true })
hi("@text.uri",             { fg = c.cyan, underline = true })
hi("@text.literal",         { fg = c.teal })
hi("@markup.heading",       { fg = c.frost, bold = true })
hi("@markup.link",          { fg = c.cyan, underline = true })
hi("@markup.raw",           { fg = c.teal })

-- ── LSP semantic tokens ───────────────────────────────────────────────────
hi("@lsp.type.class",       { fg = c.rune })
hi("@lsp.type.enum",        { fg = c.rune })
hi("@lsp.type.interface",   { fg = c.rune })
hi("@lsp.type.struct",      { fg = c.rune })
hi("@lsp.type.namespace",   { fg = c.rune })
hi("@lsp.type.function",    { fg = c.cyan })
hi("@lsp.type.method",      { fg = c.cyan })
hi("@lsp.type.property",    { fg = c.fg })
hi("@lsp.type.variable",    { fg = c.fg })
hi("@lsp.type.parameter",   { fg = c.pale })

-- ── Diagnosticos ──────────────────────────────────────────────────────────
hi("DiagnosticError",           { fg = c.red })
hi("DiagnosticWarn",            { fg = c.amber })
hi("DiagnosticInfo",            { fg = c.cyan })
hi("DiagnosticHint",            { fg = c.ice })
hi("DiagnosticOk",              { fg = c.green })
hi("DiagnosticUnderlineError",  { undercurl = true, sp = c.red })
hi("DiagnosticUnderlineWarn",   { undercurl = true, sp = c.amber })
hi("DiagnosticUnderlineInfo",   { undercurl = true, sp = c.cyan })
hi("DiagnosticUnderlineHint",   { undercurl = true, sp = c.ice })
hi("DiagnosticVirtualTextError",{ fg = c.red,   bg = c.bg_hl })
hi("DiagnosticVirtualTextWarn", { fg = c.amber, bg = c.bg_hl })
hi("DiagnosticVirtualTextInfo", { fg = c.cyan,  bg = c.bg_hl })
hi("DiagnosticVirtualTextHint", { fg = c.ice,   bg = c.bg_hl })

-- ── Diff / Git ────────────────────────────────────────────────────────────
hi("DiffAdd",       { bg = "#10261d" })
hi("DiffChange",    { bg = "#13202e" })
hi("DiffDelete",    { bg = "#2a1418", fg = c.red })
hi("DiffText",      { bg = "#1c3346" })
hi("Added",         { fg = c.green })
hi("Changed",       { fg = c.ice })
hi("Removed",       { fg = c.red })
hi("GitSignsAdd",   { fg = c.green })
hi("GitSignsChange",{ fg = c.ice })
hi("GitSignsDelete",{ fg = c.red })

-- ── Plugins comunes de LazyVim ────────────────────────────────────────────
hi("TelescopeNormal",       { fg = c.fg, bg = c.bg_dark })
hi("TelescopeBorder",       { fg = c.ice, bg = c.bg_dark })
hi("TelescopeSelection",    { fg = c.frost, bg = c.bg_sel })
hi("TelescopeMatching",     { fg = c.cyan, bold = true })
hi("TelescopePromptPrefix", { fg = c.cyan })
hi("NeoTreeNormal",         { fg = c.fg, bg = c.bg_dark })
hi("NeoTreeNormalNC",       { fg = c.fg, bg = c.bg_dark })
hi("NeoTreeDirectoryName",  { fg = c.ice })
hi("NeoTreeDirectoryIcon",  { fg = c.ice })
hi("NeoTreeGitModified",    { fg = c.ice })
hi("NeoTreeGitAdded",       { fg = c.green })
hi("NeoTreeGitDeleted",     { fg = c.red })
hi("WhichKey",              { fg = c.cyan })
hi("WhichKeyGroup",         { fg = c.ice })
hi("WhichKeyDesc",          { fg = c.fg })
hi("WhichKeySeparator",     { fg = c.comment })
hi("WhichKeyFloat",         { bg = c.bg_dark })
hi("BlinkCmpMenu",          { fg = c.fg, bg = c.bg_dark })
hi("BlinkCmpMenuBorder",    { fg = c.ice, bg = c.bg_dark })
hi("BlinkCmpLabelMatch",    { fg = c.cyan, bold = true })
hi("LazyNormal",            { fg = c.fg, bg = c.bg_dark })
hi("MiniIconsBlue",         { fg = c.ice })
hi("MiniIconsCyan",         { fg = c.cyan })
