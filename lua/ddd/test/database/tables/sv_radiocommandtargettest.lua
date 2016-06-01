local commandTargetTableTest = GUnit.Test:new("RadioCommandTargetTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
  tables.MapId:addMap()
  tables.RoundId:addRound()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addLivingTargetSpec()
  local commandTable = tables.RadioCommand
  local commandUsedTable = tables.RadioCommandUsed
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for i = 1, 100 do
    local command = GUnit.Generators.StringGen.generateAlphaNum()
    local commandId = commandTable:addCommand(command)
    local player, target = DDDTest.Helpers.getRandomPair(fakePlayerList)
    local commandUsedId = tables.RadioCommandUsed:addCommandUsed(player, command)
    local commandTargetId = tables.RadioCommandTarget:addCommandTarget(target, commandUsedId)
    GUnit.assert(commandTargetId):shouldEqual(i)
  end
end

local function addRagdollTargetSpec()
  local commandTable = tables.RadioCommand
  local commandUsedTable = tables.RadioCommandUsed
  local fakePlayerList = DDDTest.Helpers.Generators.makePlayerIdList(tables, 2, 10)

  for i = 1, 100 do
    local command = GUnit.Generators.StringGen.generateAlphaNum()
    local commandId = commandTable:addCommand(command)
    local player, target = DDDTest.Helpers.getRandomPair(fakePlayerList)
    
    local rag = {}
    rag.__index = rag
    rag.steamid = target:SteamID()
    
    function rag:GetNWString(strName, default)
        return rag[strName] or default
    end
    
    function rag:GetClass()
      return "prop_ragdoll"
    end
    
    local commandUsedId = tables.RadioCommandUsed:addCommandUsed(player, command, rag)
    local commandTargetId = tables.RadioCommandTarget:addCommandTarget(rag, commandUsedId)
    GUnit.assert(commandTargetId):shouldEqual(i)
  end
end

commandTargetTableTest:beforeEach(beforeEach)
commandTargetTableTest:afterEach(afterEach)

commandTargetTableTest:addSpec("add a live target", addLivingTargetSpec)
commandTargetTableTest:addSpec("add a dead, identified target", addRagdollTargetSpec)