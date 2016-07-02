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

--TODO: Only get the c4 ID once
function PlayerStats:getC4KillsAsRole(roleId, victimRoleId)
  local c4Name = "ttt_c4"
  local c4Id = self.tables.WeaponId:getWeaponId(c4Name)
  if (c4Id == -1) then return 0 end
  return self.tables.PlayerKill:getRoleKillsWithWeapon(self.playerId, roleId, victimRoleId, c4Id)
end

function PlayerStats:getC4DeathsAsRole(roleId, attackerRoleId)
  local c4Name = "ttt_c4"
  local c4Id = self.tables.WeaponId:getWeaponId(c4Name)
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

function PlayerStats:updateSuicideData()
  self.statsTable["TraitorSuicides"] = tables.PlayerKill:getTraitorSuicides(self.playerId)
  self.statsTable["InnocentSuicides"] = tables.PlayerKill:getInnocentSuicides(self.playerId)
  self.statsTable["DetectiveSuicides"] = tables.PlayerKill:getDetectiveSuicides(self.playerId)
end

--[[
Start off the PlayerStats table with all the aggregate data.
]]
function PlayerStats:getAggregateData()
  self.statsTable = self.tables.AggregateStats:getPlayerStats(self.playerId)
end

function PlayerStats:updateStats()
  self:getAggregateData()
  self:updateRoleData()
  self:updateSuicideData()
  self:getDataForAllRoles("C4K", PlayerStats.getC4KillsAsRole)
  self:getDataForAllRoles("C4D", PlayerStats.getC4DeathsAsRole)

  self.statsTable["TotalHPYouHealed"] = tables.Healing:getTotalHPYouHealed(self.playerId)
  self.statsTable["TotalHPOthersHealed"] = tables.Healing:getTotalHPOthersHealed(self.playerId)
end

function PlayerStats:send()
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