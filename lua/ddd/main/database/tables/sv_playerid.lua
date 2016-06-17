--local columns = " ( id INTEGER PRIMARY KEY, steam_id TEXT UNIQUE, first_seen INTEGER )"
--local playerIdTable = DDD.Table:new("ddd_player_id", columns)
local columns = {
  id = "INTEGER PRIMARY KEY",
  steam_id = "TEXT UNIQUE NOT NULL",
  first_seen = "INTEGER NOT NULL",
  last_known_name = "TEXT NOT NULL"
  }
local playerIdTable = DDD.SqlTable:new("ddd_player_id", columns)

function playerIdTable:addPlayer(ply)
  local row = {
    steam_id = ply:SteamID(),
    first_seen = os.time(),
    last_known_name = ply:GetName()
  }
  return self:insertTable(row)
end

function playerIdTable:getPlayerIdBySteamId(steamId)
  local query = "SELECT id FROM " .. self.tableName .. " WHERE steam_id = '" .. steamId .. "'"
  local result = self:query("getPlayerIdBySteamId", query, 1, "id")
  return tonumber(result)
end

function playerIdTable:getPlayerId(ply)
  return self:getPlayerIdBySteamId(ply:SteamID())
end

function playerIdTable:updatePlayerName(ply)
  local id = self:getPlayerId(ply)
  if (id > 0) then
    local query = "UPDATE " .. self.tableName .. " SET 'last_known_name' = '" .. ply:GetName() .. "' WHERE id == " .. id
    self:query("updatePlayerName", query)
  end
end

function playerIdTable:getPlayerRow(ply)
  local query = "SELECT * FROM " .. self.tableName .. " WHERE steam_id = '" .. ply:SteamID() .. "'"
  local result = self:query("getPlayerRow", query, 1)
  return result
end

function playerIdTable:playerExists(ply)
  local id = playerIdTable:getPlayerIdBySteamId(ply)
  return (id > 0)
end

DDD.Database.Tables.PlayerId = playerIdTable
playerIdTable:create()