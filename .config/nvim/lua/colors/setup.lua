local M = {}

function M.setup(colors)
  -- UI
  -- {{{
  vim.highlight.create("ColorColumn", {
    guifg = "none",
    guibg = "none"
  })
  vim.highlight.create("CursorColumn", {
    guibg = colors.graymedium
  })
  vim.highlight.create("CursorLine", {
    guibg = colors.graymedium,
    gui = "none"
  })
  -- vim.highlight.create("Conceal", {
  --   gui = "none"
  -- })
  vim.highlight.create("Cursor", {
    guifg = "none",
    guibg = "none",
    gui = "reverse"
  })
  vim.highlight.create("CursorIM", {
    gui = "none"
  })
  vim.highlight.create("CursorLineNr", {
    guifg = colors.graylight,
    guibg = colors.graymedium,
    gui = "none"
  })
  vim.highlight.create("Directory", {
    guifg = colors.blue,
  })
  vim.highlight.create("DiffAdd", {
    guifg = colors.yellow,
    guibg = colors.white,
    gui = "reverse"
  })
  vim.highlight.create("DiffDelete", {
    guifg = colors.red,
    guibg = colors.white,
    gui = "reverse"
  })
  vim.highlight.create("DiffChange", {
    guifg = colors.blue,
    guibg = colors.white,
    gui = "reverse"
  })
  vim.highlight.create("DiffText", {
    guifg = colors.blue,
    guibg = colors.white,
    gui = "reverse"
  })
  vim.highlight.link("EndOfBuffer", "NonText")
  vim.highlight.create("ErrorMsg", {
    guifg = colors.red,
    guibg = colors.black
  })
  vim.highlight.create("VertSplit", {
    guifg = colors.black,
    guibg = colors.graymedium,
    gui = "reverse"
  })
  vim.highlight.create("Folded", {
    guifg = "none",
    guibg = colors.graymedium
  })
  vim.highlight.create("FoldColumn", {
    guifg = colors.yellow,
    guibg = colors.black
  })
  vim.highlight.create("SignColumn", {
    guifg = "none",
    guibg = colors.black,
  })
  vim.highlight.create("IncSearch", {
    gui = "reverse",
    guifg = colors.yellow,
  })
  vim.highlight.create("LineNr", {
    guifg = colors.graylight,
  })
  vim.highlight.create("MatchParen", {
    guibg = colors.graydark,
  })
  vim.highlight.create("ModeMsg", {
    guifg = colors.blue,
  })
  vim.highlight.create("Error", {
    guifg = colors.red,
    guibg = colors.black
  })
  vim.highlight.create("Ignore", {
    guifg = colors.graymedium,
  })
  vim.highlight.create("InfoPopup", {
    guifg = colors.white,
    guibg = colors.graymedium
  })
  vim.highlight.create("MoreMsg", {
    guifg = colors.blue,
  })
  vim.highlight.create("NonText", {
    guifg = colors.graymedium,
  })
  vim.highlight.create("Normal", {
    guifg = colors.white,
    guibg = colors.black,
  })
  vim.highlight.create("NvimInternalError", {
    guifg = colors.red,
    guibg = colors.black,
  })
  vim.highlight.create("PMenu", {
    guifg = colors.graylight,
    guibg = colors.graymedium,
  })
  vim.highlight.create("PMenuSbar", {
    guifg = colors.white,
    guibg = colors.graymedium,
  })
  vim.highlight.create("PMenuSel", {
    guifg = colors.white,
    guibg = colors.graymedium,
  })
  vim.highlight.create("PMenuThumb", {
    guifg = colors.white,
    guibg = colors.graymedium,
  })
  vim.highlight.create("Question", {
    guifg = colors.blue,
  })
  vim.highlight.create("RedrawDebugClear", {
    guifg = colors.white,
    guibg = colors.graymedium,
  })
  vim.highlight.create("RedrawDebugComposed", {
    guifg = colors.white,
    guibg = colors.graymedium,
  })
  vim.highlight.create("RedrawDebugRecompose", {
    guifg = colors.white,
    guibg = colors.graymedium,
  })
  vim.highlight.create("Search", {
    gui = "reverse",
    guifg = colors.graydark,
  })
  vim.highlight.create("SpecialKey", {
    guifg = colors.blue,
  })
  vim.highlight.create("SpellBad", {
    guifg = colors.red,
    guibg = colors.black,
  })
  vim.highlight.create("SpellCap", {
    guifg = colors.red,
    guibg = colors.black,
  })
  vim.highlight.create("SpellLocal", {
    guifg = colors.red,
    guibg = colors.black,
  })
  vim.highlight.create("SpellRare", {
    guifg = colors.red,
    guibg = colors.black,
  })
  vim.highlight.create("StatusLine", {
    guifg = colors.graydark,
    guibg = colors.graymedium,
    gui = "reverse"
  })
  vim.highlight.create("StatusLineNC", {
    guifg = colors.graymedium,
    guibg = colors.graydark,
    gui = "underline,reverse"
  })
  vim.highlight.create("StatusLineTerm", {
    guifg = colors.blue,
    guibg = "none",
    gui = "reverse"
  })
  vim.highlight.create("StatusLineTermNC", {
    guifg = colors.blue,
    guibg = "none",
    gui = "reverse"
  })
  vim.highlight.create("TabLine", {
    guifg = colors.graydark,
    guibg = colors.graymedium,
  })
  vim.highlight.create("TabLineFill", {
    guifg = colors.graymedium,
    guibg = colors.graymedium,
  })
  vim.highlight.create("TabLineSel", {
    gui = "none"
  })
  vim.highlight.create("Title", {
    guifg = colors.blue
  })
  vim.highlight.create("Todo", {
    guifg = colors.white,
    guibg = colors.graymedium,
  })
  vim.highlight.create("ToolbarButton", {
    guifg = colors.white,
    guibg = colors.graylight,
    gui = "none"
  })
  vim.highlight.create("ToolbarLine", {
    guifg = "none",
    guibg = colors.graymedium
  })
  vim.highlight.create("Underlined", {
    gui = "underline",
    guifg = colors.red
  })
  vim.highlight.create("Visual", {
    guibg = colors.graymedium,
  })
  vim.highlight.create("VisualNOS", {
    guifg = colors.graymedium,
  })
  vim.highlight.create("WarningMsg", {
    guifg = colors.red,
    guibg = "none"
  })
  vim.highlight.create("WildMenu", {
    guifg = colors.blue,
    guibg = colors.graymedium,
  })
  -- }}}

  -- Syntax
  -- {{{
  vim.highlight.create("Comment", {
    guifg = colors.graylight,
    guibg = "none"
  })
  vim.highlight.create("Constant", {
    guifg = colors.red,
  })
  vim.highlight.link("String", "Constant")
  vim.highlight.link("Character", "Constant")
  vim.highlight.link("Number", "Constant")
  vim.highlight.link("Boolean", "Constant")
  vim.highlight.link("Float", "Constant")
  vim.highlight.create("Identifier", {
    guifg = colors.yellow,
    guibg = "none",
    gui = "none"
  })
  vim.highlight.link("Function", "Identifier")
  vim.highlight.create("Statement", {
    guifg = colors.blue,
    guibg = "none",
    gui = "none"
  })
  vim.highlight.link("Conditional", "Statement")
  vim.highlight.link("Repeat", "Statement")
  vim.highlight.link("Label", "Statement")
  vim.highlight.link("Operator", "Statement")
  vim.highlight.link("Keyword", "Statement")
  vim.highlight.link("Exception", "Statement")
  vim.highlight.create("PreProc", {
    guifg = colors.blue,
  })
  vim.highlight.link("Include", "PreProc")
  vim.highlight.link("Define", "PreProc")
  vim.highlight.link("Macro", "PreProc")
  vim.highlight.link("PreCondit", "PreProc")
  vim.highlight.create("Type", {
    guifg = colors.blue,
    guibg = "none",
    gui = "none"
  })
  vim.highlight.link("Storage", "Type")
  vim.highlight.link("Structure", "Type")
  vim.highlight.link("Typedef", "Type")
  vim.highlight.create("Special", {
    guifg = colors.yellow,
  })
  vim.highlight.link("SpecialChar", "Special")
  vim.highlight.link("Tag", "Special")
  vim.highlight.link("Delimiter", "Special")
  vim.highlight.link("SpecialComment", "Special")
  vim.highlight.link("Debug", "Special")
  -- }}}

  -- LSP
  -- {{{
  vim.cmd[[sign define DiagnosticSignError text= linehl= texthl=DiagnosticSignError numhl= ]]
  vim.cmd[[sign define DiagnosticSignWarn text= linehl= texthl=DiagnosticSignWarn numhl= ]]
  vim.cmd[[sign define DiagnosticSignInfo text= linehl= texthl=DiagnosticSignInfo numhl= ]]
  vim.cmd[[sign define DiagnosticSignHint text= linehl= texthl=DiagnosticSignHint numhl=]]

  vim.highlight.create("DiagnosticError", {
    guifg = colors.red,
  })
  vim.highlight.create("DiagnosticWarn", {
    guifg = colors.yellow,
  })
  vim.highlight.create("DiagnosticInfo", {
    guifg = colors.blue,
  })
  vim.highlight.create("DiagnosticHint", {
    guifg = colors.blue,
  })
  -- }}}
end

return M
