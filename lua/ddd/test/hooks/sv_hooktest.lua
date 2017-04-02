local hookTest = GUnit.Test:new("Hooks")
local shopItemGen = DDDTest.Helpers.Generators.ShopItemGen
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function trackPurchasesSpec()
  local traitorValidPurchases = DDDTest.Helpers.getTraitorPurchasableItemNames()
  local detectiveValidPurchases = DDDTest.Helpers.getDetectivePurchasableItemNames()

  for i = 1, 100 do
    tables.RoundId:addRound()
    local player = GUnit.Generators.FakePlayer:new()
    local playerId = tables.PlayerId:addPlayer(player)
    tables.AggregatePurchaseStats:addPlayer(playerId)

    local purchaserRole = math.random(1, 2)
    player:SetRole(purchaserRole)
    tables.RoundRoles:addRole(player)

    local thisRoundsPurchase
    if purchaserRole == ROLE_TRAITOR then
      thisRoundsPurchase = traitorValidPurchases[math.random(1, #traitorValidPurchases)]
    else
      thisRoundsPurchase = detectiveValidPurchases[math.random(1, #detectiveValidPurchases)]
    end

    local purchaseId = DDD.Hooks.trackPurchases(tables, player, thisRoundsPurchase)

    GUnit.assert(purchaseId):shouldEqual(i)

    local totalPurchases = tables.AggregatePurchaseStats:getPurchases(playerId, purchaserRole, thisRoundsPurchase)

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

local function trackCreditsLootedSpec()
  for i = 1, 100 do
    tables.RoundId:addRound()

    local looter = GUnit.Generators.FakePlayer:new()
    local victim = GUnit.Generators.FakePlayer:new()
    tables.PlayerId:addPlayer(looter)
    tables.PlayerId:addPlayer(victim)
    local fakeCorpse = GUnit.Generators.FakeEntity:new()
    CORPSE.SetPlayerSteamID(fakeCorpse, victim)

    local steamid = CORPSE.GetPlayerSteamID(fakeCorpse, "")
    GUnit.assert(steamid):shouldEqual(victim:SteamID())

    local credits = math.random(1, 10)

    local id = DDD.Hooks.trackCreditsLooted(tables, looter, fakeCorpse, credits)
    GUnit.assert(id):shouldEqual(i)
  end
end

hookTest:beforeEach(beforeEach)
hookTest:afterEach(afterEach)

hookTest:addSpec("track player purchases", trackPurchasesSpec)
hookTest:addSpec("track when player DNA is found", trackDnaDiscoverySpec)
hookTest:addSpec("track when a player loots credits", trackCreditsLootedSpec)
