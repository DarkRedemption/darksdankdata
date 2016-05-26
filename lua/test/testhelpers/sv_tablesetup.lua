--[[
Converts all sql tables into test tables with unique names.
These tables are meant to be populated with random data and deleted after the test has completed.
The tables are manually inserted into the tablesToConvert list for easy removal if one of them is breaking
and you are trying to test something else, since just one of them failing will melt the whole function.
]]
function DDDTest.Helpers.makeTables()
  local tables = DDD.Database.Tables
  local tablesToConvert = {
    PlayerId = tables.PlayerId,
    MapId = tables.MapId,
    RoundId = tables.RoundId,
    WeaponId = tables.WeaponId,
    WorldKill = tables.WorldKill,
    CombatDamage = tables.CombatDamage,
    Healing = tables.Healing,
    RoundRoles = tables.RoundRoles,
    PlayerKill = tables.PlayerKill,
    ShopItem = tables.ShopItem,
    Purchases = tables.Purchases,
    RoundResult = tables.RoundResult,
    EntityId = tables.EntityId,
    Dna = tables.Dna,
    WorldDamage = tables.WorldDamage,
    PlayerPushKill = tables.PlayerPushKill
    }
  local convertedTables = {}
  
  for tableName, sqlTable in pairs(tablesToConvert) do
    local convertedTable = DDDTest.TestSqlTable:convertTable(sqlTable)
    convertedTables[tableName] = convertedTable
  end
  
  for key, sqlTable in pairs(convertedTables) do
    sqlTable:create()
  end
  
  return convertedTables
end

function DDDTest.Helpers.dropAll(tables)
  --Needed until I add sorted tables.
  local dropOrder = {"PlayerPushKill", "WorldDamage", "Dna", "EntityId", "RoundResult", "Purchases", "ShopItem", "PlayerKill", "RoundRoles", "Healing", "CombatDamage", "WorldKill", "WeaponId", "RoundId", "MapId", "PlayerId"}
  local arraySize = table.getn(dropOrder)
  for i=1, arraySize do
    tables[dropOrder[i]]:drop()
  end
end