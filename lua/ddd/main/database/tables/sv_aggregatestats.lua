local roleIdToRole = {} -- The reverse of the main roles table, this is roleValue -> roleName instead.
roleIdToRole[0] = "innocent"
roleIdToRole[1] = "traitor"
roleIdToRole[2] = "detective"

local roleToRoleId = DDD.Database.Roles

local lightBlue = Color(0, 255, 255, 255)
local red = Color(255, 0, 0, 255)

local tables = DDD.Database.Tables
local itemColumnSuffix = {}

itemColumnSuffix["1"] = "armor_purchases"
itemColumnSuffix["2"] = "radar_purchases"
itemColumnSuffix["4"] = "disguiser_purchases"
itemColumnSuffix["weapon_ttt_flaregun"] = "flaregun_purchases"
itemColumnSuffix["weapon_ttt_knife"] = "knife_purchases"
itemColumnSuffix["weapon_ttt_teleport"] = "teleporter_purchases"
itemColumnSuffix["weapon_ttt_radio"] = "radio_purchases"
itemColumnSuffix["weapon_ttt_push"] = "newtonlauncher_purchases"
itemColumnSuffix["weapon_ttt_sipistol"] = "silentpistol_purchases"
itemColumnSuffix["weapon_ttt_decoy"] = "decoy_purchases"
itemColumnSuffix["weapon_ttt_phammer"] = "poltergeist_purchases"
itemColumnSuffix["weapon_ttt_c4"] = "c4_purchases"
itemColumnSuffix["weapon_ttt_cse"] = "visualizer_purchases"
itemColumnSuffix["weapon_ttt_defuser"] = "defuser_purchases"
itemColumnSuffix["weapon_ttt_binoculars"] = "binoculars_purchases"
itemColumnSuffix["weapon_ttt_stungun"] = "ump_purchases"
itemColumnSuffix["weapon_ttt_health_station"] = "healthstation_purchases"

--All kills/deaths are in the format of <thisplayerrole>_<opponentrole>_<kills/deaths>
local columns = { player_id = "INTEGER PRIMARY KEY",

                  innocent_rounds = "INTEGER NOT NULL DEFAULT 0",
                  detective_rounds = "INTEGER NOT NULL DEFAULT 0",
                  traitor_rounds = "INTEGER NOT NULL DEFAULT 0",

                  innocent_rounds_won = "INTEGER NOT NULL DEFAULT 0",
                  detective_rounds_won = "INTEGER NOT NULL DEFAULT 0",
                  traitor_rounds_won = "INTEGER NOT NULL DEFAULT 0",

                  innocent_rounds_lost = "INTEGER NOT NULL DEFAULT 0",
                  detective_rounds_lost = "INTEGER NOT NULL DEFAULT 0",
                  traitor_rounds_lost = "INTEGER NOT NULL DEFAULT 0",

                  innocent_suicides = "INTEGER NOT NULL DEFAULT 0",
                  traitor_suicides = "INTEGER NOT NULL DEFAULT 0",
                  detective_suicides = "INTEGER NOT NULL DEFAULT 0",

                  innocent_world_deaths = "INTEGER NOT NULL DEFAULT 0",
                  traitor_world_deaths = "INTEGER NOT NULL DEFAULT 0",
                  detective_world_deaths = "INTEGER NOT NULL DEFAULT 0",

                  traitor_armor_purchases = "INTEGER NOT NULL DEFAULT 0",
                  traitor_radar_purchases = "INTEGER NOT NULL DEFAULT 0",
                  traitor_disguiser_purchases = "INTEGER NOT NULL DEFAULT 0",
                  traitor_flaregun_purchases = "INTEGER NOT NULL DEFAULT 0",
                  traitor_knife_purchases = "INTEGER NOT NULL DEFAULT 0",
                  traitor_teleporter_purchases = "INTEGER NOT NULL DEFAULT 0",
                  traitor_radio_purchases = "INTEGER NOT NULL DEFAULT 0",
                  traitor_newtonlauncher_purchases = "INTEGER NOT NULL DEFAULT 0",
                  traitor_silentpistol_purchases = "INTEGER NOT NULL DEFAULT 0",
                  traitor_decoy_purchases = "INTEGER NOT NULL DEFAULT 0",
                  traitor_poltergeist_purchases = "INTEGER NOT NULL DEFAULT 0",
                  traitor_c4_purchases = "INTEGER NOT NULL DEFAULT 0",

                  detective_radar_purchases = "INTEGER NOT NULL DEFAULT 0",
                  detective_visualizer_purchases = "INTEGER NOT NULL DEFAULT 0",
                  detective_defuser_purchases = "INTEGER NOT NULL DEFAULT 0",
                  detective_teleporter_purchases = "INTEGER NOT NULL DEFAULT 0",
                  detective_binoculars_purchases = "INTEGER NOT NULL DEFAULT 0",
                  detective_ump_purchases = "INTEGER NOT NULL DEFAULT 0",
                  detective_healthstation_purchases = "INTEGER NOT NULL DEFAULT 0",

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

createColumnsForAllRoleCombinations("kills")
createColumnsForAllRoleCombinations("deaths")
createColumnsForAllRoleCombinations("ttt_c4_kills")
createColumnsForAllRoleCombinations("ttt_c4_deaths")

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

function aggregateStatsTable:deleteBadRows(badRows, tableName)
  for key, value in pairs(badRows) do
    local deleteQuery = "DELETE FROM " .. tableName .. " WHERE id == " .. value["id"]
    sql.Query(deleteQuery)
  end
end

function aggregateStatsTable:cleanupAll()
  --Finish this later, but basically it cleans up everything that needs to be cleaned up
  --by passing in the player_id name from that particular table.
  local t = self.tables

  local cleanableTables = {}
  cleanableTables["player_id"] = {t.Purchases, t.ShotsFired, t.RadioCommandUsed}
  cleanableTables["victim_id"] = {t.CombatDamage, t.PlayerKill, t.WorldKill, t.WorldDamage, t.PlayerPushKill}
  cleanableTables["attacker_id"] = {t.CombatDamage, t.PlayerKill, t.PlayerPushKill}
  cleanableTables["finder_id"] = {t.CorpseIdentified, t.Dna}
  cleanableTables["corpse_owner_id"] = {t.CorpseIdentified}
  cleanableTables["dna_owner_id"] = {t.Dna}
  cleanableTables["deployer_id"] = {t.Healing}
  cleanableTables["user_id"] = {t.Healing}

  for columnName, tableToClean in pairs(cleanableTables) do
    print(tableToClean.tableName)
    local selectQuery = [[
             SELECT t.id,
             t.round_id,
             t.]] .. columnName .. [[,
             player_role.role_id as player_role
             FROM ]] .. tableToClean.tableName .. [[ AS t
             LEFT JOIN ]] .. t.RoundRoles.tableName .. [[ AS player_role
             ON t.round_id == player_role.round_id
             AND t.]] .. columnName .. [[ == player_role.player_id
             WHERE (player_role is null)
         ]]

    local badRows = sql.Query(selectQuery)

    self:deleteBadRows(badRows, tableToClean.tableName)
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

function aggregateStatsTable:makeWorldDeathCountQuery(playerId, playerRole)
  return [[SELECT COUNT(*) AS count
           FROM ]] .. self.tables.WorldKill.tableName .. [[ AS kill
           LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ AS victim_roles
           ON kill.round_id == victim_roles.round_id
           AND kill.victim_id == victim_roles.player_id
           WHERE kill.victim_id == ]] .. tostring(playerId) .. [[
           AND victim_roles.role_id == ]] .. tostring(playerRole)
end

function aggregateStatsTable:calculateWorldDeaths(playerId, playerRole)
  local query = self:makeWorldDeathCountQuery(playerId, playerRole)
  local result = sql.Query(query)
  return countResult(result)
end

function aggregateStatsTable:getAllCombatKillsAndDeaths(playerStatsLuaTable)
  local playerId = playerStatsLuaTable.player_id

  for playerRole, playerRoleName in pairs(roleIdToRole) do
    for opponentRole, opponentRoleName in pairs(roleIdToRole) do
      local killColumnName = playerRoleName .. "_" .. opponentRoleName .. "_kills"
      local deathColumnName = playerRoleName .. "_" .. opponentRoleName .. "_deaths"
      playerStatsLuaTable[killColumnName] = self:calculateRoleKills(playerId, playerRole, opponentRole)
      playerStatsLuaTable[deathColumnName] = self:calculateRoleDeaths(playerId, playerRole, opponentRole)
    end
  end

  return self
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

function aggregateStatsTable:getAllWorldDeaths(playerStatsLuaTable)
  local playerId = playerStatsLuaTable.player_id

  for playerRole, playerRoleName in pairs(roleIdToRole) do
    local deathColumnName = playerRoleName .. "_world_deaths"
    playerStatsLuaTable[deathColumnName] = self:calculateWorldDeaths(playerId, playerRole)
  end

  return self
end

function aggregateStatsTable:getPurchasesAsRole(playerId, itemName, roleId)
  local itemId = self.tables.ShopItem:getItemId(itemName)
  if (itemId > 0) then
    local query =
    "SELECT COUNT(*) AS count FROM " .. self.tables.Purchases.tableName .. " as purchases " ..
    "LEFT JOIN " .. self.tables.RoundRoles.tableName .. " as roles " ..
    "ON purchases.round_id == roles.round_id " ..
    "WHERE purchases.player_id == " .. playerId .. " AND purchases.shop_item_id == " .. itemId .. " AND roles.role_id == " .. roleId
    return DDD.SqlTable:query("purchasesTable:getPurchases", query, 1, "count")
  else
    return 0
  end
end

function aggregateStatsTable:getSuicideData(playerStatsLuaTable)
  local playerId = playerStatsLuaTable.player_id
  playerStatsLuaTable["innocent_suicides"] = self:calculateRoleSuicides(playerId, 0)
  playerStatsLuaTable["traitor_suicides"] = self:calculateRoleSuicides(playerId, 1)
  playerStatsLuaTable["detective_suicides"] = self:calculateRoleSuicides(playerId, 2)
end

-- TODO: Finish this and make the cleanup for purchases
function aggregateStatsTable:getAllPurchases(playerStatsLuaTable)
    local query = [[SELECT COUNT(purchases.shop_item_id) AS count, roles.player_id, roles.role_id, items.name
                    FROM ]] .. self.tables.Purchases.tableName .. [[ as purchases
                    LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ as roles
                    ON purchases.round_id == roles.round_id
                    AND purchases.player_id == roles.player_id
                    LEFT JOIN ddd_shop_item as items
                	  ON purchases.shop_item_id == items.id
                	  GROUP BY purchases.shop_item_id, purchases.player_id, roles.role_id
                  ]]
end

function aggregateStatsTable:getPurchases(playerStatsLuaTable)
  local playerId = playerStatsLuaTable.player_id

  playerStatsLuaTable["traitor_armor_purchases"] = self:getPurchasesAsRole(playerId, "1", roleToRoleId["Traitor"])
  playerStatsLuaTable["traitor_radar_purchases"] = self:getPurchasesAsRole(playerId, "2",  roleToRoleId["Traitor"])
  playerStatsLuaTable["traitor_disguiser_purchases"] = self:getPurchasesAsRole(playerId, "4",  roleToRoleId["Traitor"])
  playerStatsLuaTable["traitor_flaregun_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_flaregun",  roleToRoleId["Traitor"])
  playerStatsLuaTable["traitor_knife_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_knife",  roleToRoleId["Traitor"])
  playerStatsLuaTable["traitor_teleporter_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_teleport",  roleToRoleId["Traitor"])
  playerStatsLuaTable["traitor_radio_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_radio",  roleToRoleId["Traitor"])
  playerStatsLuaTable["traitor_newtonlauncher_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_push",  roleToRoleId["Traitor"])
  playerStatsLuaTable["traitor_silentpistol_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_sipistol",  roleToRoleId["Traitor"])
  playerStatsLuaTable["traitor_decoy_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_decoy",  roleToRoleId["Traitor"])
  playerStatsLuaTable["traitor_poltergeist_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_phammer",  roleToRoleId["Traitor"])
  playerStatsLuaTable["traitor_c4_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_c4",  roleToRoleId["Traitor"])

  playerStatsLuaTable["detective_radar_purchases"] = self:getPurchasesAsRole(playerId, "2",  roleToRoleId["Detective"])
  playerStatsLuaTable["detective_visualizer_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_cse",  roleToRoleId["Detective"])
  playerStatsLuaTable["detective_defuser_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_defuser",  roleToRoleId["Detective"])
  playerStatsLuaTable["detective_teleporter_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_teleport",  roleToRoleId["Detective"])
  playerStatsLuaTable["detective_binoculars_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_binoculars",  roleToRoleId["Detective"])
  playerStatsLuaTable["detective_ump_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_stungun",  roleToRoleId["Detective"])
  playerStatsLuaTable["detective_healthstation_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_health_station",  roleToRoleId["Detective"])
end

function aggregateStatsTable:calculateSelfHPHealed(playerStatsLuaTable)
  local playerId = playerStatsLuaTable.player_id
  playerStatsLuaTable["self_hp_healed"] = self.tables.Healing:getTotalHPYouHealed(playerId)
end

function aggregateStatsTable:calculateRoleData(playerStatsLuaTable)
  local playerId = playerStatsLuaTable.player_id

  for rolename, rolevalue in pairs(roleToRoleId) do
    local keyname = rolename .. "_rounds"
    playerStatsLuaTable[keyname] = self.tables.RoundRoles:getRoundsAsRole(playerId, rolevalue)
  end
end

function aggregateStatsTable:getRoleWins(playerId, roleId)
  local expectedResult = ""

  if roleId == 1 then --traitor
    expectedResult = "== 2"
  else
    expectedResult = "> 2"
  end

  local query = [[SELECT COUNT(*) AS count FROM ]] .. self.tables.RoundResult.tableName .. [[ AS roundresults
                  LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ as roundroles ON roundresults.round_id == roundroles.round_id
                  WHERE player_id == ]] .. playerId .. [[ and role_id == ]] .. roleId .. [[ and `result` ]] .. expectedResult
  local result = sql.Query(query)
  return countResult(result)
end

function aggregateStatsTable:calculateRoleWins(playerStatsLuaTable)
  local playerId = playerStatsLuaTable.player_id

  for rolename, rolevalue in pairs(roleToRoleId) do
    local keyname = rolename .. "_rounds_won"
    playerStatsLuaTable[keyname] = self:getRoleWins(playerId, rolevalue)
  end
end

function aggregateStatsTable:getRoleLosses(playerId, roleId)
  local expectedResult = ""

  if roleId == 1 then
    expectedResult = "> 2"
  else
    expectedResult = "== 2"
  end

  local query = [[SELECT COUNT(*) AS count FROM ]] .. self.tables.RoundResult.tableName .. [[ AS roundresults
                  LEFT JOIN ]] .. self.tables.RoundRoles.tableName .. [[ as roundroles ON roundresults.round_id == roundroles.round_id
                  WHERE player_id == ]] .. playerId .. [[ and role_id == ]] .. roleId .. [[ and `result` ]] .. expectedResult
  local result = sql.Query(query)
  return countResult(result)
end

function aggregateStatsTable:calculateRoleLosses(playerStatsLuaTable)
  local playerId = playerStatsLuaTable.player_id

  for rolename, rolevalue in pairs(roleToRoleId) do
    local keyname = rolename .. "_rounds_lost"
    playerStatsLuaTable[keyname] = self:getRoleLosses(playerId, rolevalue)
  end
end

--[[
Recalculates a single player's stats.
--]]
function aggregateStatsTable:recalculateSinglePlayer(playerId)
  local playerStatsLuaTable = {}
  playerStatsLuaTable["player_id"] = playerId
  self:getAllCombatKillsAndDeaths(playerStatsLuaTable)
  self:getAllWorldDeaths(playerStatsLuaTable)
  self:getPurchases(playerStatsLuaTable)
  self:getSuicideData(playerStatsLuaTable)
  self:getDataForAllRoles(playerStatsLuaTable, "ttt_c4_kills", self.calculateRoleWeaponKills, {"ttt_c4"})
  self:getDataForAllRoles(playerStatsLuaTable, "ttt_c4_deaths", self.calculateRoleWeaponDeaths, {"ttt_c4"})
  self:calculateRoleData(playerStatsLuaTable)
  self:calculateRoleWins(playerStatsLuaTable)
  self:calculateRoleLosses(playerStatsLuaTable)
  self:calculateSelfHPHealed(playerStatsLuaTable)
  return playerStatsLuaTable
end

--[[
Destroys and re-creates the entire table, running queries to find every statistic.
]]
--[[
function aggregateStatsTable:recalculate()
  self:drop()
  self:create()
  local players = self.tables.PlayerId:getPlayerIdList()

  for rowId, playerId in pairs(players) do
    local playerStatsLuaTable = self:recalculateSinglePlayer(playerId)
    self:insertTable(playerStatsLuaTable)
  end
end
]]

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

function aggregateStatsTable:getItemPurchases(playerId, playerRole, item)
  local columnName = roleIdToRole[playerRole] .. "_" .. itemColumnSuffix[tostring(item)]
  return self:selectColumn(playerId, columnName)
end

function aggregateStatsTable:getSelfHPHealed(playerId)
  return self:selectColumn(playerId, "self_hp_healed")
end

function aggregateStatsTable:incrementRounds(playerId, playerRole)
  local rounds = self:getRounds(playerId, playerRole) + 1
  local columnName = roleIdToRole[playerRole] .. "_rounds"
  return self:updateColumn(playerId, columnName, rounds)
end

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

function aggregateStatsTable:incrementItemPurchases(playerId, playerRole, item)
  local purchases = self:getItemPurchases(playerId, playerRole, item) + 1
  local columnName = roleIdToRole[playerRole] .. "_" .. itemColumnSuffix[tostring(item)]
  return self:updateColumn(playerId, columnName, purchases)
end

function aggregateStatsTable:incrementSelfHPHealed(playerId)
  local hpHealed = self:getSelfHPHealed(playerId) + 1
  local columnName = "self_hp_healed"
  return self:updateColumn(playerId, columnName, hpHealed)
end

function aggregateStatsTable:getPlayerStats(playerId)
  local query = "SELECT * from " .. self.tableName .. " WHERE player_id == " .. playerId
  return self:query("aggregateStatsTable:getPlayerStats", query, 1)
end

DDD.Database.Tables.AggregateStats = aggregateStatsTable
aggregateStatsTable:create()
