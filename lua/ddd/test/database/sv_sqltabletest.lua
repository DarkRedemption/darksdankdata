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
    local foreignKeySize = sqlTableTest.table.foreignKeyTable:getForeignKeySize()
    local compositeKeySize = sqlTableTest.table.foreignKeyTable:getCompositeKeySize()
    GUnit.assert(foreignKeySize + compositeKeySize):shouldEqual(0)
    GUnit.assert(sqlTableTest.table.uniqueGroups):isNil()

    local rowToInsert = {
      name = "testname"
    }
    local insertResult = sqlTableTest.table:insertTable(rowToInsert)
    GUnit.assert(tonumber(insertResult)):shouldEqual(1)
  end

local function selectSpec()
  local rowToInsert = {
     name = "testname"
  }
  sqlTableTest.table:insertTable(rowToInsert)

  local selectedValue = sqlTableTest.table:selectById("1")
  GUnit.assert(selectedValue["name"]):shouldEqual(rowToInsert["name"])
end

local function uniqueConstraintQuerySpec()
  local uniqueGroups = {}
  local constraints = {"col1", "col2"}
  local constraints2 = {"col3", "col4", "col5"}
  local constraints3 = {"col6", "col12", "col11"}

  table.insert(uniqueGroups, constraints)
  table.insert(uniqueGroups, constraints2)
  table.insert(uniqueGroups, constraints3)

  sqlTableTest.table.uniqueGroups = uniqueGroups
  local query = sqlTableTest.table:generateUniqueConstraintsQuery()
  local expectedResult = "UNIQUE(col1, col2), UNIQUE(col3, col4, col5), UNIQUE(col6, col12, col11)"

  GUnit.assert(query):shouldEqual(expectedResult)
end

sqlTableTest:beforeEach(beforeEach)
sqlTableTest:afterEach(afterEach)

sqlTableTest:addSpec("modify the tablename", tableNameModifySpec)
sqlTableTest:addSpec("create a table and add a row", basicSpec)
sqlTableTest:addSpec("select a known column", selectSpec)
sqlTableTest:addSpec("generate unique constraint queries correctly", uniqueConstraintQuerySpec)
