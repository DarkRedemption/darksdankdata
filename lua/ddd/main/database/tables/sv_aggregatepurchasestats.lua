local itemColumnSuffix = {}
local tables = DDD.Database.Tables

local function generateColumns()
  local columns = {
    player_id = "INTEGER PRIMARY KEY NOT NULL"
  }
  local sweps = weapons.GetList()

  local function addColumn(roleId, itemName)
    local roleName

    if roleId == ROLE_TRAITOR then
      roleName = "traitor"
    elseif roleId == ROLE_DETECTIVE then
      roleName = "detective"
    else
      assert(false, "AggregatePurchaseStats: Invalid role. Innocents cannot purchase items.")
    end

    local columnName = roleName .. "_" .. itemName .. "_purchases"
    columns[columnName] = "INTEGER NOT NULL DEFAULT 0"
  end

  for index, wep in pairs(sweps) do
    if DDD.traitorCanBuy(wep) then
      addColumn(ROLE_TRAITOR, wep.ClassName)
    end

    if DDD.detectiveCanBuy(wep) then
      addColumn(ROLE_DETECTIVE, wep.ClassName)
    end
  end

  --EquipmentItems is a Global TTT variable
  for index, item in pairs(EquipmentItems[ROLE_TRAITOR]) do
    addColumn(ROLE_TRAITOR, item.name)
  end

  for index, item in pairs(EquipmentItems[ROLE_DETECTIVE]) do
    addColumn(ROLE_DETECTIVE, item.name)
  end

  return columns
end

local columns = generateColumns()

local foreignKeyTable = DDD.Database.ForeignKeyTable:new()
foreignKeyTable:addConstraint("player_id", tables.PlayerId, "id")

local aggregatePurchaseStatsTable = DDD.SqlTable:new("ddd_aggregate_purchase_stats", columns, foreignKeyTable)
aggregatePurchaseStatsTable.tables = tables --So they can be easily swapped out in test

function aggregatePurchaseStatsTable:addPlayer(playerId)
  local newPlayerTable = {
    player_id = playerId
  }
  return self:insertTable(newPlayerTable)
end

function aggregatePurchaseStatsTable:getPlayerStats(playerId)
  local query = "SELECT * from " .. self.tableName .. " WHERE player_id == " .. playerId
  return self:query("aggregatePurchaseStatsTable:getPlayerStats", query, 1)
end

function aggregatePurchaseStatsTable:getPurchases(playerId, playerRole, itemName)
  local columnName = DDD.roleIdToRole[playerRole] .. "_" .. itemName .. "_purchases"
  local query = "SELECT " .. columnName .. " FROM " .. self.tableName .. " WHERE player_id == " .. playerId
  local currentValue = self:query("aggregatePurchaseStatsTable:selectColumn", query, 1, columnName)
  return tonumber(currentValue)
end

function aggregatePurchaseStatsTable:incrementPurchases(playerId, roleId, itemName)
    assert(roleId != 0, "Innocents can't purchase items!")
    local newPurchases = self:getPurchases(playerId, roleId, itemName) + 1
    local columnName = DDD.roleIdToRole[roleId] .. "_" .. itemName .. "_purchases"
    local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. newPurchases .. " WHERE player_id == " .. playerId
    return self:query("aggregatePurchaseStatsTable:incrementPurchases", query)
end

function aggregatePurchaseStatsTable:recalculate()
  sql.Query("DROP TABLE " .. self.tableName)
  self:create()

  local query = [[SELECT purchases.player_id, roundroles.role_id, purchases.shop_item_id, shopitem.name, count(purchases.shop_item_id) AS times_purchased
                  FROM ]] .. self.tables.Purchases.tableName .. [[ AS purchases
                  LEFT JOIN ]] .. self.tables.ShopItem.tableName .. [[ AS shopitem ON purchases.shop_item_id = shopitem.id,
                   ]] .. self.tables.RoundRoles.tableName .. [[ AS roundroles ON purchases.round_id = roundroles.round_id AND purchases.player_id = roundroles.player_id
                  GROUP BY purchases.player_id, shop_item_id, roundroles.role_id
                  ORDER BY purchases.player_id, roundroles.role_id]]

  local result = self:query("aggregatePurchaseStatsTable:recalculate", query)

  if (result != nil and type(result) == "table") then
    local rowsToInsert = {}

    for index, row in pairs(result) do
      local playerId = row["player_id"]

      if rowsToInsert[playerId] == nil then
        rowsToInsert[playerId] = {}
      end

      local columnName = ""

      if tonumber(row["role_id"]) == ROLE_TRAITOR then
        columnName = "traitor_" .. row["name"] .. "_purchases"
      else
        columnName = "detective_" .. row["name"] .. "_purchases"
      end

      rowsToInsert[playerId][columnName] = row["times_purchased"]
    end

    for playerId, columns in pairs(rowsToInsert) do
      local numColumns = 0
      local columnList = " (player_id"
      local valueList = " (" .. tostring(playerId)

      for column, value in pairs(columns) do
        columnList = columnList .. ", " .. column
        valueList = valueList .. ", " .. value
      end

      columnList = columnList .. ")"
      valueList = valueList .. ")"

      local insertQuery = "INSERT INTO " .. self.tableName .. columnList .. " VALUES " .. valueList
      self:query("aggregatePurchaseStatsTable:recalculate insert step", insertQuery)
    end

  end

end

aggregatePurchaseStatsTable.traitorCanBuy = traitorCanBuy
aggregatePurchaseStatsTable.detectiveCanBuy = detectiveCanBuy

aggregatePurchaseStatsTable:create()
DDD.Database.Tables.AggregatePurchaseStats = aggregatePurchaseStatsTable
