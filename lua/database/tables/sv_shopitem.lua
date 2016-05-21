local columns = {id = "INTEGER PRIMARY KEY",
                 name = "STRING UNIQUE NOT NULL"
                 }
                        
local shopItemTable = DDD.SqlTable:new("ddd_shop_item", columns)

--[[
Adds an item to the item ID table.
PARAM equipment:String or Entity - The name of the equipment, or the entity if it's an item.
PARAM isItem:Boolean - Whether or not this is a droppable in-game item.
]]
function shopItemTable:addItem(equipment, isItem)
  local itemName = ""
  if (isItem) then
    itemName = equipment:GetName()
  else
    itemName = equipment
  end
  
  local queryTable = {
    name = itemName
  }
  return self:insertTable(queryTable)
end

function shopItemTable:getItemId(equipment)
  local query = "SELECT id FROM " .. self.tableName .. " WHERE name == \"" .. equipment .. "\""
  return tonumber(self:query("shopItemTable:getItemId", query, 1, "id"))
end

shopItemTable:create()
DDD.Database.Tables.ShopItem = shopItemTable