local creditsLootedTableTest = GUnit.Test:new("CreditsLootedTable")
local playerGen = GUnit.Generators.FakePlayer
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addCredsSpec()
  tables.MapId:addMap()
  tables.RoundId:addRound()
  
  for i = 1, 100 do
    local looter = playerGen:new()
    local victim = playerGen:new()
    
    local looterId = tables.PlayerId:addPlayer(looter)
    local victimId = tables.PlayerId:addPlayer(victim)
    local creds = math.random(1, 10)
    
    local damageId = tables.CreditsLooted:addCreditsLooted(victimId, looterId, creds)
    GUnit.assert(damageId):shouldEqual(i)
    GUnit.assert(tables.CreditsLooted:selectById(damageId)["credits_looted"]):shouldEqual(tostring(creds))
  end
end

creditsLootedTableTest:beforeEach(beforeEach)
creditsLootedTableTest:afterEach(afterEach)

creditsLootedTableTest:addSpec("add credits looted", addCredsSpec)