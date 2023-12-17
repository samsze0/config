-- nvim-tabline
-- David Zhang <https://github.com/crispgm>

local M = {}
local fn = vim.fn
local utils = require("utils")
local fzf_utils = require("fzf.utils")

_G.tabs = {}

M.options = {
  dedup_by = "opened_files",
  inactive_tab_max_length = false,
  padding = "  ",
}

local function tabline(options)
  _G.tabs = {} -- Reset

  -- Iterate over all tabs in advance for tab name de-duplication
  local get_unique_filename

  if options.dedup_by == "opened_files" then
    local filenames = {}

    for index = 1, fn.tabpagenr("$") do
      local winnr = fn.tabpagewinnr(index)
      local buflist = fn.tabpagebuflist(index)
      local bufnr = buflist[winnr]
      local bufname = fn.bufname(bufnr)
      local bufbuftype = fn.getbufvar(bufnr, "&buftype")

      if bufbuftype ~= "" or bufname == "" then
        table.insert(filenames, "")
        goto continue
      end

      table.insert(filenames, utils.reverse(vim.split(bufname, "/")))

      ::continue::
    end

    get_unique_filename = function(index)
      local filename_parts = filenames[index]
      if filename_parts == "" then return "" end

      local function expand_if_not_unique(filename_parts)
        local matches = utils.filter(
          filenames,
          function(p) return p[1] == filename_parts[1] end
        )
        local unique = #matches == 1
        if not unique then
          for _, match in ipairs(matches) do
            if #match > 1 then
              -- "Expand" by joining the first two elements. In the end the first element will become the de-duplicated filename
              utils.join_first_two_elements(
                match,
                function(p1, p2) return p2 .. "/" .. p1 end
              )
            end
          end
          if #filename_parts > 1 then expand_if_not_unique(filename_parts) end
        end
      end

      expand_if_not_unique(filename_parts)

      return filename_parts[1]
    end
  elseif options.dedup_by == "git_files" then
    local git_files = fzf_utils.git_files()
    local filenames = utils.map(
      git_files,
      function(_, f) return utils.reverse(vim.split(f, "/")) end
    )

    get_unique_filename = function(index)
      local winnr = fn.tabpagewinnr(index)
      local buflist = fn.tabpagebuflist(index)
      local bufnr = buflist[winnr]
      local bufname = vim.fn.expand("%:~:.")
      local bufbuftype = fn.getbufvar(bufnr, "&buftype")

      if bufbuftype ~= "" or bufname == "" then return "" end

      local _, i = utils.find(git_files, function(f) return f == bufname end)
      local bufname_parts = filenames[i]

      vim.notify(vim.inspect(bufname_parts))

      local function expand_if_not_unique(bufname_parts)
        local matches = utils.filter(
          filenames,
          function(p) return p[1] == bufname_parts[1] end
        )
        local unique = #matches == 1
        if not unique then
          for _, match in ipairs(matches) do
            if #match > 1 then
              -- "Expand" by joining the first two elements. In the end the first element will become the de-duplicated filename
              utils.join_first_two_elements(
                match,
                function(p1, p2) return p2 .. "/" .. p1 end
              )
            end
          end
          if #bufname_parts > 1 then expand_if_not_unique(bufname_parts) end
        end
      end

      expand_if_not_unique(bufname_parts)

      return bufname_parts[1]
    end
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

    local tabname
    local fulltabname

    if bufbuftype == "terminal" then
      tabname = "  "
      fulltabname = "Terminal"

      s = s .. tabname
    elseif bufbuftype == "" then -- Normal buffer
      local icon = ""
      if M.has_devicons then
        local ext = fn.fnamemodify(bufname, ":e")
        icon = M.devicons.get_icon(bufname, ext, { default = true }) .. " "
      end
      -- buf name
      if bufname ~= "" then
        local name = get_unique_filename(index)
        fulltabname = fn.fnamemodify(bufname, ":~:.")
        tabname = icon .. fulltabname
      else
        tabname = "  "
        fulltabname = "[No Name]"
      end

      if
        options.inactive_tab_max_length
        and options.inactive_tab_max_length > 0
        and index ~= fn.tabpagenr()
      then
        s = s .. tabname:sub(1, options.inactive_tab_max_length)
      else
        s = s .. tabname
      end

      -- modify indicator
      if fn.getbufvar(bufnr, "&mod") == 1 then s = s .. " " end

      -- readonly indicator
      if fn.getbufvar(bufnr, "&readonly") == 1 then s = s .. " " end
    else
      tabname = "  "
      fulltabname = bufbuftype

      s = s .. tabname
    end

    _G.tabs[index] = {
      full = fulltabname,
      display = tabname,
    }

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
