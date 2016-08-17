local playerIdTable = DDD.Database.Tables.PlayerId

local columns = { id = "INTEGER PRIMARY KEY", 
                  round_id = "INTEGER NOT NULL",
                  round_time = "REAL NOT NULL",
                  deployer_id = "INTEGER NOT NULL",
                  user_id = "INTEGER NOT NULL",   
                  heal_amount = "INTEGER NOT NULL",
                }

local foreignKeyTable = DDD.Database.ForeignKeyTable:new()
foreignKeyTable:addConstraint("round_id", DDD.Database.Tables.RoundId, "id")
foreignKeyTable:addConstraint("deployer_id", playerIdTable, "id")
foreignKeyTable:addConstraint("user_id", playerIdTable, "id")

local healingTable = DDD.SqlTable:new("ddd_healing", columns, foreignKeyTable)

healingTable:addIndex("roundIdIndex", {"round_id"})
healingTable:addIndex("userIndex", {"user_id"})
healingTable:addIndex("deployerIndex", {"deployer_id"})

function healingTable:addHeal(deployerId, userId, healAmount)
  local roundId = self:getForeignTableByColumn("round_id"):getCurrentRoundId()
  local roundTime = DDD.CurrentRound:getCurrentRoundTime()
  local queryTable = {
    round_id = roundId,
    round_time = roundTime,
    deployer_id = deployerId,
    user_id = userId,
    heal_amount = healAmount
  }
  return self:insertTable(queryTable)
end

--[[
Gets the total HP someone has healed themselves for.
]]
function healingTable:getTotalHPYouHealed(userId)
  local checkIfPlayerExistsQuery = "SELECT * FROM " .. self.tableName .. " WHERE user_id == " .. userId
  if self:query("healingTable:getTotalHPHealed", checkIfPlayerExistsQuery) == 0 then
    return 0
  else
    local query = "SELECT SUM(heal_amount) as total_hp_healed FROM " .. self.tableName .. " WHERE user_id == " .. userId
    return self:query("healingTable:getTotalHPHealed", query, 1, "total_hp_healed")
  end
end

--[[
Gets the total HP someone's health stations have healed others for.
]]
function healingTable:getTotalHPOthersHealed(placerId)
  local query = "SELECT SUM(heal_amount) as total_hp_healed FROM " .. self.tableName .. " WHERE user_id != " .. placerId .. " AND deployer_id == " .. placerId
  return self:query("healingTable:getTotalHPHealed", query, 1, "total_hp_healed")
end

DDD.Database.Tables.Healing = healingTable
healingTable:create()