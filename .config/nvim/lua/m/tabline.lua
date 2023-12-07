-- nvim-tabline
-- David Zhang <https://github.com/crispgm>

local M = {}
local fn = vim.fn
local utils = require("m.utils")

M.options = {
  show_modify = true,
  show_icon = false,
  no_name = "No Name",
  modify_indicator = " ",
  inactive_tab_max_length = 0,
  padding = "  ",
}

local function tabline(options)
  -- Iterate over all tabs in advance for tab name de-duplication
  local bufnames = {}
  for index = 1, fn.tabpagenr("$") do
    local winnr = fn.tabpagewinnr(index)
    local buflist = fn.tabpagebuflist(index)
    local bufnr = buflist[winnr]
    local bufname = fn.bufname(bufnr)
    local bufbuftype = fn.getbufvar(bufnr, "&buftype")

    if bufbuftype ~= "" or bufname == "" then
      table.insert(bufnames, nil)
      goto continue
    end

    table.insert(bufnames, utils.reverse(vim.split(bufname, "/")))

    ::continue::
  end

  local function get_unique_bufname(index)
    local bufname_parts = bufnames[index]
    if bufname_parts == nil then return "" end

    local function is_unique(name)
      local matches = utils.filter(bufnames, function(p) return p[1] == name end)
      local unique = #matches == 1
      if not unique then
        for _, match in ipairs(matches) do
          if #match > 1 then
            utils.join_first_two_elements(match, function(p1, p2) return p2 .. "/" .. p1 end)
          end
        end
      end
      return unique
    end

    while not is_unique(bufname_parts[1]) do end

    return bufname_parts[1]
  end

  local s = ""
  for index = 1, fn.tabpagenr("$") do
    local winnr = fn.tabpagewinnr(index)
    local buflist = fn.tabpagebuflist(index)
    local bufnr = buflist[winnr]
    local bufname = fn.bufname(bufnr)
    local bufmodified = fn.getbufvar(bufnr, "&mod")
    local buffiletype = fn.getbufvar(bufnr, "&filetype")
    local bufbuftype = fn.getbufvar(bufnr, "&buftype")
    local buflisted = fn.getbufvar(bufnr, "&buflisted")

    s = s .. "%" .. index .. "T"
    if index == fn.tabpagenr() then
      s = s .. "%#TabLineSel#"
    else
      s = s .. "%#TabLine#"
    end

    s = s .. options.padding

    if bufbuftype == "terminal" then
      s = s .. "  "
    elseif bufbuftype == "" then -- Normal buffer
      local icon = ""
      if options.show_icon and M.has_devicons then
        local ext = fn.fnamemodify(bufname, ":e")
        icon = M.devicons.get_icon(bufname, ext, { default = true }) .. " "
      end
      -- buf name
      local pre_title_s_len = string.len(s)
      if bufname ~= "" then
        s = s .. icon .. (true and get_unique_bufname(index) or fn.fnamemodify(bufname, ":t"))
      else
        s = s .. options.no_name
      end
      if options.inactive_tab_max_length and options.inactive_tab_max_length > 0 and index ~= fn.tabpagenr() then
        s = string.sub(s, 1, pre_title_s_len + options.inactive_tab_max_length)
      end
      -- modify indicator
      if bufmodified == 1 and options.show_modify and options.modify_indicator ~= nil then s = s .. options.modify_indicator end
    else
      s = s .. "  "
    end

    s = s .. options.padding
  end

  s = s .. "%#TabLineFill#"
  return s
end

function M.setup(user_options)
  M.options = vim.tbl_extend("force", M.options, user_options)
  M.has_devicons, M.devicons = pcall(require, "nvim-web-devicons")

  function _G.tabline() return tabline(M.options) end

  vim.o.tabline = "%!v:lua.tabline()"
end

return M
