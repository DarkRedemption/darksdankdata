local purchaseTableTest = GUnit.Test:new("PurchaseTable")
local tables = {}
local shopItemGen = DDDTest.Helpers.Generators.ShopItemGen

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
  tables.RoundId:addRound()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function purchaseSpec()
  for i = 1, 100 do
    local purchaser = GUnit.Generators.FakePlayer:new()
    local purchaserId = tables.PlayerId:addPlayer(purchaser)
    
    local fakeItem = shopItemGen:new()
    local isItem = math.random(0, 1)
    local itemId = tables.ShopItem:addItem(fakeItem, isItem)
    
    local id = tables.Purchases:addPurchase(purchaserId, itemId)
    GUnit.assert(id):shouldEqual(i)
  end
end

local function constraintsSpec()
  GUnit.pending()
end

purchaseTableTest:beforeEach(beforeEach)
purchaseTableTest:afterEach(afterEach)

purchaseTableTest:addSpec("add a purchase by a player", purchaseSpec)
purchaseTableTest:addSpec("conform to constraints", constraintsSpec)