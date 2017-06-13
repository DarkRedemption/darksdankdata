local Option = DDD.Misc.Option

local CachedColumn = {}
CachedColumn.__index = CachedColumn

function CachedColumn:new(columnName)
  local newColumn = {}
  setmetatable(newColumn, self)
  newColumn.name = columnName
  newColumn.type = Option:None()
  newColumn.primaryKey = false
  newColumn.notNull = false
  newColumn.unique = false
  newColumn.autoIncrement = false
  newColumn.defaultValue = Option:None()

  return newColumn
end

function CachedColumn:makeIntegerType()
  self.type = Option:Some("INTEGER")
  return self
end

function CachedColumn:makeTextType()
  self.type = Option:Some("TEXT")
  return self
end

function CachedColumn:makeNumericType()
  self.type = Option:Some("NUMERIC")
  return self
end

function CachedColumn:makeRealType()
  self.type = Option:Some("REAL")
  return self
end

function CachedColumn:makePrimaryKey()
  self.primaryKey = true
  return self
end

function CachedColumn:makeNotNull()
  self.notNull = true
  return self
end

function CachedColumn:makeUnique()
  self.unique = true
  return self
end

function CachedColumn:makeAutoIncrement()
  self.autoIncrement = true
  return self
end

function CachedColumn:setDefaultValue(value)
  self.defaultValue = Option:Some(value)
  return self
end

function CachedColumn:isType(typeName)
  return self.type == Option:Some(typeName)
end

function CachedColumn:isInteger()
  return self:isType("INTEGER")
end

function CachedColumn:isText()
  return self:isType("TEXT")
end

function CachedColumn:isNumeric()
  return self:isType("NUMERIC")
end

function CachedColumn:isReal()
  return self:isType("REAL")
end

function CachedColumn:generateCreateString()
  assert(!self.type:isEmpty(), "You must set a column type!")
  local columnType = self.type:get()
  local settingsString = self.name .. " " .. columnType

  if self.primaryKey then
    settingsString = settingsString .. " PRIMARY KEY"
  end

  if self.notNull then
    settingsString = settingsString .. " NOT NULL"
  end

  if self.unique then
    settingsString = settingsString .. " UNIQUE"
  end

  if self.autoIncrement then
    settingsString = settingsString .. " AUTOINCREMENT"
  end

  self.defaultValue:foreach(function(value)
    settingsString = settingString .. " DEFAULT "
    if self:isText() then
      settingsString = settingsString .. "'" .. tostring(value) .. "'"
    else
      settingsString = settingsString .. tostring(value)
    end
  end)

  return settingsString
end

DDD.Database.CachedColumn = CachedColumn
