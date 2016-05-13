local playerIdTest = GUnit.Test:new("PlayerIdTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addPlayerSpec()
  local players = {}
  
  for i = 1, 100 do
    local ply = GUnit.Generators.FakePlayer:new()
    table.insert(players, ply)
  end
  
  for i = 1, 100 do
    local ply = players[i]
    local id = tables.PlayerId:addPlayer(ply)
    GUnit.assert(id):shouldEqual(i)
  end
  
  for i = 1, 100 do
    local ply = players[i]
    local selectedPlyId = tables.PlayerId:getPlayerId(ply)
    GUnit.assert(selectedPlyId):shouldEqual(i)
  end
end

playerIdTest:beforeEach(beforeEach)
playerIdTest:afterEach(afterEach)

playerIdTest:addSpec("add new players and select them", addPlayerSpec)