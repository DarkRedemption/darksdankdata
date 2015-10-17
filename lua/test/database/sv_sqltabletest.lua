local sqlTableTest = GUnit.Test:new("SqlTable")

local tableName = "testtable2"
local columns = {
      id = "INTEGER PRIMARY KEY",
      name = "STRING"
    }

local function basicSpec()
    local sqlTable = DDDTest.TestSqlTable:new(tableName, columns)
    sqlTable:create()
    
    local rowToInsert = {
      name = "testname"
    }
    
    local insertResult = sqlTable:insertTable(rowToInsert)

    assert(tonumber(insertResult) == 1)
    sqlTable:drop()
    return true
  end
  
local function selectSpec()
  local sqlTable = DDDTest.TestSqlTable:new(tableName, columns)
  sqlTable:create()
    
  local rowToInsert = {
     name = "testname"
  }
    
  sqlTable:insertTable(rowToInsert)
  
  local selectedValue = sqlTable:selectById("1")
  assert(selectedValue["name"] == rowToInsert["name"])
  
  sqlTable:drop()
  return true
end
  
--sqlTableTest:addSpec("create a table successfully", tableAddSpec)
sqlTableTest:addSpec("create a table and add a row successfully", basicSpec)
sqlTableTest:addSpec("select a known column", selectSpec)