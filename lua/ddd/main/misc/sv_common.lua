local roleIdToRole = {} -- The reverse of the main roles table, this is roleValue -> roleName instead.
roleIdToRole[0] = "innocent"
roleIdToRole[1] = "traitor"
roleIdToRole[2] = "detective"

local sweps

--[[
Checks to see if something exists in an array.
]]

local function arrayContains(arr, v)
  for key, value in pairs(arr) do
    if (value == v) then
      return true
    end
  end

  return false
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

DDD.roleIdToRole = roleIdToRole
DDD.arrayContains = arrayContains
DDD.traitorCanBuy = traitorCanBuy
DDD.detectiveCanBuy = detectiveCanBuy

hook.Add("Initialize", "DDDGetWeaponListForCommon", function()
  sweps = weapons.GetList()
  DDD.traitorItems = getRoleItems(ROLE_TRAITOR)
  DDD.detectiveItems = getRoleItems(ROLE_DETECTIVE)
  DDD.traitorItemNames = getItemNames(DDD.traitorItems)
  DDD.detectiveItemNames = getItemNames(DDD.detectiveItems)
end)
