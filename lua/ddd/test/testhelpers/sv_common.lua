function DDDTest.Helpers.getRandomPair(array)
  GUnit.assert(#array):greaterThan(1)
  if (#array == 2) then return array[1], array[2] end

  local arrayId = math.random(1, #array)

  local function getSecondId()
    local secondArrayId = math.random(1, #array)
    if (arrayId == secondArrayId) then
      return getSecondId()
    else
      return secondArrayId
    end
  end

  return array[arrayId], array[getSecondId()]
end

function DDDTest.Helpers.genAndAddPlayer(tables)
  local ply = GUnit.Generators.FakePlayer:new()
  local id = tables.PlayerId:addPlayer(ply)
  local result = tables.AggregateStats:addPlayer(id)
  GUnit.assert(result):shouldEqual(id)

  return ply, id
end

local function getRolePurchasableItemNames(roleCanPurchaseItemFunc)
  local sweps = weapons.GetList()
  local result = {}

  for index, wep in pairs(sweps) do
    if (roleCanPurchaseItemFunc(wep)) then
      table.insert(result, wep.ClassName)
    end
  end

  return result
end

local function getTraitorPurchasableItemNames()
  return getRolePurchasableItemNames(DDD.Database.Tables.AggregatePurchaseStats.traitorCanBuy)
end

local function getDetectivePurchasableItemNames()
  return getRolePurchasableItemNames(DDD.Database.Tables.AggregatePurchaseStats.detectiveCanBuy)
end

DDDTest.Helpers.getTraitorPurchasableItemNames = getTraitorPurchasableItemNames
DDDTest.Helpers.getDetectivePurchasableItemNames = getDetectivePurchasableItemNames
