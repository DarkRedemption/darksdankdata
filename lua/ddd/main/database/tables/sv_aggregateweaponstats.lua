--Holds aggregate data specifically for individual weapons.
--Made into its own table due to the number of columns each weapon produces for each role.

local roleIdToRole = {} -- The reverse of the main roles table, this is roleValue -> roleName instead.
roleIdToRole[0] = "innocent"
roleIdToRole[1] = "traitor"
roleIdToRole[2] = "detective"

--[[
A list of things that cannot be used to kill that still count as SWEPs.
These are not added to the table.
]]
local weaponFilter = {
  "weapon_ttt_radio",
  "weapon_ttt_decoy",
  "weapon_ttt_binoculars",
  "weapon_ttt_defuser",
  "weapon_ttt_cse"
}

local function makeKillColumnName(weaponClass, attackerRoleId, victimRoleId)
  return weaponClass .. "_" .. roleIdToRole[tonumber(attackerRoleId)] .. "_" .. roleIdToRole[tonumber(victimRoleId)] .. "_kills"
end

local function makeDeathColumnName(weaponClass, attackerRoleId, victimRoleId)
  return weaponClass .. "_" .. roleIdToRole[tonumber(victimRoleId)] .. "_" .. roleIdToRole[tonumber(attackerRoleId)] .. "_deaths"
end

local function generateWeaponColumns()
  local columns = { player_id = "INTEGER NOT NULL" }
  local weaponList = weapons.GetList()

  for key, weaponInfo in pairs(weaponList) do
    if (weaponInfo.ClassName) then

      for playerRoleKey, playerRoleName in pairs(roleIdToRole) do

        for opponentRoleKey, opponentRoleName in pairs(roleIdToRole) do
            local killColumnName = makeKillColumnName(weaponInfo.ClassName, playerRoleKey, opponentRoleKey)
            local deathColumnName = makeDeathColumnName(weaponInfo.ClassName, playerRoleKey, opponentRoleKey)
            columns[killColumnName] = "INTEGER NOT NULL DEFAULT 0"
            columns[deathColumnName] = "INTEGER NOT NULL DEFAULT 0"
        end

        local shotsColumnName = weaponInfo.ClassName .. "_" .. playerRoleName .. "_shots_fired"
        columns[shotsColumnName] = "INTEGER NOT NULL DEFAULT 0"

      end

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
  SELECT COUNT(kills.attacker_id) as count,
  kills.attacker_id,
  weapons.weapon_class,
  attackerRoles.role_id as attacker_role,
  victimRoles.role_id as victim_role
  FROM ]] .. self.tables.PlayerKill.tableName .. [[ as kills
  LEFT JOIN ]] .. self.tables.WeaponId.tableName .. [[ as weapons
  LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ as attackerRoles
  LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ as victimRoles
  WHERE kills.weapon_id == weapons.id
  AND attackerRoles.player_id == kills.attacker_id
  AND victimRoles.player_id == kills.victim_id
  AND attackerRoles.round_id == kills.round_id
  AND victimRoles.round_id == kills.round_id
  GROUP BY kills.attacker_id, attacker_role, victim_role, weapon_class
  ]]

  return self:query("aggregateWeaponStatsTable:getWeaponKillsFromRawData", query)
end

function aggregateWeaponStatsTable:getWeaponDeathsFromRawData()
  local query = [[
  SELECT COUNT(kills.victim_id) as count,
  kills.victim_id,
  weapons.weapon_class,
  attackerRoles.role_id as attacker_role,
  victimRoles.role_id as victim_role
  FROM ]] .. self.tables.PlayerKill.tableName .. [[ as kills
  LEFT JOIN ]] .. self.tables.WeaponId.tableName .. [[ as weapons
  LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ as attackerRoles
  LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ as victimRoles
  WHERE kills.weapon_id == weapons.id
  AND attackerRoles.player_id == kills.attacker_id
  AND victimRoles.player_id == kills.victim_id
  AND attackerRoles.round_id == kills.round_id
  AND victimRoles.round_id == kills.round_id
  GROUP BY kills.victim_id, attacker_role, victim_role, weapon_class
  ]]

  return self:query("aggregateWeaponStatsTable:getWeaponDeathsFromRawData", query)
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

local function addRecalculatedPlayerStats(weaponStatsTable, playerStatsLuaTable)
  for playerId, values in pairs(playerStatsLuaTable) do
    weaponStatsTable:insertTable(values)
  end
end

function aggregateWeaponStatsTable:incrementKillColumn(weaponClass, attackerTableId, attackerRoleId, victimRoleId)
  local columnName = makeKillColumnName(weaponClass, attackerRoleId, victimRoleId)
  local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. columnName .. " + 1 " ..
                "WHERE player_id == " .. attackerTableId

  return self:query("aggregateWeaponStatsTable:incrementKillColumn", query)
end

function aggregateWeaponStatsTable:incrementDeathColumn(weaponClass, victimTableId, attackerRoleId, victimRoleId)
  local columnName = makeDeathColumnName(weaponClass, attackerRoleId, victimRoleId)
  local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. columnName .. " + 1 " ..
                "WHERE player_id == " .. victimTableId

  return self:query("aggregateWeaponStatsTable:incrementDeathColumn", query)
end

function aggregateWeaponStatsTable:recalculate()
  self:drop()
  self:create()

  local playerStatsLuaTable = {}
  local players = self.tables.PlayerId:getPlayerIdList()

  for rowId, columns in pairs(players) do
    addPlayerToLuaTable(playerStatsLuaTable, rowId)
  end

  local killRows = self:getWeaponKillsFromRawData()
  local deathRows = self:getWeaponDeathsFromRawData()

  for rowId, columns in pairs(killRows) do
    local playerId = tonumber(columns["attacker_id"])
    local columnName = makeKillColumnName(columns["weapon_class"], columns["attacker_role"], columns["victim_role"])
    playerStatsLuaTable[playerId][columnName] = columns["count"]
  end

  for rowId, columns in pairs(deathRows) do
    local playerId = tonumber(columns["victim_id"])
    local columnName = makeDeathColumnName(columns["weapon_class"], columns["attacker_role"], columns["victim_role"])
    playerStatsLuaTable[playerId][columnName] = columns["count"]
  end

  addRecalculatedPlayerStats(self, playerStatsLuaTable)
end

function aggregateWeaponStatsTable:getPlayerStats(playerId)
  local query = "SELECT * from " .. self.tableName .. " WHERE player_id == " .. playerId
  return self:query("aggregateWeaponStatsTable:getPlayerStats", query, 1)
end

DDD.Database.Tables.AggregateWeaponStats = aggregateWeaponStatsTable
aggregateWeaponStatsTable:create()
