-- Tweak from RRethy/nvim-base16
-- https://github.com/RRethy/nvim-base16/blob/master/lua/base16-colorscheme.lua

local M = {}

local white = "#CBD1DA"
local black = "#000000"
local red = "#eb5858"
local blue = "#549eff"
local yellow = "#f59953"

M.colors = {
  base00 = black,
  base01 = '#2c313c',
  base02 = '#3e4451',
  base03 = '#6c7891',
  base04 = '#565c64',
  base05 = '#abb2bf',
  base06 = '#9a9bb3',
  base07 = white,

  white = white,
  black = black,
  red = red,
  blue = blue,
  yellow = yellow,

  base08 = blue,
  base09 = yellow,
  base0A = blue,
  base0B = yellow,  -- string
  base0C = yellow,
  base0D = blue,
  base0E = blue,
  base0F = blue,
}

M.highlight = setmetatable({}, {
  __newindex = function(_, hlgroup, args)
    if ('string' == type(args)) then
      vim.api.nvim_set_hl(0, hlgroup, { link = args })
      return
    end

    local guifg, guibg, gui, guisp = args.guifg or nil, args.guibg or nil, args.gui or nil, args.guisp or nil
    local val = {}
    if guifg then val.fg = guifg end
    if guibg then val.bg = guibg end
    if guisp then val.sp = guisp end
    if gui then
      for x in string.gmatch(gui, '([^,]+)') do
        if x ~= "none" then
          val[x] = true
        end
      end
    end
    vim.api.nvim_set_hl(0, hlgroup, val)
  end
})

function M.setup()
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end
  vim.cmd('set termguicolors')

  local c = M.colors

  local hi                              = M.highlight

  -- Vim editor colors
  hi.Normal                             = { guifg = c.base05, guibg = c.base00, gui = nil, guisp = nil }
  hi.Bold                               = { guifg = nil, guibg = nil, gui = 'bold', guisp = nil }
  hi.Debug                              = { guifg = c.base08, guibg = nil, gui = nil, guisp = nil }
  hi.Directory                          = { guifg = c.base0D, guibg = nil, gui = nil, guisp = nil }
  hi.Error                              = { guifg = c.red, guibg = c.base00, gui = nil, guisp = nil }
  hi.ErrorMsg                           = { guifg = c.red, guibg = c.base00, gui = nil, guisp = nil }
  hi.Exception                          = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.FoldColumn                         = { guifg = c.base0C, guibg = c.base00, gui = nil, guisp = nil }
  hi.Folded                             = { guifg = c.base03, guibg = c.base01, gui = nil, guisp = nil }
  hi.IncSearch                          = { guifg = c.black, guibg = c.white, gui = 'none', guisp = nil }
  hi.Italic                             = { guifg = nil, guibg = nil, gui = 'none', guisp = nil }
  hi.Macro                              = { guifg = c.base08, guibg = nil, gui = nil, guisp = nil }
  hi.MatchParen                         = { guifg = nil, guibg = c.base02, gui = nil, guisp = nil }
  hi.ModeMsg                            = { guifg = c.base0B, guibg = nil, gui = nil, guisp = nil }
  hi.MoreMsg                            = { guifg = c.base0B, guibg = nil, gui = nil, guisp = nil }
  hi.Question                           = { guifg = c.base0D, guibg = nil, gui = nil, guisp = nil }
  hi.Search                             = { guifg = nil, guibg = c.base01, gui = nil, guisp = nil }
  hi.Substitute                         = { guifg = nil, guibg = c.base02, gui = 'none', guisp = nil }
  hi.SpecialKey                         = { guifg = c.base03, guibg = nil, gui = nil, guisp = nil }
  hi.TooLong                            = { guifg = c.base08, guibg = nil, gui = nil, guisp = nil }
  hi.Underlined                         = { guifg = c.base08, guibg = nil, gui = nil, guisp = nil }
  hi.Visual                             = { guifg = nil, guibg = c.base02, gui = nil, guisp = nil }
  hi.VisualNOS                          = { guifg = c.base08, guibg = nil, gui = nil, guisp = nil }
  hi.WarningMsg                         = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.WildMenu                           = { guifg = c.yellow, guibg = c.base0A, gui = nil, guisp = nil }
  hi.Title                              = { guifg = c.base0D, guibg = nil, gui = 'none', guisp = nil }
  hi.Conceal                            = { guifg = c.base0D, guibg = c.base00, gui = nil, guisp = nil }
  hi.Cursor                             = { guifg = c.base00, guibg = c.base05, gui = nil, guisp = nil }
  hi.NonText                            = { guifg = c.base03, guibg = nil, gui = nil, guisp = nil }
  hi.LineNr                             = { guifg = c.base04, guibg = c.base00, gui = nil, guisp = nil }
  hi.SignColumn                         = { guifg = c.base04, guibg = c.base00, gui = nil, guisp = nil }
  hi.StatusLine                         = { guifg = c.base05, guibg = c.base02, gui = 'none', guisp = nil }
  hi.StatusLineNC                       = { guifg = c.base04, guibg = c.base01, gui = 'none', guisp = nil }
  hi.WinBar                             = { guifg = c.base05, guibg = nil, gui = 'none', guisp = nil }
  hi.WinBarNC                           = { guifg = c.base04, guibg = nil, gui = 'none', guisp = nil }
  hi.VertSplit                          = { guifg = c.base05, guibg = c.base00, gui = 'none', guisp = nil }
  hi.ColorColumn                        = { guifg = nil, guibg = c.base01, gui = 'none', guisp = nil }
  hi.CursorColumn                       = { guifg = nil, guibg = c.base01, gui = 'none', guisp = nil }
  hi.CursorLine                         = { guifg = nil, guibg = c.base01, gui = 'none', guisp = nil }
  hi.CursorLineNr                       = { guifg = c.base04, guibg = c.base01, gui = nil, guisp = nil }
  hi.QuickFixLine                       = { guifg = nil, guibg = c.base01, gui = 'none', guisp = nil }
  hi.PMenu                              = { guifg = c.base05, guibg = c.base01, gui = 'none', guisp = nil }
  hi.PMenuSel                           = { guifg = c.base01, guibg = c.base05, gui = nil, guisp = nil }
  hi.TabLine                            = { guifg = c.base03, guibg = c.base01, gui = 'none', guisp = nil }
  hi.TabLineFill                        = { guifg = c.base03, guibg = c.base01, gui = 'none', guisp = nil }
  hi.TabLineSel                         = { guifg = c.base0B, guibg = c.base01, gui = 'none', guisp = nil }

  -- Standard syntax highlighting
  hi.Boolean                            = { guifg = c.base09, guibg = nil, gui = nil, guisp = nil }
  hi.Character                          = { guifg = c.base08, guibg = nil, gui = nil, guisp = nil }
  hi.Comment                            = { guifg = c.base03, guibg = nil, gui = nil, guisp = nil }
  hi.Conditional                        = { guifg = c.base0E, guibg = nil, gui = nil, guisp = nil }
  hi.Constant                           = { guifg = c.base09, guibg = nil, gui = nil, guisp = nil }
  hi.Define                             = { guifg = c.base0E, guibg = nil, gui = 'none', guisp = nil }
  hi.Delimiter                          = { guifg = c.base0F, guibg = nil, gui = nil, guisp = nil }
  hi.Float                              = { guifg = c.base09, guibg = nil, gui = nil, guisp = nil }
  hi.Function                           = { guifg = c.base0D, guibg = nil, gui = nil, guisp = nil }
  hi.Identifier                         = { guifg = c.base08, guibg = nil, gui = 'none', guisp = nil }
  hi.Include                            = { guifg = c.base0D, guibg = nil, gui = nil, guisp = nil }
  hi.Keyword                            = { guifg = c.base0E, guibg = nil, gui = nil, guisp = nil }
  hi.Label                              = { guifg = c.base0A, guibg = nil, gui = nil, guisp = nil }
  hi.Number                             = { guifg = c.base09, guibg = nil, gui = nil, guisp = nil }
  hi.Operator                           = { guifg = c.base0E, guibg = nil, gui = 'none', guisp = nil }
  hi.PreProc                            = { guifg = c.base0A, guibg = nil, gui = nil, guisp = nil }
  hi.Repeat                             = { guifg = c.base0A, guibg = nil, gui = nil, guisp = nil }
  hi.Special                            = { guifg = c.base0C, guibg = nil, gui = nil, guisp = nil }
  hi.SpecialChar                        = { guifg = c.base0F, guibg = nil, gui = nil, guisp = nil }
  hi.Statement                          = { guifg = c.base08, guibg = nil, gui = nil, guisp = nil }
  hi.StorageClass                       = { guifg = c.base0A, guibg = nil, gui = nil, guisp = nil }
  hi.String                             = { guifg = c.base0B, guibg = nil, gui = nil, guisp = nil }
  hi.Structure                          = { guifg = c.base0E, guibg = nil, gui = nil, guisp = nil }
  hi.Tag                                = { guifg = c.base0A, guibg = nil, gui = nil, guisp = nil }
  hi.Todo                               = { guifg = c.base0A, guibg = c.base01, gui = nil, guisp = nil }
  hi.Type                               = { guifg = c.base0A, guibg = nil, gui = 'none', guisp = nil }
  hi.Typedef                            = { guifg = c.base0A, guibg = nil, gui = nil, guisp = nil }

  -- Diff highlighting
  hi.DiffAdd                            = { guifg = c.blue, guibg = c.base00, gui = nil, guisp = nil }
  hi.DiffChange                         = { guifg = c.yellow, guibg = c.base00, gui = nil, guisp = nil }
  hi.DiffDelete                         = { guifg = c.red, guibg = c.base00, gui = nil, guisp = nil }
  hi.DiffText                           = { guifg = c.base0D, guibg = c.base00, gui = nil, guisp = nil }
  hi.DiffAdded                          = { guifg = c.blue, guibg = c.base00, gui = nil, guisp = nil }
  hi.DiffFile                           = { guifg = c.red, guibg = c.base00, gui = nil, guisp = nil }
  hi.DiffNewFile                        = { guifg = c.base0B, guibg = c.base00, gui = nil, guisp = nil }
  hi.DiffLine                           = { guifg = c.base0D, guibg = c.base00, gui = nil, guisp = nil }
  hi.DiffRemoved                        = { guifg = c.red, guibg = c.base00, gui = nil, guisp = nil }

  -- Git highlighting
  hi.gitcommitOverflow                  = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitSummary                   = { guifg = c.base0B, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitComment                   = { guifg = c.base03, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitUntracked                 = { guifg = c.base03, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitDiscarded                 = { guifg = c.base03, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitSelected                  = { guifg = c.base03, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitHeader                    = { guifg = c.base0E, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitSelectedType              = { guifg = c.base0D, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitUnmergedType              = { guifg = c.base0D, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitDiscardedType             = { guifg = c.base0D, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitBranch                    = { guifg = c.base09, guibg = nil, gui = 'bold', guisp = nil }
  hi.gitcommitUntrackedFile             = { guifg = c.base0A, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitUnmergedFile              = { guifg = c.red, guibg = nil, gui = 'bold', guisp = nil }
  hi.gitcommitDiscardedFile             = { guifg = c.red, guibg = nil, gui = 'bold', guisp = nil }
  hi.gitcommitSelectedFile              = { guifg = c.base0B, guibg = nil, gui = 'bold', guisp = nil }

  -- GitGutter highlighting
  hi.GitGutterAdd                       = { guifg = c.blue, guibg = c.base00, gui = nil, guisp = nil }
  hi.GitGutterChange                    = { guifg = c.yellow, guibg = c.base00, gui = nil, guisp = nil }
  hi.GitGutterDelete                    = { guifg = c.red, guibg = c.base00, gui = nil, guisp = nil }
  hi.GitGutterChangeDelete              = { guifg = c.base0E, guibg = c.base00, gui = nil, guisp = nil }

  -- Spelling highlighting
  hi.SpellBad                           = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.yellow }
  hi.SpellLocal                         = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.base0C }
  hi.SpellCap                           = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.base0D }
  hi.SpellRare                          = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.base0E }

  hi.DiagnosticError                    = { guifg = c.red, guibg = nil, gui = 'none', guisp = nil }
  hi.DiagnosticWarn                     = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }
  hi.DiagnosticInfo                     = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.DiagnosticHint                     = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.DiagnosticUnderlineError           = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.red }
  hi.DiagnosticUnderlineWarning         = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.yellow }
  hi.DiagnosticUnderlineWarn            = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.yellow }
  hi.DiagnosticUnderlineInformation     = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.blue }
  hi.DiagnosticUnderlineHint            = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.blue }

  hi.LspReferenceText                   = { guifg = nil, guibg = nil, gui = 'underline', guisp = c.base04 }
  hi.LspReferenceRead                   = { guifg = nil, guibg = nil, gui = 'underline', guisp = c.base04 }
  hi.LspReferenceWrite                  = { guifg = nil, guibg = nil, gui = 'underline', guisp = c.base04 }
  hi.LspDiagnosticsDefaultError         = 'DiagnosticError'
  hi.LspDiagnosticsDefaultWarning       = 'DiagnosticWarn'
  hi.LspDiagnosticsDefaultInformation   = 'DiagnosticInfo'
  hi.LspDiagnosticsDefaultHint          = 'DiagnosticHint'
  hi.LspDiagnosticsUnderlineError       = 'DiagnosticUnderlineError'
  hi.LspDiagnosticsUnderlineWarning     = 'DiagnosticUnderlineWarning'
  hi.LspDiagnosticsUnderlineInformation = 'DiagnosticUnderlineInformation'
  hi.LspDiagnosticsUnderlineHint        = 'DiagnosticUnderlineHint'

  hi.TSAnnotation                       = { guifg = c.base0F, guibg = nil, gui = 'none', guisp = nil }
  hi.TSAttribute                        = { guifg = c.base0A, guibg = nil, gui = 'none', guisp = nil }
  hi.TSBoolean                          = { guifg = c.base09, guibg = nil, gui = 'none', guisp = nil }
  hi.TSCharacter                        = { guifg = c.base08, guibg = nil, gui = 'none', guisp = nil }
  hi.TSComment                          = { guifg = c.base03, guibg = nil, gui = 'italic', guisp = nil }
  hi.TSConstructor                      = { guifg = c.base0D, guibg = nil, gui = 'none', guisp = nil }
  hi.TSConditional                      = { guifg = c.base0E, guibg = nil, gui = 'none', guisp = nil }
  hi.TSConstant                         = { guifg = c.base09, guibg = nil, gui = 'none', guisp = nil }
  hi.TSConstBuiltin                     = { guifg = c.base09, guibg = nil, gui = 'italic', guisp = nil }
  hi.TSConstMacro                       = { guifg = c.base08, guibg = nil, gui = 'none', guisp = nil }
  hi.TSError                            = { guifg = c.base08, guibg = nil, gui = 'none', guisp = nil }
  hi.TSException                        = { guifg = c.base08, guibg = nil, gui = 'none', guisp = nil }
  hi.TSField                            = { guifg = c.base05, guibg = nil, gui = 'none', guisp = nil }
  hi.TSFloat                            = { guifg = c.base09, guibg = nil, gui = 'none', guisp = nil }
  hi.TSFunction                         = { guifg = c.base0D, guibg = nil, gui = 'none', guisp = nil }
  hi.TSFuncBuiltin                      = { guifg = c.base0D, guibg = nil, gui = 'italic', guisp = nil }
  hi.TSFuncMacro                        = { guifg = c.base08, guibg = nil, gui = 'none', guisp = nil }
  hi.TSInclude                          = { guifg = c.base0D, guibg = nil, gui = 'none', guisp = nil }
  hi.TSKeyword                          = { guifg = c.base0E, guibg = nil, gui = 'none', guisp = nil }
  hi.TSKeywordFunction                  = { guifg = c.base0E, guibg = nil, gui = 'none', guisp = nil }
  hi.TSKeywordOperator                  = { guifg = c.base0E, guibg = nil, gui = 'none', guisp = nil }
  hi.TSLabel                            = { guifg = c.base0A, guibg = nil, gui = 'none', guisp = nil }
  hi.TSMethod                           = { guifg = c.base0D, guibg = nil, gui = 'none', guisp = nil }
  hi.TSNamespace                        = { guifg = c.base08, guibg = nil, gui = 'none', guisp = nil }
  hi.TSNone                             = { guifg = c.base05, guibg = nil, gui = 'none', guisp = nil }
  hi.TSNumber                           = { guifg = c.base09, guibg = nil, gui = 'none', guisp = nil }
  hi.TSOperator                         = { guifg = c.base05, guibg = nil, gui = 'none', guisp = nil }
  hi.TSParameter                        = { guifg = c.base05, guibg = nil, gui = 'none', guisp = nil }
  hi.TSParameterReference               = { guifg = c.base05, guibg = nil, gui = 'none', guisp = nil }
  hi.TSProperty                         = { guifg = c.base05, guibg = nil, gui = 'none', guisp = nil }
  hi.TSPunctDelimiter                   = { guifg = c.base0F, guibg = nil, gui = 'none', guisp = nil }
  hi.TSPunctBracket                     = { guifg = c.base05, guibg = nil, gui = 'none', guisp = nil }
  hi.TSPunctSpecial                     = { guifg = c.base05, guibg = nil, gui = 'none', guisp = nil }
  hi.TSRepeat                           = { guifg = c.base0E, guibg = nil, gui = 'none', guisp = nil }
  hi.TSString                           = { guifg = c.base0B, guibg = nil, gui = 'none', guisp = nil }
  hi.TSStringRegex                      = { guifg = c.base0C, guibg = nil, gui = 'none', guisp = nil }
  hi.TSStringEscape                     = { guifg = c.base0C, guibg = nil, gui = 'none', guisp = nil }
  hi.TSSymbol                           = { guifg = c.base0B, guibg = nil, gui = 'none', guisp = nil }
  hi.TSTag                              = { guifg = c.base08, guibg = nil, gui = 'none', guisp = nil }
  hi.TSTagDelimiter                     = { guifg = c.base0F, guibg = nil, gui = 'none', guisp = nil }
  hi.TSText                             = { guifg = c.base05, guibg = nil, gui = 'none', guisp = nil }
  hi.TSStrong                           = { guifg = nil, guibg = nil, gui = 'bold', guisp = nil }
  hi.TSEmphasis                         = { guifg = c.base09, guibg = nil, gui = 'italic', guisp = nil }
  hi.TSUnderline                        = { guifg = c.base00, guibg = nil, gui = 'underline', guisp = nil }
  hi.TSStrike                           = { guifg = c.base00, guibg = nil, gui = 'strikethrough', guisp = nil }
  hi.TSTitle                            = { guifg = c.base0D, guibg = nil, gui = 'none', guisp = nil }
  hi.TSLiteral                          = { guifg = c.base09, guibg = nil, gui = 'none', guisp = nil }
  hi.TSURI                              = { guifg = c.base09, guibg = nil, gui = 'underline', guisp = nil }
  hi.TSType                             = { guifg = c.base0A, guibg = nil, gui = 'none', guisp = nil }
  hi.TSTypeBuiltin                      = { guifg = c.base0A, guibg = nil, gui = 'italic', guisp = nil }
  hi.TSVariable                         = { guifg = c.base08, guibg = nil, gui = 'none', guisp = nil }
  hi.TSVariableBuiltin                  = { guifg = c.base08, guibg = nil, gui = 'italic', guisp = nil }

  hi.TSDefinition                       = { guifg = nil, guibg = nil, gui = 'underline', guisp = c.base04 }
  hi.TSDefinitionUsage                  = { guifg = nil, guibg = nil, gui = 'underline', guisp = c.base04 }
  hi.TSCurrentScope                     = { guifg = nil, guibg = nil, gui = 'bold', guisp = nil }

  hi.LspInlayHint                       = { guifg = c.base03, guibg = nil, gui = 'italic', guisp = nil }

  if vim.fn.has('nvim-0.8.0') then
    hi['@comment'] = 'TSComment'
    hi['@error'] = 'TSError'
    hi['@none'] = 'TSNone'
    hi['@preproc'] = 'PreProc'
    hi['@define'] = 'Define'
    hi['@operator'] = 'TSOperator'
    hi['@punctuation.delimiter'] = 'TSPunctDelimiter'
    hi['@punctuation.bracket'] = 'TSPunctBracket'
    hi['@punctuation.special'] = 'TSPunctSpecial'
    hi['@string'] = 'TSString'
    hi['@string.regex'] = 'TSStringRegex'
    hi['@string.escape'] = 'TSStringEscape'
    hi['@string.special'] = 'SpecialChar'
    hi['@character'] = 'TSCharacter'
    hi['@character.special'] = 'SpecialChar'
    hi['@boolean'] = 'TSBoolean'
    hi['@number'] = 'TSNumber'
    hi['@float'] = 'TSFloat'
    hi['@function'] = 'TSFunction'
    hi['@function.call'] = 'TSFunction'
    hi['@function.builtin'] = 'TSFuncBuiltin'
    hi['@function.macro'] = 'TSFuncMacro'
    hi['@method'] = 'TSMethod'
    hi['@method.call'] = 'TSMethod'
    hi['@constructor'] = 'TSConstructor'
    hi['@parameter'] = 'TSParameter'
    hi['@keyword'] = 'TSKeyword'
    hi['@keyword.function'] = 'TSKeywordFunction'
    hi['@keyword.operator'] = 'TSKeywordOperator'
    hi['@keyword.return'] = 'TSKeyword'
    hi['@conditional'] = 'TSConditional'
    hi['@repeat'] = 'TSRepeat'
    hi['@debug'] = 'Debug'
    hi['@label'] = 'TSLabel'
    hi['@include'] = 'TSInclude'
    hi['@exception'] = 'TSException'
    hi['@type'] = 'TSType'
    hi['@type.builtin'] = 'TSTypeBuiltin'
    hi['@type.qualifier'] = 'TSKeyword'
    hi['@type.definition'] = 'TSType'
    hi['@storageclass'] = 'StorageClass'
    hi['@attribute'] = 'TSAttribute'
    hi['@field'] = 'TSField'
    hi['@property'] = 'TSProperty'
    hi['@variable'] = 'TSVariable'
    hi['@variable.builtin'] = 'TSVariableBuiltin'
    hi['@constant'] = 'TSConstant'
    hi['@constant.builtin'] = 'TSConstant'
    hi['@constant.macro'] = 'TSConstant'
    hi['@namespace'] = 'TSNamespace'
    hi['@symbol'] = 'TSSymbol'
    hi['@text'] = 'TSText'
    hi['@text.diff.add'] = 'DiffAdd'
    hi['@text.diff.delete'] = 'DiffDelete'
    hi['@text.strong'] = 'TSStrong'
    hi['@text.emphasis'] = 'TSEmphasis'
    hi['@text.underline'] = 'TSUnderline'
    hi['@text.strike'] = 'TSStrike'
    hi['@text.title'] = 'TSTitle'
    hi['@text.literal'] = 'TSLiteral'
    hi['@text.uri'] = 'TSUri'
    hi['@text.math'] = 'Number'
    hi['@text.environment'] = 'Macro'
    hi['@text.environment.name'] = 'Type'
    hi['@text.reference'] = 'TSParameterReference'
    hi['@text.todo'] = 'Todo'
    hi['@text.note'] = 'Tag'
    hi['@text.warning'] = 'DiagnosticWarn'
    hi['@text.danger'] = 'DiagnosticError'
    hi['@tag'] = 'TSTag'
    hi['@tag.attribute'] = 'TSAttribute'
    hi['@tag.delimiter'] = 'TSTagDelimiter'
  end

  hi.NvimInternalError = { guifg = c.base00, guibg = c.base08, gui = 'none', guisp = nil }

  hi.NormalFloat       = { guifg = c.base05, guibg = '#171A1C', gui = nil, guisp = nil }
  hi.FloatBorder       = { guifg = c.base05, guibg = c.base00, gui = nil, guisp = nil }
  hi.NormalNC          = { guifg = c.base05, guibg = c.base00, gui = nil, guisp = nil }
  hi.TermCursor        = { guifg = c.base00, guibg = c.base05, gui = 'none', guisp = nil }
  hi.TermCursorNC      = { guifg = c.base00, guibg = c.base05, gui = nil, guisp = nil }

  hi.User1             = { guifg = c.base08, guibg = c.base02, gui = 'none', guisp = nil }
  hi.User2             = { guifg = c.base0E, guibg = c.base02, gui = 'none', guisp = nil }
  hi.User3             = { guifg = c.base05, guibg = c.base02, gui = 'none', guisp = nil }
  hi.User4             = { guifg = c.base0C, guibg = c.base02, gui = 'none', guisp = nil }
  hi.User5             = { guifg = c.base05, guibg = c.base02, gui = 'none', guisp = nil }
  hi.User6             = { guifg = c.base05, guibg = c.base01, gui = 'none', guisp = nil }
  hi.User7             = { guifg = c.base05, guibg = c.base02, gui = 'none', guisp = nil }
  hi.User8             = { guifg = c.base00, guibg = c.base02, gui = 'none', guisp = nil }
  hi.User9             = { guifg = c.base00, guibg = c.base02, gui = 'none', guisp = nil }

  hi.TreesitterContext = { guifg = nil, guibg = c.base01, gui = 'italic', guisp = nil }

  vim.g.terminal_color_0  = c.black
  vim.g.terminal_color_1  = c.red
  vim.g.terminal_color_2  = c.blue
  vim.g.terminal_color_3  = c.blue
  vim.g.terminal_color_4  = c.blue
  vim.g.terminal_color_5  = c.blue
  vim.g.terminal_color_6  = c.blue
  vim.g.terminal_color_7  = c.white
  vim.g.terminal_color_8  = c.base03
  vim.g.terminal_color_9  = c.red
  vim.g.terminal_color_10 = c.blue
  vim.g.terminal_color_11 = c.blue
  vim.g.terminal_color_12 = c.blue
  vim.g.terminal_color_13 = c.blue
  vim.g.terminal_color_14 = c.blue
  vim.g.terminal_color_15 = c.white

  vim.g.base16_gui00      = c.black
  vim.g.base16_gui01      = c.red
  vim.g.base16_gui02      = c.blue
  vim.g.base16_gui03      = c.blue
  vim.g.base16_gui04      = c.blue
  vim.g.base16_gui05      = c.blue
  vim.g.base16_gui06      = c.blue
  vim.g.base16_gui07      = c.white
  vim.g.base16_gui08      = c.base03
  vim.g.base16_gui09      = c.red
  vim.g.base16_gui0A      = c.blue
  vim.g.base16_gui0B      = c.blue
  vim.g.base16_gui0C      = c.blue
  vim.g.base16_gui0D      = c.blue
  vim.g.base16_gui0E      = c.blue
  vim.g.base16_gui0F      = c.white

  hi.CopilotSuggestion = { guifg = c.base03, guibg = nil }

  hi.FzfLuaBufFlagCur = { guifg = c.base03, guibg = nil }
  hi.FzfLuaHeaderText = { guifg = c.base03, guibg = nil }
  hi.FzfLuaBufLineNr = { guifg = c.base0A, guibg = nil }
  hi.FzfLuaBufNr = { guifg = c.base0A, guibg = nil }
  hi.FzfLuaBufName = { guifg = c.base0A, guibg = nil }
  hi.FzfLuaHeaderBind = { guifg = c.base0A, guibg = nil }
  hi.FzfLuaTabMarker = { guifg = c.base0A, guibg = nil }
  hi.FzfLuaBufFlagAlt = { guifg = c.base0A, guibg = nil }
end

return M
