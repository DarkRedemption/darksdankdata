local columns = {
  id = "INTEGER PRIMARY KEY",
  map_name = "TEXT UNIQUE NOT NULL"
}
local mapIdTable = DDD.SqlTable:new("ddd_map_id", columns)

function mapIdTable:addMap()
  local row = {
    map_name = game.GetMap()
    }
  return self:insertTable(row)
end

function mapIdTable:getCurrentMapId()
  local query = "SELECT id FROM " .. self.tableName .. " WHERE map_name = '" .. game.GetMap() .. "'"
  local result = self:query(query, 1, "id")
  return tonumber(result)
end

DDD.Database.Tables.MapId = mapIdTable
mapIdTable:create()
