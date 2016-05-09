local combatDamageTableTest = GUnit.Test:new("CombatDamageTable")
local playerGen = GUnit.Generators.FakePlayer
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addDamageSpec()
  tables.MapId:addMap()
  tables.RoundId:addRound()
  
  for i = 1, 100 do
    local victim = playerGen:new()
    local attacker = playerGen:new()
    local victimId = tables.PlayerId:addPlayer(victim)
    local attackerId = tables.PlayerId:addPlayer(attacker)
    local randomWeaponName = GUnit.Generators.StringGen.generateAlphaNum()
    local weaponId = tables.WeaponId:addWeapon(randomWeaponName)
    local damage = GUnit.Generators.CTakeDamageInfo:new()
    
    local damageId = tables.CombatDamage:addDamage(victimId, attackerId, weaponId, damage)
    GUnit.assert(damageId):shouldEqual(i)
  end
end

combatDamageTableTest:beforeEach(beforeEach)
combatDamageTableTest:afterEach(afterEach)

combatDamageTableTest:addSpec("add damage logs to the table", addDamageSpec)
