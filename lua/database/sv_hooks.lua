--Add Hooks object to test functions with GUnit
DDD.Hooks = {}

local tables = DDD.Database.Tables

hook.Add("PlayerInitialSpawn", "Add player if they do not exist in the table.", function(ply)
  tables.PlayerId:addPlayerId(ply)
end)

--
-- Purchase Tracking Hooks
--
  
hook.Add("TTTOrderedEquipment", "DDDTrackPurchases", function(ply, equipment, is_item)
  tables.ShopItemId:addItem(equipment)
  local itemId = tables.ShopItemId:getItemId(equipment)
  local playerId = tables.PlayerId:getPlayerId(ply)
  purchasesTable:addPurchase(tonumber(playerId), tonumber(itemId))
end)

--
-- Corpse-related hooks
--

hook.Add("TTTFoundDNA", "DDDTrackDnaFound", function(ply, dna_owner, ent)
  local playerId = tables.PlayerId:getPlayerId(ply)
  local dnaFoundOwnerId = tables.PlayerId:getPlayerId(dna_owner)
  tables.EntityId:addEntity(ent)
  local entityFoundOnId = tables.EntityId:getEntityId(ent)
  tables.Dna:addDnaFound(playerId, dnaFoundOwnerId, entityFoundOnId)
end)

--
-- Round Hooks
--

hook.Add("TTTEndRound", "DDDTrackRoundResult", function(result)
    tables.RoundResult:addResult(result)
  end)
  
local function handleNilAttackerKill(tableList, victim, dmgInfo)
  local victimId = tableList.PlayerId:getPlayerId(victim)
  if (victim.was_pushed && dmgInfo.IsDamageType(DMG_FALL)) then
    local attackerId = tableList.PlayerId:getPlayerId(victim.was_pushed.att)
    local weaponId = tableList.WeaponId:getWeaponIdAndAddIfNotExists(victim.was_pushed.wep .. "_push")
    tableList.KillInfo:addPlayerKill(victimId, attackerId, weaponId, dmgInfo)
  else
    tableList.WorldKill:addPlayerKill(victim, dmgInfo)
  end
end

--
-- Hooks for damage and kills
--

function DDD.Hooks.trackPlayerDeath(tableList, victim, attacker, damageInfo)
  if (attacker == nil) then
      handleNilAttackerKill(victim, dmgInfo)
    else
      local victimId = tableList.PlayerId:getPlayerId(victim)
      local attackerId = tableList.PlayerId:getPlayerId(attacker)
      local weaponClass = DDD.determineWeapon(damageInfo)
      local weaponId = tableList.WeaponId:getWeaponIdAndAddIfNotExists(weaponClass)
      tables.KillInfo:addPlayerKill(victimId, attackerId, weaponId)
    end
end

--TODO: Ensure this doesn't get called post round, and if it does, simply cancel it.
hook.Add("DoPlayerDeath", "DDDTrackPlayerDeath", function(victim, attacker, damageInfo)
    DDD.Hooks.trackPlayerDeath(tables, victim, attacker, damageInfo)
  end
)

local function handleNilAttackerDamage(victim, dmgInfo)
  local victimId = tables.PlayerId:getPlayerId(victim)
  if (victim.was_pushed) then
    local attackerId = tables.PlayerId:getPlayerId(victim.was_pushed.att)
    local weaponId = tables.WeaponId:getWeaponIdAndAddIfNotExists(victim.was_pushed.wep .. "_push")
    tables.CombatDamage:addPushDamage(victimId, attackerId, weaponId, dmgInfo)
  else
    tables.WorldDamage:addDamage(victimId, dmgInfo)
  end
end

local function trackDamage(victim, dmgInfo)
  if (attacker == nil) then
    handleNilAttackerDamage(victimId, victim, dmgInfo)
  else
    local victimId = tables.PlayerId:getPlayerId(victim)
    local attackerId = tables.PlayerId:getPlayerId(attacker)
    tables.CombatDamage:addDamage(victimId, attacker, dmgInfo)
  end
end

hook.Add("EntityTakeDamage", "DDDTrackDamage", function(victim, dmgInfo)
  if (victim:GetClass() == "player" && DDD.CurrentRound.isActive) then
    trackDamage(victim, dmgInfo)
  end
end)
