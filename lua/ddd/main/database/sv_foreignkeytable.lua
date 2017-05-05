--[[
Holds a table of columnName -> ForeignKeyRef(table, foreignColumn).
]]
local foreignKeyTable = {}
foreignKeyTable.foreignKeys = {}
foreignKeyTable.compositeForeignKeys = {}
foreignKeyTable.__index = foreignKeyTable

local length = DDD.length

function foreignKeyTable:getForeignKeySize()
  return length(self.foreignKeys)
end

function foreignKeyTable:getCompositeKeySize()
  return length(self.compositeForeignKeys)
end
--[[
Adds a new foreign key constraint.
PARAM columnName:String - The name of the column in the current table to constrain with a foreign key.
PARAM foreignSqlTable: SqlTable - The SQL table to reference.
PARAM foreignColumn: String - The column in the foreignSqlTable to constrain the local column with.
]]
function foreignKeyTable:addConstraint(columnName, foreignSqlTable, foreignColumn)
  self.foreignKeys[columnName] = DDD.Database.ForeignKeyRef:new(foreignSqlTable, foreignColumn)
end

--[[
Adds a new composite (multi-key) foreign key constraint.
PARAM constraintName: String - The name of the constraint. Used to get the foreign table in other functions.
PARAM columnNames:Array[String] - The names of the column in the current table to constrain with foreign keys.
PARAM foreignSqlTable: SqlTable - The SQL table to reference.
PARAM foreignColumns: Array[String] - The columns in the foreignSqlTable to constrain the local column with.
]]
function foreignKeyTable:addCompositeConstraint(constraintName, columnNames, foreignSqlTable, foreignColumns)
  self.compositeForeignKeys[constraintName] = DDD.Database.CompositeForeignKeyRef:new(columnNames, foreignSqlTable, foreignColumns)
end

--[[
Generates the part of the Create Table query that adds the foreign key constraints.
RETURNS A string that should be appended to the create table query.
]]
function foreignKeyTable:generateConstraintQuery()
  local query = ""
  local keysConverted = 0
  local numOfForeignKeys = length(self.foreignKeys)
  local numOfCompositeKeys = length(self.compositeForeignKeys)

  for columnName, foreignKeyRef in pairs(self.foreignKeys) do
    local tableName = foreignKeyRef.sqlTable.tableName
    query = query .. " FOREIGN KEY (" .. columnName .. ") REFERENCES " .. tableName .. " (" .. foreignKeyRef.foreignColumn ..")"
    keysConverted = keysConverted + 1
    if keysConverted != numOfForeignKeys or numOfCompositeKeys > 0 then
      query = query .. ", "
    end
  end

  if numOfCompositeKeys > 0 then
    keysConverted = 0

    for constraintName, compositeRef in pairs(self.compositeForeignKeys) do
      local tableName = compositeRef.sqlTable.tableName
      query = compositeRef:makeQuery()
      keysConverted = keysConverted + 1
      if keysConverted != numOfCompositeKeys then
        query = query .. ", "
      end
    end
  end

  return query
end

function foreignKeyTable:new()
  local newKeyTable = {}
  setmetatable(newKeyTable, self)
  newKeyTable.foreignKeys = {}
  newKeyTable.compositeForeignKeys = {}
  return newKeyTable
end

DDD.Database.ForeignKeyTable = foreignKeyTable
