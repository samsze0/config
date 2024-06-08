-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.

local os_utils = require("utils.os")
local lang_utils = require("utils.lang")
local jdtls = require("jdtls")

local jdtls_path = os.getenv("JDTLS_HOME")
if not jdtls_path then error("env var JDTLS_HOME not set") end
local jdtls_system_config_path = lang_utils.match(os_utils.OS, {
  ["Darwin"] = jdtls_path .. "/config_mac",
  ["Linux"] = jdtls_path .. "/config_linux",
})
local jdtls_equinox_launcher_path =
  vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

-- https://github.com/mfussenegger/nvim-jdtls?tab=readme-ov-file#data-directory-configuration
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.getcwd() .. "/.jdtls"

local lombok_path = vim.fn.getcwd() .. "/.jdtls/lombok.jar"
local lombok_exists = vim.fn.filereadable(lombok_path)
if not lombok_exists then
  vim.cmd(
    "curl https://projectlombok.org/downloads/lombok.jar -o " .. lombok_path
  )
end

if not jdtls_system_config_path then error("Unsupported OS " .. os_utils.OS) end

local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",

    "-jar",
    jdtls_equinox_launcher_path,

    "-configuration",
    jdtls_system_config_path,

    -- See `data directory configuration` section in the README
    "-data",
    workspace_dir,

    -- Lombok support
    "-javaagent",
    lombok_path,
  },

  -- vim.fs.root requires Neovim 0.10.
  -- If you're using an earlier version, use: require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
  root_dir = vim.fs.root(
    0,
    { ".git", "mvnw", "gradlew", "build.gradle", "pom.xml" }
  ),

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      signatureHelp = { enabled = true },
      extendedClientCapabilities = jdtls.extendedClientCapabilities,
    },
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  init_options = {
    bundles = {},
  },
}

jdtls.start_or_attach(config)
