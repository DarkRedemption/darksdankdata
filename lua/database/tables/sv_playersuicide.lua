local playerIdTable = DDD.Database.Tables.PlayerId
local weaponIdTable = DDD.Database.Tables.WeaponId
local mapIdTable = DDD.Database.Tables.MapId
local roundIdTable = DDD.Database.Tables.RoundId

local roles = DDD.Database.Roles

local columns = [[ ( id INTEGER PRIMARY KEY,
                        round_id INTEGER NOT NULL,
                        victim_id INTEGER NOT NULL, 
                        attacker_id INTEGER NOT NULL,
                        weapon_id INTEGER NOT NULL,
                        round_time REAL NOT NULL,
                        FOREIGN KEY(round_id) REFERENCES ]] .. roundIdTable.tableName .. [[(id),
                        FOREIGN KEY(victim_id) REFERENCES ]] .. playerIdTable.tableName .. [[(id),
                        FOREIGN KEY(attacker_id) REFERENCES ]] .. playerIdTable.tableName .. [[(id),
                        FOREIGN KEY(weapon_id) REFERENCES ]] .. weaponIdTable.tableName .. [[(id))]]
                        
local playerKillTable = DDD.Table:new("ddd_player_kill", columns)