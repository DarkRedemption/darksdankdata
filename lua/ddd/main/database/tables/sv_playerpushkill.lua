local playerIdTable = DDD.Database.Tables.PlayerId
local weaponIdTable = DDD.Database.Tables.WeaponId
local mapIdTable = DDD.Database.Tables.MapId
local roundIdTable = DDD.Database.Tables.RoundId
local roundRoleTable = DDD.Database.Tables.RoundRoles

local roles = DDD.Database.Roles

local columns = {id = "INTEGER PRIMARY KEY",
                 round_id = "INTEGER NOT NULL",
                 round_time = "REAL NOT NULL",
                 victim_id = "INTEGER NOT NULL",
                 attacker_id = "INTEGER NOT NULL",
                 weapon_id = "INTEGER NOT NULL"
               }

local playerPushKillTable = DDD.SqlTable:new("ddd_player_push_kill", columns)

playerPushKillTable:addForeignConstraint("round_id", roundIdTable, "id")
playerPushKillTable:addForeignConstraint("victim_id", playerIdTable, "id")
playerPushKillTable:addForeignConstraint("attacker_id", playerIdTable, "id")
playerPushKillTable:addForeignConstraint("weapon_id", weaponIdTable, "id")
playerPushKillTable:addCompositeForeignConstraint("victimHasRole", {"round_id", "victim_id"}, roundRoleTable, {"round_id", "player_id"})
playerPushKillTable:addCompositeForeignConstraint("attackerHasRole", {"round_id", "attacker_id"}, roundRoleTable, {"round_id", "player_id"})

playerPushKillTable:addIndex("roundIdIndex", {"round_id"})
playerPushKillTable:addIndex("victimIndex", {"victim_id"})
playerPushKillTable:addIndex("attackerIndex", {"attacker_id"})
playerPushKillTable:addIndex("attackerVsVictimIndex", {"attacker_id", "victim_id"})
playerPushKillTable:addIndex("killsWithWeaponIndex", {"attacker_id", "weapon_id"})
playerPushKillTable:addIndex("deathsFromWeaponIndex", {"victim_id", "weapon_id"})

function playerPushKillTable:addKill(victimId, attackerId, weaponId)
  local queryTable = {
    round_id = self:getForeignTableByColumn("round_id"):getCurrentRoundId(),
    victim_id = victimId,
    attacker_id = attackerId,
    weapon_id = weaponId,
    round_time = DDD.CurrentRound:getCurrentRoundTime()
  }
  return self:insertTable(queryTable)
end

DDD.Database.Tables.PlayerPushKill = playerPushKillTable
playerPushKillTable:create()
