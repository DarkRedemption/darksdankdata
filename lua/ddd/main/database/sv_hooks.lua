--Add Hooks object to test functions with GUnit
DDD.Hooks = {}

local tables = DDD.Database.Tables

hook.Add("Initialize", "DDDAddNewMap", function(ply)
  tables.MapId:addMap()
end)

hook.Add("PlayerInitialSpawn", "DDDAddNewPlayer", function(ply)
  tables.PlayerId:addPlayer(ply)
end)

--
-- Purchase Tracking Hooks
--
  
function DDD.Hooks.trackPurchases(tables, ply, equipment, isItem)
  local itemId = tables.ShopItem:getOrAddItemId(equipment, isItem)
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

function DDD.Hooks.trackPlayerRoles(tables)
  tables.RoundId:addRound()
  DDD.CurrentRound.roundStartTime = SysTime()
  DDD.CurrentRound.roundId = tables.RoundId:getCurrentRoundId()
  DDD.CurrentRound.isActive = true
  for k, ply in pairs(player:GetAll()) do
    tables.RoundRoles:addRole(ply)
  end
end

hook.Add("TTTBeginRound", "DDDTrackRoundRoles", function()
    DDD.Hooks.trackPlayerRoles(tables)
  end)

hook.Add("TTTEndRound", "DDDTrackRoundResult", function(result)
    tables.RoundResult:addResult(result)
    DDD.CurrentRound.isActive = false
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
  if (attacker == nil || attacker:GetClass() != "player") then
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

--Hooks created by overriding default TTT behavior

--From https://facepunch.com/showthread.php?t=1296788.
hook.Add("Initialize", "DDDEditWeaponBase", function()
	local weaponBase = weapons.GetStored("weapon_tttbase")
	if !weaponBase then return end
	weaponBase.DDDOldPrimaryAttack = weaponBase.PrimaryAttack
	function weaponBase:PrimaryAttack(worldsnd)
		self:DDDOldPrimaryAttack(worldsnd)  
    hook.Call("TTT_PlayerShotWeapon", GAMEMODE, self.Owner, 1)
	end
end)

hook.Add("Initialize", "DDDEditKnifeBase", function()
	local weaponBase = weapons.GetStored("weapon_ttt_knife")
	if !weaponBase then return end
  
	weaponBase.DDDOldPrimaryAttack = weaponBase.PrimaryAttack
  weaponBase.DDDOldSecondaryAttack = weaponBase.SecondaryAttack
  
	function weaponBase:PrimaryAttack()
		self:DDDOldPrimaryAttack()  
    hook.Call("TTT_PlayerShotWeapon", GAMEMODE, self.Owner, 1)
	end
  
  function weaponBase:SecondaryAttack()
		self:DDDOldSecondaryAttack()
    hook.Call("TTT_PlayerShotWeapon", GAMEMODE, self.Owner, 2)
	end
end)

--TODO: Change this so it sends out the hook only if a location is a valid mark (won't cause failed teleports).
--[[
hook.Add("Initialize", "DDDEditTeleporterBase", function()
	local weaponBase = weapons.GetStored("weapon_ttt_teleport")
	if !weaponBase then return end
	weaponBase.DDDOldPrimaryAttack = weaponBase.PrimaryAttack
	function weaponBase:PrimaryAttack()
		self:DDDOldPrimaryAttack()  
    hook.Call("TTT_PlayerShotWeapon", GAMEMODE, self.Owner, 1)
	end
end)
]]

hook.Add("Initialize", "DDDEditGrenadeBase", function()
	local weaponBase = weapons.GetStored("weapon_tttbasegrenade")
	if !weaponBase then return end
	weaponBase.DDDOldPrimaryAttack = weaponBase.PrimaryAttack
	function weaponBase:PrimaryAttack()
		self:DDDOldPrimaryAttack()  
    hook.Call("TTT_PlayerShotWeapon", GAMEMODE, self.Owner, 1)
	end
end)
 
hook.Add("TTT_PlayerShotWeapon", "DDDTrackWeaponShot", function(ply, attackType)
	if !IsValid(ply) then return end
  if DDD.CurrentRound.isActive then
    tables.ShotsFired:addShot(ply, attackType)
  end
end)

hook.Add("TTTBodyFound", "DDDTrackCorpseIdentified", function(ply, deadply, rag)
	if DDD.CurrentRound.isActive then
    tables.CorpseIdentified:addCorpseFound(ply, deadply, rag)
  end
end)

function DDD.Hooks.TrackRadioCallouts(tables, ply, commandName, commandTarget)
  local commandId = tables.RadioCommand:getOrAddCommand(commandName)
  local commandUsedId = tables.RadioCommandUsed:addCommandUsed(ply, commandName, commandTarget)
  if (commandTarget != "quick_nobody" and commandTarget != "quick_corpse") then
    tables.RadioCommandTarget:addCommandTarget(commandTarget, commandUsedId)
  end
end

hook.Add("TTTPlayerRadioCommand", "DDDTrackRadioCallouts", function(ply, cmd_name, cmd_target)
    if DDD.CurrentRound.isActive then
      DDD.Hooks.TrackRadioCallouts(tables, ply, cmd_name, cmd_target)
    end
  end)
