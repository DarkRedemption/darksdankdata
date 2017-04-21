local tables = DDD.Database.Tables
local roles = DDD.Database.Roles

local PlayerStats = {}
PlayerStats.playerId = -1
PlayerStats.__index = PlayerStats

local function countResult(result)
  if (result == nil) then
    DDD.Logging.logDebug("sv_playerstats.lua.countResult: The query returned no information.")
    return 0
  elseif (result == false) then
    DDD.Logging.logError("sv_playerstats.lua.countResult: An error occured. Error was: " .. sql.LastError())
    return -1
else
  return result[1]["count"]
  end
end

function PlayerStats:getAggregateData(tables)
  tables = tables or DDD.Database.Tables
  local id = self.playerId
  local query = [[SELECT * FROM ]] .. tables.AggregateStats.tableName .. [[ as mainstats
                  LEFT JOIN ]] .. tables.AggregateWeaponStats.tableName .. [[ as weaponstats on mainstats.player_id == weaponstats.player_id
                  LEFT JOIN ]] .. tables.AggregatePurchaseStats.tableName .. [[ as purchasestats ON mainstats.player_id == purchasestats.player_id
                  WHERE mainstats.player_id == ]] .. id .. [[
                  GROUP BY mainstats.player_id
                ]]
  local result = sql.Query(query)
  self.statsTable = result[1]
  return result[1]
end

function PlayerStats:getPlayerTime()
  if sql.TableExists("utime") then
    local query = "SELECT * FROM utime WHERE player == " .. self.ply:UniqueID()
    local result = sql.Query(query)
    if (result != nil && result != false) then
      local totalSeconds = tonumber(result[1]["totaltime"])
      print(totalSeconds)
      local formattedTime = string.format("%.2d:%.2d:%.2d",
                                          math.floor(totalSeconds/(60 * 60)),
                                          totalSeconds/60 % 60,
                                          totalSeconds % 60)
      self.statsTable["TotalServerTime"] = formattedTime
    end
  end
end

function PlayerStats:updateStats()
  self:getAggregateData()
  self:getPlayerTime()
end

function PlayerStats:new(ply, databaseTables)
  local newStats = {}
  setmetatable(newStats, self)
  local dbTables = databaseTables or tables
  newStats.ply = ply
  newStats.playerId = dbTables.PlayerId:getPlayerId(ply)
  newStats.statsTable = {}
  newStats.tables = dbTables
  return newStats
end

DDD.Database.PlayerStats = PlayerStats
