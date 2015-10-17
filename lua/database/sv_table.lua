local Table = {}
Table.tableName = ""
Table.columns = ""
Table.__index = Table

local log = DDD.Logging

--TODO: Make columns and foreign keys as two seperate tables that are then parsed for testing reasons.

function Table:create()
   if (!sql.TableExists(self.tableName)) then
      log.logDebug("Table " .. self.tableName .. " does not exist. Now creating.")
      local result = sql.Query("CREATE TABLE " .. self.tableName .. " " .. self.columns)
      if (result == false) then
        log.logError("Table " .. self.tableName .. " could not be created! Error was: " .. sql.LastError())
        return false
      else
        log.logError("Table " .. self.tableName .. " created.")
        return true
      end
   else
      log.logDebug("Table " .. self.tableName .. " already exists.")
      return true
  end
end

--Deprecated. Use insertValues instead.
function Table:insert(insertQuery)
  log.logWarning("Table:insert - This function is deprecated! Please use Table:insertValues instead.")
  log.logInfo("Now inserting " .. insertQuery)
  local result = sql.Query(insertQuery)
  if (!IsValid(result)) then --A successful INSERT returns nil.
    log.logDebug("Insert into table " .. self.tableName .. " was successful.")
    return true
  else
    log.logError("Could not insert into table " .. self.tableName .. "!")
    return false
  end
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

function Table:insertTable(luaTable)
  local query = generateInsertQuery(self, luaTable)
  log.logInfo("Now running the following insert query on table " .. self.tableName .. ": " .. query)
  local result = sql.Query(query)
  if (!IsValid(result)) then --A successful INSERT returns nil.
    log.logDebug("Insert into table " .. self.tableName .. " was successful.")
    local lastId = self:query("Table:insertTable", "SELECT last_insert_rowid() AS id", 1, id)
    return lastId
  else
    log.logError("Could not insert into table " .. self.tableName .. "!")
    return false
  end
end

--For custom queries.
function Table:query(funcName, query, resultRow, resultColumn)
  local result = sql.Query(query)
  if (result == nil) then
    return 0
  elseif (result == false) then
    DDD.Logging.LogError("Table:query via " .. funcName ..": Query on " .. self.tableName .. " failed. Query was: " .. query .. "\nError was: " ..sql.LastError())
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
    DDD.Logging.LogError("Table:query via " .. funcName ..": Result cannot be returned. You cannot only select a column to return.")
    return -1
  end
end

function Table:new(tableName, columns)
  DDD.Logging.logWarning("Table is deprecated. Use SqlTable instead for " .. tableName)
  local newTable = {}
  setmetatable(newTable, self)
  newTable.tableName = tableName
  newTable.columns = columns
  return newTable
end

DDD.Table = Table