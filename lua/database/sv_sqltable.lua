local log = DDD.Logging

local SqlTable = {}
SqlTable.tableName = ""
SqlTable.columns = {}
SqlTable.foreignKeys = {}
SqlTable.__index = SqlTable

function SqlTable:getNumberOfColumns()
  local numColumns = 0
  for columnName, columnSettings in pairs(self.columns) do
    numColumns = numColumns + 1
  end
  return numColumns
end

function SqlTable:generateColumnQuery()
  local query = "("
  local columnsConverted = 0
  local numColumns = self:getNumberOfColumns()

  for columnName, columnSettings in pairs(self.columns) do
    query = query .. " " .. columnName .. " " .. columnSettings
    columnsConverted = columnsConverted + 1
    if columnsConverted != numColumns then
      query = query .. ","
    end
  end
  
  query = query .. ")"
  return query
end

function SqlTable:generateForeignKeyQuery()
  local query = ""
  for columnName, tableName in pairs(self.foreignKeys) do
    query = query .. " FOREIGN KEY (" .. columnName .. ") REFERENCES " .. tableName .. " (id)"
    keysConverted = keysConverted + 1
    if keysConverted != #self.foreignKeys then
      query = query .. ","
    end
  end
  return query
end

function SqlTable:createTable()
  local query = "CREATE TABLE " .. self.tableName .. self:generateColumnQuery() .. self:generateForeignKeyQuery()
  log.logDebug("Creating table with command: " .. query)
  local result = sql.Query(query)
  if (result == false) then
    log.logError("Table " .. self.tableName .. " could not be created! Error was: " .. sql.LastError())
    return false
  else
    return true
  end
end

--[[
Drops the table.
THIS SHOULD NEVER BE DONE UNLESS THE TABLE WAS MADE WRONG OR YOU ARE SURE YOU DON'T NEED THE DATA IN IT ANYMORE!
]]
function SqlTable:drop()
  local query = "DROP TABLE IF EXISTS " .. self.tableName
  return sql.Query(query)
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

function SqlTable:insertTable(luaTable)
  local query = generateInsertQuery(self, luaTable)
  log.logInfo("Now running the following insert query on table " .. self.tableName .. ": " .. query)
  local result = sql.Query(query)
  if (result == nil) then --A successful INSERT returns nil.
    log.logDebug("Insert into table " .. self.tableName .. " was successful.")
    local lastId = self:query("SqlTable:insertTable", "SELECT last_insert_rowid() AS id", 1, "id")
    return lastId
  else
    log.logError("Could not insert into table " .. self.tableName .. "!")
    return false
  end
end

--For custom queries.
function SqlTable:query(funcName, query, resultRow, resultColumn)
  local result = sql.Query(query)
  if (result == nil) then
    return 0
  elseif (result == false) then
    DDD.Logging.LogError("SqlTable:query via " .. funcName ..": Query on " .. self.tableName .. " failed. Query was: " .. query .. "\nError was: " ..sql.LastError())
    return -1
  elseif (resultRow == nil && resultColumn == nil) then
    return result
  elseif (resultRow != nil && resultColumn == nil) then
    if (result[resultRow] != "NULL") then
      return result[resultRow]
    else 
      return 0
    end
  elseif (resultRow != nil && resultColumn != nil) then
    if (result[resultRow][resultColumn] != "NULL") then
      return result[resultRow][resultColumn]
    else 
      return 0
    end
  else
    DDD.Logging.LogError("SqlTable:query via " .. funcName ..": Result cannot be returned. You cannot only select a column to return.")
    return -1
  end
end

--[[
Instantiates a new SqlTable class.
PARAM tablename:String - The name of the table.
PARAM columns:Table - A lua table of column name (string keys) and column settings (string values)
PARAM foreignKeys:Table - A lua table of id column names (string keys, and only ids at the moment) 
                          and tableNames (string values)
]]
function SqlTable:new(tableName, columns, foreignKeys)
  foreignKeys = foreignKeys or {}
  local newTable = {}
  setmetatable(newTable, self)
  newTable.tableName = tableName
  newTable.columns = columns
  newTable.foreignKeys = foreignKeys
  return newTable
end

DDD.SqlTable = SqlTable