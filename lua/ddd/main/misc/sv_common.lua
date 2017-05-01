local sweps
local swepNames

--[[
Checks to see if something exists in an array.
]]

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

  for key, value in pairs(array) do
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
    local newKey, newValue = f(key, value)
    mutatedTable[newKey] = newValue
  end

  return mutatedTable
end

local function roleCanBuy(swep, role)
  if (!swep.CanBuy) then
    return false
  end

  for index, roleId in pairs(swep.CanBuy) do
    if (roleId == role) then
      return true
    end
  end

  return false
end

local function traitorCanBuy(swep)
  return roleCanBuy(swep, ROLE_TRAITOR)
end

local function detectiveCanBuy(swep)
  return roleCanBuy(swep, ROLE_DETECTIVE)
end

local function getRoleItems(role)
  local items = {}

  for index, swep in pairs(sweps) do
    if roleCanBuy(swep, role) then
      table.insert(items, swep)
    end
  end

  for index, equipmentItem in pairs(EquipmentItems[role]) do
    table.insert(items, equipmentItem)
  end

  return items
end

local function getItemNames(swepList)
  local itemNames = {}

  for index, swep in pairs(swepList) do
    if (swep.ClassName) then
      table.insert(itemNames, swep.ClassName)
    elseif (swep.name) then
      table.insert(itemNames, swep.name)
    end
  end

  return itemNames
end

local function getSwepNames(swepList)
  local swepNames = {}

  for index, swep in pairs(swepList) do
    local name = DDD.Config.DeployedWeaponTranslation[swep.ClassName] or swep.ClassName
    table.insert(swepNames, name)
  end

  return swepNames
end

DDD.arrayContains = arrayContains
DDD.traitorCanBuy = traitorCanBuy
DDD.detectiveCanBuy = detectiveCanBuy
DDD.filter = filter
DDD.filterValue = filterValue
DDD.map = map

hook.Add("Initialize", "DDDGetWeaponListForCommon", function()
  sweps = weapons.GetList()
  DDD.swepNames = getSwepNames(sweps)
  DDD.traitorItems = getRoleItems(ROLE_TRAITOR)
  DDD.detectiveItems = getRoleItems(ROLE_DETECTIVE)
  DDD.traitorItemNames = getItemNames(DDD.traitorItems)
  DDD.detectiveItemNames = getItemNames(DDD.detectiveItems)
end)
