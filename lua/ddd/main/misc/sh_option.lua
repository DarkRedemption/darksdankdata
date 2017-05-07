--[[
An implementation of the Option/Maybe data structure
found in functional programming languages.

For the uninitiated: an Option is simply an object that can contain
a single value. If it does, it is a "Some", otherwise it is a "None."
The point of this is to avoid nils and nil checking, as you can just
do functions on the Option instance that you guarantee will be returned from
a function you make, and those functions will simply do nothing instead of
failing if it is nil.
]]

local Option = {}

local function optionEquality(this, that)
  if (this:nonEmpty() and that:nonEmpty()) then
    return this:get() == that:get()
  else
    return this:isEmpty() and that:isEmpty()
  end
end

Option.__index = Option
Option.__eq = optionEquality

function Option:nonEmpty()
  return self.value != nil
end

function Option:isEmpty()
  return self.value == nil
end


local function new(optionSelf)
  local newOption = {}
  setmetatable(newOption, optionSelf)
  newOption.__isOption = true
  return newOption
end

function Option:get()
  assert(self:nonEmpty(), "Option was empty.")
  return self.value
end

function Option:getOrElse(f)
  if (self:nonEmpty()) then
    return self.value
  else
    return f()
  end
end

function Option:map(f)
  if (self:nonEmpty()) then
    return Option:Some(f(self.value))
  else
    return self
  end
end

function Option:flatMap(f)
  local result = self:map(f)
  local getResult = result:getOrElse(function() return nil end)
  assert(getResult.__isOption, "The value of the map's result is not an option and thus cannot be flattened.")
  return getResult
end

--Like map, but doesn't return anything.
function Option:foreach(f)
  self:map(f)
end

--[[These functions are capitalized for consistency with Scala,
and the fact that I may make them subclasses later.]]
function Option:Some(value)
  if (value == nil) then
    return self:None()
  else
    local newOption = new(self)
    newOption.value = value
    return newOption
  end
end

function Option:None()
  return new(self)
end

DDD.Misc.Option = Option
