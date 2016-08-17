local hookTest = GUnit.Test:new("Hooks")
local shopItemGen = DDDTest.Helpers.Generators.ShopItemGen
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
  tables.MapId:addMap()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function trackPurchasesSpec()
  for i = 1, 100 do
    tables.RoundId:addRound()
    local player = GUnit.Generators.FakePlayer:new()
    local playerId = tables.PlayerId:addPlayer(player)
    tables.AggregateStats:addPlayer(playerId)
    
    local purchaserRole = math.random(1, 2)
    player:SetRole(purchaserRole)
    tables.RoundRoles:addRole(player)
    
    local thisRoundsPurchase
    if purchaserRole == 1 then
      thisRoundsPurchase = traitorValidPurchases[math.random(1, #traitorValidPurchases)]
    else
      thisRoundsPurchase = detectiveValidPurchases[math.random(1, #detectiveValidPurchases)]
    end
    
    local purchaseId = DDD.Hooks.trackPurchases(tables, player, thisRoundsPurchase)
    
    GUnit.assert(purchaseId):shouldEqual(i)
    
    local totalPurchases = tables.AggregateStats:getItemPurchases(playerId, purchaserRole, thisRoundsPurchase)
    if (totalPurchases != 1) then
      print(thisRoundsPurchase)
    end
    
    GUnit.assert(totalPurchases):shouldEqual(1)
  end
end

local function trackDnaDiscoverySpec()
  for i = 1, 100 do
    tables.RoundId:addRound()
    
    local finder = GUnit.Generators.FakePlayer:new()
    local owner = GUnit.Generators.FakePlayer:new()
    tables.PlayerId:addPlayer(finder)
    tables.PlayerId:addPlayer(owner)
    
    local entity = GUnit.Generators.FakeEntity:new()
    
    local id = DDD.Hooks.trackDnaDiscovery(tables, finder, owner, entity)
    GUnit.assert(id):shouldEqual(i)
  end
end

hookTest:beforeEach(beforeEach)
hookTest:afterEach(afterEach)

hookTest:addSpec("track player purchases", trackPurchasesSpec)
hookTest:addSpec("track when player DNA is found", trackDnaDiscoverySpec)