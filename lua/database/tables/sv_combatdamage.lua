--Tracks the damage dealt to a player that was inflicted by another player.

local tables = DDD.Database.Tables

local columns = [[ (id INTEGER PRIMARY KEY,
                    round_id INTEGER NOT NULL,
                    victim_id INTEGER NOT NULL, 
                    attacker_id INTEGER NOT NULL,
                    weapon_id INTEGER NOT NULL,
                    round_time REAL NOT NULL,
                    damage_dealt INTEGER NOT NULL,
                    FOREIGN KEY(round_id) REFERENCES ]] .. roundIdTable.tableName .. [[(id),
                    FOREIGN KEY(victim_id) REFERENCES ]] .. playerIdTable.tableName .. [[(id),
                    FOREIGN KEY(attacker_id) REFERENCES ]] .. playerIdTable.tableName .. [[(id),
                    FOREIGN KEY(weapon_id) REFERENCES ]] .. weaponIdTable.tableName .. [[(id))]]
                        
local combatDamageTable = DDD.Table:new("ddd_combat_damage", columns)

--[[
Adds a row tracking the damage dealt to a person by another player.
Parameters:
victimId:Integer - The victim's id from the PlayerID table.
attackerId:Integer - The attacker's id from the PlayerID table.
weaponId:Integer -  The attacker's weapon's id from the WeaponID table.
dmgInfo:CTakeDamageInfo - The damage info from the attack.
]]
function combatDamageTable:addDamage(victimId, attackerId, weaponId, dmgInfo)
  local queryTable = {
    round_id = DDD.CurrentRound.roundId
    victim_id = victimId
    attacker_id = attackerId
    weapon_id = weaponId
    round_time = DDD.CurrentRound.getCurrentRoundTime()
    damage_dealt = dmgInfo.getDamage()
  }
  self:insertTable(queryTable)
end

combatDamageTable:create()
DDD.Database.Tables.CombatDamage = combatDamageTable
