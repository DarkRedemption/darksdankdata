--local columns = " ( id INTEGER PRIMARY KEY, steam_id TEXT UNIQUE, first_seen INTEGER )"
--local playerIdTable = DDD.Table:new("ddd_player_id", columns)
local columns = {
  id = "INTEGER PRIMARY KEY",
  steam_id = "TEXT UNIQUE",
  first_seen = "INTEGER"
  }
local playerIdTable = DDD.SqlTable:new("ddd_player_id", columns)

function playerIdTable:addPlayer(ply)
  local row = {
    steam_id = ply:SteamID(),
    first_seen = os.time()
  }
  return self:insertTable(row)
end

function playerIdTable:getPlayerIdFromSteamId(steamId)
  local query = "SELECT id FROM " .. self.tableName .. " WHERE steam_id = '" .. steamId .. "'"
  local result = self:query("getPlayerIdFromSteamId", query, 1, "id")
  return tonumber(result)
end

function playerIdTable:getPlayerId(ply)
  return self:getPlayerIdFromSteamId(ply:SteamID())
end

DDD.Database.Tables.PlayerId = playerIdTable
playerIdTable:create()