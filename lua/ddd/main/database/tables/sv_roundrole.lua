local playerIdTable = DDD.Database.Tables.PlayerId
local roundIdTable = DDD.Database.Tables.RoundId

local columns = {id = "INTEGER PRIMARY KEY",
                 player_id = "INTEGER NOT NULL",
                 round_id = "INTEGER NOT NULL",
                 role_id = "INTEGER NOT NULL"
                }

local uniqueConstraints = {{"player_id", "round_id"}}

local roundRolesTable = DDD.SqlTable:new("ddd_round_roles", columns, nil, uniqueConstraints)

roundRolesTable:addForeignConstraint("player_id", playerIdTable, "id")
roundRolesTable:addForeignConstraint("round_id", roundIdTable, "id")

roundRolesTable:addIndex("playerAndRoleIndex", {"player_id", "role_id"})

function roundRolesTable:addRole(ply)
  local roundId = self:getForeignTableByColumn("round_id"):getCurrentRoundId()
  local playerId = self:getForeignTableByColumn("player_id"):getPlayerId(ply)
  local queryTable = {
    player_id = playerId,
    round_id = roundId,
    role_id = ply:GetRole()
  }
  return self:insertTable(queryTable)
end

function roundRolesTable:getRoundsAsRole(playerId, roleId)
  local query = "SELECT COUNT(*) AS count FROM " .. self.tableName ..
                " WHERE player_id == " .. playerId .. " AND role_id == " .. roleId
  return self:query(query, 1, "count")
end

roundRolesTable:create()
DDD.Database.Tables.RoundRoles = roundRolesTable
