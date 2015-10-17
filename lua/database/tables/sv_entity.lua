local columns = [[ (id INTEGER PRIMARY KEY,
                        name STRING UNIQUE NOT NULL)]]
                        
local entityIdTable = DDD.Table:new("ddd_entities", columns)

function entityIdTable:addEntity(entity)
  local queryTable = {
    name = entity:GetClass()
  }
  return self:insertTable(queryTable)
end

function entityIdTable:getEntityId(entity)
  local query = "SELECT id FROM " .. self.tableName .. " WHERE name = \"" .. entity:GetClass() .. "\""
  local result = sql.Query(query)
  if (result == nil || result == false) then
    return 0
  else 
    return tonumber(result[1]['id'])
  end
end

entityIdTable:create()
DDD.Database.Tables.EntityId = entityIdTable
