--local columns = " ( id INTEGER PRIMARY KEY, steam_id TEXT UNIQUE, first_seen INTEGER )"
--local playerIdTable = DDD.Table:new("ddd_player_id", columns)
local columns = {
  id = "INTEGER PRIMARY KEY",
  steam_id = "TEXT UNIQUE NOT NULL",
  first_seen = "INTEGER NOT NULL",
  last_known_name = "TEXT NOT NULL"
}

local playerIdTable = DDD.SqlTable:new("ddd_player_id", columns)
playerIdTable:addIndex("steamIdIndex", {"steam_id"})
playerIdTable.recentIds = {}

function playerIdTable:addToRecentIds(steamId, sqlResult)
  if (type(sqlResult) == "string") then
    self.recentIds[steamId] = tonumber(sqlResult)
  else
    self.recentIds[steamId] = sqlResult
  end
end

function playerIdTable:addPlayer(ply)
  local row = {
    steam_id = ply:SteamID(),
    first_seen = os.time(),
    last_known_name = ply:GetName()
  }
  local result = self:insertTable(row)
  self:addToRecentIds(ply:SteamID(), result)
  return self.recentIds[ply:SteamID()]
end

function playerIdTable:getPlayerIdBySteamId(steamId)
  if (self.recentIds[steamId] != nil) then
    return self.recentIds[steamId]
  else
    local query = "SELECT id FROM " .. self.tableName .. " WHERE steam_id = '" .. steamId .. "'"
    local result = tonumber(self:query(query, 1, "id"))
    self:addToRecentIds(steamId, result)
    return result
  end
end

function playerIdTable:getPlayerId(ply)
  return self:getPlayerIdBySteamId(ply:SteamID())
end

--[[
Gets every player ID from the table.
Used in aggregation tables.
]]
function playerIdTable:getPlayerIdList()
  local query = "SELECT id FROM " .. self.tableName
  local result = self:query(query)

  if (result != nil and result != false and type(result) != "number") then
    local list = {}

    for row, columns in pairs(result) do
      table.insert(list, columns["id"])
    end

    return list
  end

  return result
end

function playerIdTable:updatePlayerName(ply)
  local id = self.recentIds[ply:SteamID()] or self:getPlayerId(ply)

  if (id > 0) then
    local query = "UPDATE " .. self.tableName .. " SET 'last_known_name' = '" .. ply:GetName() .. "' WHERE id == " .. id
    self:query(query)
  end

  return id
end

function playerIdTable:getPlayerRow(ply)
  local query = "SELECT * FROM " .. self.tableName .. " WHERE steam_id = '" .. ply:SteamID() .. "'"
  local result = self:query(query, 1)
  return result
end

function playerIdTable:playerExists(ply)
  local id = self.recentIds[ply:SteamID()] or self:getPlayerId(ply)
  return (id > 0)
end

function playerIdTable:addOrUpdatePlayer(ply)
  local id

  if self:playerExists(ply) then
    id = self:updatePlayerName(ply)
  else
    id = self:addPlayer(ply)
  end

  return id
end


DDD.Database.Tables.PlayerId = playerIdTable
playerIdTable:create()
