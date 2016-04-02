local roundIdTest = GUnit.Test:new("Round ID Table")

local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addRoundSpec()
  for i = 1, 100 do
    local mapId = tables.RoundId:getForeignTableByColumn("map_id")
    local id = tables.RoundId:addRound()
    assert(id == 1, "id was " .. tostring(id) .. ", expected 1")
  end
end

roundIdTest:beforeEach(beforeEach)
roundIdTest:afterEach(afterEach)
roundIdTest:addSpec("add a new, incrementing round every time the fucntion is called", addRoundSpec)