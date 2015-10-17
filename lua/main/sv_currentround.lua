DDD.CurrentRound.roundStartTime = 0
DDD.CurrentRound.roundId = 0
DDD.CurrentRound.isActive = false

local roundIdTable = DDD.Database.Tables.RoundId
local roundRolesTable = DDD.Database.Tables.RoundRoles

function DDD.CurrentRound:getCurrentRoundTime()
  return (SysTime() - self.roundStartTime)
end

hook.Add("TTTBeginRound", "Tracks when a round starts.", function()
  roundIdTable:addRound()
  DDD.CurrentRound.roundStartTime = SysTime()
  DDD.CurrentRound.roundId = roundIdTable:getCurrentRoundId()
  DDD.CurrentRound.isActive = true
  for k, ply in pairs(player:GetAll()) do
    roundRolesTable:addRole(ply)
  end
end)

hook.Add("TTTEndRound", "Tracks when a round ends.", function(result)
  DDD.CurrentRound.isActive = false
end)