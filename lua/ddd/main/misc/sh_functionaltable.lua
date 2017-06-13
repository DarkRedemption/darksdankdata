local foreach = DDD.foreach
local map = DDD.map
local Option = DDD.Misc.Option

--[[
A table with functional programming methods.
]]
local FunctionalTable = {}
FunctionalTable.__index = FunctionalTable
FunctionalTable.__eq = function(this, that)
  if !this.length or !that.length then return false end
  if this:length() != that:length() then return false end

  local isEqual = true

  foreach(this.table, function(k, v)
    if that:get(k) != v then
      isEqual = false
    end
  end)

  return isEqual
end

function FunctionalTable:length()
  return self:foldLeft(0, function(s, k, v)
    return s + 1
  end)
end

--[[
An implementation of foldLeft.
Given a seedValue, perform operations with every key and value of a table that
affects the seed value. When complete, return the seedValue.
Great for summations, turning all values into a string, and more.
Example:
myFunctionalTable.insert("My ")
myFunctionalTable.insert("String")
myFunctionalTable:foldLeft("", function(seedString, key, value)
  return seedString .. value
end) -- Returns "My String"

Note that his function may fail to work properly on tables that are not arrays.

PARAM seedValue:Any - The value to start with.
PARAM f:Function(currentSeedValue:typeof(seedValue), key:Any, value:Any) - The
function to perform on the seed.
RETURN The mutated seedValue.
]]
function FunctionalTable:foldLeft(seedValue, f)
  local newValue = seedValue
  for k, v in ipairs(self.table) do
    newValue = f(newValue, k, v)
  end
  return newValue
end

--[[
Returns a value from the table as an Option.
If it's nil, this will become a None. If it's not, it will be a Some.
]]
function FunctionalTable:lift(key)
  return Option:Some(self.table[key])
end

--[[
Flatly returns a value from your FunctionalTable without doing anything special.
PARAM key:Any -
]]
function FunctionalTable:get(key)
  return self.table[key]
end

function FunctionalTable:set(key, value)
  self.table[key] = value
  return self
end

function FunctionalTable:insert(value)
  table.insert(self.table, value)
  return self
end

function FunctionalTable:map(f)
  local newTable = FunctionalTable:new()
  newTable.table = map(self.table, f)
  return newTable
end

function FunctionalTable:foreach(f)
  foreach(self.table, f)
end

function FunctionalTable:print()
  PrintTable(self.table)
end
--[[
Make a new functional table.
]]
function FunctionalTable:new()
  local newTable = {}
  setmetatable(newTable, self)
  newTable.table = {}
  return newTable
end

DDD.Misc.FunctionalTable = FunctionalTable
