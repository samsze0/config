local fn = vim.fn
local utils = require("utils")
local fzf_utils = require("fzf.utils")
local has_error = false

local config = {
  debug = false, -- FIX: invoking vim.notify if tabline renders correctly will causes infinite loop
  padding = " ",
  inactive_tab_max_length = 500, -- Disable this feature
}

-- TODO: move away from global var

_G.tabs = {}

local M = {}

local pcall_section = function(section, name)
  local ok, val = pcall(section)
  if ok then
    return val
  else
    vim.error("Fail to render section:", name)
    has_error = true
    return ""
  end
end

local render_tab = function(index, tab)
  local current_tab = fn.tabpagenr() == index
  return string.format(
    "%%%sT%s",
    index,
    current_tab and "%#TabLineSel#" or "%#TabLine#"
  ) .. config.padding .. tab.display .. config.padding
end

local render_count = 1

M.render = function()
  if has_error then return "Error" end

  -- Caution: using vim.notify could cause infinite loop if vim.notify show message in a window
  print("Rendered tabline " .. render_count .. " times")
  render_count = render_count + 1
  return pcall_section(M.section_tabs, "tabs")
end

M.section_tabs = function()
  _G.tabs = {} -- Reset

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

    if buftype == "terminal" then
      _G.tabs[index] = {
        full = "Terminal",
        display = "  ",
      }
    elseif buftype == "" then -- Normal buffer
      local fileicon = ""
      if M.has_devicons then
        local ext = fn.fnamemodify(filename, ":e")
        fileicon = M.devicons.get_icon(filename, ext, { default = true })
      end
      filename = fn.fnamemodify(filename, ":~:.")

      local extras = {}
      if modified then table.insert(extras, "") end
      if readonly then table.insert(extras, "") end

      _G.tabs[index] = {
        full = filename ~= "" and filename or "[No Name]",
        display = filename ~= "" and string.format(
          "%s %s %s",
          fileicon,
          filename,
          table.concat(extras, " ")
        ) or "  ",
      }
    else
      _G.tabs[index] = {
        full = buftype,
        display = "  ",
      }
    end
  end

  local max_width = vim.o.columns
  local required_width = utils.sum(
    _G.tabs,
    function(_, t) return string.len(t.display) + string.len(config.padding) * 2 end
  )
  if required_width <= max_width then
    return table.concat(utils.map(_G.tabs, render_tab), "") .. "%#TabLineFill#"
  end

  local current_tab = fn.tabpagenr()
  local current_tab_length = string.len(_G.tabs[current_tab].display)

  local tab_index_to_distance_map = {}
  for i = 1, #_G.tabs do
    if i ~= current_tab then
      tab_index_to_distance_map[i] = math.abs(current_tab - i)
    end
  end
  -- Sort in-place by ascending distance
  if config.debug then vim.info(tab_index_to_distance_map) end
  local sorted_keys = utils.sort(
    tab_index_to_distance_map,
    function(a, b) return a < b end,
    { is_array = false }
  )
  if config.debug then
    for _, k in ipairs(sorted_keys) do
      vim.info(k, tab_index_to_distance_map[k])
    end
  end

  local tabs_to_render = {
    [current_tab] = _G.tabs[current_tab],
  }

  local quota = max_width - current_tab_length

  for _, i in ipairs(sorted_keys) do
    local tab_length = string.len(_G.tabs[i].display)
      + string.len(config.padding) * 2
    if config.debug then
      vim.info("Tab:", i, "Length:", tab_length, "Quota:", quota)
    end
    if tab_length < quota then
      tabs_to_render[i] = _G.tabs[i]
      quota = quota - tab_length
    elseif tab_length == quota then
      tabs_to_render[i] = _G.tabs[i]
      quota = quota - tab_length
      break
    else
      -- TODO: render part of the tab only if quota cannot be met.
      -- However, we need to consider if remaining quota is enough to even render the padding, which gets complicated,
      -- so for now we just render the tab as is.
      tabs_to_render[i] = _G.tabs[i]
      quota = quota - tab_length
      break
    end
  end

  return table.concat(
    utils.map(tabs_to_render, render_tab, { is_array = false }),
    ""
  ) .. "%#TabLineFill#"
end

function M.setup()
  _G.Tabline = M

  -- :h tabbline
  vim.opt.showtabline = 2 -- 2 = always ; 1 = at least 2 tabs ; 0 = never

  M.has_devicons, M.devicons = pcall(require, "nvim-web-devicons")

  vim.o.tabline = "%!v:lua.Tabline.render()"
end

return M
