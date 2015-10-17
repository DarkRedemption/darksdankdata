local playerIdTable = DDD.Database.Tables.PlayerId
local weaponIdTable = DDD.Database.Tables.WeaponId
local roundIdTable = DDD.Database.Tables.RoundId

local columns = [[ ( id INTEGER PRIMARY KEY,
                        round_id INTEGER NOT NULL,
                        player_id INTEGER NOT NULL, 
                        weapon_id INTEGER NOT NULL,
                        round_time REAL NOT NULL,
                        FOREIGN KEY(round_id) REFERENCES ]] .. roundIdTable.tableName .. [[(id),
                        FOREIGN KEY(player_id) REFERENCES ]] .. playerIdTable.tableName .. [[(id),
                        FOREIGN KEY(weapon_id) REFERENCES ]] .. weaponIdTable.tableName .. [[(id))]]
                        
local shotsFiredTable = DDD.Table:new("ddd_shots_fired", columns)

function shotsFiredTable:addShot(playerId, weaponId)
end

shotsFiredTable:create()
DDD.Database.Tables.ShotsFired = shotsFiredTable