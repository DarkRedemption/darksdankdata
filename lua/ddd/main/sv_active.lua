function DDD.CurrentRound:getCurrentRoundTime()
  return (SysTime() - self.roundStartTime)
end

-- These functions take a parameter for testing purposes.

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

function DDD.CurrentRound.isDisabledByVote(rounds)
    return (rounds == -1 or rounds > 0)
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
DDD.CurrentRound.disabledByVote = false
DDD.CurrentRound.disabledRoundsRemaining = 0
DDD.CurrentRound.roundStartTime = 0
DDD.CurrentRound.roundId = 0
DDD.CurrentRound.roundParticipantIds = {}
DDD.CurrentRound.isActive = false

function DDD:enabled()
  local cr = DDD.CurrentRound
  return cr.isActive and !cr.blacklisted and !cr.disabledByPop and !cr.disabledByVote
end

function DDD:updateEnabled(tables)
  local cr = DDD.CurrentRound
  tables = tables or DDD.Database.Tables
  cr.roundStartTime = SysTime()
  cr.roundId = tables.RoundId:getCurrentRoundId()
  cr.isActive = true

  cr.disabledByVote = cr.isDisabledByVote(cr.disabledRoundsRemaining)
  cr.disabledByPop = cr.isPopTooLow(cr.getNonSpectatingPlayers())

  if (cr.disabledRoundsRemaining > 0) then
    cr.disabledRoundsRemaining = cr.disabledRoundsRemaining - 1
  end

  if (cr.blacklisted) then
    PrintMessage(HUD_PRINTTALK, "DDD: This map has been excluded from stat tracking.")
  elseif (cr.disabledByPop) then
    PrintMessage(HUD_PRINTTALK, "DDD: Population is too low for stats to be tracked this round.")
  elseif (cr.disabledByVote) then
    local secondMessage

    if DDD.CurrentRound.disabledRoundsRemaining > -1 then
      secondMessage = tostring(cr.disabledRoundsRemaining) .. " more rounds remain until stats are re-enabled."
    else
      secondMessage = "DDD is disabled for the rest of the map."
    end

    PrintMessage(HUD_PRINTTALK, "DDD: Stat tracking has been disabled either manually or by vote.")
    PrintMessage(HUD_PRINTTALK, secondMessage)
  end
end
