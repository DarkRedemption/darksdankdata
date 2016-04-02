local mapIdTest = GUnit.Test:new("Map ID Table")

local function beforeEach()
  mapIdTest.tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(mapIdTest.tables)
end

local function addMapSpec()
  local mapIdTable = mapIdTest.tables.MapId
  local id = mapIdTable:addMap()
  local currentMapId = mapIdTable:getCurrentMapId()
  assert(currentMapId == 1, "Could not select the current map!")
end

mapIdTest:beforeEach(beforeEach)
mapIdTest:afterEach(afterEach)
mapIdTest:addSpec("add the current map and select it", addMapSpec)
