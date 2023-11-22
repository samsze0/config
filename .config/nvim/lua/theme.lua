-- Tweak from RRethy/nvim-base16
-- https://github.com/RRethy/nvim-base16/blob/master/lua/base16-colorscheme.lua

local config = require("config")

local M = {}

M.colors = {
  black = "#000000",
  gray_35 = "#090909",
  gray_50 = "#111111",
  gray_100 = "#17191f",
  gray_200 = "#1a1c24",
  gray_300 = '#2c313c',
  gray_400 = '#3e4451',
  gray_500 = '#535d6c',
  gray_600 = '#687184',
  gray_700 = '#8a95a7',
  gray_800 = '#abb2bf',
  white = "#cbd1da",

  red = "#eb5858",
  blue = "#549eff",
  yellow = "#f59953",

  red_100 = "#1e0b0b",
  blue_100 = "#0b131c",
  yellow_100 = "#1e1307",
  red_300 = "#2f0f0f",
  blue_300 = "#122241",
  yellow_300 = "#34200c",
  red_400 = "#571919",
  blue_400 = "#1b3567",
  yellow_400 = "#693e13",
  red_500 = "#7b2525",
  blue_500 = "#26498b",
  yellow_500 = "#905020",
  red_600 = "#913333",
  blue_600 = "#2955a7",
  yellow_600 = "#9d5925",
  red_700 = "#af4343",
  blue_700 = "#2f66cd",
  yellow_700 = "#b86b31",
}

local indent_marker = M.colors.gray_100

-- Maintaining another list instead of doing `rawset` of `M.highlight` because
-- populating entries in `M.highlight` will cause `__index` to be invoked instead of `__newindex`
M.defined_highlight_groups = {}

M.highlight = setmetatable({}, {
  __newindex = function(tbl, hlgroup, args)
    table.insert(M.defined_highlight_groups, hlgroup)

    -- If type is string, set a link
    if (type(args) == 'string') then
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

function M.setup(opts)
  local default_opts = {
    debug = {
      enabled = false,
      source = ":highlights", -- @Types "vim_fn_getcompletion" | ":highlights"
      hide_defined_entries = true,
      toggle_colorizer = false
    }
  }
  opts = vim.tbl_deep_extend("keep", opts, default_opts)

  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end
  vim.cmd('set termguicolors')

  local c                               = M.colors

  local hi                              = M.highlight

  -- Vim editor colors
  hi.Normal                             = { guifg = c.gray_800, guibg = nil, gui = nil, guisp = nil }
  hi.Bold                               = { guifg = nil, guibg = nil, gui = 'bold', guisp = nil }
  hi.Debug                              = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Directory                          = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Error                              = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.ErrorMsg                           = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.Exception                          = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.FoldColumn                         = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.Folded                             = { guifg = c.gray_600, guibg = c.gray_200, gui = nil, guisp = nil }
  hi.IncSearch                          = { guifg = c.black, guibg = c.white, gui = 'none', guisp = nil }
  hi.Italic                             = { guifg = nil, guibg = nil, gui = 'none', guisp = nil }
  hi.Macro                              = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.MatchParen                         = { guifg = nil, guibg = c.gray_400, gui = nil, guisp = nil }
  hi.ModeMsg                            = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.MoreMsg                            = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.Question                           = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Search                             = { guifg = nil, guibg = c.gray_300, gui = nil, guisp = nil }
  hi.Substitute                         = { guifg = nil, guibg = c.gray_400, gui = 'none', guisp = nil }
  hi.SpecialKey                         = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.TooLong                            = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Underlined                         = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Visual                             = { guifg = nil, guibg = c.gray_400, gui = nil, guisp = nil }
  hi.VisualNOS                          = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.WarningMsg                         = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.WildMenu                           = { guifg = c.yellow, guibg = c.blue, gui = nil, guisp = nil }
  hi.Title                              = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.Conceal                            = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Cursor                             = { guifg = c.black, guibg = c.gray_800, gui = nil, guisp = nil }
  hi.NonText                            = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.LineNr                             = { guifg = c.gray_500, guibg = nil, gui = nil, guisp = nil }
  hi.SignColumn                         = { guifg = c.gray_500, guibg = nil, gui = nil, guisp = nil }
  hi.StatusLine                         = { guifg = c.gray_800, guibg = c.gray_400, gui = 'none', guisp = nil }
  hi.StatusLineNC                       = { guifg = c.gray_500, guibg = c.gray_300, gui = 'none', guisp = nil }
  hi.WinBar                             = { guifg = c.gray_800, guibg = nil, gui = 'none', guisp = nil }
  hi.WinBarNC                           = { guifg = c.gray_500, guibg = nil, gui = 'none', guisp = nil }
  hi.VertSplit                          = { guifg = c.gray_300, guibg = nil, gui = 'none', guisp = nil }
  hi.ColorColumn                        = { guifg = nil, guibg = c.gray_300, gui = 'none', guisp = nil }
  hi.CursorColumn                       = { guifg = nil, guibg = c.gray_300, gui = 'none', guisp = nil }
  hi.CursorLine                         = { guifg = nil, guibg = c.gray_300, gui = 'none', guisp = nil }
  hi.CursorLineNr                       = { guifg = c.gray_500, guibg = c.gray_300, gui = nil, guisp = nil }
  hi.QuickFixLine                       = { guifg = nil, guibg = c.gray_300, gui = 'none', guisp = nil }
  hi.PMenu                              = { guifg = c.gray_600, guibg = c.gray_100, gui = 'none', guisp = nil }
  hi.PMenuSel                           = { guifg = c.gray_800, guibg = c.gray_400, gui = nil, guisp = nil }
  hi.PMenuSbar                          = { guifg = nil, guibg = c.gray_300, gui = 'none', guisp = nil }
  hi.PMenuThumb                         = { guifg = nil, guibg = c.gray_500, gui = nil, guisp = nil }
  hi.TabLine                            = { guifg = c.gray_600, guibg = nil, gui = 'none', guisp = nil }
  hi.TabLineFill                        = { guifg = c.gray_600, guibg = nil, gui = 'none', guisp = nil }
  hi.TabLineSel                         = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }

  -- Standard syntax highlighting
  hi.Boolean                            = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.Character                          = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Comment                            = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.Conditional                        = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Constant                           = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.Define                             = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.Delimiter                          = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Float                              = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.Function                           = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Identifier                         = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.Include                            = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Keyword                            = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Label                              = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Number                             = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.Operator                           = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.PreProc                            = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Repeat                             = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Special                            = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.SpecialChar                        = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Statement                          = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.StorageClass                       = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.String                             = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.Structure                          = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Tag                                = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.Todo                               = { guifg = nil, guibg = c.blue_300, gui = nil, guisp = nil }
  hi.Type                               = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.Typedef                            = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }

  -- Diff highlighting
  hi.DiffAdd                            = { guifg = nil, guibg = c.blue_100, gui = nil, guisp = nil }
  hi.DiffChange                         = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.DiffDelete                         = { guifg = c.gray_200, guibg = c.gray_50, gui = nil, guisp = nil }
  hi.DiffText                           = { guifg = nil, guibg = c.blue_300, gui = nil, guisp = nil }
  hi.DiffAdded                          = { guifg = nil, guibg = c.blue_100, gui = nil, guisp = nil }
  hi.DiffFile                           = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.DiffNewFile                        = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.DiffLine                           = { guifg = nil, guibg = c.yellow_100, gui = nil, guisp = nil }
  hi.DiffRemoved                        = { guifg = nil, guibg = c.red_100, gui = nil, guisp = nil }

  -- Git highlighting
  hi.gitcommitOverflow                  = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitSummary                   = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitComment                   = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitUntracked                 = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitDiscarded                 = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitSelected                  = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitHeader                    = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitSelectedType              = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitUnmergedType              = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitDiscardedType             = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitBranch                    = { guifg = c.yellow, guibg = nil, gui = 'bold', guisp = nil }
  hi.gitcommitUntrackedFile             = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.gitcommitUnmergedFile              = { guifg = c.red, guibg = nil, gui = 'bold', guisp = nil }
  hi.gitcommitDiscardedFile             = { guifg = c.red, guibg = nil, gui = 'bold', guisp = nil }
  hi.gitcommitSelectedFile              = { guifg = c.yellow, guibg = nil, gui = 'bold', guisp = nil }

  -- GitGutter highlighting
  hi.GitGutterAdd                       = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.GitGutterChange                    = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.GitGutterDelete                    = { guifg = c.red, guibg = nil, gui = nil, guisp = nil }
  hi.GitGutterChangeDelete              = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }

  -- Spelling highlighting
  hi.SpellBad                           = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.yellow }
  hi.SpellLocal                         = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.yellow }
  hi.SpellCap                           = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.blue }
  hi.SpellRare                          = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.blue }

  hi.DiagnosticError                    = { guifg = c.red, guibg = nil, gui = 'none', guisp = nil }
  hi.DiagnosticWarn                     = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }
  hi.DiagnosticInfo                     = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.DiagnosticHint                     = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.DiagnosticUnderlineError           = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.red }
  hi.DiagnosticUnderlineWarning         = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.yellow }
  hi.DiagnosticUnderlineWarn            = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.yellow }
  hi.DiagnosticUnderlineInformation     = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.blue }
  hi.DiagnosticUnderlineHint            = { guifg = nil, guibg = nil, gui = 'undercurl', guisp = c.blue }

  hi.DiagnosticVirtualTextError         = { guifg = c.red_700, guibg = c.red_100 }
  hi.DiagnosticVirtualTextWarn          = { guifg = c.yellow_700, guibg = c.yellow_100 }
  hi.DiagnosticVirtualTextInfo          = { guifg = c.blue_700, guibg = c.blue_100 }
  hi.DiagnosticVirtualTextHint          = { guifg = c.blue_700, guibg = c.blue_100 }

  hi.LspReferenceText                   = { guifg = nil, guibg = nil, gui = 'underline', guisp = c.gray_500 }
  hi.LspReferenceRead                   = { guifg = nil, guibg = nil, gui = 'underline', guisp = c.gray_500 }
  hi.LspReferenceWrite                  = { guifg = nil, guibg = nil, gui = 'underline', guisp = c.gray_500 }
  hi.LspDiagnosticsDefaultError         = 'DiagnosticError'
  hi.LspDiagnosticsDefaultWarning       = 'DiagnosticWarn'
  hi.LspDiagnosticsDefaultInformation   = 'DiagnosticInfo'
  hi.LspDiagnosticsDefaultHint          = 'DiagnosticHint'
  hi.LspDiagnosticsUnderlineError       = 'DiagnosticUnderlineError'
  hi.LspDiagnosticsUnderlineWarning     = 'DiagnosticUnderlineWarning'
  hi.LspDiagnosticsUnderlineInformation = 'DiagnosticUnderlineInformation'
  hi.LspDiagnosticsUnderlineHint        = 'DiagnosticUnderlineHint'

  hi.TSAnnotation                       = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSAttribute                        = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSBoolean                          = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }
  hi.TSCharacter                        = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSComment                          = { guifg = c.gray_600, guibg = nil, gui = 'italic', guisp = nil }
  hi.TSConstructor                      = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSConditional                      = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSConstant                         = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }
  hi.TSConstBuiltin                     = { guifg = c.yellow, guibg = nil, gui = 'italic', guisp = nil }
  hi.TSConstMacro                       = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSError                            = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSException                        = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSField                            = { guifg = c.gray_800, guibg = nil, gui = 'none', guisp = nil }
  hi.TSFloat                            = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }
  hi.TSFunction                         = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSFuncBuiltin                      = { guifg = c.blue, guibg = nil, gui = 'italic', guisp = nil }
  hi.TSFuncMacro                        = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSInclude                          = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSKeyword                          = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSKeywordFunction                  = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSKeywordOperator                  = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSLabel                            = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSMethod                           = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSNamespace                        = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSNone                             = { guifg = c.gray_800, guibg = nil, gui = 'none', guisp = nil }
  hi.TSNumber                           = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }
  hi.TSOperator                         = { guifg = c.gray_800, guibg = nil, gui = 'none', guisp = nil }
  hi.TSParameter                        = { guifg = c.gray_800, guibg = nil, gui = 'none', guisp = nil }
  hi.TSParameterReference               = { guifg = c.gray_800, guibg = nil, gui = 'none', guisp = nil }
  hi.TSProperty                         = { guifg = c.gray_800, guibg = nil, gui = 'none', guisp = nil }
  hi.TSPunctDelimiter                   = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSPunctBracket                     = { guifg = c.gray_800, guibg = nil, gui = 'none', guisp = nil }
  hi.TSPunctSpecial                     = { guifg = c.gray_800, guibg = nil, gui = 'none', guisp = nil }
  hi.TSRepeat                           = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSString                           = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }
  hi.TSStringRegex                      = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }
  hi.TSStringEscape                     = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }
  hi.TSSymbol                           = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }
  hi.TSTag                              = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSTagDelimiter                     = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSText                             = { guifg = c.gray_800, guibg = nil, gui = 'none', guisp = nil }
  hi.TSStrong                           = { guifg = nil, guibg = nil, gui = 'bold', guisp = nil }
  hi.TSEmphasis                         = { guifg = c.yellow, guibg = nil, gui = 'italic', guisp = nil }
  hi.TSUnderline                        = { guifg = c.black, guibg = nil, gui = 'underline', guisp = nil }
  hi.TSStrike                           = { guifg = c.black, guibg = nil, gui = 'strikethrough', guisp = nil }
  hi.TSTitle                            = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSLiteral                          = { guifg = c.yellow, guibg = nil, gui = 'none', guisp = nil }
  hi.TSURI                              = { guifg = c.yellow, guibg = nil, gui = 'underline', guisp = nil }
  hi.TSType                             = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSTypeBuiltin                      = { guifg = c.blue, guibg = nil, gui = 'italic', guisp = nil }
  hi.TSVariable                         = { guifg = c.blue, guibg = nil, gui = 'none', guisp = nil }
  hi.TSVariableBuiltin                  = { guifg = c.blue, guibg = nil, gui = 'italic', guisp = nil }

  hi.TSDefinition                       = { guifg = nil, guibg = nil, gui = 'underline', guisp = c.gray_500 }
  hi.TSDefinitionUsage                  = { guifg = nil, guibg = nil, gui = 'underline', guisp = c.gray_500 }
  hi.TSCurrentScope                     = { guifg = nil, guibg = nil, gui = 'bold', guisp = nil }

  hi.LspInlayHint                       = { guifg = c.gray_600, guibg = nil, gui = 'italic', guisp = nil }

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

  hi.NvimInternalError          = { guifg = c.black, guibg = c.blue, gui = 'none', guisp = nil }

  hi.NormalFloat                = { guifg = c.gray_800, guibg = c.gray_100, gui = nil, guisp = nil }
  hi.FloatBorder                = { guifg = c.gray_800, guibg = c.black, gui = nil, guisp = nil }
  hi.NormalNC                   = { guifg = c.gray_800, guibg = nil, gui = nil, guisp = nil }
  hi.TermCursor                 = { guifg = c.black, guibg = c.gray_800, gui = 'none', guisp = nil }
  hi.TermCursorNC               = { guifg = c.black, guibg = c.gray_800, gui = nil, guisp = nil }

  hi.User1                      = { guifg = c.blue, guibg = c.gray_400, gui = 'none', guisp = nil }
  hi.User2                      = { guifg = c.blue, guibg = c.gray_400, gui = 'none', guisp = nil }
  hi.User3                      = { guifg = c.gray_800, guibg = c.gray_400, gui = 'none', guisp = nil }
  hi.User4                      = { guifg = c.yellow, guibg = c.gray_400, gui = 'none', guisp = nil }
  hi.User5                      = { guifg = c.gray_800, guibg = c.gray_400, gui = 'none', guisp = nil }
  hi.User6                      = { guifg = c.gray_800, guibg = c.gray_300, gui = 'none', guisp = nil }
  hi.User7                      = { guifg = c.gray_800, guibg = c.gray_400, gui = 'none', guisp = nil }
  hi.User8                      = { guifg = c.black, guibg = c.gray_400, gui = 'none', guisp = nil }
  hi.User9                      = { guifg = c.black, guibg = c.gray_400, gui = 'none', guisp = nil }

  hi.TreesitterContext          = { guifg = nil, guibg = c.gray_300, gui = 'italic', guisp = nil }

  local override_terminal_color = true

  if override_terminal_color then
    vim.g.terminal_color_0  = c.black
    vim.g.terminal_color_1  = c.red
    vim.g.terminal_color_2  = c.blue
    vim.g.terminal_color_3  = c.blue
    vim.g.terminal_color_4  = c.blue
    vim.g.terminal_color_5  = c.blue
    vim.g.terminal_color_6  = c.blue
    vim.g.terminal_color_7  = c.white
    vim.g.terminal_color_8  = c.gray_600
    vim.g.terminal_color_9  = c.red
    vim.g.terminal_color_10 = c.blue
    vim.g.terminal_color_11 = c.blue
    vim.g.terminal_color_12 = c.blue
    vim.g.terminal_color_13 = c.blue
    vim.g.terminal_color_14 = c.blue
    vim.g.terminal_color_15 = c.white
  end

  -- Copilot
  if config.copilot_plugin == "vim" then
    hi.CopilotSuggestion = { guifg = c.gray_400, guibg = nil }
  end

  -- Fuzzy finder
  if not config.telescope_over_fzflua then
    hi.FzfLuaBufFlagCur = { guifg = c.gray_600, guibg = nil }
    hi.FzfLuaTabTitle   = { guifg = c.blue, guibg = nil }
    hi.FzfLuaHeaderText = { guifg = c.gray_600, guibg = nil }
    hi.FzfLuaBufLineNr  = { guifg = c.blue, guibg = nil }
    hi.FzfLuaBufNr      = { guifg = c.blue, guibg = nil }
    hi.FzfLuaBufName    = { guifg = c.blue, guibg = nil }
    hi.FzfLuaHeaderBind = { guifg = c.blue, guibg = nil }
    hi.FzfLuaTabMarker  = { guifg = c.blue, guibg = nil }
    hi.FzfLuaBufFlagAlt = { guifg = c.blue, guibg = nil }
  end

  -- File tree
  if config.filetree_plugin == "nvimtree" then
    hi.NvimTreeIndentMarker = { guifg = indent_marker, guibg = nil }
  end

  -- indent-blankline
  hi.IblIndent                    = { guifg = indent_marker }
  hi.IblWhitespace                = { guifg = indent_marker }
  hi.IblScope                     = { guifg = indent_marker }

  -- vim-illuminate
  hi.IlluminatedWordText          = { guibg = c.gray_200, gui = nil }
  hi.IlluminatedWordRead          = { guibg = c.gray_200, gui = nil }
  hi.IlluminatedWordWrite         = { guibg = c.gray_200, gui = nil }

  -- nvim-cmp
  hi.CmpItemAbbr                  = { guifg = c.gray_600, guibg = nil, gui = nil, guisp = nil } -- Completion items default
  hi.CmpItemAbbrDeprecated        = { guifg = c.gray_400, guibg = nil, gui = 'strikethrough', guisp = nil }
  hi.CmpItemAbbrDeprecatedDefault = 'CmpItemAbbrDeprecated'
  hi.CmpItemAbbrMatch             = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil } -- Matched portion of completion items
  hi.CmpItemAbbrMatchFuzzy        = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemMenu                  = { guifg = nil, guibg = nil, gui = nil, guisp = nil }
  -- Color of "<icon> symbol" on the right
  hi.CmpItemKindDefault           = { guifg = c.gray_800, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindKeyword           = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindVariable          = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindConstant          = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindReference         = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindValue             = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindFunction          = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindMethod            = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindConstructor       = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindClass             = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindInterface         = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindStruct            = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindEvent             = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindEnum              = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindUnit              = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindModule            = { guifg = c.yellow, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindProperty          = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindField             = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindTypeParameter     = { guifg = c.blue, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindEnumMember        = { guifg = c.white, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindOperator          = { guifg = c.white, guibg = nil, gui = nil, guisp = nil }
  hi.CmpItemKindSnippet           = { guifg = c.white, guibg = nil, gui = nil, guisp = nil }

  -- diffview
  hi.DiffviewDiffDelete           = { guifg = c.gray_50, guibg = nil }  -- Region of padding to make editors align. fg = color of diff char symbol
  hi.DiffviewDiffAdd              = { guifg = nil, guibg = c.blue_100 } -- Added/changed lines
  hi.DiffviewDiffChange           = { guifg = nil, guibg = c.blue_100 } -- Changed lines (on both editors)
  hi.DiffviewDiffText             = { guifg = nil, guibg = c.blue_300 } -- Actual changed region (within added/changed lines)
  -- Color of sign in sign column in tree view
  hi.DiffviewSignColumn           = { guifg = c.gray_800, guibg = nil }
  hi.DiffviewStatusAdded          = { guifg = c.blue, guibg = nil }
  hi.DiffviewStatusUntracked      = { guifg = c.blue, guibg = nil }
  hi.DiffviewStatusRenamed        = { guifg = c.yellow, guibg = nil }
  hi.DiffviewStatusUnmerged       = { guifg = c.yellow, guibg = nil }
  hi.DiffviewStatusIgnored        = { guifg = c.gray_600, guibg = nil }
  hi.DiffviewStatusModified       = { guifg = c.yellow, guibg = nil }
  hi.DiffviewStatusBroken         = { guifg = c.red, guibg = nil }
  hi.DiffviewStatusDeleted        = { guifg = c.red, guibg = nil }
  hi.DiffviewStatusUnknown        = { guifg = c.gray_800, guibg = nil }
  -- Color of the number of added/deleted lines in tree view
  hi.DiffviewFilePanelDeletions   = { guifg = c.gray_600, guibg = nil }
  hi.DiffviewFilePanelInsertions  = { guifg = c.gray_600, guibg = nil }
  -- Misc
  hi.DiffviewFilePanelTitle       = { gui = "bold", guifg = c.yellow }
  hi.DiffviewSecondary            = { guifg = c.red }
  hi.DiffviewPrimary              = { guifg = c.blue }
  hi.DiffviewDim1                 = { guifg = c.blue }
  hi.DiffviewFilePanelFileName    = { guifg = c.white }
  hi.DiffviewFilePanelCounter     = { guifg = c.blue, gui = "bold" }
  hi.DiffviewDiffAddAsDelete      = { gui = "bold", guifg = c.blue, guibg = c.gray_500 }

  -- Git signs
  hi.GitSignsChangeInline         = { guifg = nil, guibg = c.blue_300 } -- Current state of the hunk for preview_hunk
  hi.GitSignsDeleteVirtLn         = { guifg = nil, guibg = c.red_300 }  -- Previous state of the hunk for preview_hunk

  if config.spectre then
    hi.SpectreHeader  = { guifg = c.blue }
    hi.SpectreBody    = { guifg = c.blue }
    hi.SpectreFile    = { guifg = c.yellow }
    hi.SpectreDir     = { guifg = c.blue }
    hi.SpectreSearch  = { guibg = c.blue_300 }
    hi.SpectreBorder  = { guifg = c.blue }
    hi.SpectreReplace = { guibg = c.red_300 }
  end

  -- bufferline
  hi.BufferLineBackground          = { guifg = c.gray_500, guibg = c.gray_50 }  -- Inactive tab
  hi.BufferLineBufferSelected      = { guifg = c.gray_700, guibg = c.gray_200 } -- Active tab
  hi.BufferLineSeparator           = { guifg = c.black, guibg = c.black }
  -- Indicators
  hi.BufferLineError               = { guifg = c.red_600, guibg = c.gray_50 }
  hi.BufferLineErrorSelected       = { guifg = c.red_600, guibg = c.gray_100 }
  hi.BufferLineModified            = { guifg = c.gray_700, guibg = c.gray_50 }
  hi.BufferLineModifiedSelected    = { guifg = c.gray_700, guibg = c.gray_100 }
  hi.BufferLineDiagnosticSelected  = { guifg = c.gray_700, guibg = c.gray_100 }
  hi.BufferLinePickSelected        = 'BufferLineDiagnosticSelected'
  hi.BufferLineIndicatorSelected   = 'BufferLineDiagnosticSelected'
  hi.BufferLineNumbersSelected     = 'BufferLineDiagnosticSelected'
  hi.BufferLineCloseButtonSelected = 'BufferLineDiagnosticSelected'

  if opts.debug.enabled then
    vim.print(vim.inspect(opts))

    local function get_color_name_if_exists(target)
      for color, value in pairs(M.colors) do
        if value == target then
          return color
        end
      end
      return target
    end

    local map = require("utils").map
    local split_string = require("utils").split_string

    local buf_lines = nil

    if opts.debug.source == "vim_fn_getcompletion" then
      local fn = vim.fn
      local highlights = fn.getcompletion("", "highlight")

      local function get_color(group, attr)
        return fn.synIDattr(fn.synIDtrans(fn.hlID(group)), attr)
      end

      buf_lines = map(highlights, function(i, hl)
        local bg = get_color(hl, "bg#")
        bg = get_color_name_if_exists(bg)
        local fg = get_color(hl, "fg#")
        fg = get_color_name_if_exists(fg)
        return hl .. " fg " .. fg .. " bg " .. bg
      end)
    elseif opts.debug.source == ":highlights" then
      local hl_raw = vim.api.nvim_exec('highlight', true)
      local hl_groups = split_string(hl_raw, "\n")

      buf_lines = map(hl_groups, function(i, g)
        local parts = split_string(g, " ")

        if opts.debug.hide_defined_entries and parts[1] ~= "link" and require("utils").contains(M.defined_highlight_groups, parts[1]) then
          return nil
        end

        return table.concat(map(parts, function(i, part)
          -- a = letter; x = hexidecimal digit
          local k, v = string.match(part, "(gui%a+)=(#%x+)")
          if k and v then
            return k .. "-" .. get_color_name_if_exists(v)
          else
            return part
          end
        end), " ")
      end)
    end

    if not buf_lines then return end

    require("utils").show_content_as_buf(buf_lines)
    if opts.debug.toggle_colorizer then
      vim.cmd("ColorizerToggle")
    end
  end
end

return M
