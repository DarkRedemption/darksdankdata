function DDD.CurrentRound:getCurrentRoundTime()
  return (SysTime() - self.roundStartTime)
end

function DDD.CurrentRound.isMapBlacklisted(currentMap) --Made as a parameter for testing purposes
  for index, mapName in pairs(DDD.Config.MapBlacklist) do
    if (mapName == currentMap) then
      return true
    end
  end
  return false
end

function DDD.CurrentRound.isPopTooLow(currentPop)
  if (currentPop < DDD.Config.MinPlayers) then
    return true
  end
  return false
end

function DDD.CurrentRound.getNonSpectatingPlayers()
  local nonSpectators = 0
  
  for index, ply in pairs(player.GetAll()) do
    if ply:GetObserverMode() == 0 then
      nonSpectators = nonSpectators + 1
    end
  end
  
  return nonSpectators
end

DDD.CurrentRound.blacklisted = DDD.CurrentRound.isMapBlacklisted(game.GetMap())
DDD.CurrentRound.disabledByPop = DDD.CurrentRound.isPopTooLow(DDD.CurrentRound.getNonSpectatingPlayers())
DDD.CurrentRound.roundStartTime = 0
DDD.CurrentRound.roundId = 0
DDD.CurrentRound.roundParticipantIds = {}
DDD.CurrentRound.isActive = false

function DDD:enabled()
  local cr = DDD.CurrentRound
  return cr.isActive and !cr.blacklisted and !cr.disabledByPop
end

function DDD:updateEnabled(tables)
  tables = tables or DDD.Database.Tables
  DDD.CurrentRound.roundStartTime = SysTime()
  DDD.CurrentRound.roundId = tables.RoundId:getCurrentRoundId()
  DDD.CurrentRound.isActive = true
  
  if (DDD.CurrentRound.blacklisted) then
    PrintMessage(HUD_PRINTTALK, "DDD: This map has been excluded from stat tracking.")
  else
    DDD.CurrentRound.disabledByPop = DDD.CurrentRound.isPopTooLow(DDD.CurrentRound.getNonSpectatingPlayers())
    if (DDD.CurrentRound.disabledByPop) then
      PrintMessage(HUD_PRINTTALK, "DDD: Population is too low for stats to be tracked this round.")
    end
  end
end