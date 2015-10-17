local columns = " ( id INTEGER PRIMARY KEY, " .. 
                "round_id INTEGER NOT NULL, " ..
                "user_id INTEGER NOT NULL, " .. 
                "placer_id INTEGER NOT NULL, " .. 
                "heal_amount INTEGER NOT NULL, " ..
                "round_time REAL NOT NULL)"
                
local healingTable = DDD.Table:new("ddd_healing", columns)
local playerIdTable = DDD.Database.Tables.PlayerId

function healingTable:addHeal(userId, placerId, healAmount)
  local roundId = DDD.CurrentRound.roundId
  local roundTime = DDD.CurrentRound:getCurrentRoundTime()
  local queryTable = {
    round_id = roundId,
    user_id = userId,
    placer_id = placerId,
    heal_amount = healAmount,
    round_time = roundTime
    }
  return self:insertTable(queryTable)
end

function healingTable:getTotalHPYouHealed(userId)
  local query = "SELECT SUM(heal_amount) as total_hp_healed FROM " .. self.tableName .. " WHERE user_id == " .. userId
  return self:query("healingTable:getTotalHPHealed", query, 1, "total_hp_healed")
end

function healingTable:getTotalHPOthersHealed(placerId)
  local query = "SELECT SUM(heal_amount) as total_hp_healed FROM " .. self.tableName .. " WHERE user_id != " .. placerId .. " AND placer_id == " .. placerId
  return self:query("healingTable:getTotalHPHealed", query, 1, "total_hp_healed")
end

DDD.Database.Tables.Healing = healingTable
healingTable:create()

hook.Add("TTTPlayerUsedHealthStation", "DDDAddHeals", function(ply, ent_station, healed)
    local userId = playerIdTable:getPlayerId(ply)
    local placerId = playerIdTable:getPlayerId(ent_station:GetPlacer())
    healingTable:addHeal(userId, placerId, healed)
  end)
