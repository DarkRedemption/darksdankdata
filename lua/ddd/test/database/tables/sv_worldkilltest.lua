local worldKillTableTest = GUnit.Test:new("WorldKillTable")

local playerGen = GUnit.Generators.FakePlayer

local function beforeEach()
  worldKillTableTest.tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(worldKillTableTest.tables)
  worldKillTableTest.tables = nil
end

local function addRowSpec()
  local tables = worldKillTableTest.tables
  tables.MapId:addMap()
  
  for i = 1, 100 do
    local fakeVictim = playerGen:new()
    local fakeRoundId = i
    
    local fakeVictimId = tables.PlayerId:addPlayer(fakeVictim)
    assert(fakeVictimId == i, "Fake players were not inserted properly.")
    
    local roundId = tables.RoundId:addRound()
    assert(roundId == i, "RoundId was not added properly. Got " .. tostring(roundId) .. " instead of " .. tostring(i))
    
    local worldKillId = tables.WorldKill:addPlayerKill(fakeVictimId)
    assert(worldKillId == i)
  end
end

worldKillTableTest:beforeEach(beforeEach)
worldKillTableTest:afterEach(afterEach)
worldKillTableTest:addSpec("add rows properly", addRowSpec)