local columns = [[ (id INTEGER PRIMARY KEY,
                        name STRING UNIQUE NOT NULL)]]
                        
local shopItemIdTable = DDD.Table:new("ddd_shop_item", columns)

function shopItemIdTable:addItem(equipment, is_item)
  local itemName = ""
  if (is_item) then
    itemName = equipment:GetName()
  else
    itemName = equipment
  end
  
  local queryTable = {
    name = itemName
  }
  return self:insertTable(queryTable)
end

function shopItemIdTable:getItemId(equipment)
  local query = "SELECT id FROM " .. self.tableName .. " WHERE name == \"" .. equipment .. "\""
  return tonumber(self:query("shopItemIdTable:getItemId", query, 1, "id"))
end

shopItemIdTable:create()
DDD.Database.Tables.ShopItemId = shopItemIdTable


