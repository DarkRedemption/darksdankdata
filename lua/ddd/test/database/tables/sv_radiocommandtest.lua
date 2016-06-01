local commandTableTest = GUnit.Test:new("RadioCommandTable")
local tables = {}

local function beforeEach()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDDTest.Helpers.dropAll(tables)
end

local function addCommandSpec()
  local commandTable = tables.RadioCommand
  for i = 1, 100 do
    local command = GUnit.Generators.StringGen.generateAlphaNum()
    local insertId = commandTable:addCommand(command)
    GUnit.assert(insertId):shouldEqual(i)
    
    local commandId = commandTable:getCommandId(command)
    GUnit.assert(insertId):shouldEqual(commandId)
  end
end

commandTableTest:beforeEach(beforeEach)
commandTableTest:afterEach(afterEach)
commandTableTest:addSpec("add a command and select it", addCommandSpec)