local purchaseTableTest = GUnit.Test:new("PurchaseTable")
local tables = {}
local shopItemGen = DDDTest.Helpers.Generators.ShopItemGen

local traitorValidPurchases = DDDTest.Helpers.getTraitorPurchasableItemNames()
local detectiveValidPurchases = DDDTest.Helpers.getDetectivePurchasableItemNames()

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
  tables.RoundId:addRound()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function purchaseSpec()
  local purchaser = GUnit.Generators.FakePlayer:new()
  local purchaserId = tables.PlayerId:addPlayer(purchaser)
  local role = math.random(1, 2)
  local i = 1
  local purchasesToUse

  if role == ROLE_TRAITOR then
    purchasesToUse = traitorValidPurchases
  else
    purchasesToUse = detectiveValidPurchases
  end

  for key, itemName in pairs(purchasesToUse) do
    local itemId = tables.ShopItem:addItem(itemName)
    local id = tables.Purchases:addPurchase(purchaserId, itemId)
    GUnit.assert(id):shouldEqual(i)
    i = i + 1
  end

end

local function constraintsSpec()
  GUnit.pending()
end

purchaseTableTest:beforeEach(beforeEach)
purchaseTableTest:afterEach(afterEach)

purchaseTableTest:addSpec("add a purchase by a player", purchaseSpec)
purchaseTableTest:addSpec("conform to constraints", constraintsSpec)
