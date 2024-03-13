local utils = require("utils")
local json_utils = require("utils.json")

local M = {}

---@alias DockerImage { Containers: string, CreatedAt: string, CreatedSince: string, Digest: string, ID: string, Repository: string, SharedSize: string, Size: string, Tag: string, UniqueSize: string, VirtualSize: string }

---@alias DockerContainer { Command: string, CreatedAt: string, ID: string, Image: string, Labels: string, LocalVolumes: string, Mounts: string, Names: string, Networks: string, Ports: string, RunningFor: string, Size: string, Controller: string, Status: string }

-- Get docker images
--
---@alias GetDodckerImagesOptions { all?: boolean }
---@param opts? GetDodckerImagesOptions
---@return DockerImage[]
function M.docker_images(opts)
  if vim.fn.executable("docker") ~= 1 then
    error("Docker executable not found")
  end

  opts = utils.opts_extend({
    all = false,
  }, opts)

  local opts = {
    ["-a"] = opts.all,
    ["--format"] = "json",
  }

  local result =
    utils.system("docker image ls " .. utils.shell_opts_tostring(opts))
  result = vim.trim(result)
  local images = json_utils.parse_multiple(result)
  ---@cast images DockerImage[]

  return images
end

-- Get docker containers
--
---@alias GetDodckerContainersOptions { all?: boolean }
---@param opts? GetDodckerContainersOptions
---@return DockerContainer[]
function M.docker_containers(opts)
  if vim.fn.executable("docker") ~= 1 then
    error("Docker executable not found")
  end

  opts = utils.opts_extend({
    all = false,
  }, opts)

  local opts = {
    ["-a"] = opts.all,
    ["--format"] = "json",
  }

  local result =
    utils.system("docker container ls " .. utils.shell_opts_tostring(opts))
  result = vim.trim(result)
  local containers = json_utils.parse_multiple(result)
  ---@cast containers DockerContainer[]

  return containers
end

return M
