--Simulates a round in the database.
--This means creating a round with random players/kills/damage/shots/ids/etc.

local simulatedRoundBuilder = {}
simulatedRoundBuilder.__index = simulatedRoundBuilder

local function arrayContains(array, value)
  for k, v in pairs(array) do
    if (v == value) then return true end
  end
  return false
end

--[[
Finds unique pairs of fake players.
PARAM players:Array[FakePlayer] - An array of players where the index is equal to their id in the test database.
PARAM pairsNeeded:Int - Number of pairs to generate
PARAM id:Int - The id to pair up with.
]]
function simulatedRoundBuilder:findUniquePairs(players, pairsNeeded, id) 
  local arraySize = table.getn(players)
  assert(pairsNeeded < players)
  
  local function pairExists(pairTable, playerIdOne, playerIdTwo)
    return arrayContains(pairTable[playerIdOne], playerIdTwo)
  end

  local function addPair(pairTable, playerIdOne, playerIdTwo)
    if pairTable[playerIdOne] == nil then
      pairTable[playerIdOne] = {}
    end
    table.add(pairTable[playerIdOne], playerIdTwo)
  end
  
  local function generate(pairTable, pairTableSize)
    if (pairsNeeded == pairTableSize) then
      return pairTable
    else
      local first = id or math.random(1, arraySize)
      local second = math.random(1, arraySize)
      if (first == second || pairExists(pairTable, first, second)) then
        return generate(pairTable, pairTableSize)
      else
        addPair(pairTable, first, second)
        return generate(pairTable, pairTableSize + 1)
      end
    end
  end
  
  return generate({}, 0)
end

function simulatedRoundBuilder:shuffleArray(array)
  local totalIterations = math.floor(#array / 2)
  local newArray = table.Copy(array) --Prevent changes to the original array.
  
  local function shuffle(iteration)
    if (iteration == totalIterations) then return newArray end
    local indexOne = math.random(1, #array)
    local indexTwo = math.random(1, #array)
    newArray[indexOne], newArray[indexTwo] = newArray[indexTwo], newArray[indexOne]
    return shuffle(iteration + 1)
  end
  
  return shuffle(0) 
end

--[[
Sets everyone's round roles to the ratios of a standard TTT round.
A standard TTT round has 1 traitor for every 4 players, and 1 detective for every 8 players.
PARAM randomPlayers:Array[FakePlayer] - An array of generated players whose order is random relative to their database IDs.
RETURNS The modified randomPlayers.
]]
function simulatedRoundBuilder:setRoundRolesToTTTStandards(randomPlayers)
  local traitorRatio = 0.25
  local detectiveRatio = 0.125
  
  local traitorsThisRound = math.floor(randomPlayers * traitorRatio)
  local detectivesThisRound = math.floor(randomPlayers * detectiveRatio)
  
  local currentTraitors = 0
  local currentDetectives = 0
  
  for k, v in pairs(randomPlayers) do
    if (currentTraitors != traitorsThisRound) then
      v:SetRole(1)
    elseif (currentDetectives != detectivesThisRound) then
      v:SetRole(2)
    else
      v:SetRole(0)
    end
  end
  
  return randomPlayers
end

--[[
SimulatedRoundBuilder creates a variety of round data for use with tests on things 
such as rank, achievements, and aggregate data.
PARAM tables:Table[String -> SqlTable] - The SqlTables to output the data to.
]]
function simulatedRoundBuilder:new(tables)
  local newBuilder = {}
  setmetatable(newBuilder, self)
  newBuilder.tables = tables
  newBuilder.roundsToGenerate = 250
  newBuilder.players = 100
  newBuilder.minPlayers = 2
  newBuilder.maxPlayers = 32
  return newBuilder
end

function simulatedRoundBuilder:build()
end

DDDTest.Helpers.Generators.SimulatedRoundBuilder = simulatedRoundBuilder