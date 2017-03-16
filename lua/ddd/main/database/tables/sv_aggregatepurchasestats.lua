local itemColumnSuffix = {}
local tables = DDD.Database.Tables

local function roleCanBuy(swep, role)
  if (!swep.CanBuy) then
    return false
  end

  for index, roleId in pairs(swep.CanBuy) do
    if (roleId == role) then
      return true
    end
  end

  return false
end

local function traitorCanBuy(swep)
  return roleCanBuy(swep, ROLE_TRAITOR)
end

local function detectiveCanBuy(swep)
  return roleCanBuy(swep, ROLE_DETECTIVE)
end

local function generateColumns()
  local columns = {
    player_id = "INTEGER PRIMARY KEY"
  }
  local sweps = weapons.GetList()

  for index, wep in pairs(sweps) do

    if traitorCanBuy(wep) then
      local columnName = "traitor_" .. wep.ClassName .. "_purchases"
      columns[columnName] = "INTEGER NOT NULL DEFAULT 0"
    end

    if (detectiveCanBuy(wep)) then
      local columnName = "detective_" .. wep.ClassName .. "_purchases"
      columns[columnName] = "INTEGER NOT NULL DEFAULT 0"
    end

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

function aggregatePurchaseStatsTable:getPurchases(playerId, playerRole, itemName)
  local columnName = DDD.roleIdToRole[playerRole] .. "_" .. itemName .. "_purchases"
  local query = "SELECT " .. columnName .. " FROM " .. self.tableName .. " WHERE player_id == " .. playerId
  local currentValue = self:query("aggregatePurchaseStatsTable:selectColumn", query, 1, columnName)
  return tonumber(currentValue)
end

function aggregatePurchaseStatsTable:incrementPurchases(playerId, playerRole, itemName)
    assert(playerRole != 0, "Innocents can't purchase items!")
    local newPurchases = self:getPurchases(playerId, playerRole, itemName) + 1
    local columnName = DDD.roleIdToRole[playerRole] .. "_" .. itemName .. "_purchases"
    local query = "UPDATE " .. self.tableName .. " SET " .. columnName .. " = " .. newPurchases .. " WHERE player_id == " .. playerId
    return self:query("aggregatePurchaseStatsTable:incrementPurchases", query)
end

aggregatePurchaseStatsTable.traitorCanBuy = traitorCanBuy
aggregatePurchaseStatsTable.detectiveCanBuy = detectiveCanBuy

aggregatePurchaseStatsTable:create()
DDD.Database.Tables.AggregatePurchaseStats = aggregatePurchaseStatsTable
