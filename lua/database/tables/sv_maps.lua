local columns = " ( id INTEGER PRIMARY KEY, map_name TEXT UNIQUE )"
local mapIdTable = DDD.Table:new("ddd_map_id", columns)

function mapIdTable:addMap()
  local query = "INSERT INTO " .. self.tableName .. " (map_name) VALUES (\"" .. game.GetMap() .. "\")"
  return self:insert(query)
end

function mapIdTable:getCurrentMapId()
  local result = sql.Query("SELECT id FROM " .. self.tableName .. " WHERE map_name = '" .. game.GetMap() .. "'")
  return result[1]['id']
end

DDD.Database.Tables.MapId = mapIdTable
mapIdTable:create()
mapIdTable:addMap()