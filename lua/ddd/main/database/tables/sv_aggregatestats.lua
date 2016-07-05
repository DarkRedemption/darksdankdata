local roles = {} -- The reverse of the main roles table, this is roleValue -> roleName instead.
roles[0] = "innocent"
roles[1] = "traitor"
roles[2] = "detective" 

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
                  detective_healthstation_purchases = "INTEGER NOT NULL DEFAULT 0"
                }
                
local function createColumnsForAllRoleCombinations(suffix)
  for rolename, rolevalue in pairs(DDD.Database.Roles) do
    for secondrolename, secondrolevalue in pairs(DDD.Database.Roles) do
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

function aggregateStatsTable:calculateRoleWeaponKills(playerId, playerRole, victimRole, weaponId)
  local whereStatement = [[WHERE kill.attacker_id == ]] .. tostring(playerId) .. [[
                  AND kill.victim_id != ]] .. tostring(playerId) .. [[
                  AND attacker_roles.role_id == ]] .. tostring(playerRole) .. [[
                  AND victim_roles.role_id == ]] .. tostring(victimRole) .. [[
                  AND kill.weapon_id == ]] .. tostring(weaponId)
  return self:runKillCountQuery(whereStatement)
end

function aggregateStatsTable:calculateRoleWeaponDeaths(playerId, playerRole, attackerRole, weaponId)
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
  
  for playerRole, playerRoleName in pairs(roles) do
    for opponentRole, opponentRoleName in pairs(roles) do
      local killColumnName = playerRoleName .. "_" .. opponentRoleName .. "_kills"
      local deathColumnName = playerRoleName .. "_" .. opponentRoleName .. "_deaths"
      playerStatsLuaTable[killColumnName] = self:calculateRoleKills(playerId, playerRole, opponentRole)
      playerStatsLuaTable[deathColumnName] = self:calculateRoleDeaths(playerId, playerRole, opponentRole)
    end
  end
  
  return self
end

function aggregateStatsTable:getWeaponKillsAsRole(playerStatsLuaTable, roleId, victimRoleId, weaponName)
  local weaponId = self.tables.WeaponId:getWeaponId(weaponName)
  if (weaponId == -1) then return 0 end
  return self:calculateRoleWeaponKills(playerStatsLuaTable.player_id, roleId, victimRoleId, weaponId)
end

function aggregateStatsTable:getWeaponDeathsAsRole(playerStatsLuaTable, roleId, attackerRoleId, weaponName)
  local weaponId = self.tables.WeaponId:getWeaponId(weaponName)
  if (weaponId == -1) then return 0 end
  return self:calculateRoleWeaponDeaths(playerStatsLuaTable.player_id, roleId, attackerRoleId, weaponId)
end

function aggregateStatsTable:getDataForAllRoles(playerStatsLuaTable, suffix, func, args)
  for rolename, rolevalue in pairs(DDD.Database.Roles) do
    for secondrolename, secondrolevalue in pairs(DDD.Database.Roles) do
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
  
  for playerRole, playerRoleName in pairs(roles) do
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

function aggregateStatsTable:getPurchases(playerStatsLuaTable)
  local playerId = playerStatsLuaTable.player_id
  
  playerStatsLuaTable["traitor_armor_purchases"] = self:getPurchasesAsRole(playerId, "1", DDD.Database.Roles["Traitor"])
  playerStatsLuaTable["traitor_radar_purchases"] = self:getPurchasesAsRole(playerId, "2",  DDD.Database.Roles["Traitor"])
  playerStatsLuaTable["traitor_disguiser_purchases"] = self:getPurchasesAsRole(playerId, "4",  DDD.Database.Roles["Traitor"])
  playerStatsLuaTable["traitor_flaregun_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_flaregun",  DDD.Database.Roles["Traitor"])
  playerStatsLuaTable["traitor_knife_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_knife",  DDD.Database.Roles["Traitor"])
  playerStatsLuaTable["traitor_teleporter_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_teleport",  DDD.Database.Roles["Traitor"])
  playerStatsLuaTable["traitor_radio_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_radio",  DDD.Database.Roles["Traitor"])
  playerStatsLuaTable["traitor_newtonlauncher_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_push",  DDD.Database.Roles["Traitor"])
  playerStatsLuaTable["traitor_silentpistol_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_sipistol",  DDD.Database.Roles["Traitor"])
  playerStatsLuaTable["traitor_decoy_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_decoy",  DDD.Database.Roles["Traitor"])
  playerStatsLuaTable["traitor_poltergeist_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_phammer",  DDD.Database.Roles["Traitor"])
  playerStatsLuaTable["traitor_c4_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_c4",  DDD.Database.Roles["Traitor"])
  
  playerStatsLuaTable["detective_radar_purchases"] = self:getPurchasesAsRole(playerId, "2",  DDD.Database.Roles["Detective"])
  playerStatsLuaTable["detective_visualizer_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_cse",  DDD.Database.Roles["Detective"])
  playerStatsLuaTable["detective_defuser_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_defuser",  DDD.Database.Roles["Detective"])
  playerStatsLuaTable["detective_teleporter_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_teleport",  DDD.Database.Roles["Detective"])
  playerStatsLuaTable["detective_binoculars_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_binoculars",  DDD.Database.Roles["Detective"])
  playerStatsLuaTable["detective_ump_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_stungun",  DDD.Database.Roles["Detective"])
  playerStatsLuaTable["detective_healthstation_purchases"] = self:getPurchasesAsRole(playerId, "weapon_ttt_health_station",  DDD.Database.Roles["Detective"])
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
  self:getDataForAllRoles(playerStatsLuaTable, "ttt_c4_kills", self.getWeaponKillsAsRole, {"ttt_c4"})
  self:getDataForAllRoles(playerStatsLuaTable, "ttt_c4_deaths", self.getWeaponDeathsAsRole, {"ttt_c4"})
  return playerStatsLuaTable
end

--[[
Destroys and re-creates the entire table, running queries to find every statistic.
]]
function aggregateStatsTable:recalculate()
  self:drop()
  self:create()
  local players = self.tables.PlayerId:getPlayerIdList()
  
  for rowId, playerId in pairs(players) do
    local playerStatsLuaTable = self:recalculateSinglePlayer(playerId)
    self:insertTable(playerStatsLuaTable)
  end
end

--Adds a player known to have no stats.
function aggregateStatsTable:addPlayer(playerId)
  local newPlayerTable = {
    player_id = playerId
  }
  return self:insertTable(newPlayerTable)
end

function aggregateStatsTable:getKills(playerId, playerRole, victimRole)
  local columnName = roles[playerRole] .. "_" .. roles[victimRole] .. "_kills"
  local selectKillsQuery = "SELECT " .. columnName .. " FROM " .. self.tableName .. " WHERE player_id == " .. playerId
  local currentKills = self:query("aggregateCombatStatsTable:getKills", selectKillsQuery, 1, columnName)
  return tonumber(currentKills)
end

function aggregateStatsTable:getDeaths(playerId, playerRole, attackerRole)
  local columnName = roles[playerRole] .. "_" .. roles[attackerRole] .. "_deaths"
  local selectDeathsQuery = "SELECT " .. columnName .. " FROM " .. self.tableName .. " WHERE player_id == " .. playerId
  local currentDeaths = self:query("aggregateCombatStatsTable:getDeaths", selectDeathsQuery, 1, columnName)
  return tonumber(currentDeaths)
end

function aggregateStatsTable:getWeaponKills(playerId, playerRole, victimRole, weaponName)
  local columnName = roles[playerRole] .. "_" .. roles[victimRole] .. "_" .. weaponName .. "_kills"
  local selectKillsQuery = "SELECT " .. columnName .. " FROM " .. self.tableName .. " WHERE player_id == " .. playerId
  local currentKills = self:query("aggregateCombatStatsTable:getWeaponKills", selectKillsQuery, 1, columnName)
  return tonumber(currentKills)
end

function aggregateStatsTable:getWeaponDeaths(playerId, playerRole, attackerRole, weaponName)
  local columnName = roles[playerRole] .. "_" .. roles[attackerRole] .. "_" .. weaponName .. "_deaths"
  local selectDeathsQuery = "SELECT " .. columnName .. " FROM " .. self.tableName .. " WHERE player_id == " .. playerId
  local currentDeaths = self:query("aggregateCombatStatsTable:getWeaponDeaths", selectDeathsQuery, 1, columnName)
  return tonumber(currentDeaths)
end

function aggregateStatsTable:getSuicides(playerId, playerRole)
  local columnName = roles[playerRole] .. "_suicides"
  local selectSuicidesQuery = "SELECT " .. columnName .. " FROM " .. self.tableName .. " WHERE player_id == " .. playerId
  local currentSuicides = self:query("aggregateCombatStatsTable:getSuicides", selectSuicidesQuery, 1, columnName)
  return tonumber(currentSuicides)
end

function aggregateStatsTable:getWorldDeaths(playerId, playerRole)
  local columnName = roles[playerRole] .. "_world_deaths"
  local selectDeathsQuery = "SELECT " .. columnName .. " FROM " .. self.tableName .. " WHERE player_id == " .. playerId
  local currentDeaths = self:query("aggregateCombatStatsTable:getWorldDeaths", selectDeathsQuery, 1, columnName)
  return tonumber(currentDeaths)
end

function aggregateStatsTable:incrementKills(playerId, playerRole, victimRole)
  local kills = self:getKills(playerId, playerRole, victimRole) + 1
  local columnName = roles[playerRole] .. "_" .. roles[victimRole] .. "_kills"
  local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. kills .. " WHERE player_id == " .. playerId
  return self:query("aggregateStatsTable:incrementKills", query)
end

function aggregateStatsTable:incrementDeaths(playerId, playerRole, attackerRole)
  local deaths = self:getDeaths(playerId, playerRole, attackerRole) + 1
  local columnName = roles[playerRole] .. "_" .. roles[attackerRole] .. "_deaths"
  local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. deaths .. " WHERE player_id == " .. playerId
  return self:query("aggregateStatsTable:incrementDeaths", query)
end

function aggregateStatsTable:incrementWeaponKills(playerId, playerRole, victimRole, weaponName)
  local kills = self:getWeaponKills(playerId, playerRole, victimRole, weaponName) + 1
  local columnName = roles[playerRole] .. "_" .. roles[victimRole] .. "_" .. weaponName .. "_kills"
  local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. kills .. " WHERE player_id == " .. playerId
  return self:query("aggregateStatsTable:incrementWeaponKills", query)
end

function aggregateStatsTable:incrementWeaponDeaths(playerId, playerRole, victimRole, weaponName)
  local deaths = self:getWeaponDeaths(playerId, playerRole, victimRole, weaponName) + 1
  local columnName = roles[playerRole] .. "_" .. roles[victimRole] .. "_" .. weaponName .. "_deaths"
  local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. deaths .. " WHERE player_id == " .. playerId
  return self:query("aggregateStatsTable:incrementWeaponDeaths", query)
end

function aggregateStatsTable:incrementSuicides(playerId, playerRole)
  local suicides = self:getSuicides(playerId, playerRole) + 1
  local columnName = roles[playerRole] .. "_suicides"
  local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. suicides .. " WHERE player_id == " .. playerId
  return self:query("aggregateStatsTable:incrementSuicides", query)
end

function aggregateStatsTable:incrementWorldDeaths(playerId, playerRole)
  local deaths = self:getWorldDeaths(playerId, playerRole) + 1
  local columnName = roles[playerRole] .. "_world_deaths"
  local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. deaths .. " WHERE player_id == " .. playerId
  return self:query("aggregateStatsTable:incrementWorldDeaths", query)
end

function aggregateStatsTable:getItemPurchases(playerId, playerRole, item)
  local columnName = roles[playerRole] .. "_" .. itemColumnSuffix[tostring(item)]
  local query = "SELECT " .. columnName .. " FROM " .. self.tableName .. " WHERE player_id == " .. playerId
  return tonumber(self:query("aggregateStatsTable:getItemPurchases", query, 1, columnName))
end

function aggregateStatsTable:incrementItemPurchases(playerId, playerRole, item)
  local purchases = self:getItemPurchases(playerId, playerRole, item) + 1
  local columnName = roles[playerRole] .. "_" .. itemColumnSuffix[tostring(item)]
  local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. purchases .. " WHERE player_id == " .. playerId
  return self:query("aggregateStatsTable:incrementItemPurchases", query)
end

function aggregateStatsTable:getPlayerStats(playerId)
  local query = "SELECT * from " .. self.tableName .. " WHERE player_id == " .. playerId
  return self:query("aggregateStatsTable:getPlayerStats", query, 1)
end

DDD.Database.Tables.AggregateStats = aggregateStatsTable
aggregateStatsTable:create()

local lightBlue = Color(0, 255, 255, 255)
local red = Color(255, 0, 0, 255)

concommand.Add("ddd_recalculate", function(ply, cmd, args, argStr)
  if (ply == NULL) then
    MsgC(lightBlue, "Recalculating aggregate data. This may take a long time.\n")
    aggregateStatsTable:recalculate()
    MsgC(lightBlue, "Aggregate data recalculated.\n")
  else         
    MsgC(red, "This command may only be run through the server console.\n")
  end
end)
