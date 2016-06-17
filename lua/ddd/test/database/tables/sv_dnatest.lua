local dnaTableTest = GUnit.Test:new("DnaTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addDnaSpec()
  for i = 1, 100 do
    local roundId = tables.RoundId:addRound()
    
    local finder = GUnit.Generators.FakePlayer:new()
    local owner = GUnit.Generators.FakePlayer:new()
    local finderId = tables.PlayerId:addPlayer(finder)
    local dnaOwnerId = tables.PlayerId:addPlayer(owner)
    
    local entity = GUnit.Generators.FakeEntity:new()
    local entityId = tables.EntityId:addEntity(entity)
    
    local dnaId = tables.Dna:addDnaFound(finderId, dnaOwnerId, entityId)
    GUnit.assert(dnaId):shouldEqual(i)
  end
end

local function roundConstraintSpec()
  GUnit.pending()
end

dnaTableTest:beforeEach(beforeEach)
dnaTableTest:afterEach(afterEach)

dnaTableTest:addSpec("add new DNA discoveries", addDnaSpec)
dnaTableTest:addSpec("fail to add DNA discoveries with no round ID", roundConstraintSpec)