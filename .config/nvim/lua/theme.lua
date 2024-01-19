-- Tweak from RRethy/nvim-base16
-- https://github.com/RRethy/nvim-base16/blob/master/lua/base16-colorscheme.lua

local utils = require("utils")

local M = {}

M.rainbow_hl_groups = {
  "RainbowBlue",
  "RainbowGreen",
  "RainbowViolet",
  "RainbowCyan",
}

M.colors = {
  black = "#0c0d10",
  gray_100 = "#17191f",
  gray_200 = "#1a1c24",
  gray_300 = "#2c313c",
  gray_400 = "#3e4451",
  gray_500 = "#5c6675",
  gray_600 = "#727b8f",
  gray_700 = "#95a1b3",
  gray_800 = "#b7beca",
  white = "#cbd1da",
  true_white = "#ffffff",

  red_100 = "#280f0f",
  blue_100 = "#0e1a27",
  yellow_100 = "#291a0a",
  red_200 = "#2f1010",
  blue_200 = "#11203d",
  yellow_200 = "#3a1f0b",
  red_300 = "#3e1414",
  blue_300 = "#16274b",
  yellow_300 = "#412810",
  red_400 = "#571919",
  blue_400 = "#1b3567",
  yellow_400 = "#693e13",
  red_500 = "#7b2525",
  blue_500 = "#26498b",
  yellow_500 = "#905020",
  red_600 = "#913333",
  blue_600 = "#2955a7",
  yellow_600 = "#9d5925",
  red_700 = "#b54949",
  blue_700 = "#4071cb",
  yellow_700 = "#c87e46",
  red_800 = "#c64d4d",
  blue_800 = "#537dcd",
  yellow_800 = "#ca7a3d",
  red_900 = "#e36c6c",
  blue_900 = "#6b9af1",
  yellow_900 = "#e9a069",

  red = "#e66666",
  blue = "#61a5ff",
  gray_blue = "#8598bc",
  yellow = "#ed9a57",
}
local c = M.colors

local default_syntax_hl = {
  Comment = c.gray_600,
  Boolean = c.yellow,
  Character = c.yellow,
  Conditional = c.gray_blue,
  Constant = c.yellow,
  Define = c.gray_blue,
  Delimiter = c.gray_blue,
  Float = c.yellow,
  Function = c.blue,
  Identifier = c.gray_800,
  Include = c.blue,
  Keyword = c.blue,
  Label = c.blue,
  Number = c.yellow,
  Operator = c.gray_blue,
  Preproc = c.blue,
  Repeat = c.blue,
  Special = c.yellow,
  Specialchar = c.blue,
  Statement = c.blue,
  Storageclass = c.blue,
  String = c.yellow,
  Structure = c.blue,
  Tag = c.gray_blue,
  Type = c.blue,
  Typedef = c.blue,

  TSAnnotation = c.gray_blue,
  TSAttribute = c.gray_blue,
  TSBoolean = c.yellow_900,
  TSCharacter = c.yellow_900,
  TSComment = c.gray_600,
  TSConstructor = c.blue,
  TSConditional = c.gray_blue,
  TSConstant = c.yellow,
  TSConstBuiltin = c.yellow_900,
  TSConstMacro = c.gray_blue,
  TSError = c.red,
  TSException = c.red,
  TSField = c.gray_800,
  TSFloat = c.yellow_900,
  TSFunction = c.blue,
  TSFuncBuiltin = c.blue,
  TSFuncMacro = c.blue,
  TSInclude = c.gray_blue,
  TSKeyword = c.gray_blue,
  TSKeywordFunction = c.gray_blue,
  TSKeywordOperator = c.gray_blue,
  TSLabel = c.gray_800,
  TSMethod = c.blue,
  TSNamespace = c.blue,
  TSNone = c.gray_800,
  TSNumber = c.yellow,
  TSOperator = c.gray_blue,
  TSParameter = c.gray_800,
  TSParameterReference = c.gray_800,
  TSProperty = c.gray_800,
  TSPunctDelimiter = c.gray_blue,
  TSPunctBracket = c.gray_800,
  TSPunctSpecial = c.gray_800,
  TSRepeat = c.gray_blue,
  TSString = c.yellow_900,
  TSStringRegex = c.gray_800,
  TSStringEscape = c.gray_600,
  TSSymbol = c.yellow_900,
  TSTag = c.gray_blue,
  TSTagDelimiter = c.gray_blue,
  TSText = c.gray_800,
  TSEmphasis = c.yellow_900,
  TSUnderline = c.gray_100,
  TSStrike = c.gray_100,
  TSTitle = c.blue,
  TSLiteral = c.yellow_900,
  TSURI = c.gray_blue,
  TSType = c.blue,
  TSTypeBuiltin = c.gray_blue,
  TSVariable = c.gray_800,
  TSVariableBuiltin = c.gray_blue,

  RainbowViolet = "#abadda",
  RainbowGreen = "#a4c9c2",
  RainbowBlue = "#7dabe7",
  RainbowCyan = "#74bddd",
}
c = vim.tbl_extend("error", M.colors, default_syntax_hl)

M.defined_highlight_groups = {}

M.highlight = setmetatable({}, {
  __newindex = function(tbl, hlgroup, args)
    table.insert(M.defined_highlight_groups, hlgroup)

    -- If type is string, set a link
    if type(args) == "string" then
      vim.api.nvim_set_hl(0, hlgroup, { link = args })
      return
    end

    local guifg, guibg, gui, guisp =
      args.guifg or nil, args.guibg or nil, args.gui or nil, args.guisp or nil
    local val = {}
    if guifg then val.fg = guifg end
    if guibg then val.bg = guibg end
    if guisp then val.sp = guisp end
    if gui then
      for x in string.gmatch(gui, "([^,]+)") do
        if x ~= "none" then val[x] = true end
      end
    end
    vim.api.nvim_set_hl(0, hlgroup, val)
  end,
})

function M.setup()
  if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
  vim.cmd("set termguicolors")

  local hi = M.highlight

  -- Vim editor colors
  hi.Normal = { guifg = c.gray_800, guibg = c.black, gui = nil, guisp = nil }
  hi.Bold = { guifg = nil, guibg = nil, gui = "bold", guisp = nil }
  hi.Debug = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Directory = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Error = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.ErrorMsg = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.Exception = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.FoldColumn = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.Folded = { guifg = c.gray_600, guibg = c.gray_200, gui = nil, guisp = nil }
  hi.IncSearch =
    { guifg = c.true_white, guibg = c.yellow_800, gui = "none", guisp = nil }
  hi.Italic = { guifg = nil, guibg = nil, gui = "none", guisp = nil }
  hi.Macro = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.MatchParen = { guifg = nil, guibg = c.gray_400, gui = nil, guisp = nil }
  hi.ModeMsg = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.MoreMsg = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.Question = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Search = { guifg = nil, guibg = c.yellow_300, gui = nil, guisp = nil }
  hi.Substitute =
    { guifg = nil, guibg = c.yellow_500, gui = "none", guisp = nil }
  hi.SpecialKey = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.TooLong = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Underlined = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Visual = { guifg = nil, guibg = c.gray_400, gui = nil, guisp = nil }
  hi.VisualNOS = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.WarningMsg = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.WildMenu = { guifg = c.yellow, guibg = c.blue, gui = nil, guisp = nil }
  hi.Title = { guifg = c.blue, guibg = nil, gui = "none", guisp = nil }
  hi.Conceal = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Cursor = { guifg = c.black, guibg = c.gray_800, gui = nil, guisp = nil }
  hi.NonText = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.LineNr = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.SignColumn = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.WinBar = { guifg = c.gray_800, guibg = nil, gui = "none", guisp = nil }
  hi.WinBarNC = { guifg = c.gray_600, guibg = nil, gui = "none", guisp = nil }
  hi.VertSplit = { guifg = c.gray_300, guibg = nil, gui = "none", guisp = nil }
  hi.ColorColumn =
    { guifg = nil, guibg = c.gray_300, gui = "none", guisp = nil }
  hi.CursorColumn =
    { guifg = nil, guibg = c.gray_300, gui = "none", guisp = nil }
  hi.CursorLine = { guifg = nil, guibg = c.gray_300, gui = "none", guisp = nil }
  hi.CursorLineNr =
    { guifg = c.gray_600, guibg = c.gray_300, gui = nil, guisp = nil }
  hi.QuickFixLine =
    { guifg = nil, guibg = c.gray_300, gui = "none", guisp = nil }
  hi.PMenu =
    { guifg = c.gray_600, guibg = c.gray_100, gui = "none", guisp = nil }
  hi.PMenuSel =
    { guifg = c.gray_800, guibg = c.gray_400, gui = nil, guisp = nil }
  hi.PMenuSbar = { guifg = nil, guibg = c.gray_300, gui = "none", guisp = nil }
  hi.PMenuThumb = { guifg = nil, guibg = c.gray_600, gui = nil, guisp = nil }
  hi.StatusLine =
    { guifg = c.gray_800, guibg = c.gray_100, gui = "none", guisp = nil } -- Active status line
  hi.StatusLineNC =
    { guifg = c.gray_600, guibg = c.gray_100, gui = "none", guisp = nil } -- Inactive status line
  hi.TabLine =
    { guifg = c.gray_600, guibg = c.black, gui = "none", guisp = nil } -- Inactive tab
  hi.TabLineFill = { guifg = nil, guibg = nil, gui = "none", guisp = nil }
  hi.TabLineSel =
    { guifg = c.gray_800, guibg = c.gray_300, gui = "none", guisp = nil } -- Active tab

  -- Status line (custom)
  hi.StatusLineDiagnosticError =
    { guifg = c.red, guibg = c.gray_100, gui = nil, guisp = nil }
  hi.StatusLineDiagnosticWarn =
    { guifg = c.yellow, guibg = c.gray_100, gui = nil, guisp = nil }
  hi.StatusLineDiagnosticInfo =
    { guifg = c.blue, guibg = c.gray_100, gui = nil, guisp = nil }
  hi.StatusLineDiagnosticHint =
    { guifg = c.blue, guibg = c.gray_100, gui = nil, guisp = nil }
  hi.StatusLineMuted =
    { guifg = c.gray_600, guibg = c.gray_100, gui = nil, guisp = nil }

  -- Standard syntax highlighting
  hi.Comment = { guifg = c.Comment, guibg = nil, gui = nil, guisp = nil }
  hi.Boolean = { guifg = c.Boolean, guibg = nil, gui = nil, guisp = nil }
  hi.Character = { guifg = c.Character, guibg = nil, gui = nil, guisp = nil }
  hi.Conditional =
    { guifg = c.Conditional, guibg = nil, gui = nil, guisp = nil }
  hi.Constant = { guifg = c.Constant, guibg = nil, gui = nil, guisp = nil }
  hi.Define = { guifg = c.Define, guibg = nil, gui = "none", guisp = nil }
  hi.Delimiter = { guifg = c.Delimiter, guibg = nil, gui = nil, guisp = nil }
  hi.Float = { guifg = c.Float, guibg = nil, gui = nil, guisp = nil }
  hi.Function = { guifg = c.Function, guibg = nil, gui = nil, guisp = nil }
  hi.Identifier =
    { guifg = c.Identifier, guibg = nil, gui = "none", guisp = nil }
  hi.Include = { guifg = c.Include, guibg = nil, gui = nil, guisp = nil }
  hi.Keyword = { guifg = c.Keyword, guibg = nil, gui = nil, guisp = nil }
  hi.Label = { guifg = c.Label, guibg = nil, gui = nil, guisp = nil }
  hi.Number = { guifg = c.Number, guibg = nil, gui = nil, guisp = nil }
  hi.Operator = { guifg = c.Operator, guibg = nil, gui = "none", guisp = nil }
  hi.PreProc = { guifg = c.PreProc, guibg = nil, gui = nil, guisp = nil }
  hi.Repeat = { guifg = c.Repeat, guibg = nil, gui = nil, guisp = nil }
  hi.Special = { guifg = c.Special, guibg = nil, gui = nil, guisp = nil }
  hi.SpecialChar =
    { guifg = c.SpecialChar, guibg = nil, gui = nil, guisp = nil }
  hi.Statement = { guifg = c.Statement, guibg = nil, gui = nil, guisp = nil }
  hi.StorageClass =
    { guifg = c.StorageClass, guibg = nil, gui = nil, guisp = nil }
  hi.String = { guifg = c.String, guibg = nil, gui = nil, guisp = nil }
  hi.Structure = { guifg = c.Structure, guibg = nil, gui = nil, guisp = nil }
  hi.Tag = { guifg = c.Tag, guibg = nil, gui = nil, guisp = nil }
  hi.Type = { guifg = c.Type, guibg = nil, gui = "none", guisp = nil }
  hi.Typedef = { guifg = c.Typedef, guibg = nil, gui = nil, guisp = nil }
  hi.Todo = { guifg = nil, guibg = c.blue_300, gui = nil, guisp = nil }

  -- Diff highlighting
  hi.DiffAdd = { guifg = nil, guibg = c.blue_100, gui = nil, guisp = nil }
  hi.DiffChange = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.DiffDelete =
    { guifg = c.gray_200, guibg = c.gray_100, gui = nil, guisp = nil }
  hi.DiffText = { guifg = nil, guibg = c.blue_300, gui = nil, guisp = nil }
  hi.DiffAdded = { guifg = nil, guibg = c.blue_100, gui = nil, guisp = nil }
  hi.DiffFile = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.DiffNewFile = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.DiffLine = { guifg = nil, guibg = c.yellow_100, gui = nil, guisp = nil }
  hi.DiffRemoved = { guifg = nil, guibg = c.red_100, gui = nil, guisp = nil }

  -- Git highlighting
  hi.gitcommitOverflow = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitSummary =
    { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitComment =
    { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitUntracked =
    { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitDiscarded =
    { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitSelected =
    { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitHeader = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitSelectedType =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitUnmergedType =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitDiscardedType =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitBranch =
    { guifg = c.yellow, guibg = nil, gui = "bold", guisp = nil }
  hi.gitcommitUntrackedFile =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitUnmergedFile =
    { guifg = c.red, guibg = nil, gui = "bold", guisp = nil }
  hi.gitcommitDiscardedFile =
    { guifg = c.red, guibg = nil, gui = "bold", guisp = nil }
  hi.gitcommitSelectedFile =
    { guifg = c.yellow, guibg = nil, gui = "bold", guisp = nil }

  -- GitGutter highlighting
  hi.GitGutterAdd = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.GitGutterChange = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.GitGutterDelete = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.GitGutterChangeDelete =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }

  -- Spelling highlighting
  hi.SpellBad =
    { guifg = nil, guibg = nil, gui = "undercurl", guisp = c.yellow }
  hi.SpellLocal =
    { guifg = nil, guibg = nil, gui = "undercurl", guisp = c.yellow }
  hi.SpellCap = { guifg = nil, guibg = nil, gui = "undercurl", guisp = c.blue }
  hi.SpellRare = { guifg = nil, guibg = nil, gui = "undercurl", guisp = c.blue }

  hi.DiagnosticError = { guifg = c.red, guibg = nil, gui = "none", guisp = nil }
  hi.DiagnosticWarn =
    { guifg = c.yellow, guibg = nil, gui = "none", guisp = nil }
  hi.DiagnosticInfo = { guifg = c.blue, guibg = nil, gui = "none", guisp = nil }
  hi.DiagnosticHint = { guifg = c.blue, guibg = nil, gui = "none", guisp = nil }
  hi.DiagnosticUnderlineError =
    { guifg = nil, guibg = nil, gui = "undercurl", guisp = c.red_700 }
  hi.DiagnosticUnderlineWarning =
    { guifg = nil, guibg = nil, gui = "undercurl", guisp = c.yellow_700 }
  hi.DiagnosticUnderlineWarn =
    { guifg = nil, guibg = nil, gui = "undercurl", guisp = c.yellow_700 }
  hi.DiagnosticUnderlineInformation =
    { guifg = nil, guibg = nil, gui = "undercurl", guisp = c.blue_700 }
  hi.DiagnosticUnderlineHint =
    { guifg = nil, guibg = nil, gui = "undercurl", guisp = c.blue_700 }

  hi.DiagnosticVirtualTextError = { guifg = c.red_700, guibg = c.red_100 }
  hi.DiagnosticVirtualTextWarn = { guifg = c.yellow_700, guibg = c.yellow_100 }
  hi.DiagnosticVirtualTextInfo = { guifg = c.blue_700, guibg = c.blue_100 }
  hi.DiagnosticVirtualTextHint = { guifg = c.blue_700, guibg = c.blue_100 }

  hi.LspReferenceText =
    { guifg = nil, guibg = nil, gui = "underline", guisp = c.gray_600 }
  hi.LspReferenceRead =
    { guifg = nil, guibg = nil, gui = "underline", guisp = c.gray_600 }
  hi.LspReferenceWrite =
    { guifg = nil, guibg = nil, gui = "underline", guisp = c.gray_600 }
  hi.LspDiagnosticsDefaultError = "DiagnosticError"
  hi.LspDiagnosticsDefaultWarning = "DiagnosticWarn"
  hi.LspDiagnosticsDefaultInformation = "DiagnosticInfo"
  hi.LspDiagnosticsDefaultHint = "DiagnosticHint"
  hi.LspDiagnosticsUnderlineError = "DiagnosticUnderlineError"
  hi.LspDiagnosticsUnderlineWarning = "DiagnosticUnderlineWarning"
  hi.LspDiagnosticsUnderlineInformation = "DiagnosticUnderlineInformation"
  hi.LspDiagnosticsUnderlineHint = "DiagnosticUnderlineHint"
  hi.LspInlayHint =
    { guifg = c.gray_600, guibg = nil, gui = "italic", guisp = nil }

  hi.RainbowRed = { guifg = c.RainbowRed, guibg = nil, gui = nil, guisp = nil }
  hi.RainbowOrange =
    { guifg = c.RainbowOrange, guibg = nil, gui = nil, guisp = nil }
  hi.RainbowYellow =
    { guifg = c.RainbowYellow, guibg = nil, gui = nil, guisp = nil }
  hi.RainbowGreen =
    { guifg = c.RainbowGreen, guibg = nil, gui = nil, guisp = nil }
  hi.RainbowBlue =
    { guifg = c.RainbowBlue, guibg = nil, gui = nil, guisp = nil }
  hi.RainbowPurple =
    { guifg = c.RainbowPurple, guibg = nil, gui = nil, guisp = nil }
  hi.RainbowViolet =
    { guifg = c.RainbowViolet, guibg = nil, gui = nil, guisp = nil }
  hi.RainbowCyan =
    { guifg = c.RainbowCyan, guibg = nil, gui = nil, guisp = nil }

  hi.TSAnnotation =
    { guifg = c.TSAnnotation, guibg = nil, gui = "none", guisp = nil }
  hi.TSAttribute =
    { guifg = c.TSAttribute, guibg = nil, gui = "none", guisp = nil }
  hi.TSBoolean = { guifg = c.TSBoolean, guibg = nil, gui = "none", guisp = nil }
  hi.TSCharacter =
    { guifg = c.TSCharacter, guibg = nil, gui = "none", guisp = nil }
  hi.TSComment =
    { guifg = c.TSComment, guibg = nil, gui = "italic", guisp = nil }
  hi.TSConstructor =
    { guifg = c.TSConstructor, guibg = nil, gui = "none", guisp = nil }
  hi.TSConditional =
    { guifg = c.TSConditional, guibg = nil, gui = "none", guisp = nil }
  hi.TSConstant =
    { guifg = c.TSConstant, guibg = nil, gui = "none", guisp = nil }
  hi.TSConstBuiltin =
    { guifg = c.TSConstBuiltin, guibg = nil, gui = "italic", guisp = nil }
  hi.TSConstMacro =
    { guifg = c.TSConstMacro, guibg = nil, gui = "none", guisp = nil }
  hi.TSError = { guifg = c.TSError, guibg = nil, gui = "none", guisp = nil }
  hi.TSException =
    { guifg = c.TSException, guibg = nil, gui = "none", guisp = nil }
  hi.TSField = { guifg = c.TSField, guibg = nil, gui = "none", guisp = nil }
  hi.TSFloat = { guifg = c.TSFloat, guibg = nil, gui = "none", guisp = nil }
  hi.TSFunction =
    { guifg = c.TSFunction, guibg = nil, gui = "none", guisp = nil }
  hi.TSFuncBuiltin =
    { guifg = c.TSFuncBuiltin, guibg = nil, gui = "italic", guisp = nil }
  hi.TSFuncMacro =
    { guifg = c.TSFuncMacro, guibg = nil, gui = "none", guisp = nil }
  hi.TSInclude = { guifg = c.TSInclude, guibg = nil, gui = "none", guisp = nil }
  hi.TSKeyword = { guifg = c.TSKeyword, guibg = nil, gui = "none", guisp = nil }
  hi.TSKeywordFunction =
    { guifg = c.TSKeywordFunction, guibg = nil, gui = "none", guisp = nil }
  hi.TSKeywordOperator =
    { guifg = c.TSKeywordOperator, guibg = nil, gui = "none", guisp = nil }
  hi.TSLabel = { guifg = c.TSLabel, guibg = nil, gui = "none", guisp = nil }
  hi.TSMethod = { guifg = c.TSMethod, guibg = nil, gui = "none", guisp = nil }
  hi.TSNamespace =
    { guifg = c.TSNamespace, guibg = nil, gui = "none", guisp = nil }
  hi.TSNone = { guifg = c.TSNone, guibg = nil, gui = "none", guisp = nil }
  hi.TSNumber = { guifg = c.TSNumber, guibg = nil, gui = "none", guisp = nil }
  hi.TSOperator =
    { guifg = c.TSOperator, guibg = nil, gui = "none", guisp = nil }
  hi.TSParameter =
    { guifg = c.TSParameter, guibg = nil, gui = "none", guisp = nil }
  hi.TSParameterReference =
    { guifg = c.TSParameterReference, guibg = nil, gui = "none", guisp = nil }
  hi.TSProperty =
    { guifg = c.TSProperty, guibg = nil, gui = "none", guisp = nil }
  hi.TSPunctDelimiter =
    { guifg = c.TSPunctDelimiter, guibg = nil, gui = "none", guisp = nil }
  hi.TSPunctBracket =
    { guifg = c.TSPunctBracket, guibg = nil, gui = "none", guisp = nil }
  hi.TSPunctSpecial =
    { guifg = c.TSPunctSpecial, guibg = nil, gui = "none", guisp = nil }
  hi.TSRepeat = { guifg = c.TSRepeat, guibg = nil, gui = "none", guisp = nil }
  hi.TSString = { guifg = c.TSString, guibg = nil, gui = "none", guisp = nil }
  hi.TSStringRegex =
    { guifg = c.TSStringRegex, guibg = nil, gui = "none", guisp = nil }
  hi.TSStringEscape =
    { guifg = c.TSStringEscape, guibg = nil, gui = "none", guisp = nil }
  hi.TSSymbol = { guifg = c.TSSymbol, guibg = nil, gui = "none", guisp = nil }
  hi.TSTag = { guifg = c.TSTag, guibg = nil, gui = "none", guisp = nil }
  hi.TSTagDelimiter =
    { guifg = c.TSTagDelimiter, guibg = nil, gui = "none", guisp = nil }
  hi.TSText = { guifg = c.TSText, guibg = nil, gui = "none", guisp = nil }
  hi.TSEmphasis =
    { guifg = c.TSEmphasis, guibg = nil, gui = "italic", guisp = nil }
  hi.TSUnderline =
    { guifg = c.TSUnderline, guibg = nil, gui = "underline", guisp = nil }
  hi.TSStrike =
    { guifg = c.TSStrike, guibg = nil, gui = "strikethrough", guisp = nil }
  hi.TSTitle = { guifg = c.TSTitle, guibg = nil, gui = "none", guisp = nil }
  hi.TSLiteral = { guifg = c.TSLiteral, guibg = nil, gui = "none", guisp = nil }
  hi.TSURI = { guifg = c.TSURI, guibg = nil, gui = "underline", guisp = nil }
  hi.TSType = { guifg = c.TSType, guibg = nil, gui = "none", guisp = nil }
  hi.TSTypeBuiltin =
    { guifg = c.TSTypeBuiltin, guibg = nil, gui = "italic", guisp = nil }
  hi.TSVariable =
    { guifg = c.TSVariable, guibg = nil, gui = "none", guisp = nil }
  hi.TSVariableBuiltin =
    { guifg = c.TSVariableBuiltin, guibg = nil, gui = "italic", guisp = nil }

  hi.TSStrong = { guifg = nil, guibg = nil, gui = "bold", guisp = nil }
  hi.TSDefinition =
    { guifg = nil, guibg = nil, gui = "underline", guisp = c.gray_600 }
  hi.TSDefinitionUsage =
    { guifg = nil, guibg = nil, gui = "underline", guisp = c.gray_600 }
  hi.TSCurrentScope = { guifg = nil, guibg = nil, gui = "bold", guisp = nil }

  if vim.fn.has("nvim-0.8.0") then
    hi["@comment"] = "TSComment"
    hi["@error"] = "TSError"
    hi["@none"] = "TSNone"
    hi["@preproc"] = "PreProc"
    hi["@define"] = "Define"
    hi["@operator"] = "TSOperator"
    hi["@punctuation.delimiter"] = "TSPunctDelimiter"
    hi["@punctuation.bracket"] = "TSPunctBracket"
    hi["@punctuation.special"] = "TSPunctSpecial"
    hi["@string"] = "TSString"
    hi["@string.regex"] = "TSStringRegex"
    hi["@string.escape"] = "TSStringEscape"
    hi["@string.special"] = "SpecialChar"
    hi["@character"] = "TSCharacter"
    hi["@character.special"] = "SpecialChar"
    hi["@boolean"] = "TSBoolean"
    hi["@number"] = "TSNumber"
    hi["@float"] = "TSFloat"
    hi["@function"] = "TSFunction"
    hi["@function.call"] = "TSFunction"
    hi["@function.builtin"] = "TSFuncBuiltin"
    hi["@function.macro"] = "TSFuncMacro"
    hi["@method"] = "TSMethod"
    hi["@method.call"] = "TSMethod"
    hi["@constructor"] = "TSConstructor"
    hi["@parameter"] = "TSParameter"
    hi["@keyword"] = "TSKeyword"
    hi["@keyword.function"] = "TSKeywordFunction"
    hi["@keyword.operator"] = "TSKeywordOperator"
    hi["@keyword.return"] = "TSKeyword"
    hi["@conditional"] = "TSConditional"
    hi["@repeat"] = "TSRepeat"
    hi["@debug"] = "Debug"
    hi["@label"] = "TSLabel"
    hi["@include"] = "TSInclude"
    hi["@exception"] = "TSException"
    hi["@type"] = "TSType"
    hi["@type.builtin"] = "TSTypeBuiltin"
    hi["@type.qualifier"] = "TSKeyword"
    hi["@type.definition"] = "TSType"
    hi["@storageclass"] = "StorageClass"
    hi["@attribute"] = "TSAttribute"
    hi["@field"] = "TSField"
    hi["@property"] = "TSProperty"
    hi["@variable"] = "TSVariable"
    hi["@variable.builtin"] = "TSVariableBuiltin"
    hi["@constant"] = "TSConstant"
    hi["@constant.builtin"] = "TSConstant"
    hi["@constant.macro"] = "TSConstant"
    hi["@namespace"] = "TSNamespace"
    hi["@symbol"] = "TSSymbol"
    hi["@text"] = "TSText"
    hi["@text.diff.add"] = "DiffAdd"
    hi["@text.diff.delete"] = "DiffDelete"
    hi["@text.strong"] = "TSStrong"
    hi["@text.emphasis"] = "TSEmphasis"
    hi["@text.underline"] = "TSUnderline"
    hi["@text.strike"] = "TSStrike"
    hi["@text.title"] = "TSTitle"
    hi["@text.literal"] = "TSLiteral"
    hi["@text.uri"] = "TSUri"
    hi["@text.math"] = "Number"
    hi["@text.environment"] = "Macro"
    hi["@text.environment.name"] = "Type"
    hi["@text.reference"] = "TSParameterReference"
    hi["@text.todo"] = "Todo"
    hi["@text.note"] = "Tag"
    hi["@text.warning"] = "DiagnosticWarn"
    hi["@text.danger"] = "DiagnosticError"
    hi["@tag"] = "TSTag"
    hi["@tag.attribute"] = "TSAttribute"
    hi["@tag.delimiter"] = "TSTagDelimiter"
  end

  hi.NvimInternalError =
    { guifg = c.black, guibg = c.blue, gui = "none", guisp = nil }

  hi.NormalFloat =
    { guifg = c.gray_800, guibg = c.blue_200, gui = nil, guisp = nil }
  hi.FloatBorder =
    { guifg = c.gray_800, guibg = c.black, gui = nil, guisp = nil }
  hi.NormalNC = { guifg = c.gray_800, guibg = nil, gui = nil, guisp = nil }
  hi.TermCursor =
    { guifg = c.black, guibg = c.gray_800, gui = "none", guisp = nil }
  hi.TermCursorNC =
    { guifg = c.black, guibg = c.gray_800, gui = nil, guisp = nil }

  hi.NotifyErrorNormal =
    { guifg = c.gray_700, guibg = c.red_200, gui = nil, guisp = nil }
  hi.NotifyWarnNormal =
    { guifg = c.gray_700, guibg = c.yellow_200, gui = nil, guisp = nil }
  hi.NotifyInfoNormal =
    { guifg = c.gray_700, guibg = c.blue_200, gui = nil, guisp = nil }
  hi.NotifyDebugNormal =
    { guifg = c.gray_700, guibg = c.gray_200, gui = nil, guisp = nil }
  hi.NotifyTraceNormal =
    { guifg = c.gray_700, guibg = c.gray_200, gui = nil, guisp = nil }
  hi.NotifyUnknownNormal =
    { guifg = c.gray_700, guibg = c.gray_200, gui = nil, guisp = nil }

  hi.WinbarPath = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.WinbarFile = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }

  hi.User1 = { guifg = c.blue, guibg = c.gray_400, gui = "none", guisp = nil }
  hi.User2 = { guifg = c.blue, guibg = c.gray_400, gui = "none", guisp = nil }
  hi.User3 =
    { guifg = c.gray_800, guibg = c.gray_400, gui = "none", guisp = nil }
  hi.User4 = { guifg = c.yellow, guibg = c.gray_400, gui = "none", guisp = nil }
  hi.User5 =
    { guifg = c.gray_800, guibg = c.gray_400, gui = "none", guisp = nil }
  hi.User6 =
    { guifg = c.gray_800, guibg = c.gray_300, gui = "none", guisp = nil }
  hi.User7 =
    { guifg = c.gray_800, guibg = c.gray_400, gui = "none", guisp = nil }
  hi.User8 = { guifg = c.black, guibg = c.gray_400, gui = "none", guisp = nil }
  hi.User9 = { guifg = c.black, guibg = c.gray_400, gui = "none", guisp = nil }

  hi.TreesitterContext =
    { guifg = nil, guibg = c.gray_300, gui = "italic", guisp = nil }

  local override_terminal_color = vim.g.neovide

  if override_terminal_color then
    vim.g.terminal_color_0 = c.black
    vim.g.terminal_color_1 = c.red
    vim.g.terminal_color_2 = c.blue
    vim.g.terminal_color_3 = c.blue
    vim.g.terminal_color_4 = c.blue
    vim.g.terminal_color_5 = c.blue
    vim.g.terminal_color_6 = c.blue
    vim.g.terminal_color_7 = c.white
    vim.g.terminal_color_8 = c.gray_600
    vim.g.terminal_color_9 = c.red
    vim.g.terminal_color_10 = c.blue
    vim.g.terminal_color_11 = c.blue
    vim.g.terminal_color_12 = c.blue
    vim.g.terminal_color_13 = c.blue
    vim.g.terminal_color_14 = c.blue
    vim.g.terminal_color_15 = c.white
  end

  -- FzfLua
  hi.FzfLuaBufFlagCur = { guifg = c.gray_600, guibg = nil }
  hi.FzfLuaTabTitle = { guifg = c.blue, guibg = nil }
  hi.FzfLuaHeaderText = { guifg = c.gray_600, guibg = nil }
  hi.FzfLuaBufLineNr = { guifg = c.blue, guibg = nil }
  hi.FzfLuaBufNr = { guifg = c.blue, guibg = nil }
  hi.FzfLuaBufName = { guifg = c.blue, guibg = nil }
  hi.FzfLuaHeaderBind = { guifg = c.blue, guibg = nil }
  hi.FzfLuaTabMarker = { guifg = c.blue, guibg = nil }
  hi.FzfLuaBufFlagAlt = { guifg = c.blue, guibg = nil }

  -- nvim-cmp
  hi.CmpItemAbbr = { guifg = c.gray_700, guibg = nil, gui = nil, guisp = nil } -- Completion items default
  hi.CmpItemAbbrDeprecated =
    { guifg = c.gray_600, guibg = nil, gui = "strikethrough", guisp = nil }
  hi.CmpItemAbbrDeprecatedDefault = "CmpItemAbbrDeprecated"
  hi.CmpItemAbbrMatch = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil } -- Matched portion of completion items
  hi.CmpItemAbbrMatchFuzzy =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemMenu = { guifg = nil, guibg = nil, gui = nil, guisp = nil }
  -- Color of "<icon> symbol" on the right
  hi.CmpItemKindDefault =
    { guifg = c.gray_700, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindKeyword =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindVariable =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindConstant =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindReference =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindValue = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindFunction =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindMethod = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindConstructor =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindClass =
    { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindInterface =
    { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindStruct =
    { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindEvent =
    { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindEnum = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindUnit = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindModule =
    { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindProperty =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindField = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindTypeParameter =
    { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindEnumMember =
    { guifg = c.white, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindOperator =
    { guifg = c.white, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindSnippet =
    { guifg = c.white, guibg = nil, gui = nil, guisp = nil }

  -- Git signs
  hi.GitSignsChangeInline = { guifg = nil, guibg = c.blue_300 } -- Current state of the hunk for preview_hunk
  hi.GitSignsDeleteVirtLn = { guifg = nil, guibg = c.red_300 } -- Previous state of the hunk for preview_hunk

  -- Flash
  hi.FlashLabel = { guifg = c.true_white, guibg = c.blue_700 }
end

M.debug = function(opts)
  opts = vim.tbl_extend("force", {
    enable_colorizer = true,
    show_color_names = true,
    hide_defined_hl = true,
  }, opts or {})

  local function get_color_name_if_exists(target)
    for color, value in pairs(M.colors) do
      if value == target then return color end
    end
    return target
  end

  local map = utils.map
  local split_string = utils.split_string
  local contains = utils.contains

  local function join_lines_if_begins_with_links(lines)
    local i = 1
    while i < #lines do
      -- Trim the leading and trailing whitespace and check if first 5 char is "links"
      if
        string.sub(lines[i + 1]:gsub("^%s*(.-)%s*$", "%1"), 1, 5) == "links"
      then
        lines[i] = lines[i] .. " " .. lines[i + 1]
        table.remove(lines, i + 1)
      else
        i = i + 1
      end
    end
    return lines
  end

  local hl_groups = split_string(vim.api.nvim_exec("highlight", true), "\n")
  hl_groups = join_lines_if_begins_with_links(hl_groups)

  local buf_lines = map(hl_groups, function(i, g)
    local parts = split_string(g, " ")
    local links_to = string.match(g, "links to (%w+)")

    if
      opts.hide_defined_hl
      and contains(M.defined_highlight_groups, parts[1])
    then
      return nil
    end

    return table.concat(
      map(parts, function(i, part)
        -- a = letter; x = hexidecimal digit
        local k, v = string.match(part, "(gui%a+)=(#%x+)")
        if k and v then
          return k
            .. "-"
            .. (opts.show_color_names and get_color_name_if_exists(v) or v)
        else
          return part
        end
      end),
      " "
    )
  end)

  utils.show_content_in_buffer(buf_lines)
  if opts.enable_colorizer then vim.cmd("ColorizerToggle") end
end

return M
