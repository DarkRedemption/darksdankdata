DDD.CurrentRound.roundStartTime = 0
DDD.CurrentRound.roundId = 0
DDD.CurrentRound.isActive = false

local roundIdTable = DDD.Database.Tables.RoundId
local roundRolesTable = DDD.Database.Tables.RoundRoles

function DDD.CurrentRound:getCurrentRoundTime()
  return (SysTime() - self.roundStartTime)
end