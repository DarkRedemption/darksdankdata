local roundIdTest = GUnit.Test:new("Round ID Table")

local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function keyConstraintSpec()
  local mapId = tables.RoundId:getForeignTableByColumn("map_id")
  assert(mapId:getCurrentMapId() == 0)
  GUnit.Asserts.shouldFail(tables.RoundId:addRound())
end

local function addRoundSpec()
  local mapId = tables.RoundId:getForeignTableByColumn("map_id")
  local addedMapId = mapId:addMap()
  assert(addedMapId == 1)
  
  for i = 1, 100 do
    local id = tables.RoundId:addRound()
    local roundRow = tables.RoundId:getCurrentRoundRow()
    assert(id == i, "id was " .. tostring(id) .. ", expected " .. i )
  end
end

roundIdTest:beforeEach(beforeEach)
roundIdTest:afterEach(afterEach)

roundIdTest:addSpec("not allow rows to be added without a valid mapId", keyConstraintSpec)
roundIdTest:addSpec("add a new, incrementing round every time the function is called", addRoundSpec)