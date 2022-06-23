local dap = require('dap')

-- Python
dap.adapters.python = {
  type = 'executable';
  command = string.format("%s/bin/python", os.getenv('VIRTUAL_ENV'));
  args = { '-m', 'debugpy.adapter' };
}

dap.configurations.python = {
  {
    type = 'python';
    request = 'launch';
    name = "Launch file";

    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

    program = "${file}"; -- This configuration will launch the current file if used.
    pythonPath = function()
      return string.format("%s/bin/python", os.getenv('VIRTUAL_ENV'));
    end;
  },
}
