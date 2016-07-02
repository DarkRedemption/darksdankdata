local purchaseTableTest = GUnit.Test:new("PurchaseTable")
local tables = {}
local shopItemGen = DDDTest.Helpers.Generators.ShopItemGen

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
                                "weapon_ttt_beacon",
                                "weapon_ttt_defuser",
                                "weapon_ttt_teleport",
                                "weapon_ttt_binoculars",
                                "weapon_ttt_stungun",
                                "weapon_ttt_health_station"}
                              
local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
  tables.RoundId:addRound()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function verifyValidPurchases()
end

local function purchaseSpec()
  local purchaser = GUnit.Generators.FakePlayer:new()
  local purchaserId = tables.PlayerId:addPlayer(purchaser)
  local i = 1
  local role = math.random(1, 2)
  
  if role == 1 then
    for key, itemName in pairs(traitorValidPurchases) do
      local itemId = tables.ShopItem:addItem(itemName)
      local id = tables.Purchases:addPurchase(purchaserId, itemId)
      GUnit.assert(id):shouldEqual(i)
      i = i + 1
    end
  else
    for key, itemName in pairs(detectiveValidPurchases) do
      local itemId = tables.ShopItem:addItem(itemName)
      local id = tables.Purchases:addPurchase(purchaserId, itemId)
      GUnit.assert(id):shouldEqual(i)
      i = i + 1
    end
  end
  
end

local function constraintsSpec()
  GUnit.pending()
end

purchaseTableTest:beforeEach(beforeEach)
purchaseTableTest:afterEach(afterEach)

purchaseTableTest:addSpec("add a purchase by a player", purchaseSpec)
purchaseTableTest:addSpec("conform to constraints", constraintsSpec)