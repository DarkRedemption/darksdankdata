local tables = DDD.Database.Tables

local columns = [[ ( id INTEGER PRIMARY KEY,
                        round_id INTEGER NOT NULL,
                        victim_id INTEGER NOT NULL,
                        round_time REAL NOT NULL,
                        FOREIGN KEY(round_id) REFERENCES ]] .. tables.RoundId.tableName .. [[(id),
                        FOREIGN KEY(victim_id) REFERENCES ]] .. tables.PlayerId.tableName .. [[(id))]]
                        
local worldKillTable = DDD.Table:new("ddd_world_kill", columns)

--[[
Adds a row tracking a person's death due to the world (props, falling accidentally, and T-traps).
Parameters:
victimId:Integer - The victim's id from the PlayerID table.
dmgInfo:CTakeDamageInfo - The damage info from the fall/T-trap.
]]
function worldKillTable:addPlayerKill(victimId, attackerId)
  local queryTable = {
    round_id = DDD.CurrentRound.RoundId,
    victim_id = victimId,
    round_time = DDD.CurrentRound:getCurrentRoundTime()  
  }
  return self:insertTable(queryTable)
end

worldKillTable:create()
DDD.Database.Tables.WorldKill = worldKillTable
