local playerIdTest = GUnit.Test:new("Player ID Table")

local function beforeEach()
  playerIdTest.tables = DDDTest.Helpers.makeTables()
end

local function addPlayerSpec()
  local playerIdTable = playerIdTest.tables.PlayerId
  for i = 1, 100 do
    local ply = GUnit.Generators.FakePlayer:new()
    local id = playerIdTable:addPlayerId(ply)
    assert(tonumber(id) == i, "id was " .. tostring(id) .. ", expected " .. i)
  end
end

local function afterEach()
  DDDTest.Helpers.dropAll(playerIdTest.tables)
  playerIdTest.tables = nil
end

playerIdTest:beforeEach(beforeEach)
playerIdTest:afterEach(afterEach)
playerIdTest:addSpec("add new players", addPlayerSpec)