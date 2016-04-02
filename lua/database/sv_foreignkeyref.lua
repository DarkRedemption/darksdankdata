local foreignKeyRef = {}
foreignKeyRef.__index = foreignKeyRef

function foreignKeyRef:new(sqlTable, foreignColumn)
  local newKey = {}
  setmetatable(newKey, self)
  newKey.sqlTable = sqlTable
  newKey.foreignColumn = foreignColumn
  return newKey
end

DDD.Database.ForeignKeyRef = foreignKeyRef