--Holds aggregate data specifically for individual weapons.
--Made into its own table due to the number of columns each weapon produces for each role.

local function generateWeaponColumns()
  local columns = { player_id = "INTEGER NOT NULL" }
  local weapons = weapons.GetAll()
  
  for key, value in pairs(weapons) do
    if (value.ClassName) then
      columns[value.ClassName + "_innocent_kills"] = "INTEGER NOT NULL DEFAULT 0"
      columns[value.ClassName + "_traitor_kills"] = "INTEGER NOT NULL DEFAULT 0"
      columns[value.ClassName + "_detective_kills"] = "INTEGER NOT NULL DEFAULT 0"
      
      columns[value.ClassName + "_innocent_deaths"] = "INTEGER NOT NULL DEFAULT 0"
      columns[value.ClassName + "_traitor_deaths"] = "INTEGER NOT NULL DEFAULT 0"
      columns[value.ClassName + "_detective_deaths"] = "INTEGER NOT NULL DEFAULT 0"
      
      columns[value.ClassName + "_shots_fired"] = "INTEGER NOT NULL DEFAULT 0"
    end
  end
  
  return columns
end

local columns = generateWeaponColumns()

local aggregateWeaponStatsTable = DDD.SqlTable:new("ddd_aggregate_weapon_stats", columns)

local function countResult(result)
  if (result == nil) then
    DDD.Logging.logDebug("sv_aggregateweaponstats.lua.countResult: The query returned no information.")
    return 0
  elseif (result == false) then
    DDD.Logging.logError("sv_aggregateweaponstats.lua.countResult: An error occured. Error was: " .. sql.LastError())
    return -1
else 
  return result[1]["count"]
  end
end

function aggregateWeaponStatsTable:getWeaponKillsFromRawData()
  local query = [[
  SELECT COUNT(kills.attacker_id), 
  kills.attacker_id, 
  weapons.weapon_class, 
  attackerRoles.role_id as attacker_role, 
  victimRoles.role_id as victim_role
  FROM ]] .. self.tables.PlayerKill.tableName .. [[ as kills
  LEFT JOIN ]] .. self.tables.WeaponId.tableName [[ as weapons 
  LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ as attackerRoles  
  LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ as victimRoles
  WHERE kills.weapon_id == weapons.id 
  AND attackerRoles.player_id == kills.attacker_id 
  AND attackerRoles.round_id == kills.round_id
  AND victimRoles.round_id == kills.round_id
  GROUP BY kills.attacker_id, attacker_role, victim_role, weapon_class
  ]]
  
  return SqlTable.query("aggregateWeaponStatsTable:selectWeaponKills", query)
end

--Adds a player known to have no stats.
function aggregateWeaponStatsTable:addPlayer(playerId)
  local newPlayerTable = {
    player_id = playerId
  }
  return self:insertTable(newPlayerTable)
end

local function addPlayerToLuaTable(playerStatsLuaTable, playerId)
   if !playerStatsLuaTable[playerId] then
     playerStatsLuaTable[playerId] = {
       player_id = playerId
     }
   end
end

local function incrementRecalculatedColumn(playerStatsLuaTable, playerId, columnName)
  if playerStatsLuaTable[playerId][columnName] then
    playerStatsLuaTable[playerId][columnName] = playerStatsLuaTable[playerId][columnName] + 1
  else
    playerStatsLuaTable[playerId[columnName] = 1
  end
end

function aggregateWeaponStatsTable:recalculate()
  self:drop()
  self:create()
  
  local playerStatsLuaTable = {}
  local players = self.tables.PlayerId:getPlayerIdList()
  for rowId, columns in pairs(players) do
    addPlayerToLuaTable(playerStatsLuaTable, rowId)
  end
  
  local killRows = self:selectWeaponKillsFromMainTables()
  
  for rowId, columns in pairs(killRows) do
    incrementRecalculatedColumn(playerStatsLuaTable, columns["attacker_id"], columns["weapon_class"] .. "_kills")
    incrementRecalculatedColumn(playerStatsLuaTable, columns["victim_id"], columns["weapon_class"] .. "_deaths")
  end
end