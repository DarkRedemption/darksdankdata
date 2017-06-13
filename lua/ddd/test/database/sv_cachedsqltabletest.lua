local cachedSqlTableTest = GUnit.Test:new("CachedSqlTable")
local length = DDD.length
local CachedSqlTable = DDD.Database.CachedSqlTable
local CachedColumn = DDD.Database.CachedColumn
local currentTableName = ""

local function generateTableName()
  return "test_" .. os.time() .. "_" .. GUnit.Generators.StringGen.generateAlphaNum()
end

local function beforeEach()
  currentTableName = generateTableName()
end

local function afterEach()
  sql.Query("DROP TABLE IF EXISTS " .. currentTableName)
end

local function createTableSpec()
  local idColumn = CachedColumn:new("id"):makeIntegerType():makePrimaryKey()
  local textColumn = CachedColumn:new("name"):makeTextType():makeNotNull()
  local sqlTable = CachedSqlTable:new(currentTableName)
  sqlTable:addColumns(idColumn, textColumn)
  local createResult = sqlTable:create()
  GUnit.assert(createResult):shouldEqual(true)

  local check = sql.Query("SELECT * FROM " .. currentTableName)
  GUnit.assert(check):shouldEqual(nil)
end

local function insertQueueSpec()
  local idColumn = CachedColumn:new("id"):makeIntegerType():makePrimaryKey():makeAutoIncrement()
  local textColumn = CachedColumn:new("name"):makeTextType():makeNotNull()
  local sqlTable = CachedSqlTable:new(currentTableName)

  local newRow = {
    name = "testname"
  }

  sqlTable:insertRowLater(newRow)
  GUnit.assert(#sqlTable.rowsToInsert):shouldEqual(1)
  sqlTable:insertQueuedRows()
  GUnit.assert(#sqlTable.rowsToInsert):shouldEqual(0)

  sqlTable:selectAll()
  local row = sqlTable.cache[{id = 1}]
  GUnit.assert(row):shouldEqual({id = 1, name = "testname"})
end

cachedSqlTableTest:beforeEach(beforeEach)

cachedSqlTableTest:addSpec("create its table after being given columns", createTableSpec)
cachedSqlTableTest:addSpec("queue rows for insert, then insert them on request", insertQueueSpec)

cachedSqlTableTest:addSpec("fail to create a table if no primary keys were given", GUnit.pending)
cachedSqlTableTest:addSpec("Pull queued rows from other unique identifiers from the cache when possible", GUnit.pending)
cachedSqlTableTest:addSpec("Ignore queueing rows for insert if a row with certain values already exists", GUnit.pending)
cachedSqlTableTest:addSpec("automatically cache values, indexed by primary key", GUnit.pending)
cachedSqlTableTest:addSpec("automatically cache values, indexed by multiple primary keys", GUnit.pending)
cachedSqlTableTest:addSpec("automatically cache values of columns that are unique", GUnit.pending)
cachedSqlTableTest:addSpec("automatically cache values of columns that have unique pairs", GUnit.pending)
cachedSqlTableTest:addSpec("clear the cache", GUnit.pending)
cachedSqlTableTest:addSpec("drop the table and clear its cache at the same time", GUnit.pending)
cachedSqlTableTest:addSpec("insert new rows into the database only after executeUpdate is called", GUnit.pending)
cachedSqlTableTest:addSpec("update rows in the database only after executeUpdate is called", GUnit.pending)
cachedSqlTableTest:addSpec("automatically cache values of columns that have unique pairs", GUnit.pending)
cachedSqlTableTest:addSpec("work with default values that are determined via functions", GUnit.pending)
