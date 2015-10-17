--Tracks the damage dealt to a player that was inflicted by accidentally falling and by T traps.

local tables = DDD.Database.Tables

local columns = [[ (id INTEGER PRIMARY KEY,
                    round_id INTEGER NOT NULL,
                    victim_id INTEGER NOT NULL, 
                    round_time REAL NOT NULL,
                    damage_dealt INTEGER NOT NULL,
                    FOREIGN KEY(round_id) REFERENCES ]] .. roundIdTable.tableName .. [[(id),
                    FOREIGN KEY(victim_id) REFERENCES ]] .. playerIdTable.tableName .. [[(id))]]
                        
local worldDamageTable = DDD.Table:new("ddd_world_damage", columns)

--[[
Adds a row tracking the damage dealt to a person by the world.
Parameters:
victimId:Integer - The victim's id from the PlayerID table.
dmgInfo:CTakeDamageInfo - The damage info from the fall/T-trap.
]]
function worldDamageTable:addDamage(victimId, dmgInfo)
  local queryTable = {
    round_id = DDD.CurrentRound.roundId
    victim_id = victimId
    round_time = DDD.CurrentRound.getCurrentRoundTime()
    damage_dealt = dmgInfo.getDamage()
  }
  self:insertTable(queryTable)
end

worldDamageTable:create()
DDD.Database.Tables.WorldDamage = worldDamageTable
