local roundRoleTest = GUnit.Test:new("RoundRoleTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function afterAll()
  DDD.Logging:enable()
end

local function addRoleSpec()
  for i = 1, 100 do
    tables.RoundId:addRound()
    local player = GUnit.Generators.FakePlayer:new()
    local playerId = tables.PlayerId:addPlayer(player)
    local roleRowId = tables.RoundRoles:addRole(player)
    GUnit.assert(roleRowId):shouldEqual(i)
    
    local roleRow = tables.RoundRoles:selectById(roleRowId)
    GUnit.assert(tonumber(roleRow["role_id"])):shouldEqual(player:GetRole())
  end
end

local function onePerRoundSpec()
  tables.RoundId:addRound()
  local player = GUnit.Generators.FakePlayer:new()
  local playerId = tables.PlayerId:addPlayer(player)
  tables.RoundRoles:addRole(player)

  DDD.Logging:disable()
  for i = 1, 100 do
    local roleRowId = tables.RoundRoles:addRole(player)
    GUnit.assert(roleRowId):shouldEqual(false)
  end
  DDD.Logging:enable()
end

roundRoleTest:beforeEach(beforeEach)
roundRoleTest:afterEach(afterEach)
roundRoleTest:afterAll(afterAll)

roundRoleTest:addSpec("add a row containing the player's role that round", addRoleSpec)
roundRoleTest:addSpec("not allow you to add more than one role to a player per round", onePerRoundSpec)