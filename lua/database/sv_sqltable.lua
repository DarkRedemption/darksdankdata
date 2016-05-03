local log = DDD.Logging

local SqlTable = {}
SqlTable.tableName = ""
SqlTable.columns = {}
SqlTable.foreignKeyTable = nil
SqlTable.uniqueGroups = nil
SqlTable.__index = SqlTable

local function getTableSize(tableToCheck)
  local numKeys = 0
    for keyName, keyValue in pairs(tableToCheck) do
      numKeys = numKeys + 1
    end
    return numKeys
end

function SqlTable:getNumberOfColumns()
  return getTableSize(self.columns)
end

function SqlTable:getNumberOfUniqueGroups()
  return table.getn(self.uniqueGroups)
end

function SqlTable:generateColumnQuery()
  local query = "("
  local columnsConverted = 0
  local numColumns = self:getNumberOfColumns()

  for columnName, columnSettings in pairs(self.columns) do
    query = query .. " " .. columnName .. " " .. columnSettings
    columnsConverted = columnsConverted + 1
    if columnsConverted < numColumns then
      query = query .. ","
    end
  end

  return query
end

local function processUniqueColumnGroup(columnsToConstrain)
  local columnsProcessed = 0
  local query = "UNIQUE("
  for columnNumber, columnName in pairs(columnsToConstrain) do
    query = query .. columnName
    columnsProcessed = columnsProcessed + 1
    if columnsProcessed < table.getn(columnsToConstrain) then
      query = query .. ", "
    else
      query = query .. ")"
    end
  end
  
  return query
end

function SqlTable:generateUniqueConstraintsQuery()
  local query = ""
  local groupsConverted = 0
  local numGroups = self:getNumberOfUniqueGroups()
  
  for groupNumber, columnsToConstrain in pairs(self.uniqueGroups) do
    query = query .. processUniqueColumnGroup(columnsToConstrain)
    groupsConverted = groupsConverted + 1
    if groupsConverted < numGroups then
      query = query .. ", "
    end
  end
  
  return query
end

function SqlTable:createTable()
  local query = "CREATE TABLE " .. 
            self.tableName .. 
            self:generateColumnQuery()
            
  if (self.foreignKeyTable) then
     query = query .. ", " .. self.foreignKeyTable:generateConstraintQuery()
  end
  
  if (self.uniqueGroups) then
    query = query .. ", " .. self:generateUniqueConstraintsQuery()
  end
  
  query = query .. ")"
  
  log.logDebug("Creating table with command: " .. query)
  local result = sql.Query(query)
  
  if (result == false) then
    log.logError("Table " .. self.tableName .. " could not be created! Error was: " .. sql.LastError())
    return false
  else
    return true
  end
end

function SqlTable:create()
   if (!sql.TableExists(self.tableName)) then
      log.logDebug("Table " .. self.tableName .. " does not exist. Now creating.")
    if (!self:createTable()) then
      log.logError("Failed to create table." .. self.tableName)
    end
   else
    log.logDebug("Table " .. self.tableName .. " already exists.")
    return true
  end
end

function SqlTable:selectById(id)
  local query = "SELECT * FROM " .. self.tableName .. " WHERE id == " .. tostring(id)
  return self:query("SqlTable:selectById", query, 1)
end

local function generateInsertQuery(sqlTable, luaTable)
  local tableSize = 0
  for k, v in pairs(luaTable) do
    tableSize = tableSize + 1
  end

  local baseQuery = "INSERT INTO " .. sqlTable.tableName .. " ("
  local values = " VALUES ("
  local i = 0
  for k, v in pairs(luaTable) do
    baseQuery = baseQuery .. k
    
    if (type(v) == "string") then
      values = values .. "\"" .. v .. "\""
    else
      values = values .. v
    end
    
    i = i + 1
    if (i == tableSize) then
      baseQuery = baseQuery .. ")"
      values = values .. ")"
    else
      baseQuery = baseQuery .. ", "
      values = values .. ", "
    end
  end
  return baseQuery .. values
end

--[[
Inserts a row into the SqlTable using a lua table.
PARAM luaTable:Table - A table where the keys are the column names, and the values are what to insert into those columns.
]]
function SqlTable:insertTable(luaTable)
  local query = generateInsertQuery(self, luaTable)
  log.logDebug("Now running the following insert query on table " .. self.tableName .. ": " .. query)
  local result = sql.Query(query)
  if (result == nil) then --A successful INSERT returns nil.
    log.logDebug("Insert into table " .. self.tableName .. " was successful.")
    local lastId = self:query("SqlTable:insertTable", "SELECT last_insert_rowid() AS id", 1, "id")
    return tonumber(lastId)
  else
    log.logError("Could not insert into table " .. self.tableName .. "!")
    return false
  end
end

local function queryError(tableName, funcName, query)
  log.logError("SqlTable:query via " .. funcName ..": Query on " .. tableName .. " failed. Query was: " .. query .. "\nError was: " ..sql.LastError())
end

--[[
For custom queries. Makes the return value safe (not nil).
PARAM funcName:String - The name of the function that is calling the query for logging purposes.
PARAM query:String - The SQL query.
PARAM resultRow - The result row to select. If nil, all rows are returned.
PARAM resultColumn - The result row to select. If nil, all columns are returned. If resultRow is nil, this is ignored.
]]
function SqlTable:query(funcName, query, resultRow, resultColumn)
  local result = sql.Query(query)
  if (result == nil) then --Nothing to select
    return 0
  elseif (result == false) then --Bad query
    queryError(self.tableName, funcName, query)
    return -1
  --Everything after this point (other than the LogError) is for the user to select results safely. 
  elseif (resultRow == nil && resultColumn == nil) then --User wants everything
    return result
  elseif (resultRow != nil && resultColumn == nil) then --User wants one row
    if (result[resultRow] != "NULL") then
      return result[resultRow]
    else
      queryError(self.tableName, funcName, query)
      return 0
    end
  elseif (resultRow != nil && resultColumn != nil) then --User wants specific result
    if (result[resultRow][resultColumn] != "NULL") then
      return result[resultRow][resultColumn]
    else
      queryError(self.tableName, funcName, query)
      return 0
    end
  else
    DDD.Logging.LogError("SqlTable:query via " .. funcName ..": Result cannot be returned. You cannot only select a column to return.")
    return -1
  end
end

--[[
Deletes the test table.
Should always be run after a test, and probably never run anywhere else.
]]
function SqlTable:delete()
  local query = "DROP TABLE " .. self.tableName
  sql.Query(query)
end

function SqlTable:drop()
  self:delete()
end

--[[
Gets a foreign table in the foreign key constraints.
Used instead of calling the other databases directly because doing so would cause testing problems,
since you'd always be calling the original table instead of a table created just for the tests.
]]
function SqlTable:getForeignTableByColumn(columnName)
  return self.foreignKeyTable.foreignKeys[columnName].sqlTable
end
  
--[[
Instantiates a new SqlTable class.
PARAM tablename:String - The name of the table.
PARAM columns:Table - A lua table of column name (string keys) and column settings (string values)
PARAM foreignKeyTable:Nil Or ForeignKeyTable - A ForeignKeyTable filled with ForeignKeyRefs to the necessary constraints. Can be nil if unnecessary.
PARAM uniqueGroups:Nil or Array[ Array[String] ] - An array of string arrays, detailing unique combinations.
]]
function SqlTable:new(tableName, columns, foreignKeyTable, uniqueGroups)
  local newTable = {}
  setmetatable(newTable, self)
  newTable.tableName = tableName
  newTable.columns = columns
  if (foreignKeyTable) then
    newTable.foreignKeyTable = foreignKeyTable
  end
  if (uniqueGroups) then
    newTable.uniqueGroups = uniqueGroups
  end
  return newTable
end

DDD.SqlTable = SqlTable