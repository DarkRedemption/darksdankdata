--Tracks the damage dealt to a player that was inflicted by another player.

local tables = DDD.Database.Tables

local columns = { id = "INTEGER PRIMARY KEY",
                  round_id = "INTEGER NOT NULL",
                  victim_id = "INTEGER NOT NULL", 
                  attacker_id = "INTEGER NOT NULL",
                  weapon_id = "INTEGER NOT NULL",
                  round_time = "REAL NOT NULL",
                  damage_dealt = "INTEGER NOT NULL",
                  damage_type = "INTEGER NOT NULL"}
                  
local foreignKeyTable = DDD.Database.ForeignKeyTable:new()
foreignKeyTable:addConstraint("round_id", tables.RoundId, "id")
foreignKeyTable:addConstraint("victim_id", tables.PlayerId, "id")
foreignKeyTable:addConstraint("attacker_id", tables.PlayerId, "id")
foreignKeyTable:addConstraint("weapon_id", tables.WeaponId, "id")

local combatDamageTable = DDD.SqlTable:new("ddd_combat_damage", columns, foreignKeyTable)

combatDamageTable:addIndex("roundIdIndex", {"round_id"})
combatDamageTable:addIndex("victimIndex", {"victim_id"})
combatDamageTable:addIndex("attackerIndex", {"attacker_id"})
combatDamageTable:addIndex("attackerVsVictimIndex", {"attacker_id, victim_id"})
combatDamageTable:addIndex("killsWithWeaponIndex", {"attacker_id, weapon_id"})
combatDamageTable:addIndex("deathsFromWeaponIndex", {"victim_id, weapon_id"})

--[[
Adds a row tracking the damage dealt to a person by another player.
Parameters:
victimId:Integer - The victim's id from the PlayerID table.
attackerId:Integer - The attacker's id from the PlayerID table.
weaponId:Integer -  The attacker's weapon's id from the WeaponID table.
dmgInfo:CTakeDamageInfo - The damage info from the attack.
]]
function combatDamageTable:addDamage(victimId, attackerId, weaponId, dmgInfo)
  local roundIdTable = self:getForeignTableByColumn("round_id")
  local roundId = roundIdTable:getCurrentRoundId()
  local roundTime = DDD.CurrentRound:getCurrentRoundTime()
  
  local queryTable = {
    round_id = roundId,
    victim_id = victimId,
    attacker_id = attackerId,
    weapon_id = weaponId,
    round_time = roundTime,
    damage_dealt = dmgInfo:GetDamage(),
    damage_type = dmgInfo:GetDamageType()
  }
  return self:insertTable(queryTable)
end

DDD.Database.Tables.CombatDamage = combatDamageTable
combatDamageTable:create()