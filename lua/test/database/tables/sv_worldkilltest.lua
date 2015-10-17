local worldKillTableTest = GUnit.Test:new("WorldKillTable")

local playerGen = GUnit.Generators.FakePlayer

local function beforeEach()
  worldKillTableTest.tables = DDDTest.TestHelpers.makeTables()
end

local function addRowSpec()
  local tables = DDDTest.Helpers.makeTables()
  
  for i = 1, 100 do
    local fakeVictim = playerGen:new()
    local fakeAttacker = playerGen:new()
    local fakeVictimId = tables.PlayerId:addPlayerId(fakeVictim)
    local fakeAttackerId = tables.PlayerId:addPlayerId(fakeAttacker)
    print(tostring(fakeVictimId))
    print(tostring(fakeAttackerId))
    assert(fakeVictimId == ((i * 2) - 1) && fakeAttackerId == (i * 2), "Fake players were not inserted properly.")
    local worldKillId = tables.WorldKill:addPlayerKill(fakeVictimId, fakeAttackerId)
    assert(worldKillId == i)
  end
end

local function afterEach()
  worldKillTableTest.tables.dropAll()
  worldKillTableTest.tables = nil
end

worldKillTableTest:beforeEach(beforeEach)
worldKillTableTest:afterEach(afterEach)
--worldKillTableTest:addSpec("add rows properly", addRowSpec)