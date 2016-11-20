local playerKillTest = GUnit.Test:new("PlayerKillTable")
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
    tables.RoundRoles:addRole(victim)
    tables.RoundRoles:addRole(attacker)
    local randomWeaponName = GUnit.Generators.StringGen.generateAlphaNum()
    local weaponId = tables.WeaponId:addWeapon(randomWeaponName)

    local killId = tables.PlayerKill:addKill(victimId, attackerId, weaponId)
    GUnit.assert(killId):shouldEqual(i)
  end
end


local function getKillsAsRoleSpec()
  GUnit.pending()
  local roles = DDD.Database.Roles

  local attacker = GUnit.Generators.FakePlayer:new()
  local attackerId = tables.PlayerId:addPlayer(attacker)
  local randomWeaponName = GUnit.Generators.StringGen.generateAlphaNum()
  local weaponId = tables.WeaponId:addWeapon(randomWeaponName)

  for i = 1, 100 do
    local victim = GUnit.Generators.FakePlayer:new()
    local victimId = tables.PlayerId:addPlayer(victim)
    local killId = tables.PlayerKill:addKill(victimId, attackerId, weaponId)
  end
end

local function getSuicidesAsRoleSpec()
  GUnit.pending()
  local suicider = GUnit.Generators.FakePlayer:new()
  local suiciderId = tables.PlayerId:addPlayer(suicider)
  local randomWeaponName = GUnit.Generators.StringGen.generateAlphaNum()
  local weaponId = tables.WeaponId:addWeapon(randomWeaponName)

  local innocentSuicides = 0
  local traitorSuicides = 0
  local detectiveSuicides = 0

  for i = 1, 100 do
    local randomRole = math.random(0, 2)

    if (randomRole == 0) then
      innocentSuicides = innocentSuicides + 1
    elseif (randomRole == 1) then
      traitorSuicides = traitorSuicides + 1
    elseif (randomRole == 2) then
      detectiveSuicides = detectiveSuicides + 1
    end

    suicider:SetRole(randomRole)
    tables.RoundId:addRound()
    tables.RoundRoles:addRole(suicider)
    tables.PlayerKill:addKill(suiciderId, suiciderId, weaponId)
  end

  GUnit.assert(tables.PlayerKill:getInnocentSuicides(suiciderId)):shouldEqual(innocentSuicides)
  GUnit.assert(tables.PlayerKill:getTraitorSuicides(suiciderId)):shouldEqual(traitorSuicides)
  GUnit.assert(tables.PlayerKill:getDetectiveSuicides(suiciderId)):shouldEqual(detectiveSuicides)
end

playerKillTest:beforeEach(beforeEach)
playerKillTest:afterEach(afterEach)

playerKillTest:addSpec("add a new player kill", addPlayerKillSpec)
playerKillTest:addSpec("get kills as a specific role", getKillsAsRoleSpec)
playerKillTest:addSpec("get suicides as a specific role", getSuicidesAsRoleSpec)
