local commandUsedTableTest = GUnit.Test:new("RadioCommandUsedTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
  tables.RoundId:addRound()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addCommandUsedSpec()
  local commandTable = tables.RadioCommand
  local commandUsedTable = tables.RadioCommandUsed
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for i = 1, 100 do
    local command = GUnit.Generators.StringGen.generateAlphaNum()
    local commandId = commandTable:addCommand(command)
    GUnit.assert(commandId):shouldEqual(i)
    
    local player, target = DDDTest.Helpers.getRandomPair(fakePlayerList)
    
    local commandUsedId = tables.RadioCommandUsed:addCommandUsed(player, command, target)
    GUnit.assert(commandUsedId):shouldEqual(i)
  end
end

local function addCommandUsedOnNobodySpec()
  local commandTable = tables.RadioCommand
  local commandUsedTable = tables.RadioCommandUsed
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for i = 1, 100 do
    local command = GUnit.Generators.StringGen.generateAlphaNum()
    local commandId = commandTable:addCommand(command)
    GUnit.assert(commandId):shouldEqual(i)
    
    local playerIndex = math.random(1, #fakePlayerList)
    local player = fakePlayerList[playerIndex]
    
    local commandUsedId = tables.RadioCommandUsed:addCommandUsed(player, command, "quick_nobody")
    GUnit.assert(commandUsedId):shouldEqual(i)
  end
end

local function addCommandUsedOnDisguiserSpec()
  local commandTable = tables.RadioCommand
  local commandUsedTable = tables.RadioCommandUsed
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for i = 1, 100 do
    local command = GUnit.Generators.StringGen.generateAlphaNum()
    local commandId = commandTable:addCommand(command)
    GUnit.assert(commandId):shouldEqual(i)
    
    local playerIndex = math.random(1, #fakePlayerList)
    local player = fakePlayerList[playerIndex]
    
    local commandUsedId = tables.RadioCommandUsed:addCommandUsed(player, command, "quick_disg")
    GUnit.assert(commandUsedId):shouldEqual(i)
  end
end

local function addCommandUsedOnUnidSpec()
  local commandTable = tables.RadioCommand
  local commandUsedTable = tables.RadioCommandUsed
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for i = 1, 100 do
    local command = GUnit.Generators.StringGen.generateAlphaNum()
    local commandId = commandTable:addCommand(command)
    GUnit.assert(commandId):shouldEqual(i)
    
    local playerIndex = math.random(1, #fakePlayerList)
    local player = fakePlayerList[playerIndex]
    
    local commandUsedId = tables.RadioCommandUsed:addCommandUsed(player, command, "quick_corpse")
    GUnit.assert(commandUsedId):shouldEqual(i)
  end
end

local function addCommandUsedOnRagdollSpec()
  local commandTable = tables.RadioCommand
  local commandUsedTable = tables.RadioCommandUsed
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for i = 1, 100 do
    local command = GUnit.Generators.StringGen.generateAlphaNum()
    local commandId = commandTable:addCommand(command)
    GUnit.assert(commandId):shouldEqual(i)
    
    local player, target = DDDTest.Helpers.getRandomPair(fakePlayerList)
    
    local rag = {}
    rag.__index = rag
    rag.steamid = target:SteamID()
    
    function rag:GetNWString(strName, default)
        return rag[strName] or default
    end
    
    local commandUsedId = tables.RadioCommandUsed:addCommandUsed(player, command, target)
    GUnit.assert(commandUsedId):shouldEqual(i)
  end
end

commandUsedTableTest:beforeEach(beforeEach)
commandUsedTableTest:afterEach(afterEach)

commandUsedTableTest:addSpec("add rows from multiple players", addCommandUsedSpec)
commandUsedTableTest:addSpec("add rows from multiple players targeting no one", addCommandUsedOnNobodySpec)
commandUsedTableTest:addSpec("add rows from multiple players targeting disguised people", addCommandUsedOnDisguiserSpec)
commandUsedTableTest:addSpec("add rows from multiple players targeting unidentified corpses", addCommandUsedOnUnidSpec)
commandUsedTableTest:addSpec("add rows from multiple players targeting identified corpses", addCommandUsedOnRagdollSpec)
commandUsedTableTest:addSpec("not add rows that do not have a player", GUnit.pending)