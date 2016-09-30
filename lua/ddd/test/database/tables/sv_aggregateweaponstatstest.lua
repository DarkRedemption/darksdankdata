local aggregateWeaponStatsTest = GUnit.Test:new("AggregateWeaponStatsTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.AggregateStats.tables = tables
  tables.AggregateWeaponStats.tables = tables
  tables.MapId:addMap()
  tables.WeaponId:getOrAddWeaponId("ttt_c4")
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
  DDD.Logging:enable()
end

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

local function recalculateWeaponKillsSpec()
  local oldRows = {}
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)
  local weapons = weapons.GetList()
  local weaponSqlIds = {}
  
  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateWeaponStats:addPlayer(fakePlayer.tableId)
  end
  
  for index, weaponInfo in pairs(weapons) do
    local weaponId = tables.WeaponId:addWeapon(weapons.className)
    weaponSqlIds[weaponId] = weapons.className
  end

  local attacker = fakePlayerList[1]
  GUnit.assert(attacker.tableId):shouldEqual(1)
  
  for i = 1, 100 do
    local victim = fakePlayerList[math.random(2, #fakePlayerList)]
    local weaponId = tables.WeaponId:addWeapon(GUnit.Generators.StringGen.generateAlphaNum())
    
    tables.RoundId:addRound()
    tables.RoundRoles:addRole(attacker)
    tables.RoundRoles:addRole(victim)
    
    tables.PlayerKill:addKill(victim.tableId, attacker.tableId, weaponId)
    tables.AggregateStats:incrementKills(attacker.tableId, attacker:GetRole(), victim:GetRole())
    tables.AggregateStats:incrementRounds(attacker.tableId, attacker:GetRole())
  end
  
  for i = 1, #fakePlayerList do
    table.insert(oldRows, tables.AggregateStats:getPlayerStats(i))
  end
  
  tables.AggregateStats:recalculate()
  
  local newRow = tables.AggregateStats:getPlayerStats(1)
    
  --Needs to only check kills
  for columnName, columnValue in pairs(newRow) do
    GUnit.assert(oldRows[1][columnName]):shouldEqual(columnValue)
  end
end

aggregateWeaponStatsTest:beforeEach(beforeEach)
aggregateWeaponStatsTest:afterEach(afterEach)

--aggregateWeaponStatsTest:addSpec("add columns based on available SWEPs", addWeaponColumnsTest)
--aggregateWeaponStatsTest:addSpec("recalculate every player's kills from the raw data", recalculateWeaponKillsSpec)