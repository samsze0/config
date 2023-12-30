local fn = vim.fn
local utils = require("utils")
local fzf_utils = require("fzf.utils")

local config = {
  padding = "  ",
  inactive_tab_max_length = 500, -- Disable this feature
}

_G.tabs = {}

local M = {}

local pcall_section = function(section, name)
  local ok, val = pcall(section)
  if ok then
    return val
  else
    vim.error("Fail to render section:", name)
    return "Error"
  end
end

M.render = function() return pcall_section(M.section_tabs, "tabs") end

M.section_tabs = function()
  _G.tabs = {} -- Reset

  -- TODO: git_files cause cursor to flicker. Probably need to use some filewatch utils
  -- local git_files = fzf_utils.git_files()
  -- local filenames = utils.map(
  --   git_files,
  --   function(_, f) return utils.reverse(vim.split(f, "/")) end
  -- )
  --
  -- local get_unique_filename = function(index)
  --   local winnr = fn.tabpagewinnr(index)
  --   local buflist = fn.tabpagebuflist(index)
  --   local bufnr = buflist[winnr]
  --   local bufname = vim.fn.expand("%:~:.")
  --   local bufbuftype = fn.getbufvar(bufnr, "&buftype")
  --
  --   if bufbuftype ~= "" or bufname == "" then return "" end
  --
  --   local _, i = utils.find(git_files, function(f) return f == bufname end)
  --   local bufname_parts = filenames[i]
  --
  --   vim.notify(vim.inspect(bufname_parts))
  --
  --   local function expand_if_not_unique(bufname_parts)
  --     local matches = utils.filter(
  --       filenames,
  --       function(p) return p[1] == bufname_parts[1] end
  --     )
  --     local unique = #matches == 1
  --     if not unique then
  --       for _, match in ipairs(matches) do
  --         if #match > 1 then
  --           -- "Expand" by joining the first two elements. In the end the first element will become the de-duplicated filename
  --           utils.join_first_two_elements(
  --             match,
  --             function(p1, p2) return p2 .. "/" .. p1 end
  --           )
  --         end
  --       end
  --       if #bufname_parts > 1 then expand_if_not_unique(bufname_parts) end
  --     end
  --   end
  --
  --   expand_if_not_unique(bufname_parts)
  --
  --   return bufname_parts[1]
  -- end

  local s = ""
  for index = 1, fn.tabpagenr("$") do
    local winnr = fn.tabpagewinnr(index)
    local buflist = fn.tabpagebuflist(index)
    local bufnr = buflist[winnr]
    local filename = fn.bufname(bufnr)
    local modified = vim.bo[bufnr].modified
    local filetype = vim.bo[bufnr].filetype
    local buftype = vim.bo[bufnr].buftype
    local buflisted = vim.bo[bufnr].buflisted
    local readonly = vim.bo[bufnr].readonly

    s = s .. "%" .. index .. "T"
    if index == fn.tabpagenr() then
      s = s .. "%#TabLineSel#"
    else
      s = s .. "%#TabLine#"
    end

    s = s .. config.padding

    local tabname
    local fulltabname

    if buftype == "terminal" then
      tabname = "  "
      fulltabname = "Terminal"

      s = s .. tabname
    elseif buftype == "" then -- Normal buffer
      local icon = ""
      if M.has_devicons then
        local ext = fn.fnamemodify(filename, ":e")
        icon = M.devicons.get_icon(filename, ext, { default = true }) .. " "
      end
      if filename ~= "" then
        fulltabname = fn.fnamemodify(filename, ":~:.")
        tabname = icon .. fulltabname
      else
        tabname = "  "
        fulltabname = "[No Name]"
      end

      if index ~= fn.tabpagenr() then
        s = s .. tabname:sub(1, config.inactive_tab_max_length)
      else
        s = s .. tabname
      end

      if modified then s = s .. " " end
      if readonly then s = s .. " " end
    else
      tabname = "  "
      fulltabname = buftype

      s = s .. tabname
    end

    _G.tabs[index] = {
      full = fulltabname,
      display = tabname,
    }

    s = s .. config.padding
  end

  s = s .. "%#TabLineFill#"
  return s
end

function M.setup()
  _G.Tabline = M

  -- :h tabbline
  vim.opt.showtabline = 2 -- 2 = always ; 1 = at least 2 tabs ; 0 = never

  M.has_devicons, M.devicons = pcall(require, "nvim-web-devicons")

  vim.o.tabline = "%!v:lua.Tabline.render()"
end

return M
