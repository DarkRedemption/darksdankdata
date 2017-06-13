local roleIdToRole = {} -- The reverse of the main roles table, this is roleValue -> roleName instead.
roleIdToRole[0] = "innocent"
roleIdToRole[1] = "traitor"
roleIdToRole[2] = "detective"

local function arrayContains(array, v)
  for key, value in pairs(array) do
    if (value == v) then
      return true
    end
  end

  return false
end

local function filter(table, f)
  local filteredTable = {}

  for key, value in pairs(table) do
    if (f(key, value)) then
      filteredTable[key] = value
    end
  end

  return filteredTable
end

--[[
Filters the given table with the function provided.
Returns a new array with any item that matched the predicate function.
]]
local function filterValue(array, f)
  local filteredArray = {}

  for key, value in pairs(array) do
    if (f(value)) then
      table.insert(filteredArray, value)
    end
  end

  return filteredArray
end

--[[
Performs a map on a table.
Maps are like a for each loop, but they return the mutated values.
]]
local function map(table, f)
  local mutatedTable = {}

  for key, value in pairs(table) do
    local _1, _2 = f(key, value)
    if (_2 == nil) then
      mutatedTable[key] = _1
    else
      mutatedTable[_1] = _2
    end
  end

  return mutatedTable
end

--[[
Like map, only return nothing.
]]
local function foreach(table, f)
  for key, value in pairs(table) do
    f(key, value)
  end
end

--[[
Like map, only return nothing.
This version uses ipairs instead of pairs.
]]
local function iforeach(table, f)
  for key, value in ipairs(table) do
    f(key, value)
  end
end

local function foreachValue(table, f)
  for key, value in pairs(table) do
    f(value)
  end
end

local function length(table)
  local i = 0

  foreach(table, function(x, y)
    i = i + 1
  end)

  return i
end

DDD.roleIdToRole = roleIdToRole
DDD.arrayContains = arrayContains
DDD.filter = filter
DDD.filterValue = filterValue
DDD.map = map
DDD.foreach = foreach
DDD.iforeach = iforeach
DDD.foreachValue = foreachValue
DDD.length = length
