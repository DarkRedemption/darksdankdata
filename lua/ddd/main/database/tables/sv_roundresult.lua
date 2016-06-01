local roundIdTable = DDD.Database.Tables.RoundId

local columns = { id = "INTEGER PRIMARY KEY",
                  round_id = "INTEGER UNIQUE NOT NULL",
                  result = "INTEGER NOT NULL",
                  total_round_time = "REAL NOT NULL"
                }

local foreignKeyTable = DDD.Database.ForeignKeyTable:new()
foreignKeyTable:addConstraint("round_id", roundIdTable, "id")

local roundResultTable = DDD.SqlTable:new("ddd_round_result", columns, foreignKeyTable)

function roundResultTable:addResult(roundResult)
  local roundId = self:getForeignTableByColumn("round_id"):getCurrentRoundId()
  local queryTable = {
    round_id = roundId,
    result = roundResult,
    total_round_time = DDD.CurrentRound:getCurrentRoundTime()
  }
  return self:insertTable(queryTable)
end

roundResultTable:create()
DDD.Database.Tables.RoundResult = roundResultTable