local playerKillTest = GUnit.Test:new("PlayerPushKillTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
  tables.RoundId:addRound()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addPlayerKillSpec()  
  for i = 1, 100 do
    local victim = GUnit.Generators.FakePlayer:new()
    local attacker = GUnit.Generators.FakePlayer:new()
    local victimId = tables.PlayerId:addPlayer(victim)
    local attackerId = tables.PlayerId:addPlayer(attacker)

    local randomWeaponName = GUnit.Generators.StringGen.generateAlphaNum()
    local weaponId = tables.WeaponId:addWeapon(randomWeaponName)
        
    local killId = tables.PlayerPushKill:addKill(victimId, attackerId, weaponId)
    GUnit.assert(killId):shouldEqual(i)
  end
end

playerKillTest:beforeEach(beforeEach)
playerKillTest:afterEach(afterEach)

playerKillTest:addSpec("add a new player kill", addPlayerKillSpec)