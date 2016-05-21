local shopItemTest = GUnit.Test:new("ShopItemTable")
local tables = {}
local shopItemGen = DDDTest.Helpers.Generators.ShopItemGen

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addItemTest()
  for i = 1, 100 do
    local fakeItem = shopItemGen:new()
    local isItem = math.random(0, 1)
    local id = tables.ShopItem:addItem(fakeItem, isItem)
    GUnit.assert(id):shouldEqual(i)
  end
end

shopItemTest:beforeEach(beforeEach)
shopItemTest:afterEach(afterEach)

shopItemTest:addSpec("add new items", addItemTest)