local rankTableTest = GUnit.Test:new("RankTable")
local tables = {}

local makePlayerIdList = DDDTest.Helpers.Generators.makePlayerIdList

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
  DDD.Logging:enable()
end

local function enemyKdTest()
  GUnit.pending()
  local players = makePlayerIdList(tables, 1000)
  local fiveKillOneDeathId = math.random(1, 1000)
  for i = 1, 100 do
    local id = tables.RoundId:addRound()
    local numPlayers = math.random(2, 64)
    local randomPlayerIds = getRandomPlayerIds(players, numPlayers)
    local randomPlayers = {}
    for k, v in pairs(randomPlayerIds) do
      table.add(randomPlayers, players[v])
    end
    setRoundRolesToTTTStandards(randomPlayers)
    tables.RoundRoles:addRole(randomPlayers)
  end
  --Make a set number of kills and ensure the K/D is right
end

local function noAllyKdTest()
  --Everyone's K/D should be 0 here
end

rankTableTest:beforeEach(beforeEach)
rankTableTest:afterEach(afterEach)
--rankTableTest:addSpec("ignore players with less than 100 kills", GUnit.pending)
rankTableTest:addSpec("get the total enemy kd of each player properly", enemyKdTest)
--rankTableTest:addSpec("not count killing allies in the total enemy kd", GUnit.pending)

