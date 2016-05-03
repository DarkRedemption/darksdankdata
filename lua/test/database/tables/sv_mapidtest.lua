local mapIdTest = GUnit.Test:new("MapIdTable")

local function beforeEach()
  mapIdTest.tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(mapIdTest.tables)
end

local function noMapTestSpec()
  local mapIdTable = mapIdTest.tables.MapId
  local currentMapId = mapIdTable:getCurrentMapId()
  GUnit.assert(currentMapId):shouldEqual(0)
end

local function addMapSpec()
  local mapIdTable = mapIdTest.tables.MapId
  local id = mapIdTable:addMap()
  local currentMapId = mapIdTable:getCurrentMapId()
  GUnit.assert(currentMapId):shouldEqual(1)
end

mapIdTest:beforeEach(beforeEach)
mapIdTest:afterEach(afterEach)

mapIdTest:addSpec("add the current map and select it", addMapSpec)
mapIdTest:addSpec("not automatically add the current map when copied", noMapTestSpec)
