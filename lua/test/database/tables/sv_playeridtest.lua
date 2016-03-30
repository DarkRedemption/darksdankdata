local playerIdTest = GUnit.Test:new("Player ID Table")

local function beforeEach()
  playerIdTest.tables = DDDTest.Helpers.makeTables()
end

local function addPlayerSpec()
  local playerIdTable = playerIdTest.tables.PlayerId
  local players = {}
  
  for i = 1, 100 do
    local ply = GUnit.Generators.FakePlayer:new()
    table.insert(players, ply)
  end
  
  for i = 1, 100 do
    local ply = players[i]
    local id = playerIdTable:addPlayerId(ply)
    assert(tonumber(id) == i, "id was " .. tostring(id) .. ", expected " .. i)
  end
  
  for i = 1, 100 do
    local ply = players[i]
    local selectedPlyId = playerIdTable:getPlayerId(ply)
    assert(tonumber(selectedPlyId) == i, "Could not select player. id was " .. selectedPlyId .. ", expected " .. tostring(i))
  end
end

local function afterEach()
  DDDTest.Helpers.dropAll(playerIdTest.tables)
  playerIdTest.tables = nil
end

playerIdTest:beforeEach(beforeEach)
--playerIdTest:afterEach(afterEach)
playerIdTest:addSpec("add new players and select them", addPlayerSpec)