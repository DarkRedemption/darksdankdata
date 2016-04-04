--[[
Converts all sql tables into test tables with unique names.
These tables are meant to be populated with random data and deleted after the test has completed.
]]
function DDDTest.Helpers.makeTables()
  local tables = DDD.Database.Tables
  local tablesToConvert = {
    PlayerId = tables.PlayerId,
    MapId = tables.MapId,
    RoundId = tables.RoundId,
    WeaponId = tables.WeaponId
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
  for key, sqlTable in pairs(tables) do
    sqlTable:drop()
  end
end