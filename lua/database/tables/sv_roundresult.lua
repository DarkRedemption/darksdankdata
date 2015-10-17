local roundIdTable = DDD.Database.Tables.RoundId

local columns = "(id INTEGER PRIMARY KEY, round_id INTEGER UNIQUE NOT NULL, result INTEGER NOT NULL, " ..
                "FOREIGN KEY (round_id) REFERENCES " .. roundIdTable.tableName .. " (id))"
local roundResultTable = DDD.Table:new("ddd_round_result", columns)

function roundResultTable:addResult(roundResult)
  local queryTable = {
    round_id = DDD.CurrentRound.roundId,
    result = roundResult
  }
  return self:insertTable(queryTable)
end

roundResultTable:create()
DDD.Database.Tables.RoundResult = roundResultTable