local worldDamageTest = GUnit.Test:new("WorldDamageTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
  DDD.Logging:enable()
end

local function addDamageSpec()
  for i = 1, 100 do
    tables.RoundId:addRound()
    local victim = GUnit.Generators.FakePlayer:new()
    local victimId = tables.PlayerId:addPlayer(victim)
    local damageInfo = GUnit.Generators.CTakeDamageInfo:new()
    local id = tables.WorldDamage:addDamage(victimId, damageInfo)
    
    GUnit.assert(i):shouldEqual(id)
  end
end

local function noRoundsConstraintSpec()
  DDD.Logging:disable()
  for i = 1, 100 do
    local victim = GUnit.Generators.FakePlayer:new()
    local victimId = tables.PlayerId:addPlayer(victim)
    local damageInfo = GUnit.Generators.CTakeDamageInfo:new()
    local id = tables.WorldDamage:addDamage(victimId, damageInfo)
   
    GUnit.assert(id):shouldNotEqual(1)
  end
end

local function playerMustExistSpec()
  DDD.Logging:disable()
  for i = 1, 100 do
    tables.RoundId:addRound()
    local invalidVictimId = math.random(1, 10000)
    local damageInfo = GUnit.Generators.CTakeDamageInfo:new()
    local id = tables.WorldDamage:addDamage(invalidVictimId, damageInfo)
    
    GUnit.assert(invalidVictimId):shouldNotEqual(id)
  end
end

worldDamageTest:beforeEach(beforeEach)
worldDamageTest:afterEach(afterEach)

worldDamageTest:addSpec("add a damage log", addDamageSpec)
worldDamageTest:addSpec("not add a damage if there is no rounds in the database", noRoundsConstraintSpec)
worldDamageTest:addSpec("not add a damage log if the player does not exist", playerMustExistSpec)
