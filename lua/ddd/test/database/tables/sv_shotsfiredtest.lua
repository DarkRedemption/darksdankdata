local shotsFiredTest = GUnit.Test:new("ShotsFiredTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
  tables.RoundId:addRound()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addShotSpec()
  for i = 1, 10 do
    local player = GUnit.Generators.FakePlayer:new()
    local playerId = tables.PlayerId:addPlayer(player)
    for j = 1, 10 do
      local attackType = math.random(1, 2)
      local id = tables.ShotsFired:addShot(player, attackType)
      local expectedVal = ((i - 1) * 10) + j
      GUnit.assert(id):shouldEqual(expectedVal)
    end
  end
end

shotsFiredTest:beforeEach(beforeEach)
shotsFiredTest:afterEach(afterEach)
shotsFiredTest:addSpec("add shots successfully", addShotSpec)
shotsFiredTest:addSpec("fail if the player does not exist", GUnit.pending)
shotsFiredTest:addSpec("fail if the weapon does not exist", GUnit.pending)
shotsFiredTest:addSpec("fail if the attack type does not exist", GUnit.pending)

