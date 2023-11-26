require("toggleterm").setup {
  size = 20,
  on_create = function(term) end,
  on_open = function(term) end,
  on_close = function(term) end,
  on_stdout = function(term, num_jobs, data, name) end,
  on_stderr = function(term, num_jobs, data, name) end,
  on_exit = function(term, num_jobs, exit_code, name) end,
  float_opts = { -- see :h nvim_open_win
  }
}
