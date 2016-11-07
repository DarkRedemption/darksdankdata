local foreignKeyRef = {}
foreignKeyRef.__index = foreignKeyRef

function foreignKeyRef:new(sqlTable, foreignColumn)
  local newKey = {}
  setmetatable(newKey, self)
  newKey.sqlTable = sqlTable
  newKey.foreignColumn = foreignColumn
  return newKey
end

local compositeForeignKeyRef = {}
compositeForeignKeyRef.__index = compositeForeignKeyRef

local function makeCompositeString(array)
  local str = ""

  for i = 1, #array do
    str = str .. array[i]
    if i != #array then
      str = str .. ", "
    end
  end

  return str
end

function compositeForeignKeyRef:makeQuery()
  local tableName = self.sqlTable.tableName
  local columnNamesString = makeCompositeString(self.columnNames)
  local foreignColumnString = makeCompositeString(self.foreignColumns)
  local query = "FOREIGN KEY (" .. columnNamesString .. ") REFERENCES " .. tableName .. " (" .. foreignColumnString .. ")"
  return query
end

function compositeForeignKeyRef:new(columnNames, sqlTable, foreignColumns)
  local newKey = {}
  setmetatable(newKey, self)
  newKey.sqlTable = sqlTable
  newKey.columnNames = columnNames
  newKey.foreignColumns = foreignColumns
  return newKey
end

DDD.Database.ForeignKeyRef = foreignKeyRef
DDD.Database.CompositeForeignKeyRef = compositeForeignKeyRef
