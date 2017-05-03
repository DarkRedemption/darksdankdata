local sweps
local swepNames

local map = DDD.map
local filter = DDD.filter
local foreach = DDD.foreach
--[[
Checks to see if something exists in an array.
]]

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
  local items = filter(sweps, function(index, swep)
    return roleCanBuy(swep, role)
  end)

  foreach(EquipmentItems[role], function(_, equipmentItem)
    table.insert(items, equipmentItem)
  end)

  return items
end

local function getItemNames(swepList)
  return map(swepList, function(index, swep)
    return (swep.ClassName or swep.name)
  end)
end

local function getSwepNames(swepList)
  return map(swepList, function(_, swep)
    return DDD.Config.DeployedWeaponTranslation[swep.ClassName] or swep.ClassName
  end)
end

DDD.traitorCanBuy = traitorCanBuy
DDD.detectiveCanBuy = detectiveCanBuy

hook.Add("Initialize", "DDDGetWeaponListForCommon", function()
  sweps = weapons.GetList()
  DDD.swepNames = getSwepNames(sweps)
  DDD.traitorItems = getRoleItems(ROLE_TRAITOR)
  DDD.detectiveItems = getRoleItems(ROLE_DETECTIVE)
  DDD.traitorItemNames = getItemNames(DDD.traitorItems)
  DDD.detectiveItemNames = getItemNames(DDD.detectiveItems)
end)
