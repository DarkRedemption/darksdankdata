--Add Hooks object to test functions with GUnit
DDD.Hooks = {}

local tables = DDD.Database.Tables

hook.Add("PlayerInitialSpawn", "Add player if they do not exist in the table.", function(ply)
  tables.PlayerId:addPlayer(ply)
end)

--
-- Purchase Tracking Hooks
--
  
function DDD.Hooks.trackPurchases(tables, ply, equipment, isItem)
  tables.ShopItem:addItem(equipment, isItem)
  local itemId = tables.ShopItem:getItemId(equipment)
  local playerId = tables.PlayerId:getPlayerId(ply)
  --Return the id for testing purposes.
  return tables.Purchases:addPurchase(tonumber(playerId), tonumber(itemId))
end

hook.Add("TTTOrderedEquipment", "DDDTrackPurchases", function(ply, equipment, is_item)
  DDD.Hooks.trackPurchases(tables, ply, equipment, is_item)
end)

--
-- Corpse-related hooks
--

function DDD.Hooks.trackDnaDiscovery(tables, finder, dnaOwner, entityFoundOn)
  local playerId = tables.PlayerId:getPlayerId(finder)
  local dnaFoundOwnerId = tables.PlayerId:getPlayerId(dnaOwner)
  tables.EntityId:addEntity(entityFoundOn)
  local entityFoundOnId = tables.EntityId:getEntityId(entityFoundOn)
  return tables.Dna:addDnaFound(playerId, dnaFoundOwnerId, entityFoundOnId)
end

hook.Add("TTTFoundDNA", "DDDTrackDnaFound", function(finder, dnaOwner, entityFoundOn)
  DDD.Hooks.trackDnaDiscovery(tables, finder, dnaOwner, ent)
end)

--
-- Round Hooks
--

hook.Add("TTTEndRound", "DDDTrackRoundResult", function(result)
    tables.RoundResult:addResult(result)
  end)
 
local function handlePushKill(tables, victim, damageInfo)
  local victimId = tables.PlayerId:getPlayerId(victim)
  local attackerId = tables.PlayerId:getPlayerId(victim.was_pushed.att)
  local weaponId = tables.WeaponId:getOrAddWeaponId(victim.was_pushed.wep)
  return tables.PlayerPushKill:addKill(victimId, attackerId, weaponId, damageInfo)
end

--[[
Handles all kills from attackers that the game claims do not exist.
This means kills from the world, as well as pushing weapons
(which do have an attacker we can derive)
]]
local function handleNilAttackerKill(tables, victim, damageInfo)
  if (victim.was_pushed && damageInfo:IsDamageType(DMG_FALL)) then
    return handlePushKill(tables, victim, damageInfo)
  else
    local victimId = tables.PlayerId:getPlayerId(victim)
    return tables.WorldKill:addPlayerKill(victimId, damageInfo)
  end
end

--
-- Hooks for damage and kills
--

function DDD.Hooks.trackPlayerDeath(tables, victim, attacker, damageInfo)
  if (attacker == nil) then
      return handleNilAttackerKill(tables, victim, damageInfo)
    else
      local victimId = tables.PlayerId:getPlayerId(victim)
      local attackerId = tables.PlayerId:getPlayerId(attacker)
      local weaponClass = DDD.determineWeapon(damageInfo)
      local weaponId = tables.WeaponId:getOrAddWeaponId(weaponClass)
      return tables.PlayerKill:addKill(victimId, attackerId, weaponId)
    end
end

--TODO: Ensure this doesn't get called post round, and if it does, simply cancel it.
hook.Add("DoPlayerDeath", "DDDTrackPlayerDeath", function(victim, attacker, damageInfo)
    DDD.Hooks.trackPlayerDeath(tables, victim, attacker, damageInfo)
  end
)

local function handleNilAttackerDamage(tables, victim, damageInfo)
  local victimId = tables.PlayerId:getPlayerId(victim)
  if (victim.was_pushed) then
    local attackerId = tables.PlayerId:getPlayerId(victim.was_pushed.att)
    local weaponId = tables.WeaponId:getOrAddWeaponId(victim.was_pushed.wep .. "_push")
    return tables.CombatDamage:addPushDamage(victimId, attackerId, weaponId, damageInfo)
  else
    return tables.WorldDamage:addDamage(victimId, damageInfo)
  end
end

function DDD.Hooks.trackDamage(tables, victim, damageInfo)
  local attacker = damageInfo:GetAttacker()
  if (attacker == nil) then
    return handleNilAttackerDamage(tables, victim, damageInfo)
  else
    local weaponClass = damageInfo:GetInflictor():GetClass()
    local victimId = tables.PlayerId:getPlayerId(victim)
    local attackerId = tables.PlayerId:getPlayerId(attacker)
    local weaponId = tables.WeaponId:getOrAddWeaponId(weaponClass)
    return tables.CombatDamage:addDamage(victimId, attackerId, weaponId, damageInfo)
  end
end

hook.Add("EntityTakeDamage", "DDDTrackDamage", function(victim, damageInfo)
  if (victim:GetClass() == "player" && DDD.CurrentRound.isActive) then
    DDD.Hooks.trackDamage(tables, victim, damageInfo)
  end
end)
