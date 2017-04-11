local roleIdToRole = DDD.roleIdToRole
local roleToRoleId = DDD.Database.Roles

local lightBlue = Color(0, 255, 255, 255)
local red = Color(255, 0, 0, 255)

local tables = DDD.Database.Tables

--All kills/deaths are in the format of <thisplayerrole>_<opponentrole>_<kills/deaths>
local columns = { player_id = "INTEGER PRIMARY KEY",
                  self_hp_healed = "INTEGER NOT NULL DEFAULT 0",
                  others_hp_healed = "INTEGER NOT NULL DEFAULT 0"
                }

local function createColumnsForAllRoleCombinations(suffix)
  for rolename, rolevalue in pairs(roleToRoleId) do
    for secondrolename, secondrolevalue in pairs(roleToRoleId) do
      local keyname = string.lower(rolename) .. "_" .. string.lower(secondrolename) .. "_" .. suffix
      columns[keyname] = "INTEGER NOT NULL DEFAULT 0"
    end
  end
end

local function createColumnsForSingleRole(suffix)
  for rolename, rolevalue in pairs(roleToRoleId) do
    local keyname = string.lower(rolename) .. "_" .. suffix
    columns[keyname] = "INTEGER NOT NULL DEFAULT 0"
  end
end

createColumnsForAllRoleCombinations("kills")
createColumnsForAllRoleCombinations("deaths")
createColumnsForAllRoleCombinations("ttt_c4_kills")
createColumnsForAllRoleCombinations("ttt_c4_deaths")

createColumnsForSingleRole("rounds")
createColumnsForSingleRole("rounds_won")
createColumnsForSingleRole("rounds_lost")
createColumnsForSingleRole("suicides")
createColumnsForSingleRole("world_deaths")

local foreignKeyTable = DDD.Database.ForeignKeyTable:new()
foreignKeyTable:addConstraint("player_id", tables.PlayerId, "id")

local aggregateStatsTable = DDD.SqlTable:new("ddd_aggregate_stats", columns, foreignKeyTable)
aggregateStatsTable.tables = tables --So they can be easily swapped out in test
aggregateStatsTable.itemColumnSuffix = itemColumnSuffix
--TODO: Override create() to check if it doesn't exist. If it doesn't, create AND recalculate.

local function countResult(result)
  if (result == nil) then
    DDD.Logging.logDebug("sv_aggregatestats.lua.countResult: The query returned no information.")
    return 0
  elseif (result == false) then
    DDD.Logging.logError("sv_aggregatestats.lua.countResult: An error occured. Error was: " .. sql.LastError())
    return -1
else
  return result[1]["count"]
  end
end

--[[
Gets all combat-based kills and adds them to the in-memory table of recalculated rows.
PARAM playerTables:Table[Int -> Table[String -> Int] ] - A table of player ids containing a table of rows to be inserted to AggregateStats
RETURN A new playerTables that increments the selfrole_opponentrole_kills columns by the number of combat kills found.
]]
function aggregateStatsTable:getAllCombatKillCounts(playerTables)
  local newTables = table.Copy(playerTables)
  local query = [[
                 SELECT COUNT(kill.id) AS count,
                 kill.attacker_id,
                 victim_roles.role_id as victim_role,
                 attacker_roles.role_id as attacker_role
                 FROM ]] .. self.tables.PlayerKill.tableName .. [[ AS kill
                 LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ AS victim_roles
                 ON kill.round_id == victim_roles.round_id
                 AND kill.victim_id == victim_roles.player_id
                 LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ AS attacker_roles
                 ON kill.round_id == attacker_roles.round_id
                 AND kill.attacker_id == attacker_roles.player_id
                 WHERE kill.victim_id != kill.attacker_id
      		       GROUP BY kill.attacker_id, victim_role, attacker_role
                ]]

   local rows = sql.Query(query)

   if (rows != nil) then
     for id, columns in pairs(rows) do
       local playerId = columns["attacker_id"]
       local playerRole = roleIdToRole[tonumber(columns["attacker_role"])]
       local victimRole = roleIdToRole[tonumber(columns["victim_role"])]
       local columnName = playerRole .. "_" .. victimRole .. "_kills"
       newTables[playerId][columnName] = newTables[playerId][columnName] + tonumber(columns["count"])
     end
  end

   return newTables
end

--[[
Gets all combat-based deaths and adds them to the in-memory table of recalculated rows.
PARAM playerTables:Table[Int -> Table[String -> Int] ] - A table of player ids containing a table of rows to be inserted to AggregateStats
RETURN A new playerTables that increments the selfrole_opponentrole_deaths columns by the number of combat deaths found.
]]
function aggregateStatsTable:getAllCombatDeathCounts(playerTables)
  local newTables = table.Copy(playerTables)

  local query = [[
                 SELECT COUNT(kill.id) AS count,
                 kill.victim_id,
                 victim_roles.role_id as victim_role,
                 attacker_roles.role_id as attacker_role
                 FROM ]] .. self.tables.PlayerKill.tableName .. [[ AS kill
                 LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ AS victim_roles
                 ON kill.round_id == victim_roles.round_id
                 AND kill.victim_id == victim_roles.player_id
                 LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ AS attacker_roles
                 ON kill.round_id == attacker_roles.round_id
                 AND kill.attacker_id == attacker_roles.player_id
                 WHERE kill.victim_id != kill.attacker_id
      		       GROUP BY kill.victim_id, victim_role, attacker_role
                ]]

  local rows = sql.Query(query)

  if (rows != nil) then
    for id, columns in pairs(rows) do
      local playerId = columns["victim_id"]
      local playerRole = roleIdToRole[tonumber(columns["victim_role"])]
      local attackerRole = roleIdToRole[tonumber(columns["attacker_role"])]
      local columnName = playerRole .. "_" .. attackerRole .. "_deaths"
      newTables[playerId][columnName] = newTables[playerId][columnName] + tonumber(columns["count"])
    end
  end

  return newTables
end


function aggregateStatsTable:getAllSuicides(playerTables)
  local newTables = table.Copy(playerTables)

  local query = [[
                 SELECT COUNT(kill.id) AS count,
                 kill.victim_id,
                 victim_roles.role_id as victim_role
                 FROM ]] .. self.tables.PlayerKill.tableName .. [[ AS kill
                 LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ AS victim_roles
                 ON kill.round_id == victim_roles.round_id
                 AND kill.victim_id == victim_roles.player_id
                 LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ AS attacker_roles
                 ON kill.round_id == attacker_roles.round_id
                 AND kill.attacker_id == attacker_roles.player_id
                 WHERE kill.victim_id == kill.attacker_id
      		       GROUP BY kill.victim_id, victim_role
                ]]

  local rows = sql.Query(query)

  if (rows != nil) then
    for id, columns in pairs(rows) do
      local playerId = columns["victim_id"]
      local playerRole = roleIdToRole[tonumber(columns["victim_role"])]
      local columnName = playerRole .. "_suicides"
      newTables[playerId][columnName] = newTables[playerId][columnName] + tonumber(columns["count"])
    end
  end

  return newTables
end


function aggregateStatsTable:getRoundsPlayed(playerTables)
  local newTables = table.Copy(playerTables)
  local query = [[
                SELECT roundroles.player_id,
                roundroles.role_id,
                COUNT(*) AS count
                FROM ]] .. self.tables.RoundRoles.tableName .. [[ AS roundroles
                GROUP BY roundroles.player_id, roundroles.role_id
                ]]

   local rows = sql.Query(query)

   if (rows != nil) then
     for id, columns in pairs(rows) do
       local playerId = columns["player_id"]
       local roleId = tonumber(columns["role_id"])
       local role = roleIdToRole[roleId]
       local numResults = tonumber(columns["count"])

       local columnName = role .. "_rounds"
       newTables[playerId][columnName] = newTables[playerId][columnName] + tonumber(columns["count"])
     end
  end

   return newTables
end


function aggregateStatsTable:getRoundsWonAndLost(playerTables)
  local function isWin(roleId, result)
    if roleId == 1 then --traitor
      return result == 2
    else
      return result > 2
    end
  end

  local newTables = table.Copy(playerTables)
  local query = [[
                SELECT roundroles.player_id,
                roundroles.role_id,
                roundresults.`result`,
                COUNT(*) AS count
                FROM ]] .. self.tables.RoundResult.tableName .. [[ AS roundresults
                LEFT JOIN ]] .. self.tables.RoundRoles.tableName  .. [[ AS roundroles
                ON roundresults.round_id == roundroles.round_id
                GROUP BY roundroles.player_id, roundroles.role_id, roundresults.`result`
                ]]

   local rows = sql.Query(query)

   if (rows != nil) then
     for id, columns in pairs(rows) do
       local playerId = columns["player_id"]
       local roleId = tonumber(columns["role_id"])
       local role = roleIdToRole[roleId]
       local result = tonumber(columns["result"])
       local numResults = tonumber(columns["count"])
       local suffix
       if (isWin(roleId, result)) then
         suffix = "rounds_won"
       else
         suffix = "rounds_lost"
       end

       local columnName = role .. "_" .. suffix
       newTables[playerId][columnName] = newTables[playerId][columnName] + tonumber(columns["count"])
     end
  end

   return newTables
end


function aggregateStatsTable:runKillCountQuery(whereStatement)
  local query = [[SELECT COUNT(*) AS count
           FROM ]] .. self.tables.PlayerKill.tableName .. [[ AS kill
           LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ AS victim_roles
           ON kill.round_id == victim_roles.round_id
           AND kill.victim_id == victim_roles.player_id
           LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ AS attacker_roles
           ON kill.round_id == attacker_roles.round_id
           AND kill.attacker_id == attacker_roles.player_id ]] .. whereStatement
  local result = sql.Query(query)
  return countResult(result)
end

function aggregateStatsTable:calculateRoleKills(playerId, playerRole, victimRole)
  local whereStatement = [[WHERE kill.attacker_id == ]] .. tostring(playerId) .. [[
                           AND kill.victim_id != ]] .. tostring(playerId) .. [[
                           AND attacker_roles.role_id == ]] .. tostring(playerRole) .. [[
                           AND victim_roles.role_id == ]] .. tostring(victimRole)
  return self:runKillCountQuery(whereStatement)
end

function aggregateStatsTable:calculateRoleDeaths(playerId, playerRole, attackerRole)
  local whereStatement = [[WHERE kill.victim_id == ]] .. tostring(playerId) .. [[
                           AND attacker_roles.role_id == ]] .. tostring(attackerRole) .. [[
                           AND victim_roles.role_id == ]] .. tostring(playerRole)
  return self:runKillCountQuery(whereStatement)
end

function aggregateStatsTable:calculateRoleSuicides(playerId, playerRole)
  local whereStatement = [[WHERE kill.victim_id == ]] .. tostring(playerId) .. [[
                           AND kill.attacker_id == ]] .. tostring(playerId) .. [[
                           AND attacker_roles.role_id == ]] .. tostring(playerRole)
  return self:runKillCountQuery(whereStatement)
end

function aggregateStatsTable:calculateRoleWeaponKills(playerStatsLuaTable, playerRole, victimRole, weaponName)
  local playerId = playerStatsLuaTable.player_id
  local weaponId = self.tables.WeaponId:getWeaponId(weaponName)
  if (weaponId == -1) then return 0 end

  local whereStatement = [[WHERE kill.attacker_id == ]] .. tostring(playerId) .. [[
                  AND kill.victim_id != ]] .. tostring(playerId) .. [[
                  AND attacker_roles.role_id == ]] .. tostring(playerRole) .. [[
                  AND victim_roles.role_id == ]] .. tostring(victimRole) .. [[
                  AND kill.weapon_id == ]] .. tostring(weaponId)
  return self:runKillCountQuery(whereStatement)
end

function aggregateStatsTable:calculateRoleWeaponDeaths(playerStatsLuaTable, playerRole, attackerRole, weaponName)
  local playerId = playerStatsLuaTable.player_id
  local weaponId = self.tables.WeaponId:getWeaponId(weaponName)
  if (weaponId == -1) then return 0 end

  local whereStatement = [[WHERE kill.victim_id == ]] .. tostring(playerId) .. [[
                  AND attacker_roles.role_id == ]] .. tostring(attackerRole) .. [[
                  AND victim_roles.role_id == ]] .. tostring(playerRole) .. [[
                  AND kill.weapon_id == ]] .. tostring(weaponId)
  return self:runKillCountQuery(whereStatement)
end

function aggregateStatsTable:calculateWorldDeaths(playerId, roleId)
  local query = [[SELECT COUNT(*) AS count
           FROM ]] .. self.tables.WorldKill.tableName .. [[ AS kill
           LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ AS victim_roles
           ON kill.round_id == victim_roles.round_id
           AND kill.victim_id == victim_roles.player_id
           WHERE kill.victim_id == ]] .. tostring(playerId) .. [[
           AND victim_roles.role_id == ]] .. tostring(roleId)

  local result = sql.Query(query)
  return countResult(result)
end

function aggregateStatsTable:getDataForAllRoles(playerStatsLuaTable, suffix, func, args)
  for rolename, rolevalue in pairs(roleToRoleId) do
    for secondrolename, secondrolevalue in pairs(roleToRoleId) do
      local keyname = string.lower(rolename) .. "_" .. string.lower(secondrolename) .. "_" .. suffix
      if args and #args > 0 then
        playerStatsLuaTable[keyname] = func(self, playerStatsLuaTable, string.lower(rolevalue), string.lower(secondrolevalue), unpack(args))
      else
        playerStatsLuaTable[keyname] = func(self, playerStatsLuaTable, string.lower(rolevalue), string.lower(secondrolevalue))
      end
    end
  end
end

function aggregateStatsTable:calculateSelfHPHealed(playerStatsLuaTable)
  local playerId = playerStatsLuaTable.player_id
  playerStatsLuaTable["self_hp_healed"] = self.tables.Healing:getTotalHPYouHealed(playerId)
end
--[[
Recalculates a single player's stats.
--]]
function aggregateStatsTable:recalculateSinglePlayer(playerId)
  local playerStatsLuaTable = {}
  playerStatsLuaTable["player_id"] = playerId
  --self:getAllCombatKillsAndDeaths(playerStatsLuaTable)
  --self:getAllWorldDeaths(playerStatsLuaTable)
  --self:getSuicideData(playerStatsLuaTable)
  self:getDataForAllRoles(playerStatsLuaTable, "ttt_c4_kills", self.calculateRoleWeaponKills, {"ttt_c4"})
  self:getDataForAllRoles(playerStatsLuaTable, "ttt_c4_deaths", self.calculateRoleWeaponDeaths, {"ttt_c4"})
  --self:calculateRoleData(playerStatsLuaTable)
  --self:calculateRoleWins(playerStatsLuaTable)
  --self:calculateRoleLosses(playerStatsLuaTable)
  self:calculateSelfHPHealed(playerStatsLuaTable)
  return playerStatsLuaTable
end

function aggregateStatsTable:getAllWorldDeathCounts(newTables)
  local query = [[SELECT kill.victim_id, victim_roles.role_id, COUNT(*) AS count
                  FROM ]] .. self.tables.WorldKill.tableName .. [[ AS kill
                  LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ AS victim_roles
                  ON kill.round_id == victim_roles.round_id
                  AND kill.victim_id == victim_roles.player_id
                  GROUP BY kill.victim_id, victim_roles.role_id
                  ORDER BY kill.victim_id, victim_roles.role_id]]

  local result = self:query("aggregateStatsTable:getAllWorldDeathCounts", query)

  if (result != nil && result != 0) then
     for id, columns in pairs(result) do
       local role = roleIdToRole[tonumber(columns["role_id"])]
       local playerId = columns["victim_id"]
       local columnName = role .. "_world_deaths"
       newTables[playerId][columnName] = tonumber(columns["count"])
     end
  end

  return newTables
end

function aggregateStatsTable:getAllSelfHealing(newTables)
  local query = [[SELECT user_id, SUM(heal_amount) as total_hp_healed FROM ]] .. self.tables.Healing.tableName .. [[
                  GROUP BY user_id]]
  local result = self:query("aggregateStatsTable:getAllSelfHealing", query)

  if (result != nil && result != 0) then
     for id, columns in pairs(result) do
       local playerId = columns["user_id"]
       local columnName = "self_hp_healed"
       newTables[playerId][columnName] = tonumber(columns["total_hp_healed"])
     end
  end

  return newTables
end

function aggregateStatsTable:getAllOtherHealing(newTables)
  local query = [[SELECT deployer_id, SUM(heal_amount) as total_hp_healed FROM ]] .. self.tables.Healing.tableName .. [[
                  WHERE user_id != deployer_id
                  GROUP BY deployer_id]]
  local result = self:query("aggregateStatsTable:getAllSelfHealing", query)

  if (result != nil && result != 0) then
     for id, columns in pairs(result) do
       local playerId = columns["deployer_id"]
       local columnName = "others_hp_healed"
       newTables[playerId][columnName] = tonumber(columns["total_hp_healed"])
     end
  end

  return newTables
end

function aggregateStatsTable:recalculate()
  self:drop()
  self:create()
  local players = self.tables.PlayerId:getPlayerIdList()
  local playerTables = {}

  for rowId, playerId in pairs(players) do
    playerTables[playerId] = {}

    for columnName, columnSqlType in pairs(self.columns) do
      playerTables[playerId][columnName] = 0
    end

    playerTables[playerId]["player_id"] = playerId
  end

  playerTables = self:getAllCombatKillCounts(playerTables)
  playerTables = self:getAllCombatDeathCounts(playerTables)
  playerTables = self:getAllSuicides(playerTables)
  playerTables = self:getAllWorldDeathCounts(playerTables)
  playerTables = self:getRoundsPlayed(playerTables)
  playerTables = self:getRoundsWonAndLost(playerTables)
  playerTables = self:getAllSelfHealing(playerTables)
  playerTables = self:getAllOtherHealing(playerTables)

  for playerId, newRow in pairs(playerTables) do
    self:insertTable(newRow)
  end
end

--Adds a player known to have no stats.
function aggregateStatsTable:addPlayer(playerId)
  local newPlayerTable = {
    player_id = playerId
  }
  return self:insertTable(newPlayerTable)
end

function aggregateStatsTable:selectColumn(playerId, columnName)
  local query = "SELECT " .. columnName .. " FROM " .. self.tableName .. " WHERE player_id == " .. playerId
  local currentValue = self:query("aggregateCombatStatsTable:selectColumn", query, 1, columnName)
  return tonumber(currentValue)
end

function aggregateStatsTable:updateColumn(playerId, columnName, newValue)
  local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. newValue .. " WHERE player_id == " .. playerId
  return self:query("aggregateStatsTable:updateColumn", query)
end

--
-- Getters
--

function aggregateStatsTable:getRounds(playerId, playerRole)
  local columnName = roleIdToRole[playerRole] .. "_rounds"
  return self:selectColumn(playerId, columnName)
end

function aggregateStatsTable:getRoundsWon(playerId, playerRole)
  local columnName = roleIdToRole[playerRole] .. "_rounds_won"
  return self:selectColumn(playerId, columnName)
end

function aggregateStatsTable:getRoundsLost(playerId, playerRole)
  local columnName = roleIdToRole[playerRole] .. "_rounds_lost"
  return self:selectColumn(playerId, columnName)
end

function aggregateStatsTable:getKills(playerId, playerRole, victimRole)
  local columnName = roleIdToRole[playerRole] .. "_" .. roleIdToRole[victimRole] .. "_kills"
  return self:selectColumn(playerId, columnName)
end

function aggregateStatsTable:getDeaths(playerId, playerRole, attackerRole)
  local columnName = roleIdToRole[playerRole] .. "_" .. roleIdToRole[attackerRole] .. "_deaths"
  return self:selectColumn(playerId, columnName)
end

function aggregateStatsTable:getWeaponKills(playerId, playerRole, victimRole, weaponName)
  local columnName = roleIdToRole[playerRole] .. "_" .. roleIdToRole[victimRole] .. "_" .. weaponName .. "_kills"
  return self:selectColumn(playerId, columnName)
end

function aggregateStatsTable:getWeaponDeaths(playerId, playerRole, attackerRole, weaponName)
  local columnName = roleIdToRole[playerRole] .. "_" .. roleIdToRole[attackerRole] .. "_" .. weaponName .. "_deaths"
  return self:selectColumn(playerId, columnName)
end

function aggregateStatsTable:getSuicides(playerId, playerRole)
  local columnName = roleIdToRole[playerRole] .. "_suicides"
  return self:selectColumn(playerId, columnName)
end

function aggregateStatsTable:getWorldDeaths(playerId, playerRole)
  local columnName = roleIdToRole[playerRole] .. "_world_deaths"
  return self:selectColumn(playerId, columnName)
end

function aggregateStatsTable:getSelfHPHealed(playerId)
  return self:selectColumn(playerId, "self_hp_healed")
end

function aggregateStatsTable:getOthersHPHealed(playerId)
  return self:selectColumn(playerId, "others_hp_healed")
end

function aggregateStatsTable:incrementRounds(playerId, playerRole)
  local rounds = self:getRounds(playerId, playerRole) + 1
  local columnName = roleIdToRole[playerRole] .. "_rounds"
  return self:updateColumn(playerId, columnName, rounds)
end

function aggregateStatsTable:getPlayerStats(playerId)
  local query = "SELECT * from " .. self.tableName .. " WHERE player_id == " .. playerId
  return self:query("aggregateStatsTable:getPlayerStats", query, 1)
end

--
-- Incrementers
--

function aggregateStatsTable:incrementRoundsWon(playerId, playerRole)
  local rounds = self:getRoundsWon(playerId, playerRole) + 1
  local columnName = roleIdToRole[playerRole] .. "_rounds_won"
  return self:updateColumn(playerId, columnName, rounds)
end

function aggregateStatsTable:incrementRoundsLost(playerId, playerRole)
  local rounds = self:getRoundsLost(playerId, playerRole) + 1
  local columnName = roleIdToRole[playerRole] .. "_rounds_lost"
  return self:updateColumn(playerId, columnName, rounds)
end

function aggregateStatsTable:incrementKills(playerId, playerRole, victimRole)
  local kills = self:getKills(playerId, playerRole, victimRole) + 1
  local columnName = roleIdToRole[playerRole] .. "_" .. roleIdToRole[victimRole] .. "_kills"
  return self:updateColumn(playerId, columnName, kills)
end

function aggregateStatsTable:incrementDeaths(playerId, playerRole, attackerRole)
  local deaths = self:getDeaths(playerId, playerRole, attackerRole) + 1
  local columnName = roleIdToRole[playerRole] .. "_" .. roleIdToRole[attackerRole] .. "_deaths"
  return self:updateColumn(playerId, columnName, deaths)
end

function aggregateStatsTable:incrementWeaponKills(playerId, playerRole, victimRole, weaponName)
  local kills = self:getWeaponKills(playerId, playerRole, victimRole, weaponName) + 1
  local columnName = roleIdToRole[playerRole] .. "_" .. roleIdToRole[victimRole] .. "_" .. weaponName .. "_kills"
  return self:updateColumn(playerId, columnName, kills)
end

function aggregateStatsTable:incrementWeaponDeaths(playerId, playerRole, victimRole, weaponName)
  local deaths = self:getWeaponDeaths(playerId, playerRole, victimRole, weaponName) + 1
  local columnName = roleIdToRole[playerRole] .. "_" .. roleIdToRole[victimRole] .. "_" .. weaponName .. "_deaths"
  return self:updateColumn(playerId, columnName, deaths)
end

function aggregateStatsTable:incrementSuicides(playerId, playerRole)
  local suicides = self:getSuicides(playerId, playerRole) + 1
  local columnName = roleIdToRole[playerRole] .. "_suicides"
  return self:updateColumn(playerId, columnName, suicides)
end

function aggregateStatsTable:incrementWorldDeaths(playerId, playerRole)
  local deaths = self:getWorldDeaths(playerId, playerRole) + 1
  local columnName = roleIdToRole[playerRole] .. "_world_deaths"
  return self:updateColumn(playerId, columnName, deaths)
end

function aggregateStatsTable:incrementSelfHPHealed(playerId)
  local hpHealed = self:getSelfHPHealed(playerId) + 1
  local columnName = "self_hp_healed"
  return self:updateColumn(playerId, columnName, hpHealed)
end

function aggregateStatsTable:incrementOthersHPHealed(playerId)
  local hpHealed = self:getOthersHPHealed(playerId) + 1
  local columnName = "others_hp_healed"
  return self:updateColumn(playerId, columnName, hpHealed)
end


DDD.Database.Tables.AggregateStats = aggregateStatsTable
aggregateStatsTable:create()
