local tables = DDD.Database.Tables

local columns = { id = "INTEGER PRIMARY KEY",
                  round_id = "INTEGER NOT NULL",
                  victim_id = "INTEGER NOT NULL",
                  round_time = "REAL NOT NULL"
                }
                
local foreignKeys = DDD.Database.ForeignKeyTable:new()
foreignKeys:addConstraint("round_id", tables.RoundId, "id")
foreignKeys:addConstraint("victim_id", tables.PlayerId, "id")
                        
local worldKillTable = DDD.SqlTable:new("ddd_world_kill", columns, foreignKeys)

--[[
Adds a row tracking a person's death due to the world (props, falling accidentally, and T-traps).
Parameters:
victimId:Integer - The victim's id from the PlayerID table.
]]
function worldKillTable:addPlayerKill(victimId)
  local roundIdTable = self:getForeignTableByColumn("round_id")
  local roundId = roundIdTable:getCurrentRoundId()
  local roundTime = DDD.CurrentRound:getCurrentRoundTime()
  local queryTable = {
    round_id = roundId,
    victim_id = victimId,
    round_time = roundTime
  }
  return self:insertTable(queryTable)
end

worldKillTable:create()
DDD.Database.Tables.WorldKill = worldKillTable
