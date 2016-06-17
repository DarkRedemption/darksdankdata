local playerIdTest = GUnit.Test:new("PlayerIdTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
  DDD.Logging:enable()
end

local function generatePlayerList(size)
  local players = {}
  
  for i = 1, size do
    local ply = GUnit.Generators.FakePlayer:new()
    table.insert(players, ply)
  end
  
  return players
end

local function addPlayerSpec()
  local players = generatePlayerList(100)
  
  for i = 1, 100 do
    local ply = players[i]
    local id = tables.PlayerId:addPlayer(ply)
    GUnit.assert(id):shouldEqual(i)
  end
  
  for i = 1, 100 do
    local ply = players[i]
    local selectedPlyId = tables.PlayerId:getPlayerId(ply)
    GUnit.assert(selectedPlyId):shouldEqual(i)
  end
end

local function noDuplicatePlayersSpec()
  DDD.Logging:disable()
  local players = generatePlayerList(100)
  
  for i = 1, 100 do
    local ply = players[i]
    tables.PlayerId:addPlayer(ply)
    local id = tables.PlayerId:addPlayer(ply)
    GUnit.assert(id):shouldEqual(false)
  end
end

local function getRowSpec()
  local players = generatePlayerList(100)
  
  for i = 1, 100 do
    local ply = players[i]
    local id = tables.PlayerId:addPlayer(ply)
    local row = tables.PlayerId:getPlayerRow(ply)
    GUnit.assert(tonumber(row["id"])):shouldEqual(id)
    GUnit.assert(row["steam_id"]):shouldEqual(ply:SteamID())
    GUnit.assert(row["last_known_name"]):shouldEqual(ply:GetName())
  end
end


local function updatePlayerNameSpec()
  local players = generatePlayerList(100)

  for i = 1, 100 do
    local ply = players[i]
    local oldName = ply:GetName()
    tables.PlayerId:addPlayer(ply)
    local oldRow = tables.PlayerId:getPlayerRow(ply)
    GUnit.assert(oldName):shouldEqual(oldRow["last_known_name"])
    
    local newName = GUnit.Generators.StringGen.generateAlphaNum()
    ply:SetName(newName)
    GUnit.assert(newName):shouldEqual(ply:GetName())
    
    tables.PlayerId:updatePlayerName(ply)
    local newRow = tables.PlayerId:getPlayerRow(ply)
    GUnit.assert(newName):shouldEqual(newRow["last_known_name"])
  end
  
end

local function updateOnlyOnePlayerSpec()
  local players = generatePlayerList(100)

  local randomIndex = math.random(1, 100)
  local playersWithOldName = 0
  local playersWithNewName = 0
  
  for i = 1, 100 do
    local ply = players[i]
    tables.PlayerId:addPlayer(ply)
  end
  
  local randomPly = players[randomIndex]
  local oldName = randomPly:GetName()
  local newName = GUnit.Generators.StringGen.generateAlphaNum()
  randomPly:SetName(newName)
  tables.PlayerId:updatePlayerName(randomPly)
  
  for i = 1, 100 do
    local row = tables.PlayerId:getPlayerRow(players[i])
    if (row["last_known_name"] == oldName) then
      playersWithOldName = playersWithOldName + 1
    elseif (row["last_known_name"] == newName) then
      playersWithNewName = playersWithNewName + 1
    end
  end  
  
  GUnit.assert(playersWithOldName):shouldEqual(0)
  GUnit.assert(playersWithNewName):shouldEqual(1)
end


playerIdTest:beforeEach(beforeEach)
playerIdTest:afterEach(afterEach)

playerIdTest:addSpec("add new players and select them", addPlayerSpec)
playerIdTest:addSpec("not add a player with the same SteamId to the table", noDuplicatePlayersSpec)
playerIdTest:addSpec("get a whole row", getRowSpec)
playerIdTest:addSpec("update usernames", updatePlayerNameSpec)
playerIdTest:addSpec("only update the specified user's name", updateOnlyOnePlayerSpec)