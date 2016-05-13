local entityTest = GUnit.Test:new("EntityTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addEntityTest()
  for i = 1, 100 do
    local entity = GUnit.Generators.FakeEntity:new()
    local id = tables.EntityId:addEntity(entity)
    GUnit.assert(id):shouldEqual(i)
    local entityIdByName = tables.EntityId:getEntityId(entity)
    GUnit.assert(id):shouldEqual(entityIdByName)
  end
end

entityTest:beforeEach(beforeEach)
entityTest:afterEach(afterEach)

entityTest:addSpec("add new entities correctly", addEntityTest)
