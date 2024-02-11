-- TODO: move away from global vars

_G.jumps_subscribers = {}
_G.current_jump = {}

local debug = true

local M = {}

-- FIX: Quickly jumping back and forward crashes window, regardless of whether there is a next node

local ag = vim.api.nvim_create_augroup("Jump", { clear = true })

M.setup = function(opts)
  opts = vim.tbl_extend("force", {}, opts or {})
  vim.api.nvim_create_autocmd("WinClosed", {
    group = ag,
    callback = function(ctx)
      local win_id = ctx.match
      _G.current_jump[win_id] = nil
    end,
  })
end

local function new_node(value) return { value = value, next = {}, prev = nil } end

local function create_jump(win_id)
  local bufnr = vim.api.nvim_win_get_buf(win_id)
  local line, col = unpack(vim.api.nvim_win_get_cursor(win_id))
  local filename = vim.api.nvim_buf_get_name(bufnr)
  filename = vim.fn.fnamemodify(filename, ":~:.")
  local t = os.time()
  local text =
    vim.trim(vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1])
  local jump = {
    filename = filename,
    line = line,
    col = col,
    time = t,
    text = text,
  }
  return jump
end

local function cursor_on_current_jump(win_id)
  local current_jump_node = _G.current_jump[win_id]
  if not current_jump_node then return false end
  local current_jump = current_jump_node.value
  local jump = create_jump(win_id)
  return jump.filename == current_jump.filename
    and jump.line == current_jump.line
    and jump.col == current_jump.col
end

local function notify_subscribers(win_id)
  for _, sub in ipairs(_G.jumps_subscribers) do
    sub(win_id)
  end
end

local function jump_to(jump)
  vim.cmd("e " .. jump.filename)
  vim.api.nvim_win_set_cursor(0, { jump.line, jump.col })
end

local function jump_to_current(win_id)
  local jump = _G.current_jump[win_id].value
  jump_to(jump)
end

function M.get_jumps_as_list(win_id, opts)
  opts = vim.tbl_extend("force", { max_num_entries = 100 }, opts or {})
  win_id = win_id or vim.api.nvim_get_current_win()
  local node = M.get_latest_jump(win_id)
  if node == nil then return {} end
  local current_jump_idx = nil
  local current_jumpnode = _G.current_jump[win_id]

  local entries = {}
  for i = 1, opts.max_num_entries do
    if node == nil then break end
    if node == current_jumpnode then current_jump_idx = i end
    table.insert(entries, node.value)
    node = node.prev
  end
  return entries, current_jump_idx
end

function M.save(win_id)
  win_id = win_id or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win_id)

  if
    cursor_on_current_jump(win_id)
    or vim.bo[buf].buftype ~= "" -- Special buf
    or vim.fn.bufname(buf) == "" -- Unnamed buf
  then
    return
  end

  local jump = create_jump(win_id)

  local node = new_node(jump)
  if not _G.current_jump[win_id] then
    _G.current_jump[win_id] = node
  else
    table.insert(_G.current_jump[win_id].next, node)
    node.prev = _G.current_jump[win_id]
    _G.current_jump[win_id] = node
  end

  notify_subscribers(win_id)
end

function M.jump_back(win_id)
  win_id = win_id or vim.api.nvim_get_current_win()
  if debug then
    vim.notify(
      string.format(
        "Jumping back from\n%s",
        vim.inspect(_G.current_jump[win_id])
      )
    )
  end
  if not _G.current_jump[win_id] then
    vim.notify("No jumps for window " .. win_id)
    return
  end
  if cursor_on_current_jump(win_id) then
    if _G.current_jump[win_id].prev == nil then
      vim.notify("No previous jump")
      return
    end

    _G.current_jump[win_id] = _G.current_jump[win_id].prev
    jump_to_current(win_id)
  else
    local jump = create_jump(win_id)
    local node = new_node(jump)
    table.insert(_G.current_jump[win_id].next, node)
    node.prev = _G.current_jump[win_id]
    jump_to_current(win_id)
  end

  notify_subscribers(win_id)
end

function M.jump_forward(win_id)
  win_id = win_id or vim.api.nvim_get_current_win()
  if debug then
    vim.notify(
      string.format(
        "Jumping forward from\n%s",
        vim.inspect(_G.current_jump[win_id])
      )
    )
  end
  if not _G.current_jump[win_id] then
    vim.notify("No jumps for window " .. win_id)
    return
  end
  local next = _G.current_jump[win_id].next
  if #next == 0 then
    vim.notify("No next jump")
    return
  end
  if not cursor_on_current_jump(win_id) then
    _G.current_jump[win_id].value = create_jump(win_id) -- Update current jump
  end

  local node = next[#next]
  if #node.next == 0 then
    local jump = node.value
    jump_to(jump)
    table.remove(next, #next)
  else
    _G.current_jump[win_id] = node
    jump_to_current(win_id)
  end

  notify_subscribers(win_id)
end

function M.get_latest_jump(win_id)
  win_id = win_id or vim.api.nvim_get_current_win()
  if not _G.current_jump[win_id] then return nil end
  local latest = _G.current_jump[win_id]
  while #latest.next > 0 do
    latest = latest.next[#latest.next]
  end
  return latest
end

return M
