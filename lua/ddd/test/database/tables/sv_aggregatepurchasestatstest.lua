local aggregatePurchaseStatsTest = GUnit.Test:new("AggregatePurchaseStatsTable")
local tables = {}

local traitorValidPurchases = { "1",
                                "2",
                                "weapon_ttt_flaregun",
                                "weapon_ttt_knife",
                                "weapon_ttt_teleport",
                                "weapon_ttt_radio",
                                "weapon_ttt_push",
                                "weapon_ttt_sipistol",
                                "weapon_ttt_decoy",
                                "weapon_ttt_phammer",
                                "weapon_ttt_c4"}

  local detectiveValidPurchases = { "2", --Forget the body armor since you start with it
                                "weapon_ttt_cse",
                                "weapon_ttt_defuser",
                                "weapon_ttt_teleport",
                                "weapon_ttt_binoculars",
                                "weapon_ttt_stungun",
                                "weapon_ttt_health_station"}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.AggregatePurchaseStats.tables = tables
  tables.MapId:addMap()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
  DDD.Logging:enable()
end

local function allColumnsZero(row)
  for columnName, value in pairs(row) do
    if (columnName != "player_id") then
      GUnit.assert(value):shouldEqual("0")
    end
  end
end

local function genAndAddPlayer()
  local ply = GUnit.Generators.FakePlayer:new()
  local id = tables.PlayerId:addPlayer(ply)
  local result = tables.AggregatePurchaseStats:addPlayer(id)
  GUnit.assert(result):shouldEqual(id)

  return ply, id
end

local function getRolePurchasableItemNames(roleCanPurchaseFunction)
  local sweps = weapons.GetList()
  local result = {}

  for index, wep in pairs(sweps) do
    if (roleCanPurchaseFunction(wep)) then
      table.insert(result, wep.ClassName)
    end
  end

  return result
end

local function getTraitorPurchasableItemNames()
  return getRolePurchasableItemNames(tables.AggregatePurchaseStats.traitorCanBuy)
end

local function getDetectivePurchasableItemNames()
  return getRolePurchasableItemNames(tables.AggregatePurchaseStats.detectiveCanBuy)
end


local function incrementSpec()
  local ply, id = genAndAddPlayer()
  local traitorItemNames = getTraitorPurchasableItemNames()
  local detectiveItemNames = getDetectivePurchasableItemNames()

  for i = 1, 100 do
    local playerRole = math.random(1, 2)
    local randomItemName

    if (playerRole == ROLE_TRAITOR) then
      local index = math.random(1, #traitorItemNames)
      randomItemName = traitorItemNames[index]
    else
      local index = math.random(1, #detectiveItemNames)
      randomItemName = detectiveItemNames[index]
    end

    local originalValue = tables.AggregatePurchaseStats:getPurchases(id, playerRole, randomItemName)
    tables.AggregatePurchaseStats:incrementPurchases(id, playerRole, randomItemName)
    local newValue = tables.AggregatePurchaseStats:getPurchases(id, playerRole, randomItemName)
    GUnit.assert(newValue):shouldEqual(originalValue + 1)
  end
end

local function recalculateSpec()
  GUnit.pending()
end

aggregatePurchaseStatsTest:beforeEach(beforeEach)
aggregatePurchaseStatsTest:afterEach(afterEach)
aggregatePurchaseStatsTest:addSpec("increment items purchased", incrementSpec)
aggregatePurchaseStatsTest:addSpec("recalculate properly", recalculateSpec)
