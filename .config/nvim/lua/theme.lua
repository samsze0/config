local colors = require("colors")

local M = {}

local syntax_hl = {
  Comment = colors.gray_600,
  Boolean = colors.yellow,
  Character = colors.yellow,
  Conditional = colors.gray_blue,
  Constant = colors.yellow,
  Define = colors.gray_blue,
  Delimiter = colors.gray_blue,
  Float = colors.yellow,
  Function = colors.blue,
  Identifier = colors.gray_800,
  Include = colors.blue,
  Keyword = colors.blue,
  Label = colors.blue,
  Number = colors.yellow,
  Operator = colors.gray_blue,
  Preproc = colors.blue,
  Repeat = colors.blue,
  Special = colors.yellow,
  Specialchar = colors.blue,
  Statement = colors.blue,
  Storageclass = colors.blue,
  String = colors.yellow,
  Structure = colors.blue,
  Tag = colors.gray_blue,
  Type = colors.blue,
  Typedef = colors.blue,

  TSAnnotation = colors.gray_blue,
  TSAttribute = colors.gray_blue,
  TSBoolean = colors.yellow_900,
  TSCharacter = colors.yellow_900,
  TSComment = colors.gray_600,
  TSConstructor = colors.blue,
  TSConditional = colors.gray_blue,
  TSConstant = colors.yellow,
  TSConstBuiltin = colors.yellow_900,
  TSConstMacro = colors.gray_blue,
  TSError = colors.red,
  TSException = colors.red,
  TSField = colors.gray_800,
  TSFloat = colors.yellow_900,
  TSFunction = colors.blue,
  TSFuncBuiltin = colors.blue,
  TSFuncMacro = colors.blue,
  TSInclude = colors.gray_blue,
  TSKeyword = colors.gray_blue,
  TSKeywordFunction = colors.gray_blue,
  TSKeywordOperator = colors.gray_blue,
  TSLabel = colors.gray_800,
  TSMethod = colors.blue,
  TSNamespace = colors.blue,
  TSNone = colors.gray_800,
  TSNumber = colors.yellow,
  TSOperator = colors.gray_blue,
  TSParameter = colors.gray_800,
  TSParameterReference = colors.gray_800,
  TSProperty = colors.gray_800,
  TSPunctDelimiter = colors.gray_blue,
  TSPunctBracket = colors.gray_800,
  TSPunctSpecial = colors.gray_800,
  TSRepeat = colors.gray_blue,
  TSString = colors.yellow_900,
  TSStringRegex = colors.gray_800,
  TSStringEscape = colors.gray_600,
  TSSymbol = colors.yellow_900,
  TSTag = colors.gray_blue,
  TSTagDelimiter = colors.gray_blue,
  TSText = colors.gray_800,
  TSEmphasis = colors.yellow_900,
  TSUnderline = colors.gray_100,
  TSStrike = colors.gray_100,
  TSTitle = colors.blue,
  TSLiteral = colors.yellow_900,
  TSURI = colors.gray_blue,
  TSType = colors.blue,
  TSTypeBuiltin = colors.gray_blue,
  TSVariable = colors.gray_800,
  TSVariableBuiltin = colors.gray_blue,
}

---@type table<string, vim.api.keyset.highlight | string>
local hl = setmetatable({}, {
  __newindex = function(tbl, hlgroup, hl)
    -- If type is string, set a link
    if type(hl) == "string" then
      vim.api.nvim_set_hl(0, hlgroup, { link = hl })
      return
    end

    vim.api.nvim_set_hl(0, hlgroup, hl)
  end,
})

---@param opts? {}
function M.setup(opts)
  if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
  vim.cmd("set termguicolors")

  -- stylua: ignore start

  -- Vim editor colors
  hl.Normal = { fg = colors.gray_800, bg = colors.black }
  hl.Bold = { bold = true }
  hl.Debug = { fg = colors.blue }
  hl.Directory = { fg = colors.blue }
  hl.Error = { fg = colors.red }
  hl.ErrorMsg = { fg = colors.red }
  hl.Exception = { fg = colors.red }
  hl.FoldColumn = { fg = colors.gray_600 }
  hl.Folded = { fg = colors.gray_600, bg = colors.gray_200 }
  hl.IncSearch = { fg = colors.true_white, bg = colors.yellow_800 }
  hl.Italic = { italic = true }
  hl.Macro = { fg = colors.blue }
  hl.MatchParen = { bg = colors.gray_400 }
  hl.ModeMsg = { fg = colors.yellow }
  hl.MoreMsg = { fg = colors.yellow }
  hl.Question = { fg = colors.blue }
  hl.Search = { bg = colors.yellow_300 }
  hl.CurSearch = { bg = colors.yellow_300 }
  hl.Substitute = { bg = colors.yellow_500 }
  hl.SpecialKey = { fg = colors.gray_600 }
  hl.TooLong = { fg = colors.blue }
  hl.Underlined = { fg = colors.blue }
  hl.Visual = { bg = colors.gray_400 }
  hl.VisualNOS = { fg = colors.blue }
  hl.WarningMsg = { fg = colors.yellow }
  hl.WildMenu = { fg = colors.yellow, bg = colors.blue }
  hl.Title = { fg = colors.blue }
  hl.Conceal = { fg = colors.blue }
  hl.Cursor = { fg = colors.black, bg = colors.gray_800 }
  hl.NonText = { fg = colors.gray_600 }
  hl.LineNr = { fg = colors.gray_600 }
  hl.SignColumn = { fg = colors.gray_600 }
  hl.WinBar = { fg = colors.gray_800 }
  hl.WinBarNC = { fg = colors.gray_600 }
  hl.VertSplit = { fg = colors.gray_300 }
  hl.ColorColumn = { bg = colors.gray_300 }
  hl.CursorColumn = { bg = colors.gray_300 }
  hl.CursorLine = { bg = colors.gray_300 }
  hl.CursorLineNr = { fg = colors.gray_600, bg = colors.gray_300 }
  hl.QuickFixLine = { bg = colors.gray_300 }
  hl.PMenu = { fg = colors.gray_600, bg = colors.gray_100 }
  hl.PMenuSel = { fg = colors.gray_800, bg = colors.gray_400 }
  hl.PMenuSbar = { bg = colors.gray_300 }
  hl.PMenuThumb = { bg = colors.gray_600 }
  hl.StatusLine = { fg = colors.gray_800, bg = colors.gray_100 }  -- Active status line
  hl.StatusLineNC = { fg = colors.gray_600, bg = colors.gray_100 }  -- Inactive status line
  hl.TabLine = { fg = colors.gray_600, bg = colors.black }  -- Inactive tab
  hl.TabLineFill = {}
  hl.TabLineSel = { fg = colors.gray_800, bg = colors.gray_300 }  -- Active tab

  -- Status line (custom)
  --
  hl.StatusLineCopilotInactive = { fg = colors.gray_600, bg = colors.gray_100 }
  hl.StatusLineCopilotActive = { fg = colors.gray_800, bg = colors.gray_100 }

  hl.StatusLineFileInfo = { fg = colors.gray_600, bg = colors.gray_100 }

  hl.StatusLineGitSignsAdded = { fg = colors.blue, bg = colors.gray_100 }
  hl.StatusLineGitSignsChanged = { fg = colors.yellow, bg = colors.gray_100 }
  hl.StatusLineGitSignsRemoved = { fg = colors.red, bg = colors.gray_100 }
  hl.StatusLineGitSignsHead = { fg = colors.gray_800, bg = colors.gray_100 }

  hl.StatusLineDiagnosticError = { fg = colors.red, bg = colors.gray_100 }
  hl.StatusLineDiagnosticWarn = { fg = colors.yellow, bg = colors.gray_100 }
  hl.StatusLineDiagnosticInfo = { fg = colors.blue, bg = colors.gray_100 }
  hl.StatusLineDiagnosticHint = { fg = colors.blue, bg = colors.gray_100 }

  -- Standard syntax highlighting
  hl.Comment = { fg = syntax_hl.Comment }
  hl.Boolean = { fg = syntax_hl.Boolean }
  hl.Character = { fg = syntax_hl.Character }
  hl.Conditional = { fg = syntax_hl.Conditional }
  hl.Constant = { fg = syntax_hl.Constant }
  hl.Define = { fg = syntax_hl.Define }
  hl.Delimiter = { fg = syntax_hl.Delimiter }
  hl.Float = { fg = syntax_hl.Float }
  hl.Function = { fg = syntax_hl.Function }
  hl.Identifier = { fg = syntax_hl.Identifier }
  hl.Include = { fg = syntax_hl.Include }
  hl.Keyword = { fg = syntax_hl.Keyword }
  hl.Label = { fg = syntax_hl.Label }
  hl.Number = { fg = syntax_hl.Number }
  hl.Operator = { fg = syntax_hl.Operator }
  hl.PreProc = { fg = syntax_hl.PreProc }
  hl.Repeat = { fg = syntax_hl.Repeat }
  hl.Special = { fg = syntax_hl.Special }
  hl.SpecialChar = { fg = syntax_hl.SpecialChar }
  hl.Statement = { fg = syntax_hl.Statement }
  hl.StorageClass = { fg = syntax_hl.StorageClass }
  hl.String = { fg = syntax_hl.String }
  hl.Structure = { fg = syntax_hl.Structure }
  hl.Tag = { fg = syntax_hl.Tag }
  hl.Type = { fg = syntax_hl.Type }
  hl.Typedef = { fg = syntax_hl.Typedef }
  hl.Todo = { bg = syntax_hl.blue_300 }

  -- Diff highlighting
  hl.DiffAdd = { bg = colors.blue_200 }
  hl.DiffChange = { bg = colors.yellow_200 }
  hl.DiffDelete = { bg = colors.red_200 }
  hl.DiffText = { bg = colors.yellow_400 }

  -- GitGutter highlighting
  hl.GitGutterAdd = { fg = colors.blue }
  hl.GitGutterChange = { fg = colors.yellow }
  hl.GitGutterDelete = { fg = colors.red }
  hl.GitGutterChangeDelete = { fg = colors.blue }

  -- Spelling highlighting
  hl.SpellBad = { undercurl = true, sp = colors.yellow }
  hl.SpellLocal = { undercurl = true, sp = colors.yellow }
  hl.SpellCap = { undercurl = true, sp = colors.blue }
  hl.SpellRare = { undercurl = true, sp = colors.blue }

  hl.DiagnosticError = { fg = colors.red }
  hl.DiagnosticWarn = { fg = colors.yellow }
  hl.DiagnosticOk = { fg = colors.blue }
  hl.DiagnosticInfo = { fg = colors.blue }
  hl.DiagnosticHint = { fg = colors.blue }
  hl.DiagnosticUnderlineError = { undercurl = true, sp = colors.red_700 }
  hl.DiagnosticUnderlineWarning = { undercurl = true, sp = colors.yellow_700 }
  hl.DiagnosticUnderlineWarn = { undercurl = true, sp = colors.yellow_700 }
  hl.DiagnosticUnderlineInformation = { undercurl = true, sp = colors.blue_700 }
  hl.DiagnosticUnderlineHint = { undercurl = true, sp = colors.blue_700 }

  hl.DiagnosticVirtualTextError = { fg = colors.red_700, bg = colors.red_100 }
  hl.DiagnosticVirtualTextWarn = { fg = colors.yellow_700, bg = colors.yellow_100 }
  hl.DiagnosticVirtualTextInfo = { fg = colors.blue_700, bg = colors.blue_100 }
  hl.DiagnosticVirtualTextHint = { fg = colors.blue_700, bg = colors.blue_100 }

  hl.LspReferenceText = { underline = true, sp = colors.gray_600 }
  hl.LspReferenceRead = { underline = true, sp = colors.gray_600 }
  hl.LspReferenceWrite = { underline = true, sp = colors.gray_600 }
  hl.LspDiagnosticsDefaultError = "DiagnosticError"
  hl.LspDiagnosticsDefaultWarning = "DiagnosticWarn"
  hl.LspDiagnosticsDefaultInformation = "DiagnosticInfo"
  hl.LspDiagnosticsDefaultHint = "DiagnosticHint"
  hl.LspDiagnosticsUnderlineError = "DiagnosticUnderlineError"
  hl.LspDiagnosticsUnderlineWarning = "DiagnosticUnderlineWarning"
  hl.LspDiagnosticsUnderlineInformation = "DiagnosticUnderlineInformation"
  hl.LspDiagnosticsUnderlineHint = "DiagnosticUnderlineHint"
  hl.LspInlayHint = { fg = colors.gray_600, italic = true }

  hl.TSAnnotation = { fg = syntax_hl.TSAnnotation }
  hl.TSAttribute = { fg = syntax_hl.TSAttribute }
  hl.TSBoolean = { fg = syntax_hl.TSBoolean }
  hl.TSCharacter = { fg = syntax_hl.TSCharacter }
  hl.TSComment = { fg = syntax_hl.TSComment, italic = true }
  hl.TSConstructor = { fg = syntax_hl.TSConstructor }
  hl.TSConditional = { fg = syntax_hl.TSConditional }
  hl.TSConstant = { fg = syntax_hl.TSConstant }
  hl.TSConstBuiltin = { fg = syntax_hl.TSConstBuiltin, italic = true }
  hl.TSConstMacro = { fg = syntax_hl.TSConstMacro }
  hl.TSError = { fg = syntax_hl.TSError }
  hl.TSException = { fg = syntax_hl.TSException }
  hl.TSField = { fg = syntax_hl.TSField }
  hl.TSFloat = { fg = syntax_hl.TSFloat }
  hl.TSFunction = { fg = syntax_hl.TSFunction }
  hl.TSFuncBuiltin = { fg = syntax_hl.TSFuncBuiltin, italic = true }
  hl.TSFuncMacro = { fg = syntax_hl.TSFuncMacro }
  hl.TSInclude = { fg = syntax_hl.TSInclude }
  hl.TSKeyword = { fg = syntax_hl.TSKeyword }
  hl.TSKeywordFunction = { fg = syntax_hl.TSKeywordFunction }
  hl.TSKeywordOperator = { fg = syntax_hl.TSKeywordOperator }
  hl.TSLabel = { fg = syntax_hl.TSLabel }
  hl.TSMethod = { fg = syntax_hl.TSMethod }
  hl.TSNamespace = { fg = syntax_hl.TSNamespace }
  hl.TSNone = { fg = syntax_hl.TSNone }
  hl.TSNumber = { fg = syntax_hl.TSNumber }
  hl.TSOperator = { fg = syntax_hl.TSOperator }
  hl.TSParameter = { fg = syntax_hl.TSParameter }
  hl.TSParameterReference = { fg = syntax_hl.TSParameterReference }
  hl.TSProperty = { fg = syntax_hl.TSProperty }
  hl.TSPunctDelimiter = { fg = syntax_hl.TSPunctDelimiter }
  hl.TSPunctBracket = { fg = syntax_hl.TSPunctBracket }
  hl.TSPunctSpecial = { fg = syntax_hl.TSPunctSpecial }
  hl.TSRepeat = { fg = syntax_hl.TSRepeat }
  hl.TSString = { fg = syntax_hl.TSString }
  hl.TSStringRegex = { fg = syntax_hl.TSStringRegex }
  hl.TSStringEscape = { fg = syntax_hl.TSStringEscape }
  hl.TSSymbol = { fg = syntax_hl.TSSymbol }
  hl.TSTag = { fg = syntax_hl.TSTag }
  hl.TSTagDelimiter = { fg = syntax_hl.TSTagDelimiter }
  hl.TSText = { fg = syntax_hl.TSText }
  hl.TSEmphasis = { fg = syntax_hl.TSEmphasis, italic = true }
  hl.TSUnderline = { fg = syntax_hl.TSUnderline, underline = true }
  hl.TSStrike = { fg = syntax_hl.TSStrike, strikethrough = true }
  hl.TSTitle = { fg = syntax_hl.TSTitle }
  hl.TSLiteral = { fg = syntax_hl.TSLiteral }
  hl.TSURI = { fg = syntax_hl.TSURI, underline = true }
  hl.TSType = { fg = syntax_hl.TSType }
  hl.TSTypeBuiltin = { fg = syntax_hl.TSTypeBuiltin, italic = true }
  hl.TSVariable = { fg = syntax_hl.TSVariable }
  hl.TSVariableBuiltin = { fg = syntax_hl.TSVariableBuiltin, italic = true }

  hl.TSStrong = { bold = true }
  hl.TSDefinition = { underline = true, sp = colors.gray_600 }
  hl.TSDefinitionUsage = { underline = true, sp = colors.gray_600 }
  hl.TSCurrentScope = { bold = true }

  hl["@comment"] = "TSComment"
  hl["@error"] = "TSError"
  hl["@none"] = "TSNone"
  hl["@preproc"] = "PreProc"
  hl["@define"] = "Define"
  hl["@operator"] = "TSOperator"
  hl["@punctuation.delimiter"] = "TSPunctDelimiter"
  hl["@punctuation.bracket"] = "TSPunctBracket"
  hl["@punctuation.special"] = "TSPunctSpecial"
  hl["@string"] = "TSString"
  hl["@string.regex"] = "TSStringRegex"
  hl["@string.escape"] = "TSStringEscape"
  hl["@string.special"] = "SpecialChar"
  hl["@character"] = "TSCharacter"
  hl["@character.special"] = "SpecialChar"
  hl["@boolean"] = "TSBoolean"
  hl["@number"] = "TSNumber"
  hl["@float"] = "TSFloat"
  hl["@function"] = "TSFunction"
  hl["@function.call"] = "TSFunction"
  hl["@function.builtin"] = "TSFuncBuiltin"
  hl["@function.macro"] = "TSFuncMacro"
  hl["@method"] = "TSMethod"
  hl["@method.call"] = "TSMethod"
  hl["@constructor"] = "TSConstructor"
  hl["@parameter"] = "TSParameter"
  hl["@keyword"] = "TSKeyword"
  hl["@keyword.function"] = "TSKeywordFunction"
  hl["@keyword.operator"] = "TSKeywordOperator"
  hl["@keyword.return"] = "TSKeyword"
  hl["@conditional"] = "TSConditional"
  hl["@repeat"] = "TSRepeat"
  hl["@debug"] = "Debug"
  hl["@label"] = "TSLabel"
  hl["@include"] = "TSInclude"
  hl["@exception"] = "TSException"
  hl["@type"] = "TSType"
  hl["@type.builtin"] = "TSTypeBuiltin"
  hl["@type.qualifier"] = "TSKeyword"
  hl["@type.definition"] = "TSType"
  hl["@storageclass"] = "StorageClass"
  hl["@attribute"] = "TSAttribute"
  hl["@field"] = "TSField"
  hl["@property"] = "TSProperty"
  hl["@variable"] = "TSVariable"
  hl["@variable.builtin"] = "TSVariableBuiltin"
  hl["@constant"] = "TSConstant"
  hl["@constant.builtin"] = "TSConstant"
  hl["@constant.macro"] = "TSConstant"
  hl["@namespace"] = "TSNamespace"
  hl["@symbol"] = "TSSymbol"
  hl["@text"] = "TSText"
  hl["@text.diff.add"] = "DiffAdd"
  hl["@text.diff.delete"] = "DiffDelete"
  hl["@text.strong"] = "TSStrong"
  hl["@text.emphasis"] = "TSEmphasis"
  hl["@text.underline"] = "TSUnderline"
  hl["@text.strike"] = "TSStrike"
  hl["@text.title"] = "TSTitle"
  hl["@text.literal"] = "TSLiteral"
  hl["@text.uri"] = "TSUri"
  hl["@text.math"] = "Number"
  hl["@text.environment"] = "Macro"
  hl["@text.environment.name"] = "Type"
  hl["@text.reference"] = "TSParameterReference"
  hl["@text.todo"] = "Todo"
  hl["@text.note"] = "Tag"
  hl["@text.warning"] = "DiagnosticWarn"
  hl["@text.danger"] = "DiagnosticError"
  hl["@tag"] = "TSTag"
  hl["@tag.attribute"] = "TSAttribute"
  hl["@tag.delimiter"] = "TSTagDelimiter"

  hl.Added = { bg = colors.blue_200 }
  hl.Changed = { bg = colors.yellow_200 }
  hl.Removed = { fg = colors.gray_200, bg = colors.red_200 }
  hl["@diff.plus"] = "Added"
  hl["@diff.delta"] = "Changed"
  hl["@diff.minus"] = "Removed"

  hl.NvimInternalError = { fg = colors.black, bg = colors.blue }

  hl.NormalFloat = { fg = colors.gray_800, bg = colors.blue_200 }
  hl.FloatBorder = { fg = colors.gray_800, bg = colors.black }
  hl.NormalNC = { fg = colors.gray_800 }
  hl.TermCursor = { fg = colors.black, bg = colors.gray_800 }
  hl.TermCursorNC = { fg = colors.black, bg = colors.gray_800 }

  hl.NotifierError = { fg = colors.gray_700, bg = colors.red_300 }
  hl.NotifierWarn = { fg = colors.gray_700, bg = colors.yellow_300 }
  hl.NotifierInfo = { fg = colors.gray_700, bg = colors.blue_300 }
  hl.NotifierDebug = { fg = colors.gray_700, bg = colors.gray_300 }
  hl.NotifierTrace = { fg = colors.gray_700, bg = colors.gray_300 }
  hl.NotifierUnknown = { fg = colors.gray_700, bg = colors.gray_200 }

  hl.WinbarPath = { fg = colors.gray_600 }
  hl.WinbarFile = { fg = colors.gray_600 }

  hl.User1 = { fg = colors.blue, bg = colors.gray_400 }
  hl.User2 = { fg = colors.blue, bg = colors.gray_400 }
  hl.User3 = { fg = colors.gray_800, bg = colors.gray_400 }
  hl.User4 = { fg = colors.yellow, bg = colors.gray_400 }
  hl.User5 = { fg = colors.gray_800, bg = colors.gray_400 }
  hl.User6 = { fg = colors.gray_800, bg = colors.gray_300 }
  hl.User7 = { fg = colors.gray_800, bg = colors.gray_400 }
  hl.User8 = { fg = colors.black, bg = colors.gray_400 }
  hl.User9 = { fg = colors.black, bg = colors.gray_400 }

  hl.TreesitterContext = { bg = colors.gray_300, italic = true }

  local override_terminal_color = vim.g.neovide

  if override_terminal_color then
    vim.g.terminal_color_0 = colors.black
    vim.g.terminal_color_1 = colors.red
    vim.g.terminal_color_2 = colors.blue
    vim.g.terminal_color_3 = colors.blue
    vim.g.terminal_color_4 = colors.blue
    vim.g.terminal_color_5 = colors.blue
    vim.g.terminal_color_6 = colors.blue
    vim.g.terminal_color_7 = colors.white
    vim.g.terminal_color_8 = colors.gray_600
    vim.g.terminal_color_9 = colors.red
    vim.g.terminal_color_10 = colors.blue
    vim.g.terminal_color_11 = colors.blue
    vim.g.terminal_color_12 = colors.blue
    vim.g.terminal_color_13 = colors.blue
    vim.g.terminal_color_14 = colors.blue
    vim.g.terminal_color_15 = colors.white
  end

  -- FzfLua
  hl.FzfLuaBufFlagCur = { fg = colors.gray_600 }
  hl.FzfLuaTabTitle = { fg = colors.blue }
  hl.FzfLuaHeaderText = { fg = colors.gray_600 }
  hl.FzfLuaBufLineNr = { fg = colors.blue }
  hl.FzfLuaBufNr = { fg = colors.blue }
  hl.FzfLuaBufName = { fg = colors.blue }
  hl.FzfLuaHeaderBind = { fg = colors.blue }
  hl.FzfLuaTabMarker = { fg = colors.blue }
  hl.FzfLuaBufFlagAlt = { fg = colors.blue }

  -- nvim-cmp
  hl.CmpItemAbbr = { fg = colors.gray_700 } -- Completion items default
  hl.CmpItemAbbrDeprecated = { fg = colors.gray_600, strikethrough = true }
  hl.CmpItemAbbrDeprecatedDefault = "CmpItemAbbrDeprecated"
  hl.CmpItemAbbrMatch = { fg = colors.blue } -- Matched portion of completion items
  hl.CmpItemAbbrMatchFuzzy = { fg = colors.blue }
  hl.CmpItemMenu = { }
  -- Color of "<icon> symbol" on the right
  hl.CmpItemKindDefault = { fg = colors.gray_700 }
  hl.CmpItemKindKeyword = { fg = colors.blue }
  hl.CmpItemKindVariable = { fg = colors.blue }
  hl.CmpItemKindConstant = { fg = colors.blue }
  hl.CmpItemKindReference = { fg = colors.blue }
  hl.CmpItemKindValue = { fg = colors.blue }
  hl.CmpItemKindFunction = { fg = colors.blue }
  hl.CmpItemKindMethod = { fg = colors.blue }
  hl.CmpItemKindConstructor = { fg = colors.blue }
  hl.CmpItemKindClass = { fg = colors.yellow }
  hl.CmpItemKindInterface = { fg = colors.yellow }
  hl.CmpItemKindStruct = { fg = colors.yellow }
  hl.CmpItemKindEvent = { fg = colors.yellow }
  hl.CmpItemKindEnum = { fg = colors.yellow }
  hl.CmpItemKindUnit = { fg = colors.yellow }
  hl.CmpItemKindModule = { fg = colors.yellow }
  hl.CmpItemKindProperty = { fg = colors.blue }
  hl.CmpItemKindField = { fg = colors.blue }
  hl.CmpItemKindTypeParameter = { fg = colors.blue }
  hl.CmpItemKindEnumMember = { fg = colors.white }
  hl.CmpItemKindOperator = { fg = colors.white }
  hl.CmpItemKindSnippet = { fg = colors.white }

  -- Git signs
  hl.GitSignsChangeInline = { bg = colors.blue_300 } -- Current state of the hunk for preview_hunk
  hl.GitSignsDeleteVirtLn = { bg = colors.red_300 } -- Previous state of the hunk for preview_hunk

  -- TUI
  hl.TUIBorderActive = { fg = colors.gray_600, bg = colors.black }
  hl.TUIBorderInactive = { fg = colors.gray_300, bg = colors.black }

  -- Fzf
  hl.FzfBorderSelectorBreadcrumbs = { fg = colors.blue, bold = true }
  hl.FzfBorderFiletype = { fg = colors.gray_800 }
  hl.FzfBorderLoadingIndicator = { fg = colors.yellow }
  hl.FzfBorderStaleIndicator = { fg = colors.yellow }

  -- Fzf Git status
  hl.FzfGitStatusBorderAdded = { fg = colors.blue, bold = true }
  hl.FzfGitStatusBorderChanged = { fg = colors.yellow, bold = true }
  hl.FzfGitStatusBorderDeleted = { fg = colors.red, bold = true }
  hl.FzfGitStatusBorderNormal = { fg = colors.gray_800, bold = true }
  hl.FzfGitStatusBorderDiffStat = { fg = colors.gray_800 }

  -- Fzf Git stash
  hl.FzfGitStatusBorderDiffStat = "FzfGitStatusBorderDiffStat"

  -- Fzf Git commit
  hl.FzfGitCommitBorderDiffStat = "FzfGitStatusBorderDiffStat"

  -- Fzf Git file changes
  hl.FzfGitFileChangesBorderAdded = "FzfGitStatusBorderAdded"
  hl.FzfGitFileChangesBorderChanged = "FzfGitStatusBorderChanged"
  hl.FzfGitFileChangesBorderDeleted = "FzfGitStatusBorderDeleted"
  hl.FzfGitFileChangesBorderNormal = "FzfGitStatusBorderNormal"
  hl.FzfGitFileChangesBorderDiffStat = "FzfGitStatusBorderDiffStat"

  -- Fzf Diff
  hl.FzfDiffAdd = "DiffAdd"
  hl.FzfDiffAddAsDelete = "DiffDelete"
  hl.FzfDiffDelete = "DiffDelete"
  hl.FzfDiffPadding = { fg = colors.gray_100, bg = colors.gray_100 }
  hl.FzfDiffChange = "DiffChange"
  hl.FzfDiffText = "DiffText"

  -- stylua: ignore end
end

return M
