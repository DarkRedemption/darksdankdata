local aggregateWeaponStatsTest = GUnit.Test:new("AggregateWeaponStatsTable")
local tables = {}

local function addWeaponColumnsTest()
  local columns = { player_id = "INTEGER NOT NULL" }
  local weapons = weapons.GetList()
  
  for key, value in pairs(weapons) do
    if (value.ClassName) then
      columns[value.ClassName] = "INTEGER NOT NULL DEFAULT 0"
    end
  end
  
  PrintTable(columns)
end

local function selectWeaponKillsSpec()
  PrintTable(aggregateWeaponStatsTable:selectWeaponKills())
end


--aggregateWeaponStatsTest:addSpec("add columns based on available SWEPs", addWeaponColumnsTest)
--aggregateWeaponStatsTest:addSpec("select all the kills made by available SWEPs", addWeaponColumnsTest)