local playerIdTable = DDD.Database.Tables.PlayerId
local weaponIdTable = DDD.Database.Tables.WeaponId
local mapIdTable = DDD.Database.Tables.MapId
local roundIdTable = DDD.Database.Tables.RoundId
local entityIdTable = DDD.Database.Tables.EntityId

local roles = DDD.Database.Roles

local columns = { id = "INTEGER PRIMARY KEY",
                  round_id = "INTEGER NOT NULL",
                  finder_id = "INTEGER NOT NULL",
                  dna_owner_id = "INTEGER NOT NULL",
                  entity_found_on = "INTEGER NOT NULL",
                  round_time = "REAL NOT NULL"
                }

local dnaTable = DDD.SqlTable:new("ddd_dna", columns)

dnaTable:addForeignConstraint("round_id", roundIdTable, "id")
dnaTable:addForeignConstraint("finder_id", playerIdTable, "id")
dnaTable:addForeignConstraint("dna_owner_id", playerIdTable, "id")
dnaTable:addForeignConstraint("entity_found_on", entityIdTable, "id")

dnaTable:addIndex("finderIndex", {"finder_id"})
dnaTable:addIndex("ownerIndex", {"dna_owner_id"})

function dnaTable:addDnaFound(finderId, dnaOwnerId, entityFoundOnId)
  local insertTable = {
    round_id = self:getForeignTableByColumn("round_id"):getCurrentRoundId(),
    finder_id = finderId,
    dna_owner_id = dnaOwnerId,
    entity_found_on = entityFoundOnId,
    round_time = DDD.CurrentRound:getCurrentRoundTime()
  }
  return self:insertTable(insertTable)
end

dnaTable:create()
DDD.Database.Tables.Dna = dnaTable