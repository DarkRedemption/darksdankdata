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

function PlayerStats:getC4Id()
  local c4Name = "ttt_c4"
  return self.tables.WeaponId:getWeaponId(c4Name)
end

function PlayerStats:getC4KillsAsRole(roleId, victimRoleId)
  local c4Id = self:getC4Id()
  if (c4Id == -1) then return 0 end
  return self.tables.PlayerKill:getRoleKillsWithWeapon(self.playerId, roleId, victimRoleId, c4Id)
end

function PlayerStats:getC4DeathsAsRole(roleId, attackerRoleId)
  local c4Id = self:getC4Id()
  if (c4Id == -1) then return 0 end
  return self.tables.PlayerKill:getRoleDeathsWithWeapon(self.playerId, roleId, attackerRoleId, c4Id)
end

function PlayerStats:updateRoleData()
  for rolename, rolevalue in pairs(roles) do
    local keyname = rolename .. "Rounds"
    self.statsTable[keyname] = self.tables.RoundRoles:getRoundsAsRole(self.playerId, rolevalue)
  end
end

function PlayerStats:getRoleAssists(playerRole)
end

--Gets every combination of roles and passes them into a function, adding their result to the stats table.
function PlayerStats:getDataForAllRoles(suffix, func)
  for rolename, rolevalue in pairs(roles) do
    for secondrolename, secondrolevalue in pairs(DDD.Database.Roles) do
      local keyname = rolename .. secondrolename .. suffix
      self.statsTable[keyname] = func(self, rolevalue, secondrolevalue)
    end
  end
end

--[[
Start off the PlayerStats table with all the aggregate data.
]]
function PlayerStats:getAggregateData()
  self.statsTable = self.tables.AggregateStats:getPlayerStats(self.playerId)
end

function PlayerStats:getPlayerTime()
  if sql.TableExists("utime") then
    local query = "SELECT * FROM utime WHERE player == " .. self.ply:UniqueID()
    local result = sql.Query(query)
    if (result != nil && result != false) then
      local totalSeconds = tonumber(result[1]["totaltime"])
      local formattedTime = string.format("%.2d:%.2d:%.2d", totalSeconds/(60*60), totalSeconds/60%60, totalSeconds%60)
      self.statsTable["TotalServerTime"] = formattedTime
    end
  end
end

function PlayerStats:updateStats()
  self:getAggregateData()
  self:getPlayerTime()
  self:updateRoleData()

  self.statsTable["TotalHPYouHealed"] = tables.Healing:getTotalHPYouHealed(self.playerId)
  self.statsTable["TotalHPOthersHealed"] = tables.Healing:getTotalHPOthersHealed(self.playerId)
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