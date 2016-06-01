local playerStatsTest = GUnit.Test:new("PlayerStats")
local tables = {}
local roles = DDD.Database.Roles
local makePlayerIdList = DDDTest.Helpers.Generators.makePlayerIdList

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
  tables = nil
end

--[[
Checks if an array contains a value.
PARAM array:Array[T] - An array of elements of any type.
PARAM value:T - The value of the same type as the elements of the array.  
]]
local function arrayContains(array, value)
end

--[[
Generates a list of unique pairs from a list.
PARAM array:Array[Any] - An array of elements of any type.
PARAM pairsNeeded - The number of unique pairs to return.
]]
local function getUniquePairs(array, pairsNeeded)
  local arraySize = table.getn(array)
  GUnit.assert(pairsNeeded)
  
  local function generate(currentTable, currentTableSize)
    if (pairsNeeded == currentTableSize) then
      return currentTable
    else
      --TODO: Finish this after doing achievements/ranks
      local first = math.random(1, 1)
      local second = math.random(1, table.getn(list))
      if (first == second || currentTable[attacker] != nil) then
        return generate(currentTable, currentTableSize)
      else
        currentTable[attacker] = victim
        return generate(currentTable, currentTableSize + 1)
      end
    end
  end
  
  return generate({}, 0)
end

local function roundsPlayedSpec()
  local player = GUnit.Generators.FakePlayer:new()
  local playerId = tables.PlayerId:addPlayer(player)
  
  local totalRounds = math.random(2, 300)
  local innocentRounds = 0
  local traitorRounds = 0
  local detectiveRounds = 0
  
  for i = 1, totalRounds do
    local role = math.random(0, 2)
    if (role == 0) then 
      innocentRounds = innocentRounds + 1
    elseif (role == 1) then 
      traitorRounds = traitorRounds + 1
    elseif (role == 2) then 
      detectiveRounds = detectiveRounds + 1
    end
    
    player:SetRole(role)
    tables.RoundId:addRound()
    local roundRoleId = tables.RoundRoles:addRole(player)
    GUnit.assert(roundRoleId):shouldEqual(i)
  end
  
  local playerStats = DDD.Database.PlayerStats:new(player, tables)
  playerStats:updateRoleData()
  local tableInnocentRounds = tonumber(playerStats.statsTable["InnocentRounds"])
  local tableTraitorRounds = tonumber(playerStats.statsTable["TraitorRounds"])
  local tableDetectiveRounds = tonumber(playerStats.statsTable["DetectiveRounds"])
  
  GUnit.assert(tableInnocentRounds):shouldEqual(innocentRounds)
  GUnit.assert(tableTraitorRounds):shouldEqual(traitorRounds)
  GUnit.assert(tableDetectiveRounds):shouldEqual(detectiveRounds)
end

local function getRoleAssistsSpec()
  GUnit.pending()
  local player = GUnit.Generators.FakePlayer:new()
  local playerId = tables.PlayerId:addPlayer(player)
  
  --Make a list of random player Ids to get "killed"
  --TODO: adjust makePlayerIdList usage with the fact that it's now an of int -> player
  local potentialKillerId, killerIdSize = makePlayerIdList(tables, 1, 20)
  local totalRounds = math.random(2, 300)
  local innocentAssists = 0
  local traitorRounds = 0
  local detectiveRounds = 0
  
  for i = 1, totalRounds do
    local role = math.random(0, 2)
    if (role == 0) then 
      innocentRounds = innocentRounds + 1
    elseif (role == 1) then 
      traitorRounds = traitorRounds + 1
    elseif (role == 2) then 
      detectiveRounds = detectiveRounds + 1
    end
    
    player:SetRole(role)
    tables.RoundId:addRound()
    local roundRoleId = tables.RoundRoles:addRole(player)
    GUnit.assert(roundRoleId):shouldEqual(i)
  end
  
  local playerStats = DDD.Database.PlayerStats:new(player, tables)
  playerStats:updateRoleData()
  local tableInnocentAssists = tonumber(playerStats.statsTable["InnocentAssists"])
  local tableTraitorAssists = tonumber(playerStats.statsTable["TraitorAssists"])
  local tableDetectiveAssists = tonumber(playerStats.statsTable["DetectiveAssists"])
  
  GUnit.assert(tableInnocentAssists):shouldEqual(innocentAssists)
  GUnit.assert(tableTraitorAssists):shouldEqual(traitorAssists)
  GUnit.assert(tableDetectiveAssists):shouldEqual(detectiveAssists)
end

playerStatsTest:beforeEach(beforeEach)
playerStatsTest:afterEach(afterEach)

playerStatsTest:addSpec("get the right number of rounds played in a role", roundsPlayedSpec)

playerStatsTest:addSpec("get the right number of assists in a role", getRoleAssistsSpec)