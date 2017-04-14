local aggregateWeaponStatsTest = GUnit.Test:new("AggregateWeaponStatsTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.AggregateStats.tables = tables
  tables.AggregateWeaponStats.tables = tables
  tables.MapId:addMap()
  --tables.WeaponId:getOrAddWeaponId("ttt_c4")
end

local function afterEach()
  --DDDTest.Helpers.dropAll(tables)
  DDD.Logging:enable()
end

--TODO: Put this in a helper singleton because there's a duplicate function in AggregateWeaponStats
local function filterContains(weaponClass)
  for key, value in pairs(DDD.Config.AggregateWeaponStatsFilter) do
    if (value == weaponClass) then
      return true
    end
  end

  return false
end

local function recalculateWeaponDataSpec()
  local oldRows = {}
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)
  local weaponList = weapons.GetList()
  local weaponSqlIds = {}

  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateWeaponStats:addPlayer(fakePlayer.tableId)
  end

  for index, weaponInfo in pairs(weaponList) do
    if (weaponInfo.ClassName and !filterContains(weaponInfo.ClassName)) then
      local weaponId = tables.WeaponId:addWeapon(weaponInfo.ClassName)
      weaponSqlIds[weaponId] = weaponInfo.ClassName
    end
  end

  local attacker = fakePlayerList[1]
  GUnit.assert(attacker.tableId):shouldEqual(1)

  for i = 1, 100 do
    local victim = fakePlayerList[math.random(2, #fakePlayerList)]
    local weaponId = math.random(1, #weaponSqlIds)
    local weaponClass = weaponSqlIds[weaponId]
    attacker:SetRole(math.random(0, 2))
    victim:SetRole(math.random(0, 2))
    tables.RoundId:addRound()
    tables.RoundRoles:addRole(attacker)
    tables.RoundRoles:addRole(victim)

    tables.PlayerKill:addKill(victim.tableId, attacker.tableId, weaponId)
    tables.AggregateWeaponStats:incrementKillColumn(
                        weaponClass, attacker.tableId, attacker:GetRole(), victim:GetRole())
    tables.AggregateWeaponStats:incrementDeathColumn(
                        weaponSqlIds[weaponId], victim.tableId, attacker:GetRole(), victim:GetRole())

  end

  for i = 1, #fakePlayerList do
    table.insert(oldRows, tables.AggregateWeaponStats:getPlayerStats(i))
  end

  tables.AggregateWeaponStats:recalculate()

for i = 1, #fakePlayerList do
  local newRow = tables.AggregateWeaponStats:getPlayerStats(i)

    for columnName, columnValue in pairs(newRow) do
      --print(columnName .. " value is " .. columnValue .. ", was " .. oldRows[i][columnName])
      GUnit.assert(oldRows[i][columnName]):shouldEqual(columnValue)
    end
  end
end

aggregateWeaponStatsTest:beforeEach(beforeEach)
aggregateWeaponStatsTest:afterEach(afterEach)

aggregateWeaponStatsTest:addSpec("recalculate every player's kills, deaths, and shots fired from the raw data", recalculateWeaponDataSpec)
