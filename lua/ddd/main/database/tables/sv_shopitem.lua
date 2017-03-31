local columns = {id = "INTEGER PRIMARY KEY",
                 name = "STRING UNIQUE NOT NULL"
                 }

local shopItemTable = DDD.SqlTable:new("ddd_shop_item", columns)

--[[
Adds an item to the item ID table.
PARAM equipment:String or Entity - The name of the equipment, or the entity if it's an item.
]]
function shopItemTable:addItem(equipment)
  local queryTable = {
    name = tostring(equipment)
  }

  return self:insertTable(queryTable)
end

function shopItemTable:getItemId(equipment)
  local query = "SELECT id FROM " .. self.tableName .. " WHERE name == \"" .. equipment .. "\""
  return tonumber(self:query("shopItemTable:getItemId", query, 1, "id"))
end

function shopItemTable:getOrAddItemId(equipment)
  local id = self:getItemId(equipment)
  if (id > 0) then
    return id
  else
    return self:addItem(equipment)
  end
end

shopItemTable:create()
DDD.Database.Tables.ShopItem = shopItemTable
