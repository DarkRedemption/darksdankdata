local simulatedRoundTest = GUnit.Test:new("SimulatedRound")
local tables = {}

local makePlayerList = DDDTest.Helpers.Generators.makePlayerIdList
local SimulatedRoundBuilder = DDDTest.Helpers.Generators.SimulatedRoundBuilder

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
  DDD.Logging:enable()
end

local function shuffleArraySpec()
  for i = 1, 10 do
    local players = makePlayerList(tables, 10, 100)
    local builder = SimulatedRoundBuilder:new()
    
    local shuffled = false
    local newPlayerArray = builder:shuffleArray(players)
    
    for i = 1, #players do
      --Check an actual value inside to be sure we aren't comparing with something like 'nil'.
      if (players[i]:GetName() != newPlayerArray[i]:GetName()) then
        shuffled = true
        break
      end
    end
    
    GUnit.assert(shuffled):isTrue()
  end
end

local function uniquePairsSpec()
  GUnit.pending()
  for i = 1, 10 do
    local players = makePlayerList(tables, 10, 100)
    local builder = SimulatedRoundBuilder:new()
    
    local isUnique = true
    local newPlayerArray = builder:shuffleArray(players)
    
    for i = 1, #players do
      --Check an actual value inside to be sure we aren't comparing with something like 'nil'.
      if (players[i]:GetName() != newPlayerArray[i]:GetName()) then
        shuffled = true
        break
      end
    end
    
    GUnit.assert(shuffled):isTrue()
  end
end


simulatedRoundTest:beforeEach(beforeEach)
simulatedRoundTest:afterEach(afterEach)

simulatedRoundTest:addSpec("shuffle arrays", shuffleArraySpec)
simulatedRoundTest:addSpec("find unique pairs in an array of players", uniquePairsSpec)
simulatedRoundTest:addSpec("find unique pairs in an array of players where a specific player is in each pair", GUnit.pending)
simulatedRoundTest:addSpec("have no kills from allied teams in a clean round", GUnit.pending)