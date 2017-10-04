--[[
TODO:
Save things to the cache that have just been inserted
Create a "diffCache" of some kind that holds all changed rows
Put freshly inserted rows into both the cache and diffCache
Update all rows and flush diffcache on round end
Cache structure: (table of primary key->value) -> Row

]]

local log = DDD.Logging
local length = DDD.length
local filter = DDD.filter
local foreach = DDD.foreach
local iforeach = DDD.iforeach
local map = DDD.map
local foldLeft = DDD.foldLeft
local Option = DDD.Misc.Option
local FunctionalTable = DDD.Misc.FunctionalTable

local CachedSqlTable = {}
CachedSqlTable.__index = CachedSqlTable

--[[
local integerEquivalents = {"number", "int", "tinyint", "mediumint", "bigint", "integer"}
local textEquivalents = {"text", "string", "char", "character", "varchar", "nvarchar"}
local numericEquivalents = {"numeric", "decimal", "boolean", "date", "datetime"}
local realEquivalents = {"real", "float", "double"}
local blobEquivalents = {"blob"}

local function valueExistsInString(array, str)
  local lowercaseValue = string.lower(str)

  for i = 1, table.getn(array) do
    if string.find(lowercaseValue, array[i]) then
      return true
    end
  end

  return false
end

local function detectPrimaryKeys(columns)
  local keys = map(columns, function(k, v)
    if string.find(string.lower(v), "primary key") then

      if (valueExistsInString(integerEquivalents, v)) then
        return k, "integer"
      elseif (valueExistsInString(textEquivalents, v)) then
        return k, "text"
      elseif (valueExistsInString(numericEquivalents, v)) then
        return k, "numeric"
      elseif (valueExistsInString(realEquivalents, v)) then
        return k, "real"
      elseif (valueExistsInString(blobEquivalents, v)) then
        return k, "blob"
      else
        error("Unrecognized primary key type.")
      end

    end
  end)

  return keys
end
--]]

--[[
Adds a column configured with the CachedColumn class.
Must be called before create().
]]

local function queryError(tableName, funcName, query)
  log.logError("CachedSqlTable:query via " .. funcName ..": Query on " .. tableName .. " failed. Query was: " .. query .. "\nError was: " .. sql.LastError())
end

function CachedSqlTable:addColumn(cachedColumn)
  self.columns[cachedColumn.name] = cachedColumn
  return self
end

function CachedSqlTable:addColumns(...)
  local args = {...}

  foreach(args, function(k, column)
    self:addColumn(column)
  end)

  return self
end

function CachedSqlTable:select(whereValues)
  local selectStatement = "SELECT * FROM " .. self.tableName
  local whereStatement = " WHERE "
  local len = length(whereValues)
  local totalLoops = 0

  foreach(whereValues, function(k, v)
    whereStatement = whereStatement .. "'" .. k .. "' == " .. v
    totalLoops = totalLoops + 1

    if s < len then
      whereStatement = whereStatement .. " AND "
    end

    return totalLoops
  end)

  local result = self:query(selectStatement .. whereStatement)

  result:foreach(function(result)

  end)
end

--[[
Selects and caches everything from the table.
]]
function CachedSqlTable:selectAll()
  local selectStatement = "SELECT * FROM " .. self.tableName
  local result = self:query(selectStatement)
  local fTable = FunctionalTable:new()

  foreach(result, function(resultId, row)
    self:addToCache(row)
  end)

  return self
end

function CachedSqlTable:addToCache(key, value)
  self.cache[key] = value
  return self
end

function CachedSqlTable:clearCache()
  self.cache = {}
  return self
end

function CachedSqlTable:getPrimaryKeyValuesOfRow(row)
  local primaryKeyValueTable = {}

  foreach(self.primaryKeys, function(keyname, settings)
    primaryKeyValueTable[keyname] = row[keyname]
  end)

  return primaryKeyValueTable
end


--[[
Drops the table and clears the cache.
]]
function CachedSqlTable:drop()
  local query = "DROP TABLE " .. self.tableName
  self:clearCache()
  return self:query(query)
end

local function isNull(value)
  return value == "NULL"
end

--[[
For custom queries. Makes the return value safe (not nil).
PARAM query:String - The SQL query.
PARAM resultRow - The result row to select. If nil, all rows are returned.
PARAM resultColumn - The result row to select. If nil, all columns are returned. If resultRow is nil, this is ignored.
]]
function CachedSqlTable:query(query, resultRow, resultColumn)
  local funcName = debug.getinfo(2).name
  local result = sql.Query(query)

  if (result == nil) then --Nothing to select
    return Option:Some(true)
  elseif (result == false) then --Bad query
    queryError(self.tableName, funcName, query)
    return Option:None()
  --Everything after this point (other than the LogError) is for the user to select results safely.
  elseif (resultRow == nil && resultColumn == nil) then --User wants everything
    return result
  elseif (resultRow != nil && resultColumn == nil) then --User wants one row
    if !isNull(result[resultRow]) then
      return Option:Some(result[resultRow])
    else
      queryError(self.tableName, funcName, query)
      return Option:None()
    end
  elseif (resultRow != nil && resultColumn != nil) then --User wants specific result
    if !isNull(result[resultRow][resultColumn]) then
      return Option:Some(result[resultRow][resultColumn])
    else
      queryError(self.tableName, funcName, query)
      return Option:None()
    end
  else
    DDD.Logging.LogError("SqlTable:query via " .. funcName ..": Result cannot be returned. You cannot only select a column to return.")
    return Option:None()
  end
end

--[[
Generates the query used by the create statement
to setup the columns the table will have.
]]
function CachedSqlTable:generateColumnQuery()
  local query = "("
  local columnsConverted = 0
  local numColumns = length(self.columns)

  foreach(self.columns, function(columnName, cachedColumn)
    query = query .. " " .. cachedColumn:generateCreateString()
    columnsConverted = columnsConverted + 1

    if columnsConverted < numColumns then
      query = query .. ","
    end

  end)

  return query
end

function CachedSqlTable:create()
  local query = "CREATE TABLE " ..
            self.tableName ..
            self:generateColumnQuery()

  if (self.foreignKeyTable:getForeignKeySize() > 0 or self.foreignKeyTable:getCompositeKeySize() > 0) then
     query = query .. ", " .. self.foreignKeyTable:generateConstraintQuery()
  end

  if (self.uniqueGroups) then
    query = query .. ", " .. self:generateUniqueConstraintsQuery()
  end

  query = query .. ")"

  log.logDebug("Creating table with command: " .. query)

  local result = self:query(query)

  return result:getOrElse(function()
    log.logError("Table " .. self.tableName .. " could not be created! Error was: " .. sql.LastError() .. "\nQuery was : " .. query)
    return false
  end)
end

function CachedSqlTable:insertRowLater(row)
  table.insert(self.rowsToInsert, row)
  return self
end

--[[
function CachedSqlTable:insertRowLaterIfNotExists(row)
  local keyValues = self.getPrimaryKeyValuesOfRow(row)
  local found = false

  self.cache:lift(keyValues):orElse(function()
    self:insertRowLater(row)
  end)

  if !found then
    foreach(self.columns, function(k, cachedColumn)
      if self.columns:isUnique() then
        self.cacheIndices[]
    end)
  end

  return self
end
]]


function CachedSqlTable:getInsertColumns()
  local count = 0
  local insertColumns = filter(self.columns, function(columnName, cachedColumn)
    if (!cachedColumn.autoIncrement) then
      count = count + 1
    end
    return !cachedColumn.autoIncrement
  end)

  return insertColumns, count
end

function CachedSqlTable:insertQueuedRows()
  local columns, numColumns = self:getInsertColumns()
  local count = 0
  local query = "INSERT INTO " .. self.tableName .. " ("

  foreach(columns, function(columnName, cachedColumn)
    query = query .. columnName
    count = count + 1
    if count < numColumns then
      query = query .. ", "
    end
  end)

  query = query .. ") VALUES "

  iforeach(self.rowsToInsert, function(i, row)
    query = query .. "("

    foreach(columns, function(columnName, cachedColumn)
      local columnValue = row[columnName] or cachedColumn.defaultValue.getOrElse(function()
        error("No valid value found for " .. columnName .. " in " .. self.tableName)
      end)

      if (cachedColumn:isText()) then
        query = query .. "'" .. tostring(columnValue) .. "'"
      else
        query = query .. tostring(columnValue)
      end

      if count < numColumns then
        query = query .. ", "
      else
        query = query .. ")"
      end

    end)

    if i < #self.rowsToInsert then
      query = query .. ", "
    end
  end)

  self:query(query)
  self.rowsToInsert = {}
  return self
end

function CachedSqlTable:liftRow(keyValuePairs)
  return self.cache:lift(keyValuePairs)
end

function CachedSqlTable:new(tableName, uniqueGroups)
  local newTable = {}
  setmetatable(newTable, self)
  newTable.tableName = tableName
  newTable.foreignKeyTable = DDD.Database.ForeignKeyTable:new()
  newTable.columns = {}
  newTable.cache = DDD.Misc.FunctionalTable:new()
  newTable.rowsToInsert = {}
  newTable.rowsToUpdate = {}
  newTable.primaryKeys = {}
  
  if (uniqueGroups) then
    newTable.uniqueGroups = uniqueGroups
  end

  newTable.indices = {}

  return newTable
end

DDD.Database.CachedSqlTable = CachedSqlTable
