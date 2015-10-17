function DDDTest.Helpers.makeTables()
  local tables = {}
  local playerIdTable = DDDTest.TestSqlTable:convertTable(DDD.Database.Tables.PlayerId)
  local worldKillTable = DDDTest.TestSqlTable:convertTable(DDD.Database.Tables.WorldKill)
  tables.PlayerId = playerIdTable
  tables.WorldKill = worldKillTable
  
  for key, sqlTable in pairs(tables) do
    sqlTable:create()
  end
  
  return tables
end

function DDDTest.Helpers.dropAll(tables)
  for key, sqlTable in pairs(tables) do
    sqlTable:drop()
  end
end