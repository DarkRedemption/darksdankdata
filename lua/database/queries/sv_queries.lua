--Holds all the queries for data.
--TODO: Turn this into a class for getting the stats

local Queries = {}
local KillInfo = DDD.Database.Tables.KillInfo
local Healing = DDD.Database.Tables.Healing
local WeaponId = DDD.Database.Tables.WeaponId
local roles = DDD.Database.Roles

local function getC4KillsAsRole(playerId, roleId, victimRoleId)
  local c4Name = "ttt_c4"
  local c4Id = WeaponId:getWeaponId(c4Name)
  return KillInfo:getRoleKillsWithWeapon(playerId, roleId, victimRoleId, c4Id)
end

local function getC4DeathsAsRole(playerId, roleId, attackerRoleId)
  local c4Name = "ttt_c4"
  local c4Id = WeaponId:getWeaponId(c4Name)
  return KillInfo:getRoleDeathsWithWeapon(playerId, roleId, attackerRoleId, c4Id)
end

function Queries.getAllStats(ply)
  local playerId = DDD.Database.Tables.PlayerId:getPlayerId(ply)
  local statsTable = {}
  statsTable["K"] = KillInfo:getTotalKills(playerId)
  statsTable["D"] = KillInfo:getTotalDeaths(playerId)
  
  statsTable["TraitorInnocentK"] = KillInfo:getTraitorInnocentKills(playerId)
  statsTable["TraitorDetectiveK"] = KillInfo:getTraitorDetectiveKills(playerId)
  statsTable["TraitorTraitorK"] = KillInfo:getTraitorTraitorKills(playerId)
  statsTable["InnocentInnocentK"] = KillInfo:getInnocentInnocentKills(playerId)
  statsTable["InnocentDetectiveK"] = KillInfo:getInnocentDetectiveKills(playerId)
  statsTable["InnocentTraitorK"] = KillInfo:getInnocentTraitorKills(playerId)
  statsTable["DetectiveInnocentK"] = KillInfo:getDetectiveInnocentKills(playerId)
  statsTable["DetectiveDetectiveK"] = KillInfo:getDetectiveDetectiveKills(playerId)
  statsTable["DetectiveTraitorK"] = KillInfo:getDetectiveTraitorKills(playerId)
  
  statsTable["TraitorInnocentD"] = KillInfo:getTraitorInnocentDeaths(playerId)
  statsTable["TraitorDetectiveD"] = KillInfo:getTraitorDetectiveDeaths(playerId)
  statsTable["TraitorTraitorD"] = KillInfo:getTraitorTraitorDeaths(playerId)
  statsTable["InnocentInnocentD"] = KillInfo:getInnocentInnocentDeaths(playerId)
  statsTable["InnocentDetectiveD"] = KillInfo:getInnocentDetectiveDeaths(playerId)
  statsTable["InnocentTraitorD"] = KillInfo:getInnocentTraitorDeaths(playerId)
  statsTable["DetectiveInnocentD"] = KillInfo:getDetectiveInnocentDeaths(playerId)
  statsTable["DetectiveDetectiveD"] = KillInfo:getDetectiveDetectiveDeaths(playerId)
  statsTable["DetectiveTraitorD"] = KillInfo:getDetectiveTraitorDeaths(playerId)
  
  statsTable["TraitorSuicides"] = KillInfo:getTraitorSuicides(playerId)
  statsTable["InnocentSuicides"] = KillInfo:getInnocentSuicides(playerId)
  statsTable["DetectiveSuicides"] = KillInfo:getDetectiveSuicides(playerId)
  
  statsTable["TraitorInnocentC4K"] = getC4KillsAsRole(playerId, roles["Traitor"], roles["Innocent"]) 
  statsTable["TraitorDetectiveC4K"] = getC4KillsAsRole(playerId, roles["Traitor"], roles["Detective"]) 
  statsTable["TraitorTraitorC4K"] = getC4KillsAsRole(playerId, roles["Traitor"], roles["Traitor"]) 
  statsTable["InnocentInnocentC4K"] = getC4KillsAsRole(playerId, roles["Innocent"], roles["Innocent"]) 
  statsTable["InnocentDetectiveC4K"] = getC4KillsAsRole(playerId, roles["Innocent"], roles["Detective"]) 
  statsTable["InnocentTraitorC4K"] = getC4KillsAsRole(playerId, roles["Innocent"], roles["Traitor"]) 
  statsTable["DetectiveInnocentC4K"] = getC4KillsAsRole(playerId, roles["Detective"], roles["Innocent"]) 
  statsTable["DetectiveDetectiveC4K"] = getC4KillsAsRole(playerId, roles["Detective"], roles["Detective"]) 
  statsTable["DetectiveTraitorC4K"] = getC4KillsAsRole(playerId, roles["Detective"], roles["Traitor"]) 
  
  statsTable["TraitorInnocentC4D"] = getC4DeathsAsRole(playerId, roles["Traitor"], roles["Innocent"]) 
  statsTable["TraitorDetectiveC4D"] = getC4DeathsAsRole(playerId, roles["Traitor"], roles["Detective"]) 
  statsTable["TraitorTraitorC4D"] = getC4DeathsAsRole(playerId, roles["Traitor"], roles["Traitor"]) 
  statsTable["InnocentInnocentC4D"] = getC4DeathsAsRole(playerId, roles["Innocent"], roles["Innocent"]) 
  statsTable["InnocentDetectiveC4D"] = getC4DeathsAsRole(playerId, roles["Innocent"], roles["Detective"]) 
  statsTable["InnocentTraitorC4D"] = getC4DeathsAsRole(playerId, roles["Innocent"], roles["Traitor"]) 
  statsTable["DetectiveInnocentC4D"] = getC4DeathsAsRole(playerId, roles["Detective"], roles["Innocent"]) 
  statsTable["DetectiveDetectiveC4D"] = getC4DeathsAsRole(playerId, roles["Detective"], roles["Detective"]) 
  statsTable["DetectiveTraitorC4D"] = getC4DeathsAsRole(playerId, roles["Detective"], roles["Traitor"]) 
  
  statsTable["TotalHPHealed"] = Healing:getTotalHPHealed(ply)
  
  return statsTable
end

DDD.Database.Queries = Queries