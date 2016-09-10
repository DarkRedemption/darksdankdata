local tables = DDD.Database.Tables
local roles = DDD.Database.Roles

local columns = {id = "INTEGER PRIMARY KEY",
                 round_id = "INTEGER NOT NULL",
                 round_time = "REAL NOT NULL",
                 looter_id = "INTEGER NOT NULL", 
                 victim_id = "INTEGER NOT NULL",
                 credits_looted = "INTEGER NOT NULL"
               }

local creditsLootedTable = DDD.SqlTable:new("ddd_credits_looted", columns)

creditsLootedTable:addForeignConstraint("round_id", tables.RoundId, "id")
creditsLootedTable:addForeignConstraint("looter_id", tables.PlayerId, "id")
creditsLootedTable:addForeignConstraint("victim_id", tables.PlayerId, "id")

creditsLootedTable:addIndex("roundIdIndex", {"round_id"})
creditsLootedTable:addIndex("looterIndex", {"looter_id"})
creditsLootedTable:addIndex("victimIndex", {"victim_id"})
creditsLootedTable:addIndex("looterAndVictimIndex", {"looter_id", "victim_id"})

function creditsLootedTable:addCreditsLooted(looterId, victimId, creds)
  local roundIdTable = self:getForeignTableByColumn("round_id")
  local roundId = roundIdTable:getCurrentRoundId()
  local roundTime = DDD.CurrentRound:getCurrentRoundTime()
  
  local queryTable = {
    round_id = roundId,
    round_time = roundTime,
    looter_id = looterId,
    victim_id = victimId,
    credits_looted = creds
  }
  return self:insertTable(queryTable)
end

DDD.Database.Tables.CreditsLooted = creditsLootedTable
creditsLootedTable:create()