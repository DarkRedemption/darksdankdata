--TODO: Add tests for the queries on how much a player healed and how much they did not.

local healingTest = GUnit.Test:new("HealingTable")
local playerGen = GUnit.Generators.FakePlayer
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
  tables = {}
end

local function addHealingTest()
  tables.MapId:addMap()
  for i = 1, 100 do
    tables.RoundId:addRound()
    
    local deployer = playerGen:new()
    local user = playerGen:new()
    local healAmount = math.random(1, 100)
    
    local deployerId = tables.PlayerId:addPlayer(deployer)
    local userId = tables.PlayerId:addPlayer(user)
    
    local healId = tables.Healing:addHeal(deployerId, userId, healAmount)
    local healRow = tables.Healing:selectById(healId)
    
    GUnit.assert(healId):shouldEqual(i)
    GUnit.assert(tonumber(healRow["heal_amount"])):shouldEqual(healAmount)
    GUnit.assert(tonumber(healRow["round_id"])):shouldEqual(i)    
  end
end

healingTest:beforeEach(beforeEach)
healingTest:afterEach(afterEach)

healingTest:addSpec("add a row with the correct amount a player healed", addHealingTest)