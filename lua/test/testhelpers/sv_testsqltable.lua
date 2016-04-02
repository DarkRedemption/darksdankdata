--A test version of SqlTable that renames the table and its foreign key constraints to have "test_" prepended to them.
--Inherits from SqlTable.

local TestSqlTable = DDD.SqlTable:new("", {})
TestSqlTable.__index = TestSqlTable

 local function search (k, plist)
    for i=1, table.getn(plist) do
      local v = plist[i][k]     -- try `i'-th superclass
      if v then return v end
    end
  end
    
--Converts foreign key constraint names to a test version where they have the same table name,
--but now "test_" has been prepended to them. This is to ensure only test tables are ever used
--so your production code is not messed with.
local function convertForeignKeyConstraints(foreignKeyTable)
  local convertedTable = DDD.Database.ForeignKeyTable:new()
  if (foreignKeyTable != nil) then
    for columnName, foreignKeyRef in pairs(foreignKeyTable.foreignKeys) do
      local testTable = TestSqlTable:convertTable(foreignKeyRef.sqlTable)
      convertedTable:addConstraint(columnName, testTable, foreignKeyRef.foreignColumn)
      testTable:create()
    end
  end
  return convertedTable
end

function TestSqlTable:getForeignTableByColumn(columnName)
  return self.foreignKeyTable.foreignKeys[columnName].sqlTable
end

--[[
Takes a regular DDD SQL table and converts it into a test version.
This mostly means it renames the table it to not interfere with tables in use.
]]
function TestSqlTable:convertTable(dddTable)
  local newMetaTable = {}
  local testTable = {}
  testTable = table.Copy(dddTable)
  
  testTable.tableName = "test_" .. GUnit.timestamp .. "_" .. dddTable.tableName
  if (testTable.foreignKeyTable) then
    testTable.foreignKeyTable = convertForeignKeyConstraints(testTable.foreignKeyTable)
  end
  
  setmetatable(newMetaTable, {__index = function (t, k)
    return search(k, {testTable, self})
  end})
  newMetaTable.__index = newMetaTable
  setmetatable(testTable, newMetaTable)
  
  return testTable
end

--[[
Deletes the test table.
Should always be run after a test.
]]
function TestSqlTable:delete()
  local query = "DROP TABLE " .. self.tableName
  sql.Query(query)
end

function TestSqlTable:drop()
  self:delete()
end

DDDTest.TestSqlTable = TestSqlTable