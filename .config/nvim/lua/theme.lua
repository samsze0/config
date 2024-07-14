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

local hl = setmetatable({}, {
  __newindex = function(tbl, hlgroup, args)
    -- If type is string, set a link
    if type(args) == "string" then
      vim.api.nvim_set_hl(0, hlgroup, { link = args })
      return
    end

    local val = {}
    if args.guifg then val.fg = args.guifg end
    if args.guibg then val.bg = args.guibg end
    if args.guisp then val.sp = args.guisp end
    if args.gui then
      for x in args.gui:gmatch("([^,]+)") do
        if x ~= "none" then val[x] = true end
      end
    end
    vim.api.nvim_set_hl(0, hlgroup, val)
  end,
})

---@param opts? {}
function M.setup(opts)
  if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
  vim.cmd("set termguicolors")

  -- stylua: ignore start

  -- Vim editor colors
  hl.Normal = { guifg = colors.gray_800, guibg = colors.black, gui = nil, guisp = nil }
  hl.Bold = { guifg = nil, guibg = nil, gui = "bold", guisp = nil }
  hl.Debug = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.Directory = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.Error = { guifg = colors.red, guibg = nil, gui = nil, guisp = nil }
  hl.ErrorMsg = { guifg = colors.red, guibg = nil, gui = nil, guisp = nil }
  hl.Exception = { guifg = colors.red, guibg = nil, gui = nil, guisp = nil }
  hl.FoldColumn = { guifg = colors.gray_600, guibg = nil, gui = nil, guisp = nil }
  hl.Folded = { guifg = colors.gray_600, guibg = colors.gray_200, gui = nil, guisp = nil }
  hl.IncSearch = { guifg = colors.true_white, guibg = colors.yellow_800, gui = "none", guisp = nil }
  hl.Italic = { guifg = nil, guibg = nil, gui = "none", guisp = nil }
  hl.Macro = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.MatchParen = { guifg = nil, guibg = colors.gray_400, gui = nil, guisp = nil }
  hl.ModeMsg = { guifg = colors.yellow, guibg = nil, gui = nil, guisp = nil }
  hl.MoreMsg = { guifg = colors.yellow, guibg = nil, gui = nil, guisp = nil }
  hl.Question = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.Search = { guifg = nil, guibg = colors.yellow_300, gui = nil, guisp = nil }
  hl.CurSearch = { guifg = nil, guibg = colors.yellow_300, gui = nil, guisp = nil }
  hl.Substitute = { guifg = nil, guibg = colors.yellow_500, gui = "none", guisp = nil }
  hl.SpecialKey = { guifg = colors.gray_600, guibg = nil, gui = nil, guisp = nil }
  hl.TooLong = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.Underlined = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.Visual = { guifg = nil, guibg = colors.gray_400, gui = nil, guisp = nil }
  hl.VisualNOS = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.WarningMsg = { guifg = colors.yellow, guibg = nil, gui = nil, guisp = nil }
  hl.WildMenu = { guifg = colors.yellow, guibg = colors.blue, gui = nil, guisp = nil }
  hl.Title = { guifg = colors.blue, guibg = nil, gui = "none", guisp = nil }
  hl.Conceal = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.Cursor = { guifg = colors.black, guibg = colors.gray_800, gui = nil, guisp = nil }
  hl.NonText = { guifg = colors.gray_600, guibg = nil, gui = nil, guisp = nil }
  hl.LineNr = { guifg = colors.gray_600, guibg = nil, gui = nil, guisp = nil }
  hl.SignColumn = { guifg = colors.gray_600, guibg = nil, gui = nil, guisp = nil }
  hl.WinBar = { guifg = colors.gray_800, guibg = nil, gui = "none", guisp = nil }
  hl.WinBarNC = { guifg = colors.gray_600, guibg = nil, gui = "none", guisp = nil }
  hl.VertSplit = { guifg = colors.gray_300, guibg = nil, gui = "none", guisp = nil }
  hl.ColorColumn = { guifg = nil, guibg = colors.gray_300, gui = "none", guisp = nil }
  hl.CursorColumn = { guifg = nil, guibg = colors.gray_300, gui = "none", guisp = nil }
  hl.CursorLine = { guifg = nil, guibg = colors.gray_300, gui = "none", guisp = nil }
  hl.CursorLineNr = { guifg = colors.gray_600, guibg = colors.gray_300, gui = nil, guisp = nil }
  hl.QuickFixLine = { guifg = nil, guibg = colors.gray_300, gui = "none", guisp = nil }
  hl.PMenu = { guifg = colors.gray_600, guibg = colors.gray_100, gui = "none", guisp = nil }
  hl.PMenuSel = { guifg = colors.gray_800, guibg = colors.gray_400, gui = nil, guisp = nil }
  hl.PMenuSbar = { guifg = nil, guibg = colors.gray_300, gui = "none", guisp = nil }
  hl.PMenuThumb = { guifg = nil, guibg = colors.gray_600, gui = nil, guisp = nil }
  hl.StatusLine = { guifg = colors.gray_800, guibg = colors.gray_100, gui = "none", guisp = nil } -- Active status line
  hl.StatusLineNC = { guifg = colors.gray_600, guibg = colors.gray_100, gui = "none", guisp = nil } -- Inactive status line
  hl.TabLine = { guifg = colors.gray_600, guibg = colors.black, gui = "none", guisp = nil } -- Inactive tab
  hl.TabLineFill = { guifg = nil, guibg = nil, gui = "none", guisp = nil }
  hl.TabLineSel = { guifg = colors.gray_800, guibg = colors.gray_300, gui = "none", guisp = nil } -- Active tab

  -- Status line (custom)
  hl.StatusLineDiagnosticError = { guifg = colors.red, guibg = colors.gray_100, gui = nil, guisp = nil }
  hl.StatusLineDiagnosticWarn = { guifg = colors.yellow, guibg = colors.gray_100, gui = nil, guisp = nil }
  hl.StatusLineDiagnosticInfo = { guifg = colors.blue, guibg = colors.gray_100, gui = nil, guisp = nil }
  hl.StatusLineDiagnosticHint = { guifg = colors.blue, guibg = colors.gray_100, gui = nil, guisp = nil }
  hl.StatusLineMuted = { guifg = colors.gray_600, guibg = colors.gray_100, gui = nil, guisp = nil }

  -- Standard syntax highlighting
  hl.Comment = { guifg = syntax_hl.Comment, guibg = nil, gui = nil, guisp = nil }
  hl.Boolean = { guifg = syntax_hl.Boolean, guibg = nil, gui = nil, guisp = nil }
  hl.Character = { guifg = syntax_hl.Character, guibg = nil, gui = nil, guisp = nil }
  hl.Conditional = { guifg = syntax_hl.Conditional, guibg = nil, gui = nil, guisp = nil }
  hl.Constant = { guifg = syntax_hl.Constant, guibg = nil, gui = nil, guisp = nil }
  hl.Define = { guifg = syntax_hl.Define, guibg = nil, gui = "none", guisp = nil }
  hl.Delimiter = { guifg = syntax_hl.Delimiter, guibg = nil, gui = nil, guisp = nil }
  hl.Float = { guifg = syntax_hl.Float, guibg = nil, gui = nil, guisp = nil }
  hl.Function = { guifg = syntax_hl.Function, guibg = nil, gui = nil, guisp = nil }
  hl.Identifier = { guifg = syntax_hl.Identifier, guibg = nil, gui = "none", guisp = nil }
  hl.Include = { guifg = syntax_hl.Include, guibg = nil, gui = nil, guisp = nil }
  hl.Keyword = { guifg = syntax_hl.Keyword, guibg = nil, gui = nil, guisp = nil }
  hl.Label = { guifg = syntax_hl.Label, guibg = nil, gui = nil, guisp = nil }
  hl.Number = { guifg = syntax_hl.Number, guibg = nil, gui = nil, guisp = nil }
  hl.Operator = { guifg = syntax_hl.Operator, guibg = nil, gui = "none", guisp = nil }
  hl.PreProc = { guifg = syntax_hl.PreProc, guibg = nil, gui = nil, guisp = nil }
  hl.Repeat = { guifg = syntax_hl.Repeat, guibg = nil, gui = nil, guisp = nil }
  hl.Special = { guifg = syntax_hl.Special, guibg = nil, gui = nil, guisp = nil }
  hl.SpecialChar = { guifg = syntax_hl.SpecialChar, guibg = nil, gui = nil, guisp = nil }
  hl.Statement = { guifg = syntax_hl.Statement, guibg = nil, gui = nil, guisp = nil }
  hl.StorageClass = { guifg = syntax_hl.StorageClass, guibg = nil, gui = nil, guisp = nil }
  hl.String = { guifg = syntax_hl.String, guibg = nil, gui = nil, guisp = nil }
  hl.Structure = { guifg = syntax_hl.Structure, guibg = nil, gui = nil, guisp = nil }
  hl.Tag = { guifg = syntax_hl.Tag, guibg = nil, gui = nil, guisp = nil }
  hl.Type = { guifg = syntax_hl.Type, guibg = nil, gui = "none", guisp = nil }
  hl.Typedef = { guifg = syntax_hl.Typedef, guibg = nil, gui = nil, guisp = nil }
  hl.Todo = { guifg = nil, guibg = syntax_hl.blue_300, gui = nil, guisp = nil }

  -- Diff highlighting
  hl.DiffAdd = { guifg = nil, guibg = colors.blue_200, gui = nil, guisp = nil }
  hl.DiffChange = { guifg = nil, guibg = colors.yellow_200, gui = nil, guisp = nil }
  hl.DiffDelete = { guifg = colors.gray_200, guibg = colors.red_200, gui = nil, guisp = nil }
  hl.DiffText = { guifg = nil, guibg = colors.yellow_400, gui = nil, guisp = nil }

  -- GitGutter highlighting
  hl.GitGutterAdd = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.GitGutterChange = { guifg = colors.yellow, guibg = nil, gui = nil, guisp = nil }
  hl.GitGutterDelete = { guifg = colors.red, guibg = nil, gui = nil, guisp = nil }
  hl.GitGutterChangeDelete = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }

  -- Spelling highlighting
  hl.SpellBad = { guifg = nil, guibg = nil, gui = "undercurl", guisp = colors.yellow }
  hl.SpellLocal = { guifg = nil, guibg = nil, gui = "undercurl", guisp = colors.yellow }
  hl.SpellCap = { guifg = nil, guibg = nil, gui = "undercurl", guisp = colors.blue }
  hl.SpellRare = { guifg = nil, guibg = nil, gui = "undercurl", guisp = colors.blue }

  hl.DiagnosticError = { guifg = colors.red, guibg = nil, gui = "none", guisp = nil }
  hl.DiagnosticWarn = { guifg = colors.yellow, guibg = nil, gui = "none", guisp = nil }
  hl.DiagnosticOk = { guifg = colors.blue, guibg = nil, gui = "none", guisp = nil }
  hl.DiagnosticInfo = { guifg = colors.blue, guibg = nil, gui = "none", guisp = nil }
  hl.DiagnosticHint = { guifg = colors.blue, guibg = nil, gui = "none", guisp = nil }
  hl.DiagnosticUnderlineError = { guifg = nil, guibg = nil, gui = "undercurl", guisp = colors.red_700 }
  hl.DiagnosticUnderlineWarning = { guifg = nil, guibg = nil, gui = "undercurl", guisp = colors.yellow_700 }
  hl.DiagnosticUnderlineWarn = { guifg = nil, guibg = nil, gui = "undercurl", guisp = colors.yellow_700 }
  hl.DiagnosticUnderlineInformation = { guifg = nil, guibg = nil, gui = "undercurl", guisp = colors.blue_700 }
  hl.DiagnosticUnderlineHint = { guifg = nil, guibg = nil, gui = "undercurl", guisp = colors.blue_700 }

  hl.DiagnosticVirtualTextError = { guifg = colors.red_700, guibg = colors.red_100 }
  hl.DiagnosticVirtualTextWarn = { guifg = colors.yellow_700, guibg = colors.yellow_100 }
  hl.DiagnosticVirtualTextInfo = { guifg = colors.blue_700, guibg = colors.blue_100 }
  hl.DiagnosticVirtualTextHint = { guifg = colors.blue_700, guibg = colors.blue_100 }

  hl.LspReferenceText = { guifg = nil, guibg = nil, gui = "underline", guisp = colors.gray_600 }
  hl.LspReferenceRead = { guifg = nil, guibg = nil, gui = "underline", guisp = colors.gray_600 }
  hl.LspReferenceWrite = { guifg = nil, guibg = nil, gui = "underline", guisp = colors.gray_600 }
  hl.LspDiagnosticsDefaultError = "DiagnosticError"
  hl.LspDiagnosticsDefaultWarning = "DiagnosticWarn"
  hl.LspDiagnosticsDefaultInformation = "DiagnosticInfo"
  hl.LspDiagnosticsDefaultHint = "DiagnosticHint"
  hl.LspDiagnosticsUnderlineError = "DiagnosticUnderlineError"
  hl.LspDiagnosticsUnderlineWarning = "DiagnosticUnderlineWarning"
  hl.LspDiagnosticsUnderlineInformation = "DiagnosticUnderlineInformation"
  hl.LspDiagnosticsUnderlineHint = "DiagnosticUnderlineHint"
  hl.LspInlayHint = { guifg = colors.gray_600, guibg = nil, gui = "italic", guisp = nil }

  hl.TSAnnotation = { guifg = syntax_hl.TSAnnotation, guibg = nil, gui = "none", guisp = nil }
  hl.TSAttribute = { guifg = syntax_hl.TSAttribute, guibg = nil, gui = "none", guisp = nil }
  hl.TSBoolean = { guifg = syntax_hl.TSBoolean, guibg = nil, gui = "none", guisp = nil }
  hl.TSCharacter = { guifg = syntax_hl.TSCharacter, guibg = nil, gui = "none", guisp = nil }
  hl.TSComment = { guifg = syntax_hl.TSComment, guibg = nil, gui = "italic", guisp = nil }
  hl.TSConstructor = { guifg = syntax_hl.TSConstructor, guibg = nil, gui = "none", guisp = nil }
  hl.TSConditional = { guifg = syntax_hl.TSConditional, guibg = nil, gui = "none", guisp = nil }
  hl.TSConstant = { guifg = syntax_hl.TSConstant, guibg = nil, gui = "none", guisp = nil }
  hl.TSConstBuiltin = { guifg = syntax_hl.TSConstBuiltin, guibg = nil, gui = "italic", guisp = nil }
  hl.TSConstMacro = { guifg = syntax_hl.TSConstMacro, guibg = nil, gui = "none", guisp = nil }
  hl.TSError = { guifg = syntax_hl.TSError, guibg = nil, gui = "none", guisp = nil }
  hl.TSException = { guifg = syntax_hl.TSException, guibg = nil, gui = "none", guisp = nil }
  hl.TSField = { guifg = syntax_hl.TSField, guibg = nil, gui = "none", guisp = nil }
  hl.TSFloat = { guifg = syntax_hl.TSFloat, guibg = nil, gui = "none", guisp = nil }
  hl.TSFunction = { guifg = syntax_hl.TSFunction, guibg = nil, gui = "none", guisp = nil }
  hl.TSFuncBuiltin = { guifg = syntax_hl.TSFuncBuiltin, guibg = nil, gui = "italic", guisp = nil }
  hl.TSFuncMacro = { guifg = syntax_hl.TSFuncMacro, guibg = nil, gui = "none", guisp = nil }
  hl.TSInclude = { guifg = syntax_hl.TSInclude, guibg = nil, gui = "none", guisp = nil }
  hl.TSKeyword = { guifg = syntax_hl.TSKeyword, guibg = nil, gui = "none", guisp = nil }
  hl.TSKeywordFunction = { guifg = syntax_hl.TSKeywordFunction, guibg = nil, gui = "none", guisp = nil }
  hl.TSKeywordOperator = { guifg = syntax_hl.TSKeywordOperator, guibg = nil, gui = "none", guisp = nil }
  hl.TSLabel = { guifg = syntax_hl.TSLabel, guibg = nil, gui = "none", guisp = nil }
  hl.TSMethod = { guifg = syntax_hl.TSMethod, guibg = nil, gui = "none", guisp = nil }
  hl.TSNamespace = { guifg = syntax_hl.TSNamespace, guibg = nil, gui = "none", guisp = nil }
  hl.TSNone = { guifg = syntax_hl.TSNone, guibg = nil, gui = "none", guisp = nil }
  hl.TSNumber = { guifg = syntax_hl.TSNumber, guibg = nil, gui = "none", guisp = nil }
  hl.TSOperator = { guifg = syntax_hl.TSOperator, guibg = nil, gui = "none", guisp = nil }
  hl.TSParameter = { guifg = syntax_hl.TSParameter, guibg = nil, gui = "none", guisp = nil }
  hl.TSParameterReference = { guifg = syntax_hl.TSParameterReference, guibg = nil, gui = "none", guisp = nil }
  hl.TSProperty = { guifg = syntax_hl.TSProperty, guibg = nil, gui = "none", guisp = nil }
  hl.TSPunctDelimiter = { guifg = syntax_hl.TSPunctDelimiter, guibg = nil, gui = "none", guisp = nil }
  hl.TSPunctBracket = { guifg = syntax_hl.TSPunctBracket, guibg = nil, gui = "none", guisp = nil }
  hl.TSPunctSpecial = { guifg = syntax_hl.TSPunctSpecial, guibg = nil, gui = "none", guisp = nil }
  hl.TSRepeat = { guifg = syntax_hl.TSRepeat, guibg = nil, gui = "none", guisp = nil }
  hl.TSString = { guifg = syntax_hl.TSString, guibg = nil, gui = "none", guisp = nil }
  hl.TSStringRegex = { guifg = syntax_hl.TSStringRegex, guibg = nil, gui = "none", guisp = nil }
  hl.TSStringEscape = { guifg = syntax_hl.TSStringEscape, guibg = nil, gui = "none", guisp = nil }
  hl.TSSymbol = { guifg = syntax_hl.TSSymbol, guibg = nil, gui = "none", guisp = nil }
  hl.TSTag = { guifg = syntax_hl.TSTag, guibg = nil, gui = "none", guisp = nil }
  hl.TSTagDelimiter = { guifg = syntax_hl.TSTagDelimiter, guibg = nil, gui = "none", guisp = nil }
  hl.TSText = { guifg = syntax_hl.TSText, guibg = nil, gui = "none", guisp = nil }
  hl.TSEmphasis = { guifg = syntax_hl.TSEmphasis, guibg = nil, gui = "italic", guisp = nil }
  hl.TSUnderline = { guifg = syntax_hl.TSUnderline, guibg = nil, gui = "underline", guisp = nil }
  hl.TSStrike = { guifg = syntax_hl.TSStrike, guibg = nil, gui = "strikethrough", guisp = nil }
  hl.TSTitle = { guifg = syntax_hl.TSTitle, guibg = nil, gui = "none", guisp = nil }
  hl.TSLiteral = { guifg = syntax_hl.TSLiteral, guibg = nil, gui = "none", guisp = nil }
  hl.TSURI = { guifg = syntax_hl.TSURI, guibg = nil, gui = "underline", guisp = nil }
  hl.TSType = { guifg = syntax_hl.TSType, guibg = nil, gui = "none", guisp = nil }
  hl.TSTypeBuiltin = { guifg = syntax_hl.TSTypeBuiltin, guibg = nil, gui = "italic", guisp = nil }
  hl.TSVariable = { guifg = syntax_hl.TSVariable, guibg = nil, gui = "none", guisp = nil }
  hl.TSVariableBuiltin = { guifg = syntax_hl.TSVariableBuiltin, guibg = nil, gui = "italic", guisp = nil }

  hl.TSStrong = { guifg = nil, guibg = nil, gui = "bold", guisp = nil }
  hl.TSDefinition = { guifg = nil, guibg = nil, gui = "underline", guisp = colors.gray_600 }
  hl.TSDefinitionUsage = { guifg = nil, guibg = nil, gui = "underline", guisp = colors.gray_600 }
  hl.TSCurrentScope = { guifg = nil, guibg = nil, gui = "bold", guisp = nil }

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

  hl.Added = { guifg = nil, guibg = colors.blue_200, gui = nil, guisp = nil }
  hl.Changed = { guifg = nil, guibg = colors.yellow_200, gui = nil, guisp = nil }
  hl.Removed = { guifg = colors.gray_200, guibg = colors.red_200, gui = nil, guisp = nil }
  hl["@diff.plus"] = "Added"
  hl["@diff.delta"] = "Changed"
  hl["@diff.minus"] = "Removed"

  hl.NvimInternalError = { guifg = colors.black, guibg = colors.blue, gui = "none", guisp = nil }

  hl.NormalFloat = { guifg = colors.gray_800, guibg = colors.blue_200, gui = nil, guisp = nil }
  hl.FloatBorder = { guifg = colors.gray_800, guibg = colors.black, gui = nil, guisp = nil }
  hl.NormalNC = { guifg = colors.gray_800, guibg = nil, gui = nil, guisp = nil }
  hl.TermCursor = { guifg = colors.black, guibg = colors.gray_800, gui = "none", guisp = nil }
  hl.TermCursorNC = { guifg = colors.black, guibg = colors.gray_800, gui = nil, guisp = nil }

  hl.NotifierError = { guifg = colors.gray_700, guibg = colors.red_300, gui = nil, guisp = nil }
  hl.NotifierWarn = { guifg = colors.gray_700, guibg = colors.yellow_300, gui = nil, guisp = nil }
  hl.NotifierInfo = { guifg = colors.gray_700, guibg = colors.blue_300, gui = nil, guisp = nil }
  hl.NotifierDebug = { guifg = colors.gray_700, guibg = colors.gray_300, gui = nil, guisp = nil }
  hl.NotifierTrace = { guifg = colors.gray_700, guibg = colors.gray_300, gui = nil, guisp = nil }
  hl.NotifierUnknown = { guifg = colors.gray_700, guibg = colors.gray_200, gui = nil, guisp = nil }

  hl.WinbarPath = { guifg = colors.gray_600, guibg = nil, gui = nil, guisp = nil }
  hl.WinbarFile = { guifg = colors.gray_600, guibg = nil, gui = nil, guisp = nil }

  hl.User1 = { guifg = colors.blue, guibg = colors.gray_400, gui = "none", guisp = nil }
  hl.User2 = { guifg = colors.blue, guibg = colors.gray_400, gui = "none", guisp = nil }
  hl.User3 = { guifg = colors.gray_800, guibg = colors.gray_400, gui = "none", guisp = nil }
  hl.User4 = { guifg = colors.yellow, guibg = colors.gray_400, gui = "none", guisp = nil }
  hl.User5 = { guifg = colors.gray_800, guibg = colors.gray_400, gui = "none", guisp = nil }
  hl.User6 = { guifg = colors.gray_800, guibg = colors.gray_300, gui = "none", guisp = nil }
  hl.User7 = { guifg = colors.gray_800, guibg = colors.gray_400, gui = "none", guisp = nil }
  hl.User8 = { guifg = colors.black, guibg = colors.gray_400, gui = "none", guisp = nil }
  hl.User9 = { guifg = colors.black, guibg = colors.gray_400, gui = "none", guisp = nil }

  hl.TreesitterContext = { guifg = nil, guibg = colors.gray_300, gui = "italic", guisp = nil }

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
  hl.FzfLuaBufFlagCur = { guifg = colors.gray_600, guibg = nil }
  hl.FzfLuaTabTitle = { guifg = colors.blue, guibg = nil }
  hl.FzfLuaHeaderText = { guifg = colors.gray_600, guibg = nil }
  hl.FzfLuaBufLineNr = { guifg = colors.blue, guibg = nil }
  hl.FzfLuaBufNr = { guifg = colors.blue, guibg = nil }
  hl.FzfLuaBufName = { guifg = colors.blue, guibg = nil }
  hl.FzfLuaHeaderBind = { guifg = colors.blue, guibg = nil }
  hl.FzfLuaTabMarker = { guifg = colors.blue, guibg = nil }
  hl.FzfLuaBufFlagAlt = { guifg = colors.blue, guibg = nil }

  -- nvim-cmp
  hl.CmpItemAbbr = { guifg = colors.gray_700, guibg = nil, gui = nil, guisp = nil } -- Completion items default
  hl.CmpItemAbbrDeprecated = { guifg = colors.gray_600, guibg = nil, gui = "strikethrough", guisp = nil }
  hl.CmpItemAbbrDeprecatedDefault = "CmpItemAbbrDeprecated"
  hl.CmpItemAbbrMatch = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil } -- Matched portion of completion items
  hl.CmpItemAbbrMatchFuzzy = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemMenu = { guifg = nil, guibg = nil, gui = nil, guisp = nil }
  -- Color of "<icon> symbol" on the right
  hl.CmpItemKindDefault = { guifg = colors.gray_700, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindKeyword = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindVariable = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindConstant = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindReference = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindValue = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindFunction = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindMethod = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindConstructor = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindClass = { guifg = colors.yellow, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindInterface = { guifg = colors.yellow, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindStruct = { guifg = colors.yellow, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindEvent = { guifg = colors.yellow, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindEnum = { guifg = colors.yellow, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindUnit = { guifg = colors.yellow, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindModule = { guifg = colors.yellow, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindProperty = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindField = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindTypeParameter = { guifg = colors.blue, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindEnumMember = { guifg = colors.white, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindOperator = { guifg = colors.white, guibg = nil, gui = nil, guisp = nil }
  hl.CmpItemKindSnippet = { guifg = colors.white, guibg = nil, gui = nil, guisp = nil }

  -- Git signs
  hl.GitSignsChangeInline = { guifg = nil, guibg = colors.blue_300 } -- Current state of the hunk for preview_hunk
  hl.GitSignsDeleteVirtLn = { guifg = nil, guibg = colors.red_300 } -- Previous state of the hunk for preview_hunk

  -- TUI
  hl.TUIBorderActive = { guifg = colors.gray_600, guibg = colors.black }
  hl.TUIBorderInactive = { guifg = colors.gray_300, guibg = colors.black }

  -- Fzf
  hl.FzfSelectorBreadcrumbs = { guifg = colors.blue, guibg = nil, gui = "bold" }

  -- Fzf Git status
  hl.FzfGitStatusBorderAdded = { guifg = colors.blue, guibg = nil, gui = "bold" }
  hl.FzfGitStatusBorderChanged = { guifg = colors.yellow, guibg = nil, gui = "bold" }
  hl.FzfGitStatusBorderDeleted = { guifg = colors.red, guibg = nil, gui = "bold" }
  hl.FzfGitStatusBorderNormal = { guifg = colors.gray_800, guibg = nil, gui = "bold" }
  hl.FzfGitStatusBorderDiffStat = { guifg = colors.gray_800, guibg = nil }

  -- Fzf files
  hl.FzfFilesBorderFiletype = { guifg = colors.gray_800, guibg = nil, gui = "bold" }

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

  -- stylua: ignore end
end

return M
