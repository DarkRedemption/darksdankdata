--Tracks when a player attempts to teleport and they have a spot marked.
--This is to track interruptions to the process, primarily.

local tables = DDD.Database.Tables

local columns = {
  id = "INTEGER PRIMARY KEY",
  round_id = "INTEGER NOT NULL",
  player_id = "INTEGER NOT NULL",
  round_time = "REAL NOT NULL"  
}

local foreignKeyTable = DDD.Database.ForeignKeyTable:new()  
foreignKeyTable:addConstraint("round_id", tables.RoundId, "id")
foreignKeyTable:addConstraint("player_id", tables.PlayerId, "id")
                        
local teleportStartTable = DDD.SqlTable:new("ddd_teleport_start", columns, foreignKeyTable)

function teleportStartTable:addTeleportStart(player)
  local roundIdTable = self:getForeignTableByColumn("round_id")
  local playerIdTable = self:getForeignTableByColumn("player_id")
  
  local row = {
    round_id = roundIdTable:getCurrentRoundId(),
    player_id = playerIdTable:getPlayerId(player),
    round_time =  DDD.CurrentRound:getCurrentRoundTime()
    }
  return self:insertTable(row)
end

teleportStartTable:create()
DDD.Database.Tables.teleportStartTable = teleportStartTable