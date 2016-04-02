local sqlTableTest = GUnit.Test:new("SqlTable")

local tableName = "testtable2"
local columns = {
      id = "INTEGER PRIMARY KEY",
      name = "STRING"
    }

local function beforeEach()
  local sqlTable = DDD.SqlTable:new(tableName, columns)
  local testSqlTable = DDDTest.TestSqlTable:convertTable(sqlTable)
  testSqlTable:create()
  sqlTableTest.table = testSqlTable
end

local function afterEach()
  sqlTableTest.table:drop()
  sqlTableTest.table = nil
end

local function tableNameModifySpec()
  assert(sqlTableTest.table.tableName != tableName, "The table name didn't change. It is " .. sqlTableTest.table.tableName)
end

local function basicSpec()
    local rowToInsert = {
      name = "testname"
    }
    local insertResult = sqlTableTest.table:insertTable(rowToInsert)
    assert(tonumber(insertResult) == 1)
  end
  
local function selectSpec()
  local rowToInsert = {
     name = "testname"
  }
  sqlTableTest.table:insertTable(rowToInsert)
  
  local selectedValue = sqlTableTest.table:selectById("1")
  assert(selectedValue["name"] == rowToInsert["name"])
end

sqlTableTest:beforeEach(beforeEach)
sqlTableTest:afterEach(afterEach)

sqlTableTest:addSpec("modify the tablename ", tableNameModifySpec)
sqlTableTest:addSpec("create a table and add a row", basicSpec)
sqlTableTest:addSpec("select a known column", selectSpec)