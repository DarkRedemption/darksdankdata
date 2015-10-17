local playerIdTable = DDD.Database.Tables.PlayerId
local roundIdTable = DDD.Database.Tables.PlayerId

local columns = "(id INTEGER PRIMARY KEY, round_id INTEGER NOT NULL, player_id INTEGER NOT NULL, role_id INTEGER NOT NULL, " ..
                "FOREIGN KEY (round_id) REFERENCES " .. roundIdTable.tableName .. " (id), " ..
                "FOREIGN KEY (player_id) REFERENCES " .. playerIdTable.tableName .. " (id))"
local roundRolesTable = DDD.Table:new("ddd_round_roles", columns)

function roundRolesTable:addRole(ply)
  local playerId = playerIdTable:getPlayerId(ply)
  local queryTable = {
    round_id = DDD.CurrentRound.roundId,
    player_id = playerId,
    role_id = ply:GetRole()
  }
  return self:insertTable(queryTable)
end

function roundRolesTable:getRoundsAsRole(playerId, role_id)
  local query = "SELECT COUNT(*) AS count FROM " .. self.tableName .. 
                " WHERE player_id == " .. playerId .. " AND role_id == " .. role_id
  return self:query("roundRolesTable:getRoundsAsRole", query, 1, "count")
end

roundRolesTable:create()
DDD.Database.Tables.RoundRoles = roundRolesTable
