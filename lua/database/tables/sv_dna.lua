local playerIdTable = DDD.Database.Tables.PlayerId
local weaponIdTable = DDD.Database.Tables.WeaponId
local mapIdTable = DDD.Database.Tables.MapId
local roundIdTable = DDD.Database.Tables.RoundId
local entityIdTable = DDD.Database.Tables.EntityId

local roles = DDD.Database.Roles

local columns = [[ ( id INTEGER PRIMARY KEY,
                        round_id INTEGER NOT NULL,
                        player_id INTEGER NOT NULL, 
                        dna_owner_player_id INTEGER NOT NULL,
                        entity_found_on INTEGER NOT NULL,
                        round_time REAL NOT NULL,
                        FOREIGN KEY(round_id) REFERENCES ]] .. roundIdTable.tableName .. [[(id),
                        FOREIGN KEY(player_id) REFERENCES ]] .. playerIdTable.tableName .. [[(id),
                        FOREIGN KEY(dna_owner_player_id) REFERENCES ]] .. playerIdTable.tableName .. [[(id),
                        FOREIGN KEY(entity_found_on) REFERENCES ]] .. entityIdTable.tableName .. [[(id))]]
                        
local dnaTable = DDD.Table:new("ddd_dna", columns)

function dnaTable:addDnaFound(playerId, dnaOwnerPlayerId, entityFoundOnId)
  local insertTable = {
    round_id = DDD.CurrentRound.roundId,
    player_id = playerId,
    dna_owner_player_id = dnaOwnerPlayerId,
    entity_found_on = entityFoundOnId,
    round_time = DDD.CurrentRound:getCurrentRoundTime()
  }
  return self:insertTable(insertTable)
end

dnaTable:create()
DDD.Database.Tables.Dna = dnaTable