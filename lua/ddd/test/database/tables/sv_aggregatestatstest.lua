local aggregateStatsTest = GUnit.Test:new("AggregateStatsTable")
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
                                "weapon_ttt_beacon",
                                "weapon_ttt_defuser",
                                "weapon_ttt_teleport",
                                "weapon_ttt_binoculars",
                                "weapon_ttt_stungun",
                                "weapon_ttt_health_station"}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.AggregateStats.tables = tables
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

local function addPlayerSpec()
  for i = 1, 100 do
    local ply = GUnit.Generators.FakePlayer:new()
    local id = tables.PlayerId:addPlayer(ply)
    local result = tables.AggregateStats:addPlayer(id)
    GUnit.assert(result):shouldEqual(id)
    
    local row = tables.AggregateStats:getPlayerStats(id)
    allColumnsZero(row)
  end
end

local function incrementKillsSpec()
  local ply = GUnit.Generators.FakePlayer:new()
  local id = tables.PlayerId:addPlayer(ply)
  tables.AggregateStats:addPlayer(id)
    
  for i = 1, 100 do
    local playerRole = math.random(0, 2)
    local victimRole = math.random(0, 2)
    
    local currentKills = tables.AggregateStats:getKills(id, playerRole, victimRole)
    tables.AggregateStats:incrementKills(id, playerRole, victimRole)
    local row = tables.AggregateStats:getPlayerStats(id)
    local newKills = tables.AggregateStats:getKills(id, playerRole, victimRole)
    
    GUnit.assert(newKills):shouldEqual(currentKills + 1)
  end
end

local function incrementDeathsSpec()
  local ply = GUnit.Generators.FakePlayer:new()
  local id = tables.PlayerId:addPlayer(ply)
  tables.AggregateStats:addPlayer(id)
    
  for i = 1, 100 do
    local playerRole = math.random(0, 2)
    local attackerRole = math.random(0, 2)
    
    local currentDeaths = tables.AggregateStats:getDeaths(id, playerRole, attackerRole)
    tables.AggregateStats:incrementDeaths(id, playerRole, attackerRole)
    local row = tables.AggregateStats:getPlayerStats(id)
    local newDeaths = tables.AggregateStats:getDeaths(id, playerRole, attackerRole)
    
    GUnit.assert(newDeaths):shouldEqual(currentDeaths + 1)
  end
end

local function incrementWorldDeathsSpec()
  local ply = GUnit.Generators.FakePlayer:new()
  local id = tables.PlayerId:addPlayer(ply)
  tables.AggregateStats:addPlayer(id)
    
  for i = 1, 100 do
    local playerRole = math.random(0, 2)
    
    local currentDeaths = tables.AggregateStats:getWorldDeaths(id, playerRole)
    tables.AggregateStats:incrementWorldDeaths(id, playerRole)
    local row = tables.AggregateStats:getPlayerStats(id)
    local newDeaths = tables.AggregateStats:getWorldDeaths(id, playerRole)
    
    GUnit.assert(newDeaths):shouldEqual(currentDeaths + 1)
  end
end

local function incrementPurchasesSpec()
  local ply = GUnit.Generators.FakePlayer:new()
  local id = tables.PlayerId:addPlayer(ply)  
  tables.AggregateStats:addPlayer(id)
  
  for i = 1, 100 do
    local playerRole = math.random(1, 2)
    ply:SetRole(playerRole)
    
    local thisRoundsPurchase
    if (playerRole == 1) then
      thisRoundsPurchase = traitorValidPurchases[math.random(1, #traitorValidPurchases)]
    else
      thisRoundsPurchase = detectiveValidPurchases[math.random(1, #detectiveValidPurchases)]
    end
    
    local currentPurchases = tables.AggregateStats:getItemPurchases(id, playerRole, thisRoundsPurchase)
    tables.AggregateStats:incrementItemPurchases(id, playerRole, thisRoundsPurchase)
    local newPurchases = tables.AggregateStats:getItemPurchases(id, playerRole, thisRoundsPurchase)
    
    GUnit.assert(newPurchases):shouldEqual(currentPurchases + 1)
  end
end

local function calculateKillsSpec()
  --The rows before recalculating should equal the recalculated rows
  local oldRows = {}
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)
  
  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end

  local attacker = fakePlayerList[1]
  GUnit.assert(attacker.tableId):shouldEqual(1)
  
  for i = 1, 100 do
    tables.RoundId:addRound()
    local victim = fakePlayerList[math.random(2, #fakePlayerList)]
    tables.RoundRoles:addRole(attacker)
    tables.RoundRoles:addRole(victim)
    local weaponId = tables.WeaponId:addWeapon(GUnit.Generators.StringGen.generateAlphaNum())
    
    tables.PlayerKill:addKill(victim.tableId, attacker.tableId, weaponId)
    tables.AggregateStats:incrementKills(attacker.tableId, attacker:GetRole(), victim:GetRole())
  end
  
  for i = 1, #fakePlayerList do
    table.insert(oldRows, tables.AggregateStats:getPlayerStats(i))
  end
  
  tables.AggregateStats:recalculate()
  
    local newRow = tables.AggregateStats:getPlayerStats(1)
    --Needs to only check kills
    for columnName, columnValue in pairs(newRow) do
      GUnit.assert(oldRows[1][columnName]):shouldEqual(columnValue)
    end
end

local function recalculateWithNoDataSpec()
  for i = 1, 100 do
    local ply = GUnit.Generators.FakePlayer:new()
    local id = tables.PlayerId:addPlayer(ply)
    tables.AggregateStats:addPlayer(id)
    tables.AggregateStats:incrementKills(id, 0, 0)
    
    local row = tables.AggregateStats:getPlayerStats(id)
    GUnit.assert(row["innocent_innocent_kills"]):shouldEqual("1")
  end
  
  tables.AggregateStats:recalculate()
  
  for i = 1, 100 do
    local newRow = tables.AggregateStats:getPlayerStats(i)
    allColumnsZero(newRow)
  end
end

local function recalculateCombatDataSpec()
  --The rows before recalculating should equal the recalculated rows
  local oldRows = {}
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)
  
  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end

  for i = 1, 100 do
    tables.RoundId:addRound()
    local attacker, victim = DDDTest.Helpers.getRandomPair(fakePlayerList)  
    tables.RoundRoles:addRole(attacker)
    tables.RoundRoles:addRole(victim)
    local weaponId = tables.WeaponId:addWeapon(GUnit.Generators.StringGen.generateAlphaNum())
    
    tables.PlayerKill:addKill(victim.tableId, attacker.tableId, weaponId)
    tables.AggregateStats:incrementKills(attacker.tableId, attacker:GetRole(), victim:GetRole())
    tables.AggregateStats:incrementDeaths(victim.tableId, victim:GetRole(), attacker:GetRole())
  end
  
  for i = 1, #fakePlayerList do
    table.insert(oldRows, tables.AggregateStats:getPlayerStats(i))
  end
  
  tables.AggregateStats:recalculate()
  
  for i = 1, #fakePlayerList do
    local newRow = tables.AggregateStats:getPlayerStats(i)
    --PrintTable(oldRows[i])
    --print("")
    --PrintTable(newRow)
    for columnName, columnValue in pairs(newRow) do
      GUnit.assert(oldRows[i][columnName]):shouldEqual(columnValue)
    end
  end
end

local function recalculateWorldDeathsSpec()
  --The rows before recalculating should equal the recalculated rows
  local oldRows = {}
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)
  
  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end

  for i = 1, 100 do
    tables.RoundId:addRound()
    local victim = fakePlayerList[math.random(1, #fakePlayerList)]
    tables.RoundRoles:addRole(victim)
    
    tables.WorldKill:addPlayerKill(victim.tableId)
    tables.AggregateStats:incrementWorldDeaths(victim.tableId, victim:GetRole())
  end
  
  for i = 1, #fakePlayerList do
    table.insert(oldRows, tables.AggregateStats:getPlayerStats(i))
  end
  
  tables.AggregateStats:recalculate()
  
  for i = 1, #fakePlayerList do
    local newRow = tables.AggregateStats:getPlayerStats(i)
    --PrintTable(oldRows[i])
    --print("")
    --PrintTable(newRow)
    for columnName, columnValue in pairs(newRow) do
      GUnit.assert(oldRows[i][columnName]):shouldEqual(columnValue)
    end
  end
end

local function recalculatePurchasesSpec()
  --The rows before recalculating should equal the recalculated rows
  local oldRows = {}
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)
  
  for index, fakePlayer in pairs(fakePlayerList) do
    tables.AggregateStats:addPlayer(fakePlayer.tableId)
  end
    
  for i = 1, 100 do
    tables.RoundId:addRound()
     
    local player = fakePlayerList[math.random(1, #fakePlayerList)]
    local playerRole = math.random(1, 2)
    player:SetRole(playerRole)
    tables.RoundRoles:addRole(player)
    
    local thisRoundsPurchase
    if (playerRole == 1) then
      thisRoundsPurchase = traitorValidPurchases[math.random(1, #traitorValidPurchases)]
    else
      thisRoundsPurchase = detectiveValidPurchases[math.random(1, #detectiveValidPurchases)]
    end
    
    local shopItemId = tables.ShopItem:getOrAddItemId(thisRoundsPurchase)
    local purchaseId = tables.Purchases:addPurchase(player.tableId, shopItemId)
    GUnit.assert(purchaseId):shouldEqual(i)
    
    tables.AggregateStats:incrementItemPurchases(player.tableId, playerRole, thisRoundsPurchase)
  end
  
  for i = 1, #fakePlayerList do
    table.insert(oldRows, tables.AggregateStats:getPlayerStats(i))
  end
  
  tables.AggregateStats:recalculate()
  
  for i = 1, #fakePlayerList do
    local newRow = tables.AggregateStats:getPlayerStats(i)
    --PrintTable(oldRows[i])
    --print("")
    --PrintTable(newRow)
    for columnName, columnValue in pairs(newRow) do
      GUnit.assert(oldRows[i][columnName]):shouldEqual(columnValue)
    end
  end
end

aggregateStatsTest:beforeEach(beforeEach)
aggregateStatsTest:afterEach(afterEach)

aggregateStatsTest:addSpec("add a player with no stats", addPlayerSpec)
aggregateStatsTest:addSpec("increment kills properly", incrementKillsSpec)
aggregateStatsTest:addSpec("increment deaths properly", incrementDeathsSpec)
aggregateStatsTest:addSpec("increment world deaths properly", incrementWorldDeathsSpec)
aggregateStatsTest:addSpec("increment item purchases properly", incrementPurchasesSpec)
aggregateStatsTest:addSpec("calculate a player's kills accurately", calculateKillsSpec)
aggregateStatsTest:addSpec("recalculate every player's stats who actually has no data", recalculateWithNoDataSpec)
aggregateStatsTest:addSpec("recalculate every player's combat stats with data", recalculateCombatDataSpec)
aggregateStatsTest:addSpec("recalculate every player's world deaths with data", recalculateWorldDeathsSpec)
aggregateStatsTest:addSpec("recalculate every player's purchases with data", recalculatePurchasesSpec)