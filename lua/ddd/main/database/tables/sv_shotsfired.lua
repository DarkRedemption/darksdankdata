--Tracks every shot a player makes.
--Pulling the pin on a grenade counts as a shot.

local tables = DDD.Database.Tables

local columns = {
  id = "INTEGER PRIMARY KEY",
  round_id = "INTEGER NOT NULL",
  player_id = "INTEGER NOT NULL",
  weapon_id = "INTEGER NOT NULL",
  attack_type = "INTEGER NOT NULL", --1 = Primary, 2 = Secondary
  round_time = "REAL NOT NULL"
}

local foreignKeyTable = DDD.Database.ForeignKeyTable:new()  
foreignKeyTable:addConstraint("round_id", tables.RoundId, "id")
foreignKeyTable:addConstraint("player_id", tables.PlayerId, "id")
foreignKeyTable:addConstraint("weapon_id", tables.WeaponId, "id")
                        
local shotsFiredTable = DDD.SqlTable:new("ddd_shots_fired", columns, foreignKeyTable)

function shotsFiredTable:addShot(player, attackType)
  local roundIdTable = self:getForeignTableByColumn("round_id")
  local playerIdTable = self:getForeignTableByColumn("player_id")
  local weaponIdTable = self:getForeignTableByColumn("weapon_id")
  
  local row = {
    round_id = roundIdTable:getCurrentRoundId(),
    player_id = playerIdTable:getPlayerId(player),
    weapon_id = weaponIdTable:getOrAddWeaponId(player:GetActiveWeapon():GetClass()),
    attack_type = attackType,
    round_time =  DDD.CurrentRound:getCurrentRoundTime()
    }
  return self:insertTable(row)
end

shotsFiredTable:create()
DDD.Database.Tables.ShotsFired = shotsFiredTable