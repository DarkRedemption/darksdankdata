local recalculateTest = GUnit.Test:new("recalculate")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function fixShopItemSpec()
  local itemNames = {}
  itemNames[1] = "item_armor"
  itemNames[2] = "item_radar"
  itemNames[4] = "item_disg"

  for id, name in pairs(itemNames) do
    tables.ShopItem:addItem(id)
  end

  DDD.Database.recalculate(tables)

  for id, name in pairs(itemNames) do
    GUnit.assert(tables.ShopItem:getItemId(name)):greaterThan(0)
    GUnit.assert(tables.ShopItem:getItemId(id)):lessThan(1)
  end
end

recalculateTest:beforeEach(beforeEach)
recalculateTest:afterEach(afterEach)

recalculateTest:addSpec("change Vanilla items with their name set as their ID to their EquipmentItems name", fixShopItemSpec)
