--A test version of SqlTable that renames the table and its foreign key constraints to have "test_" prepended to them.
--Inherits from SqlTable.

local TestSqlTable = table.Copy(DDD.SqlTable)
TestSqlTable.__index = TestSqlTable
    
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

--[[
Takes a regular DDD SQL table and converts it into a test version.
This mostly means it renames the table it to not interfere with tables in use.
]]
function TestSqlTable:convertTable(dddTable)
  local testTable = table.Copy(dddTable) 
  testTable.tableName = "test_" .. GUnit.timestamp .. "_" .. dddTable.tableName
  if (dddTable.foreignKeyTable) then
    testTable.foreignKeyTable = convertForeignKeyConstraints(dddTable.foreignKeyTable)
  end
  
  return testTable
end

DDDTest.TestSqlTable = TestSqlTable