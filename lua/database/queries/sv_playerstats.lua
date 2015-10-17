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

local function makeCountQuery(whereStatement)
  return [[SELECT COUNT(*) AS count
           FROM ddd_player_kill AS kill
           LEFT JOIN ddd_round_roles AS victim_roles 
           ON kill.round_id == victim_roles.round_id
           AND kill.victim_id == victim_roles.player_id
           LEFT JOIN ddd_round_roles AS attacker_roles
           ON kill.round_id == attacker_roles.round_id
           AND kill.attacker_id == attacker_roles.player_id ]] .. whereStatement
end


--TODO: Only get the c4 ID once
function PlayerStats:getC4KillsAsRole(roleId, victimRoleId)
  local c4Name = "ttt_c4"
  local c4Id = tables.WeaponId:getWeaponId(c4Name)
  if (c4Id == -1) then return 0 end
  return tables.KillInfo:getRoleKillsWithWeapon(self.playerId, roleId, victimRoleId, c4Id)
end

function PlayerStats:getC4DeathsAsRole(roleId, attackerRoleId)
  local c4Name = "ttt_c4"
  local c4Id = tables.WeaponId:getWeaponId(c4Name)
  if (c4Id == -1) then return 0 end
  return tables.KillInfo:getRoleDeathsWithWeapon(self.playerId, roleId, attackerRoleId, c4Id)
end

function PlayerStats:updateRoleData()
  for rolename, rolevalue in pairs(roles) do
    local keyname = rolename .. "Rounds"
    self.statsTable[keyname] = tables.RoundRoles:getRoundsAsRole(self.playerId, rolevalue)
  end
end

function PlayerStats:getRoleKills(playerRole, victimRole)
  local whereStatement = [[WHERE kill.attacker_id == ]] .. tostring(self.playerId) .. [[
                           AND kill.victim_id != ]] .. tostring(self.playerId) .. [[
                           AND attacker_roles.role_id == ]] .. tostring(playerRole) .. [[
                           AND victim_roles.role_id == ]] .. tostring(victimRole)
  local query = makeCountQuery(whereStatement)     
  local result = sql.Query(query)
  return countResult(result)
end

function PlayerStats:getRoleDeaths(playerRole, attackerRole)
  local whereStatement = [[WHERE kill.victim_id == ]] .. tostring(self.playerId) .. [[
                           AND attacker_roles.role_id == ]] .. tostring(attackerRole) .. [[
                           AND victim_roles.role_id == ]] .. tostring(playerRole)
  local query = makeCountQuery(whereStatement)
  local result = sql.Query(query)
  return countResult(result)
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

function PlayerStats:updateKillData()
  self.statsTable["K"] = tables.KillInfo:getTotalKills(self.playerId)
  self:getDataForAllRoles("K", PlayerStats.getRoleKills)
end

function PlayerStats:updateDeathData()
  self.statsTable["D"] = tables.KillInfo:getTotalDeaths(self.playerId)
  self:getDataForAllRoles("D", PlayerStats.getRoleDeaths)
end

function PlayerStats:updateSuicideData()
  self.statsTable["TraitorSuicides"] = tables.KillInfo:getTraitorSuicides(self.playerId)
  self.statsTable["InnocentSuicides"] = tables.KillInfo:getInnocentSuicides(self.playerId)
  self.statsTable["DetectiveSuicides"] = tables.KillInfo:getDetectiveSuicides(self.playerId)
end

function PlayerStats:getPurchasesAsRole(itemName, roleId)
  local itemId = tables.ShopItemId:getItemId(itemName)
  print(itemName)
  print("Item id is")
  print(itemId)
  if (itemId > 0) then
    local query = "SELECT COUNT(*) AS count FROM " .. tables.Purchases.tableName .. " as purchases " .. 
    "LEFT JOIN ddd_round_roles as roles " ..
    "ON purchases.round_id == roles.round_id " ..
    "WHERE purchases.player_id == " .. self.playerId .. " AND purchases.shop_item_id == " .. itemId .. " AND roles.role_id == " .. roleId
    return DDD.Table:query("purchasesTable:getPurchases", query, 1, "count")
  else 
    return 0
  end
end

function PlayerStats:getPurchases()
  self.statsTable["TraitorArmorPurchases"] = self:getPurchasesAsRole("1", roles["Traitor"])
  self.statsTable["TraitorRadarPurchases"] = self:getPurchasesAsRole("2", roles["Traitor"])
  self.statsTable["TraitorDisguiserPurchases"] = self:getPurchasesAsRole("4", roles["Traitor"])
  self.statsTable["TraitorFlareGunPurchases"] = self:getPurchasesAsRole("weapon_ttt_flaregun", roles["Traitor"])
  self.statsTable["TraitorKnifePurchases"] = self:getPurchasesAsRole("weapon_ttt_knife", roles["Traitor"])
  self.statsTable["TraitorTeleporterPurchases"] = self:getPurchasesAsRole("weapon_ttt_teleport", roles["Traitor"])
  self.statsTable["TraitorRadioPurchases"] = self:getPurchasesAsRole("weapon_ttt_radio", roles["Traitor"])
  self.statsTable["TraitorNewtonLauncherPurchases"] = self:getPurchasesAsRole("weapon_ttt_push", roles["Traitor"])
  self.statsTable["TraitorSilentPistolPurchases"] = self:getPurchasesAsRole("weapon_ttt_sipistol", roles["Traitor"])
  self.statsTable["TraitorDecoyPurchases"] = self:getPurchasesAsRole("weapon_ttt_decoy", roles["Traitor"])
  self.statsTable["TraitorPoltergeistPurchases"] = self:getPurchasesAsRole("weapon_ttt_phammer", roles["Traitor"])
  self.statsTable["TraitorC4Purchases"] = self:getPurchasesAsRole("weapon_ttt_c4", roles["Traitor"])
  
  self.statsTable["DetectiveRadarPurchases"] = self:getPurchasesAsRole("2", roles["Detective"])
  self.statsTable["DetectiveVisualizerPurchases"] = self:getPurchasesAsRole("weapon_ttt_beacon", roles["Detective"])
  self.statsTable["DetectiveDefuserPurchases"] = self:getPurchasesAsRole("weapon_ttt_defuser", roles["Detective"])
  self.statsTable["DetectiveTeleporterPurchases"] = self:getPurchasesAsRole("weapon_ttt_teleport", roles["Detective"])
  self.statsTable["DetectiveBinocularsPurchases"] = self:getPurchasesAsRole("weapon_ttt_binoculars", roles["Detective"])
  self.statsTable["DetectiveUmpPurchases"] = self:getPurchasesAsRole("weapon_ttt_stungun", roles["Detective"])
  self.statsTable["DetectiveHealthStationPurchases"] = self:getPurchasesAsRole("weapon_ttt_health_station", roles["Detective"])
end

function PlayerStats:updateStats()
  self:updateRoleData()
  self:updateKillData()
  self:updateSuicideData()
  self:updateDeathData()
  self:getDataForAllRoles("C4K", PlayerStats.getC4KillsAsRole)
  self:getDataForAllRoles("C4D", PlayerStats.getC4DeathsAsRole)
  self:getPurchases()
  
  self.statsTable["TotalHPYouHealed"] = tables.Healing:getTotalHPYouHealed(self.playerId)
  self.statsTable["TotalHPOthersHealed"] = tables.Healing:getTotalHPOthersHealed(self.playerId)
end

function PlayerStats:send()
end

function PlayerStats:new(ply)
  local newStats = {}
  setmetatable(newStats, self)
  newStats.ply = ply
  newStats.playerId = tables.PlayerId:getPlayerId(ply)
  newStats.statsTable = {}
  return newStats
end

DDD.Database.PlayerStats = PlayerStats