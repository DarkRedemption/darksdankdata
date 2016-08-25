local rankTableTest = GUnit.Test:new("RankTable")
local tables = {}

local makePlayerIdList = DDDTest.Helpers.Generators.makePlayerIdList

local function arrayContains(array, value)
  for k, v in pairs(array) do
    if (v == value) then return true end
  end
  return false
end

local function generateCombatData()
end

local function generateRoundData(tables, players)
  local id = tables.RoundId:addRound()
  local numPlayers = math.random(2, 64)
  local randomPlayerIds = getRandomPlayerIds(players, numPlayers)
  for k, v in pairs(randomPlayerIds) do
    table.add(randomPlayers, players[v])
  end
  
end

local function generateRandomData(tables)
  local players = makePlayerIdList(tables, 100)
  for i = 1, 500 do
    
  end
end

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
  DDD.Logging:enable()
end

--[[
Gets a list of random player ids for the round,
but always includes player ID 1.
]]
local function getRandomPlayerIdsWithPlayerOne(players, maxPlayers)
  local numAdditionalPlayers = math.random(1, maxPlayers - 1)
  
  local function selectPlayers(numRemaining, randomPlayers)
    if numRemaining == 0 then return randomPlayers end
    
    local randomPlayer = math.random(2, #players)
    
    if arrayContains(randomPlayers, players[randomPlayer]) then
      return selectPlayers(numRemaining)
    else
      table.add(randomPlayers, players[randomPlayer])
      return selectPlayers(numRemaining - 1)
    end
  end
  
  return selectPlayers(numAdditionalPlayers, {players[1]})
end

local function enemyKdTest()
  GUnit.pending()
  
  for i = 1, 250 do
    local id = tables.RoundId:addRound()
    
    local randomOtherPlayerIds = getRandomPlayerIdsWithPlayerOne(players, 32)
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

