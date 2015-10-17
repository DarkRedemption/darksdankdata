local mapIdTable = DDD.Database.Tables.MapId

local columns = "(id INTEGER PRIMARY KEY, map_id INTEGER, start_timestamp INTEGER, FOREIGN KEY (map_id) REFERENCES " .. mapIdTable.tableName .. " (id))"
local roundIdTable = DDD.Table:new("ddd_round_id", columns)

function roundIdTable:addRound()
  local timestamp = os.time()
  local currentMapId = mapIdTable:getCurrentMapId()
  local queryTable = {
    map_id = currentMapId,
    start_timestamp = timestamp
  }
  return self:insertTable(queryTable)
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
