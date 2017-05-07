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

local CachedSqlTable = {}
CachedSqlTable.tableName = ""
CachedSqlTable.columns = {}
CachedSqlTable.__index = CachedSqlTable

function CachedSqlTable:addIntegerPrimaryKey(columnName)
  local settings = "INTEGER NOT NULL PRIMARY KEY"
  newTable.primaryKeys[columnName] = settings
end

function CachedSqlTable:addTextPrimaryKey(columnName)
end

function CachedSqlTable:clearCache()
  self.cache = {}
end

function CachedSqlTable:select(whereValues)

end

function CachedSqlTable:selectAll()

end

function CachedSqlTable:drop()
  local query = "DROP TABLE " .. self.tableName
  return self:query(query)
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

function CachedSqlTable:new(tableName, columns, uniqueGroups)
  local newTable = {}
  setmetatable(newTable, self)
  newTable.tableName = tableName
  newTable.primaryKeys = {}
  newTable.columns = columns
  newTable.foreignKeyTable = DDD.Database.ForeignKeyTable:new()
  newTable.cache = {}

  if (uniqueGroups) then
    newTable.uniqueGroups = uniqueGroups
  end

  newTable.indices = {}

  return newTable
end

DDD.CachedSqlTable = CachedSqlTable
