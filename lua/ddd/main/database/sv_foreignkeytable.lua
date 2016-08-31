--[[
Holds a table of columnName -> ForeignKeyRef(table, foreignColumn).
]]
local foreignKeyTable = {}
foreignKeyTable.foreignKeys = {}
foreignKeyTable.__index = foreignKeyTable

--[[
Adds a new foreign key constraint.
PARAM columnName:String - The name of the column in the current table to constrain with a foreign key.
PARAM foreignSqlTable: SqlTable - The SQL table to reference.
PARAM foreignColumn: String - The column in the foreignSqlTable to constrain the local column with.
]]
function foreignKeyTable:addConstraint(columnName, foreignSqlTable, foreignColumn)
  self.foreignKeys[columnName] = DDD.Database.ForeignKeyRef:new(foreignSqlTable, foreignColumn)
end

function foreignKeyTable:getSize()
  local numOfForeignKeys = 0
  
  for key, value in pairs(self.foreignKeys) do
    numOfForeignKeys = numOfForeignKeys + 1
  end
  
  return numOfForeignKeys
end

--[[
Generates the part of the Create Table query that adds the foreign key constraints.
RETURNS A string that should be appended to the create table query.
]]
function foreignKeyTable:generateConstraintQuery()
  local query = ""
  local keysConverted = 0
  local numOfForeignKeys = self:getSize()
  
  for columnName, foreignKeyRef in pairs(self.foreignKeys) do
    local tableName = foreignKeyRef.sqlTable.tableName
    query = query .. " FOREIGN KEY (" .. columnName .. ") REFERENCES " .. tableName .. " (" .. foreignKeyRef.foreignColumn ..")"
    keysConverted = keysConverted + 1
    if keysConverted != numOfForeignKeys then
      query = query .. ", "
    end
  end
  
  return query
end
  
function foreignKeyTable:new()
  local newKeyTable = {}
  setmetatable(newKeyTable, self)
  newKeyTable.foreignKeys = {}
  return newKeyTable
end

DDD.Database.ForeignKeyTable = foreignKeyTable