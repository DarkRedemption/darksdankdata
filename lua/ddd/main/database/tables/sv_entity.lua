--Stores names of miscellaneous entities.

local columns = { id = "INTEGER PRIMARY KEY",
                  classname = "STRING UNIQUE NOT NULL"
                }
                        
local entityIdTable = DDD.SqlTable:new("ddd_entities", columns)

function entityIdTable:addEntity(entity)
  local queryTable = {
    classname = entity:GetClass()
  }
  return self:insertTable(queryTable)
end

function entityIdTable:getEntityId(entity)
  local query = "SELECT id FROM " .. self.tableName .. " WHERE classname = '" .. entity:GetClass() .. "'"
  return tonumber(self:query("entityIdTable:getEntityId", query, 1, "id"))
end

entityIdTable:create()
DDD.Database.Tables.EntityId = entityIdTable
