local corpseIdentifiedTest = GUnit.Test:new("CorpseIdentifiedTable")
local playerGen = GUnit.Generators.FakePlayer
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
  tables.RoundId:addRound()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addCorpseSpec()
  local players = DDDTest.Helpers.Generators.makePlayerIdList(tables, 20, 100)
  
  for i = 1, 100 do
    if (i % 10 == 0) then
      tables.RoundId:addRound()
    end
    
    local finder, corpseOwner = DDDTest.Helpers.getRandomPair(players)
    local id = tables.CorpseIdentified:addCorpseFound(finder, corpseOwner, nil)
    GUnit.assert(id):shouldEqual(i)
  end
end

local function addDisconnectedCorpseSpec()
  local players = DDDTest.Helpers.Generators.makePlayerIdList(tables, 20, 100)
  
  for i = 1, 100 do
    if (i % 10 == 0) then
      tables.RoundId:addRound()
    end
    
    local finder, corpseOwner = DDDTest.Helpers.getRandomPair(players)
    local rag = {}
    rag.__index = rag
    rag.steamid = corpseOwner:SteamID()
    
    function rag:GetNWString(strName, default)
        return rag[strName] or default
    end
    
    local id = tables.CorpseIdentified:addCorpseFound(finder, nil, rag)
    GUnit.assert(id):shouldEqual(i)
  end
end

corpseIdentifiedTest:beforeEach(beforeEach)
corpseIdentifiedTest:afterEach(afterEach)

corpseIdentifiedTest:addSpec("add a found corpse", addCorpseSpec)
corpseIdentifiedTest:addSpec("add a found corpse whose player has disconnected", addDisconnectedCorpseSpec)