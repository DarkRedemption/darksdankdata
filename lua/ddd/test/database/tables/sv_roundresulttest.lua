local roundResultTest = GUnit.Test:new("RoundResultTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
  DDD.Logging:enable()
end

local function addResultSpec()
  for i = 1, 100 do
    tables.RoundId:addRound()
    local roundResult = math.random(0, 2)
    local resultId = tables.RoundResult:addResult(roundResult)
    GUnit.assert(resultId):shouldEqual(i)
  end
end

local function onePerRoundSpec()
  DDD.Logging:disable()
  for i = 1, 100 do
    tables.RoundId:addRound()
    local roundResult = math.random(0, 2)
    tables.RoundResult:addResult(roundResult)
    local resultId = tables.RoundResult:addResult(roundResult)
    GUnit.assert(resultId):shouldNotEqual(i)
  end
end

local function roundMustExistSpec()
  DDD.Logging:disable()
  local roundResult = math.random(0, 2)
  local resultId = tables.RoundResult:addResult(roundResult)
  GUnit.assert(resultId):shouldNotEqual(1)
end

roundResultTest:beforeEach(beforeEach)
roundResultTest:afterEach(afterEach)

roundResultTest:addSpec("add a round result", addResultSpec)
roundResultTest:addSpec("not let you add more than one result per round", onePerRoundSpec)
roundResultTest:addSpec("not let you add a result when there are no rounds", roundMustExistSpec)