local tables = DDD.Database.Tables

local function incrementAggregateKillsAndDeaths(attacker, victim, attackerId, victimId)
  if (attackerId == victimId) then
    tables.AggregateStats:incrementSuicides(attackerId, attacker:GetRole())
  else
    tables.AggregateStats:incrementKills(attackerId, attacker:GetRole(), victim:GetRole())
  end
    tables.AggregateStats:incrementDeaths(victimId, victim:GetRole(), attacker:GetRole())
end

local function handlePushKill(tables, victim, damageInfo)
  local attacker = victim.was_pushed.att
  local victimId = tables.PlayerId:getPlayerId(victim)
  local attackerId = tables.PlayerId:getPlayerId(attacker)
  local weaponId = tables.WeaponId:getOrAddWeaponId(victim.was_pushed.wep)
  local addKillResult = tables.PlayerPushKill:addKill(victimId, attackerId, weaponId, damageInfo)
  if (addKillResult != nil and addKillResult != false) then
    incrementAggregateKillsAndDeaths(attacker, victim, attackerId, victimId)
  end

  return addKillResult
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
    local addKillResult = tables.WorldKill:addPlayerKill(victimId, damageInfo)

    if (addKillResult != nil and addKillResult != false) then
      tables.AggregateStats:incrementWorldDeaths(victimId, victim:GetRole())
    end

    return addKillResult
  end
end

function DDD.Hooks.trackPlayerDeath(tables, victim, attacker, damageInfo)
  if (attacker == nil || attacker:GetClass() != "player") then
      return handleNilAttackerKill(tables, victim, damageInfo)
    else
      local victimId = tables.PlayerId:getPlayerId(victim)
      local attackerId = tables.PlayerId:getPlayerId(attacker)
      local weaponClass = DDD.determineWeapon(damageInfo)
      local weaponId = tables.WeaponId:getOrAddWeaponId(weaponClass)
      local addKillResult = tables.PlayerKill:addKill(victimId, attackerId, weaponId)

      if (addKillResult != nil and addKillResult != false) then
        incrementAggregateKillsAndDeaths(attacker, victim, attackerId, victimId)
        tables.AggregateWeaponStats:incrementKillColumn(weaponClass, attackerId, attacker:GetRole(), victim:GetRole())
        tables.AggregateWeaponStats:incrementDeathColumn(weaponClass, victimId, victim:GetRole(), attacker:GetRole())
      end

      return addKillResult
    end
end

--TODO: Ensure this doesn't get called post round, and if it does, simply cancel it.
hook.Add("DoPlayerDeath", "DDDTrackPlayerDeath", function(victim, attacker, damageInfo)
    if (DDD:enabled()) then
      DDD.Hooks.trackPlayerDeath(tables, victim, attacker, damageInfo)
    end
  end
)

local function handleNilAttackerDamage(tables, victim, damageInfo)
  local victimId = tables.PlayerId:getPlayerId(victim)

  if (victim.was_pushed and IsValid(victim.was_pushed.att)) then
    local attackerId = tables.PlayerId:getPlayerId(victim.was_pushed.att)
    local weaponId = tables.WeaponId:getOrAddWeaponId(victim.was_pushed.wep)
    return tables.CombatDamage:addDamage(victimId, attackerId, weaponId, damageInfo)
  else
    return tables.WorldDamage:addDamage(victimId, damageInfo)
  end
end

function DDD.Hooks.trackDamage(tables, victim, damageInfo)
  local attacker = damageInfo:GetAttacker()
  --class of attacker is "worldspawn" if the world kills you
  if (attacker == nil || attacker:GetClass() != "player") then
    return handleNilAttackerDamage(tables, victim, damageInfo)
  else
    --print(attacker:GetClass())
    --local weaponClass = damageInfo:GetInflictor():GetClass()
    local weaponClass = DDD.determineWeapon(damageInfo)
    local victimId = tables.PlayerId:getPlayerId(victim)
    local attackerId = tables.PlayerId:getPlayerId(attacker)
    local weaponId = tables.WeaponId:getOrAddWeaponId(weaponClass)

    return tables.CombatDamage:addDamage(victimId, attackerId, weaponId, damageInfo)
  end
end

hook.Add("EntityTakeDamage", "DDDTrackDamage", function(victim, damageInfo)
  if (DDD:enabled() and victim:GetClass() == "player") then
    DDD.Hooks.trackDamage(tables, victim, damageInfo)
  end
end)

hook.Add("TTT_PlayerShotWeapon", "DDDTrackWeaponShot", function(ply, attackType)
	if !IsValid(ply) then return end
  if DDD:enabled() then
    tables.ShotsFired:addShot(ply, attackType)
  end
end)
