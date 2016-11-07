local aggregateStatsTest = GUnit.Test:new("AggregateStatsTable")
local tables = {}

local traitorValidPurchases = { "1",
                                "2",
                                "weapon_ttt_flaregun",
                                "weapon_ttt_knife",
                                "weapon_ttt_teleport",
                                "weapon_ttt_radio",
                                "weapon_ttt_push",
                                "weapon_ttt_sipistol",
                                "weapon_ttt_decoy",
                                "weapon_ttt_phammer",
                                "weapon_ttt_c4"}

  local detectiveValidPurchases = { "2", --Forget the body armor since you start with it
                                "weapon_ttt_cse",
                                "weapon_ttt_defuser",
                                "weapon_ttt_teleport",
                                "weapon_ttt_binoculars",
                                "weapon_ttt_stungun",
                                "weapon_ttt_health_station"}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.AggregateStats.tables = tables
  tables.MapId:addMap()
  tables.WeaponId:getOrAddWeaponId("ttt_c4")
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
  DDD.Logging:enable()
end

local function allColumnsZero(row)
  for columnName, value in pairs(row) do
    if (columnName != "player_id") then
      GUnit.assert(value):shouldEqual("0")
    end
  end
end

local function genAndAddPlayer()
  local ply = GUnit.Generators.FakePlayer:new()
  local id = tables.PlayerId:addPlayer(ply)
  local result = tables.AggregateStats:addPlayer(id)
  GUnit.assert(result):shouldEqual(id)

  return ply, id
end

--[[
A higher order function that creates a standard test for aggregate table incrementation functions.
PARAM getFunc: Int, Int, Int => Int - The function that takes a playerId, playerRole, and otherPlayerRole to get the value.
PARAM incrementFunc: Int, Int, Int => Int - The function that takes the same as above to increment the value.
RETURNS Int, Int, Int => Int - A new function that will call the getFunc, the incrementFunc, and ensure incrementFunc = getFunc + 1
]]
local function buildIncrementingFunctionTest(tables, getFunc, incrementFunc)

  local newFunc = function(id, ...)
    local arg = {...}
    local originalValue = getFunc(tables.AggregateStats, id, unpack(arg))
    incrementFunc(tables.AggregateStats, id, unpack(arg))
    local row = tables.AggregateStats:getPlayerStats(id)
    local newValue = getFunc(tables.AggregateStats, id, unpack(arg))
    GUnit.assert(newValue):shouldEqual(originalValue + 1)
  end

  return newFunc
end


local function confirmRecalculatedValuesMatchOriginal(tables, playerList)
  local oldRows = {}

  for i = 1, #playerList do
    table.insert(oldRows, tables.AggregateStats:getPlayerStats(i))
  end

  tables.AggregateStats:recalculate()

  for i = 1, #playerList do
    local newRow = tables.AggregateStats:getPlayerStats(i)

    for columnName, columnValue in pairs(newRow) do
      GUnit.assert(oldRows[i][columnName]):shouldEqual(columnValue)
    end
  end
end

--
-- Misc Specs
--

local function addPlayerSpec()
  for i = 1, 100 do
    local ply, id = genAndAddPlayer()

    local row = tables.AggregateStats:getPlayerStats(id)
    allColumnsZero(row)
  end
end

--
-- Increment Specs
--

local function incrementRoundsSpec()
  local ply, id = genAndAddPlayer()

  for i = 1, 100 do
    local playerRole = math.random(0, 2)

    local testFunc = buildIncrementingFunctionTest(tables, tables.AggregateStats.getRounds, tables.AggregateStats.incrementRounds)
    testFunc(id, playerRole)
  end
end

local function incrementRoundsWonSpec()
  local ply, id = genAndAddPlayer()

  for i = 1, 100 do
    local playerRole = math.random(0, 2)

    local testFunc = buildIncrementingFunctionTest(tables, tables.AggregateStats.getRoundsWon, tables.AggregateStats.incrementRoundsWon)
    testFunc(id, playerRole)
  end
end

local function incrementRoundsLostSpec()
  local ply, id = genAndAddPlayer()

  for i = 1, 100 do
    local playerRole = math.random(0, 2)

    local testFunc = buildIncrementingFunctionTest(tables, tables.AggregateStats.getRoundsLost, tables.AggregateStats.incrementRoundsLost)
    testFunc(id, playerRole)
  end
end

local function incrementKillsSpec()
  local ply, id = genAndAddPlayer()

  for i = 1, 100 do
    local playerRole = math.random(0, 2)
    local victimRole = math.random(0, 2)

    local testFunc = buildIncrementingFunctionTest(tables, tables.AggregateStats.getKills, tables.AggregateStats.incrementKills)
    testFunc(id, playerRole, victimRole)
  end
end

local function incrementDeathsSpec()
  local ply, id = genAndAddPlayer()

  for i = 1, 100 do
    local playerRole = math.random(0, 2)
    local attackerRole = math.random(0, 2)

    local testFunc = buildIncrementingFunctionTest(tables, tables.AggregateStats.getDeaths, tables.AggregateStats.incrementDeaths)
    testFunc(id, playerRole, attackerRole)
  end
end

local function incrementSuicidesSpec()
  local ply, id = genAndAddPlayer()

  for i = 1, 100 do
    local playerRole = math.random(0, 2)

    local testFunc = buildIncrementingFunctionTest(tables, tables.AggregateStats.getSuicides, tables.AggregateStats.incrementSuicides)
    testFunc(id, playerRole)
  end
end

local function incrementWorldDeathsSpec()
  local ply, id = genAndAddPlayer()

  for i = 1, 100 do
    local playerRole = math.random(0, 2)

    local testFunc = buildIncrementingFunctionTest(tables, tables.AggregateStats.getWorldDeaths, tables.AggregateStats.incrementWorldDeaths)
    testFunc(id, playerRole)
  end
end

local function incrementPurchasesSpec()
  local ply, id = genAndAddPlayer()

  for i = 1, 100 do
    local playerRole = math.random(1, 2)
    ply:SetRole(playerRole)

    local thisRoundsPurchase
    if (playerRole == 1) then
      thisRoundsPurchase = traitorValidPurchases[math.random(1, #traitorValidPurchases)]
    else
      thisRoundsPurchase = detectiveValidPurchases[math.random(1, #detectiveValidPurchases)]
    end

    local testFunc = buildIncrementingFunctionTest(tables,
                                                   tables.AggregateStats.getItemPurchases,
                                                   tables.AggregateStats.incrementItemPurchases)
    testFunc(id, playerRole, thisRoundsPurchase)
  end
end

local function incrementC4KillsSpec()
  local ply, id = genAndAddPlayer()

  for i = 1, 100 do
    local playerRole = math.random(0, 2)
    local victimRole = math.random(0, 2)
    local weaponName = "ttt_c4"

    local testFunc = buildIncrementingFunctionTest(tables, tables.AggregateStats.getWeaponKills, tables.AggregateStats.incrementWeaponKills)
    testFunc(id, playerRole, victimRole, weaponName)
  end
end

local function incrementSelfHealingSpec()
  local ply, id = genAndAddPlayer()

  for i = 1, 100 do
    local playerRole = math.random(0, 2)

    local testFunc = buildIncrementingFunctionTest(tables, tables.AggregateStats.getSelfHPHealed, tables.AggregateStats.incrementSelfHPHealed)
    testFunc(id)
  end
end

--
-- Recalculation specs
--

local function recalculateKillsSpec()
  --The rows before recalculating should equal the recalculated rows
  local oldRows = {}
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
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

local function recalculateRoundsWonSpec()
  local oldRows = {}
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end

  for i = 1, 100 do
    local ply = fakePlayerList[math.random(1, #fakePlayerList)]

    tables.RoundId:addRound()

    local role = math.random(0, 2)
    ply:SetRole(role)
    tables.RoundRoles:addRole(ply)

    local result = 0
    if role == 1 then
      result = WIN_TRAITOR -- 2
    else
      result = math.random(WIN_INNOCENT, WIN_TIMELIMIT) -- 3, 4
    end

    tables.RoundResult:addResult(result)

    tables.AggregateStats:incrementRounds(ply.tableId, ply:GetRole())
    tables.AggregateStats:incrementRoundsWon(ply.tableId, ply:GetRole())
  end

  confirmRecalculatedValuesMatchOriginal(tables, fakePlayerList)
end

local function recalculateRoundsLostSpec()
  local oldRows = {}
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end

  for i = 1, 100 do
    local ply = fakePlayerList[math.random(1, #fakePlayerList)]

    tables.RoundId:addRound()

    local role = math.random(0, 2)
    ply:SetRole(role)
    tables.RoundRoles:addRole(ply)

    local result = 0
    if role != 1 then
      result = WIN_TRAITOR -- 2
    else
      result = math.random(WIN_INNOCENT, WIN_TIMELIMIT) -- 3, 4
    end

    tables.RoundResult:addResult(result)

    tables.AggregateStats:incrementRounds(ply.tableId, ply:GetRole())
    tables.AggregateStats:incrementRoundsLost(ply.tableId, ply:GetRole())
  end

  confirmRecalculatedValuesMatchOriginal(tables, fakePlayerList)
end

local function recalculateWithNoDataSpec()
  for i = 1, 100 do
    local ply, id = genAndAddPlayer()
    tables.AggregateStats:incrementKills(id, 0, 0)

    local row = tables.AggregateStats:getPlayerStats(id)
    GUnit.assert(row["innocent_innocent_kills"]):shouldEqual("1")
  end

  tables.AggregateStats:recalculate()

  for i = 1, 100 do
    local newRow = tables.AggregateStats:getPlayerStats(i)
    allColumnsZero(newRow)
  end
end

local function recalculateCombatDataSpec()
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end

  for i = 1, 100 do
    local weaponId = tables.WeaponId:addWeapon(GUnit.Generators.StringGen.generateAlphaNum())
    local attacker, victim = DDDTest.Helpers.getRandomPair(fakePlayerList)
    GUnit.assert(attacker):shouldNotEqual(victim)

    tables.RoundId:addRound()
    tables.RoundRoles:addRole(attacker)
    tables.RoundRoles:addRole(victim)

    tables.PlayerKill:addKill(victim.tableId, attacker.tableId, weaponId)
    tables.AggregateStats:incrementKills(attacker.tableId, attacker:GetRole(), victim:GetRole())
    tables.AggregateStats:incrementDeaths(victim.tableId, victim:GetRole(), attacker:GetRole())
    tables.AggregateStats:incrementRounds(attacker.tableId, attacker:GetRole())
    tables.AggregateStats:incrementRounds(victim.tableId, victim:GetRole())
  end

  confirmRecalculatedValuesMatchOriginal(tables, fakePlayerList)
end

local function recalculateSuicideDataSpec()
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end

  for i = 1, 100 do
    local suicider = fakePlayerList[math.random(1, #fakePlayerList)]
    local role = math.random(0, 2)
    local weaponId = tables.WeaponId:addWeapon(GUnit.Generators.StringGen.generateAlphaNum())

    suicider:SetRole(role)
    tables.RoundId:addRound()
    tables.RoundRoles:addRole(suicider)

    tables.PlayerKill:addKill(suicider.tableId, suicider.tableId, weaponId)
    tables.AggregateStats:incrementSuicides(suicider.tableId, suicider:GetRole())
    tables.AggregateStats:incrementDeaths(suicider.tableId, suicider:GetRole(), suicider:GetRole())
    tables.AggregateStats:incrementRounds(suicider.tableId, suicider:GetRole())
  end

  confirmRecalculatedValuesMatchOriginal(tables, fakePlayerList)
end

local function recalculateWorldDeathsSpec()
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end

  for i = 1, 100 do
    local victim = fakePlayerList[math.random(1, #fakePlayerList)]

    tables.RoundId:addRound()
    tables.RoundRoles:addRole(victim)

    tables.WorldKill:addPlayerKill(victim.tableId)
    tables.AggregateStats:incrementWorldDeaths(victim.tableId, victim:GetRole())
    tables.AggregateStats:incrementRounds(victim.tableId, victim:GetRole())
  end

  confirmRecalculatedValuesMatchOriginal(tables, fakePlayerList)
end

local function recalculatePurchasesSpec()
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end

  for i = 1, 100 do
    local player = fakePlayerList[math.random(1, #fakePlayerList)]
    local playerRole = math.random(1, 2)

    player:SetRole(playerRole)
    tables.RoundId:addRound()
    tables.RoundRoles:addRole(player)

    local thisRoundsPurchase
    if (playerRole == 1) then
      thisRoundsPurchase = traitorValidPurchases[math.random(1, #traitorValidPurchases)]
    else
      thisRoundsPurchase = detectiveValidPurchases[math.random(1, #detectiveValidPurchases)]
    end

    local shopItemId = tables.ShopItem:getOrAddItemId(thisRoundsPurchase)
    local purchaseId = tables.Purchases:addPurchase(player.tableId, shopItemId)
    GUnit.assert(purchaseId):shouldEqual(i)

    tables.AggregateStats:incrementItemPurchases(player.tableId, playerRole, thisRoundsPurchase)
    tables.AggregateStats:incrementRounds(player.tableId, player:GetRole())
  end

  confirmRecalculatedValuesMatchOriginal(tables, fakePlayerList)
end

local function recalculateC4KillsSpec()
  --The rows before recalculating should equal the recalculated rows
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end

  local attacker = fakePlayerList[1]
  GUnit.assert(attacker.tableId):shouldEqual(1)

  for i = 1, 100 do
    local victim = fakePlayerList[math.random(2, #fakePlayerList)]
    local weaponName = "ttt_c4"
    local weaponId = tables.WeaponId:getOrAddWeaponId(weaponName)

    tables.RoundId:addRound()
    tables.RoundRoles:addRole(attacker)
    tables.RoundRoles:addRole(victim)

    tables.PlayerKill:addKill(victim.tableId, attacker.tableId, weaponId)
    tables.AggregateStats:incrementKills(attacker.tableId, attacker:GetRole(), victim:GetRole())
    tables.AggregateStats:incrementWeaponKills(attacker.tableId, attacker:GetRole(), victim:GetRole(), weaponName)
    tables.AggregateStats:incrementRounds(attacker.tableId, attacker:GetRole())
    tables.AggregateStats:incrementRounds(victim.tableId, victim:GetRole())
  end

  local oldRows = {}

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

local function recalculateSelfHPHealedSpec()
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end

  for i = 1, 100 do
    local healer = fakePlayerList[math.random(1, #fakePlayerList)]
    local id = healer.tableId

    tables.RoundId:addRound()
    tables.RoundRoles:addRole(healer)

    for x = 1, math.random(1, 10) do
      tables.Healing:addHeal(id, id, 1)
      tables.AggregateStats:incrementSelfHPHealed(id)
    end

    tables.AggregateStats:incrementRounds(healer.tableId, healer:GetRole())
  end

  confirmRecalculatedValuesMatchOriginal(tables, fakePlayerList)
end

aggregateStatsTest:beforeEach(beforeEach)
aggregateStatsTest:afterEach(afterEach)

aggregateStatsTest:addSpec("add a player with no stats", addPlayerSpec)
aggregateStatsTest:addSpec("increment rounds properly", incrementRoundsSpec)
aggregateStatsTest:addSpec("increment rounds won properly", incrementRoundsWonSpec)
aggregateStatsTest:addSpec("increment rounds lost properly", incrementRoundsLostSpec)
aggregateStatsTest:addSpec("increment kills properly", incrementKillsSpec)
aggregateStatsTest:addSpec("increment deaths properly", incrementDeathsSpec)
aggregateStatsTest:addSpec("increment suicides properly", incrementSuicidesSpec)
aggregateStatsTest:addSpec("increment world deaths properly", incrementWorldDeathsSpec)
aggregateStatsTest:addSpec("increment item purchases properly", incrementPurchasesSpec)
aggregateStatsTest:addSpec("increment c4 kills properly", incrementC4KillsSpec)
aggregateStatsTest:addSpec("increment healing properly", incrementSelfHealingSpec)

aggregateStatsTest:addSpec("calculate a player's kills accurately", recalculateKillsSpec)
aggregateStatsTest:addSpec("recalculate every player's stats who actually has no data", recalculateWithNoDataSpec)
aggregateStatsTest:addSpec("recalculate a player's rounds won", recalculateRoundsWonSpec)
aggregateStatsTest:addSpec("recalculate a player's rounds lost", recalculateRoundsLostSpec)
aggregateStatsTest:addSpec("recalculate every player's combat stats with data", recalculateCombatDataSpec)
aggregateStatsTest:addSpec("recalculate every player's suicides with data", recalculateSuicideDataSpec)
aggregateStatsTest:addSpec("recalculate every player's world deaths with data", recalculateWorldDeathsSpec)
aggregateStatsTest:addSpec("recalculate every player's purchases with data", recalculatePurchasesSpec)
aggregateStatsTest:addSpec("recalculate every player's c4 kills with data", recalculateC4KillsSpec)
aggregateStatsTest:addSpec("recalculate every player's healing stats with data", recalculateSelfHPHealedSpec)
