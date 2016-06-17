local roundIdTable = DDD.Database.Tables.RoundId
local playerIdTable = DDD.Database.Tables.PlayerId
local shopItemIdTable = DDD.Database.Tables.ShopItem

local columns = { id = "INTEGER PRIMARY KEY",
                  round_id = "INTEGER NOT NULL",
                  player_id = "INTEGER NOT NULL", 
                  shop_item_id = "INTEGER NOT NULL",
                  round_time = "REAL NOT NULL"
                }
local foreignKeyTable = DDD.Database.ForeignKeyTable:new()
foreignKeyTable:addConstraint("round_id", roundIdTable, "id")
foreignKeyTable:addConstraint("player_id", playerIdTable, "id")
foreignKeyTable:addConstraint("shop_item_id", shopItemIdTable, "id")

local purchasesTable = DDD.SqlTable:new("ddd_purchases", columns, foreignKeyTable)

function purchasesTable:addPurchase(playerId, itemId)
  local queryTable = {
    round_id = self:getForeignTableByColumn("round_id"):getCurrentRoundId(),
    player_id = playerId,
    shop_item_id = itemId,
    round_time = DDD.CurrentRound:getCurrentRoundTime()
  }
  return self:insertTable(queryTable)
end

purchasesTable:create()
DDD.Database.Tables.Purchases = purchasesTable