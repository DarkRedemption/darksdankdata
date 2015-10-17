--Stores the damage type enum names as strings.
--Does not store their integer value, as the gmod team has stated it can change between gmod versions.
--Enum list: https://wiki.garrysmod.com/page/Enums/DMG

local columns = "(id INTEGER PRIMARY KEY, damage_type STRING UNIQUE NOT NULL)"
local damageTypeTable = DDD.Table:new("ddd_damage_type", columns)

function damageTypeTable:addDamageType(damageType)
  local query = "INSERT INTO " .. self.tableName .. " (damage_type) VALUES ('" .. damageType .. "')"
  return self:insert(query)
end

function damageTypeTable:getDamageTypeId(damageTypeNumber)
  local damageType = DDD.Misc.Enums.DamageType[damageTypeNumber]
  local query = "SELECT id FROM " .. self.tableName .. " WHERE damage_type == '" .. damageType .. "'"
  return self:query("DamageType.getDamageTypeId", query, 1, "id")
end

--[[damageTypeIdTable:create()
for damageTypeNumber, damageTypeString in DDD.Misc.Enums.DamageType do
  damageTypeTable:addDamageType(damageType)
end
DDD.Database.Tables.DamageType = damageTypeTable
]]

