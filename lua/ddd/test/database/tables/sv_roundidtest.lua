local roundIdTest = GUnit.Test:new("RoundIdTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function keyConstraintSpec()
  local mapId = tables.RoundId:getForeignTableByColumn("map_id")
  GUnit.assert(mapId:getCurrentMapId()):shouldEqual(0)
  
  local addRound = tables.RoundId:addRound()
  GUnit.assert(addRound):shouldNotEqual(1)
end

local function addRoundSpec()
  local mapId = tables.RoundId:getForeignTableByColumn("map_id")
  local addedMapId = mapId:addMap()
  GUnit.assert(addedMapId):shouldEqual(1)
  
  for i = 1, 100 do
    local id = tables.RoundId:addRound()
    local roundRow = tables.RoundId:getCurrentRoundRow()
    GUnit.assert(id):shouldEqual(i)
    GUnit.assert(tonumber(roundRow["id"])):shouldEqual(i)
  end
end

roundIdTest:beforeEach(beforeEach)
roundIdTest:afterEach(afterEach)

roundIdTest:addSpec("not allow rows to be added without any map ids", keyConstraintSpec)
roundIdTest:addSpec("add a new, incrementing round every time the function is called", addRoundSpec)