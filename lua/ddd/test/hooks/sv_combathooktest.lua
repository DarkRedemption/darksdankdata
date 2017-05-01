local hookTest = GUnit.Test:new("CombatHooks")
local tables = {}
local sweps = DDD.filterValue(weapons.GetList(), function(value)
  return !DDD.arrayContains(DDD.Config.AggregateWeaponStatsFilter, value.ClassName)
end)

sweps = DDD.map(sweps, function(key, value)
  local fakeWeapon = GUnit.Generators.FakeEntity:new()
  local className = value.ClassName
  fakeWeapon:SetIsWeapon(true)
  fakeWeapon.classname = DDD.Config.DeployedWeaponTranslation[className] or className
  return key, fakeWeapon
end)

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function trackPlayerCombatDeathSpec()
  for i = 1, 100 do
    local roundId = tables.RoundId:addRound()
    local victim = GUnit.Generators.FakePlayer:new()
    local attacker = GUnit.Generators.FakePlayer:new()
    local victimId = tables.PlayerId:addPlayer(victim)
    local attackerId = tables.PlayerId:addPlayer(attacker)
    local randomWeaponId = math.random(1, #sweps)
    local weapon = sweps[randomWeaponId]
    local damageInfo = GUnit.Generators.CTakeDamageInfo:new()
    tables.RoundRoles:addRole(victim)
    tables.RoundRoles:addRole(attacker)
    damageInfo:SetInflictor(weapon)

    local id = DDD.Hooks.trackPlayerDeath(tables, victim, attacker, damageInfo)
    GUnit.assert(id):shouldEqual(i)

    local killRow = tables.PlayerKill:selectById(id)
    GUnit.assert(killRow):shouldNotEqual(0)
    GUnit.assert(tonumber(killRow["round_id"])):shouldEqual(roundId)
    GUnit.assert(tonumber(killRow["victim_id"])):shouldEqual(victimId)
    GUnit.assert(tonumber(killRow["attacker_id"])):shouldEqual(attackerId)
  end
end

local function trackPlayerPushDeathSpec()
  for i = 1, 100 do
    local roundId = tables.RoundId:addRound()
    local victim = GUnit.Generators.FakePlayer:new()
    local attacker = GUnit.Generators.FakePlayer:new()
    local victimId = tables.PlayerId:addPlayer(victim)
    local attackerId = tables.PlayerId:addPlayer(attacker)
    local randomWeaponId = math.random(1, #sweps)
    local weapon = sweps[randomWeaponId]
    local damageInfo = GUnit.Generators.CTakeDamageInfo:new()
    tables.RoundRoles:addRole(victim)
    tables.RoundRoles:addRole(attacker)
    damageInfo:SetDamageType(DMG_FALL)

    local wasPushed = {
      att = attacker,
      wep = weapon:GetClass()
    }
    victim.was_pushed = wasPushed

    local id = DDD.Hooks.trackPlayerDeath(tables, victim, nil, damageInfo)
    GUnit.assert(id):shouldEqual(i)

    local killRow = tables.PlayerPushKill:selectById(id)
    GUnit.assert(killRow):shouldNotEqual(0)
    GUnit.assert(tonumber(killRow["round_id"])):shouldEqual(roundId)
    GUnit.assert(tonumber(killRow["victim_id"])):shouldEqual(victimId)
    GUnit.assert(tonumber(killRow["attacker_id"])):shouldEqual(attackerId)
  end
end

local function trackPlayerWorldDeathSpec()
  for i = 1, 100 do
    local roundId = tables.RoundId:addRound()
    local victim = GUnit.Generators.FakePlayer:new()
    local victimId = tables.PlayerId:addPlayer(victim)
    local damageInfo = GUnit.Generators.CTakeDamageInfo:new()
    tables.RoundRoles:addRole(victim)

    local id = DDD.Hooks.trackPlayerDeath(tables, victim, nil, damageInfo)
    GUnit.assert(id):shouldEqual(i)

    local killRow = tables.WorldKill:selectById(id)
    GUnit.assert(killRow):shouldNotEqual(0)
    GUnit.assert(tonumber(killRow["round_id"])):shouldEqual(roundId)
    GUnit.assert(tonumber(killRow["victim_id"])):shouldEqual(victimId)
  end
end

local function trackPlayerCombatDamageSpec()
  for i = 1, 100 do
    local roundId = tables.RoundId:addRound()

    local victim = GUnit.Generators.FakePlayer:new()
    local attacker = GUnit.Generators.FakePlayer:new()
    local victimId = tables.PlayerId:addPlayer(victim)
    local attackerId = tables.PlayerId:addPlayer(attacker)
    local randomWeaponId = math.random(1, #sweps)
    local weapon = sweps[randomWeaponId]
    local damageInfo = GUnit.Generators.CTakeDamageInfo:new()
    tables.RoundRoles:addRole(victim)
    tables.RoundRoles:addRole(attacker)

    damageInfo:SetAttacker(attacker)
    damageInfo:SetInflictor(weapon)

    local id = DDD.Hooks.trackDamage(tables, victim, damageInfo)

    GUnit.assert(id):shouldEqual(i)

    local damageRow = tables.CombatDamage:selectById(id)

    GUnit.assert(damageRow):shouldNotEqual(0)
    GUnit.assert(tonumber(damageRow["round_id"])):shouldEqual(roundId)
    GUnit.assert(tonumber(damageRow["victim_id"])):shouldEqual(victimId)
    GUnit.assert(tonumber(damageRow["attacker_id"])):shouldEqual(attackerId)
    GUnit.assert(tonumber(damageRow["damage_dealt"])):shouldEqual(damageInfo:GetDamage())
  end
end

local function trackPlayerWorldDamageSpec()
  for i = 1, 100 do
    local roundId = tables.RoundId:addRound()
    local victim = GUnit.Generators.FakePlayer:new()
    local victimId = tables.PlayerId:addPlayer(victim)
    local damageInfo = GUnit.Generators.CTakeDamageInfo:new()
    tables.RoundRoles:addRole(victim)

    local id = DDD.Hooks.trackDamage(tables, victim, damageInfo)
    GUnit.assert(id):shouldEqual(i)

    local damageRow = tables.WorldDamage:selectById(id)
    GUnit.assert(damageRow):shouldNotEqual(0)
    GUnit.assert(tonumber(damageRow["round_id"])):shouldEqual(roundId)
    GUnit.assert(tonumber(damageRow["victim_id"])):shouldEqual(victimId)
    GUnit.assert(tonumber(damageRow["damage_dealt"])):shouldEqual(damageInfo:GetDamage())
  end
end

hookTest:beforeEach(beforeEach)
hookTest:afterEach(afterEach)

hookTest:addSpec("track when a player dies from an attacker", trackPlayerCombatDeathSpec)
hookTest:addSpec("track when a player dies from pushing", trackPlayerPushDeathSpec)
hookTest:addSpec("track when a player dies from the world", trackPlayerWorldDeathSpec)
hookTest:addSpec("track when a player takes damage in combat", trackPlayerCombatDamageSpec)
hookTest:addSpec("track when a player takes damage from the world", trackPlayerWorldDamageSpec)
