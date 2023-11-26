-- Tweak from:
-- https://github.com/sindrets/m.nvim/blob/main/lua/m/oop.lua

local fmt = string.format

local M = {}

function M.abstract_stub()
  error("Unimplemented abstract method!")
end

-- Create an enum object by adding reverse lookup to the table.
---@generic T
---@param t T
---@return T
function M.enum(t)
  vim.tbl_add_reverse_lookup(t)
  return t
end

---Wrap metatable methods to ensure they're called with the instance as `self`.
---@param func function
---@param instance table
---@return function
local function wrap_metatable_func(func, instance)
  return function(_, k)
    return func(instance, k)
  end
end

local metatable_func_names = {
  "__index",
  "__tostring",
  "__eq",
  "__add",
  "__sub",
  "__mul",
  "__div",
  "__mod",
  "__pow",
  "__unm",
  "__len",
  "__lt",
  "__le",
  "__concat",
  "__newindex",
  "__call",
}

-- Return new instance of a class by wrapping its metatable functions such that all of them receive 'self' as the first arg
-- Also invoking the constructor
local function new_instance(class, ...)
  local instance = { class = class }
  local metatable = { __index = class }

  for _, func_name in ipairs(metatable_func_names) do
    local func = class[func_name]

    if type(func) == "function" then
      metatable[func_name] = wrap_metatable_func(func, instance)
    elseif func ~= nil then
      metatable[func_name] = func
    end
  end

  local self = setmetatable(instance, metatable)
  self:init(...)

  return self
end

local function tostring(class)
  return fmt("<class %s>", class.__name)
end

-- Create a class at which when invoked/called, invokes its constructor (`init`)
-- Optionally takes a super class to inherit from
---@generic T : m.Object
---@generic U : m.Object
---@param name string
---@param super_class? T
---@return U new_class
function M.create_class(name, super_class)
  super_class = super_class or M.Object

  return setmetatable(
    {
      __name = name,
      super_class = super_class,
    },
    {
      __index = super_class,
      __call = new_instance,
      __tostring = tostring,
    }
  )
end

local function class_method_safeguard(x)
  assert(x.class == nil, "Class method should not be invoked from an instance!")
end

local function instance_method_safeguard(x)
  assert(type(x.class) == "table", "Instance method must be called from a class instance!")
end

-- Create the base class 'Object' (like in JS)
---@class m.Object
---@field protected __name string
---@field private __init_caller? table
---@field class table|m.Object
---@field super_class table|m.Object
local Object = M.create_class("Object")
M.Object = Object

function Object:__tostring()
  return fmt("<a %s>", self.class.__name)
end

-- ### CLASS METHODS ###

---@return string
function Object:name()
  class_method_safeguard(self)
  return self.__name
end

---Check if this class is an ancestor of the given instance. `A` is an ancestor
---of `b` if - and only if - `b` is an instance of a subclass of `A`.
---@param other any
---@return boolean
function Object:ancestorof(other)
  class_method_safeguard(self)
  if not M.is_instance(other) then return false end

  return other:instanceof(self)
end

---@return string
function Object:classpath()
  class_method_safeguard(self)
  local ret = self.__name
  local cur = self.super_class

  while cur do
    ret = cur.__name .. "." .. ret
    cur = cur.super_class
  end

  return ret
end

-- ### INSTANCE METHODS ###

---Call constructor.
function Object:init(...) end

---Call super constructor.
---@param ... any
function Object:super(...)
  instance_method_safeguard(self)
  local next_super

  -- Keep track of what class is currently calling the constructor such that we
  -- can avoid loops.
  if self.__init_caller then
    next_super = self.__init_caller.super_class
  else
    next_super = self.super_class
  end

  if not next_super then return end

  self.__init_caller = next_super
  next_super.init(self, ...)
  self.__init_caller = nil
end

---@param other m.Object
---@return boolean
function Object:instanceof(other)
  instance_method_safeguard(self)
  local cur = self.class

  while cur do
    if cur == other then return true end
    cur = cur.super_class
  end

  return false
end

---@param x any
---@return boolean
function M.is_class(x)
  if type(x) ~= "table" then return false end
  return type(rawget(x, "__name")) == "string" and x.instanceof == Object.instanceof
end

---@param x any
---@return boolean
function M.is_instance(x)
  if type(x) ~= "table" then return false end
  return M.is_class(x.class)
end

---@class Symbol
---@operator call : Symbol
---@field public name? string
---@field public id integer
---@field private _id_counter integer
local Symbol = M.create_class("Symbol")
M.Symbol = Symbol

---@private
Symbol._id_counter = 1

---@param name? string
function Symbol:init(name)
  self.name = name
  self.id = Symbol._id_counter
  Symbol._id_counter = Symbol._id_counter + 1
end

function Symbol:__tostring()
  if self.name then
    return fmt("<Symbol('%s)>", self.name)
  else
    return fmt("<Symbol(#%d)>", self.id)
  end
end

return M
