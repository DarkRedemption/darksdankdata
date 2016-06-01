local playerIdTable = DDD.Database.Tables.PlayerId
local weaponIdTable = DDD.Database.Tables.WeaponId
local mapIdTable = DDD.Database.Tables.MapId
local roundIdTable = DDD.Database.Tables.RoundId

local roles = DDD.Database.Roles

local columns = {id = "INTEGER PRIMARY KEY",
                 round_id = "INTEGER NOT NULL",
                 round_time = "REAL NOT NULL",
                 victim_id = "INTEGER NOT NULL", 
                 attacker_id = "INTEGER NOT NULL",
                 weapon_id = "INTEGER NOT NULL"
               }
      
local foreignKeyTable = DDD.Database.ForeignKeyTable:new()
foreignKeyTable:addConstraint("round_id", roundIdTable, "id")
foreignKeyTable:addConstraint("victim_id", playerIdTable, "id")
foreignKeyTable:addConstraint("attacker_id", playerIdTable, "id")
foreignKeyTable:addConstraint("weapon_id", weaponIdTable, "id")
  
local playerPushKillTable = DDD.SqlTable:new("ddd_player_push_kill", columns, foreignKeyTable)

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