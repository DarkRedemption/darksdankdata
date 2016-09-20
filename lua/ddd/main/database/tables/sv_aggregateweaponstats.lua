--Holds aggregate data specifically for individual weapons.
--Made into its own table due to the number of columns each weapon produces for each role.

local function generateWeaponColumns()
  local columns = { player_id = "INTEGER NOT NULL" }
  local weapons = weapons.GetAll()
  
  for key, value in pairs(weapons) do
    if (value.ClassName) then
      columns[value.ClassName] = "INTEGER NOT NULL DEFAULT 0"
    end
  end
  
  return columns
end

local columns = generateWeaponColumns()

local aggregateWeaponStatsTable = DDD.SqlTable:new("ddd_aggregate_weapon_stats", columns)

local function countResult(result)
  if (result == nil) then
    DDD.Logging.logDebug("sv_aggregateweaponstats.lua.countResult: The query returned no information.")
    return 0
  elseif (result == false) then
    DDD.Logging.logError("sv_aggregateweaponstats.lua.countResult: An error occured. Error was: " .. sql.LastError())
    return -1
else 
  return result[1]["count"]
  end
end

function aggregateWeaponStatsTable:selectWeaponKills()
  local query = [[SELECT kills.*, weapons.weapon_class FROM ]] 
                .. self.tables.PlayerKill.tableName .. 
                [[ as kills LEFT JOIN ]] 
                .. self.tables.WeaponId.tableName .. 
                [[ WHERE kills.weapon_id == weapons.id]]
  
  return SqlTable.query("aggregateWeaponStatsTable:selectWeaponKills", query)
end

function aggregateWeaponsStatsTable:recalculate()
end