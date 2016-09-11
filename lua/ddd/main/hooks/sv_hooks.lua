--Add Hooks object to test functions with GUnit
DDD.Hooks = {}

local tables = DDD.Database.Tables

hook.Add("Initialize", "DDDAddNewMap", function(ply)
  tables.MapId:addMap()
end)

hook.Add("PlayerInitialSpawn", "DDDAddOrUpdatePlayer", function(ply)
  tables.PlayerId:addOrUpdatePlayer(ply)
  tables.AggregateStats:addPlayer(tables.PlayerId:getPlayerId(ply))
end)

--
-- Purchase Tracking Hooks
--

function DDD.Hooks.trackPurchases(tables, ply, equipment)
  local itemId = tables.ShopItem:getOrAddItemId(equipment)
  local playerId = tables.PlayerId:getPlayerId(ply)
  local purchaseResult = tables.Purchases:addPurchase(playerId, itemId)
  if (purchaseResult != nil and purchaseResult != false) then
    tables.AggregateStats:incrementItemPurchases(playerId, ply:GetRole(), equipment)
  end
  
    --Return the id for testing purposes.
  return purchaseResult
end

hook.Add("TTTOrderedEquipment", "DDDTrackPurchases", function(ply, equipment, is_item)
  if (DDD:enabled()) then
    DDD.Hooks.trackPurchases(tables, ply, equipment)
  end
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
  if (DDD:enabled()) then
    DDD.Hooks.trackDnaDiscovery(tables, finder, dnaOwner, entityFoundOn)
  end
end)

--
-- Round Hooks
--

function DDD.Hooks.trackPlayerRoles(tables)
  tables.RoundId:addRound()
  
  for k, ply in pairs(player:GetAll()) do
    if ply:GetObserverMode() == 0 then
      tables.RoundRoles:addRole(ply)
      local playerId = tables.PlayerId:getPlayerId(ply)
      tables.AggregateStats:incrementRounds(playerId, ply:GetRole())
      DDD.CurrentRound.roundParticipantIds[playerId] = ply:GetRole()
    end
  end
end

hook.Add("TTTBeginRound", "DDDTrackRoundRoles", function()
  DDD:updateEnabled()
  if DDD:enabled() then
    DDD.Hooks.trackPlayerRoles(tables)
  end
end)

function DDD.Hooks.addRoundResult(tables, roundResult)
  tables.RoundResult:addResult(result)
  
  for playerId, playerRole in pairs(DDD.CurrentRound.roundParticipantIds) do
    if (playerRole == 1 and roundResult == 2) or 
       (playerRole != 1 and roundResult > 2) then
      tables.AggregateStats:incrementRoundsWon(playerId, playerRole)
    end
  end
end

hook.Add("TTTEndRound", "DDDTrackRoundResult", function(result)
    if DDD:enabled() then
      DDD.Hooks.addRoundResult(tables, result)
    end
    DDD.CurrentRound.isActive = false
    DDD.CurrentRound.roundParticipantIds = {}
    DDD.Rank.RankTable:update()
  end)

hook.Add("TTTBodyFound", "DDDTrackCorpseIdentified", function(ply, deadply, rag)
	if DDD:enabled() then
    tables.CorpseIdentified:addCorpseFound(ply, deadply, rag)
  end
end)

function DDD.Hooks.TrackRadioCallouts(tables, ply, commandName, commandTarget)
  local commandId = tables.RadioCommand:getOrAddCommand(commandName)
  local commandUsedId = tables.RadioCommandUsed:addCommandUsed(ply, commandName, commandTarget)
  if (commandTarget != "quick_nobody" and commandTarget != "quick_corpse" and commandTarget != "quick_disg") then
    tables.RadioCommandTarget:addCommandTarget(commandTarget, commandUsedId)
  end
end

hook.Add("TTTPlayerRadioCommand", "DDDTrackRadioCallouts", function(ply, cmd_name, cmd_target)
  if DDD:enabled() then
    DDD.Hooks.TrackRadioCallouts(tables, ply, cmd_name, cmd_target)
  end
end)

function DDD.Hooks.TrackHealing(tables, ply, ent_station, healed)
  local placerId = ent_station.DDDOwnerId
  local userId = tables.PlayerId:getPlayerId(ply)
  tables.Healing:addHeal(userId, placerId, healed)
  tables.AggregateStats:incrementSelfHPHealed(userId)
end

hook.Add("TTTPlayerUsedHealthStation", "DDDAddHeals", function(ply, ent_station, healed)
  if DDD:enabled() then
    DDD.Hooks.TrackHealing(tables, ply, ent_station, healed)
  end
end)

function DDD.Hooks.trackCreditsLooted(tables, looter, rag, credits)
  local looterId = tables.PlayerId:getPlayerId(looter)
  local victimSteamId = CORPSE.GetPlayerSteamID(rag, "")
  local victimId = tables.PlayerId:getPlayerIdBySteamId(victimSteamId)
  return tables.CreditsLooted:addCreditsLooted(looterId, victimId, credits)
end

hook.Add("DDDCreditsLooted", "DDDTrackCreditsLooted", function(ply, rag, credits)
  if DDD:enabled() then
    DDD.Hooks.TrackCreditsLooted(tables, ply, rag, credits)
  end
end)

