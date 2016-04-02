local mapIdTable = DDD.Database.Tables.MapId

local columns = {
  id = "INTEGER PRIMARY KEY",
  map_id = "INTEGER NOT NULL",
  start_timestamp = "INTEGER NOT NULL"
}

local foreignKeys = DDD.Database.ForeignKeyTable:new()
foreignKeys:addConstraint("map_id", mapIdTable, "id")

local roundIdTable = DDD.SqlTable:new("ddd_round_id", columns, foreignKeys)

function roundIdTable:addRound()
  local timestamp = os.time()
  local currentMapId = self:getForeignTableByColumn("map_id"):getCurrentMapId()
  local queryTable = {
    map_id = currentMapId,
    start_timestamp = timestamp
  }
  return self:insertTable(queryTable)
end

function roundIdTable:getCurrentRoundRow()
  local query = "SELECT * FROM " .. self.tableName .. " ORDER BY id DESC LIMIT 1"
  local result = self:query("getCurrentRoundRow", query)
  return result
end

function roundIdTable:getCurrentRoundId()
  local query = "SELECT max(id) FROM " .. self.tableName
  local result = sql.Query(query)
  if (result == nil || result == false) then 
    return 0
  else 
    return tonumber(result[1]['max(id)'])
  end
end

roundIdTable:create()
DDD.Database.Tables.RoundId = roundIdTable
