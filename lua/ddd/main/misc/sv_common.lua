local roleIdToRole = {} -- The reverse of the main roles table, this is roleValue -> roleName instead.
roleIdToRole[0] = "innocent"
roleIdToRole[1] = "traitor"
roleIdToRole[2] = "detective"

local sweps
local traitorItems
local detectiveItems

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
    if (roleCanBuy(equipmentItem, role)) then
      table.insert(items, equipmentItem)
    end
  end

  return items
end

DDD.roleIdToRole = roleIdToRole
DDD.arrayContains = arrayContains
DDD.traitorCanBuy = traitorCanBuy
DDD.detectiveCanBuy = roleCanBuy
DDD.detectiveItems = detectiveItems
DDD.traitorItems = traitorItems

hook.Add("Initialize", "DDDGetWeaponListForCommon", function()
  sweps = weapons.GetList()
  traitorItems = getRoleItems(ROLE_TRAITOR)
  detectiveItems = getRoleItems(ROLE_DETECTIVE)
end)
