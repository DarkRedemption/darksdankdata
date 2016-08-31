local roundIdTable = DDD.Database.Tables.RoundId
local playerIdTable = DDD.Database.Tables.PlayerId
local shopItemIdTable = DDD.Database.Tables.ShopItem

local columns = { id = "INTEGER PRIMARY KEY",
                  round_id = "INTEGER NOT NULL",
                  player_id = "INTEGER NOT NULL", 
                  shop_item_id = "INTEGER NOT NULL",
                  round_time = "REAL NOT NULL"
                }
                


local purchasesTable = DDD.SqlTable:new("ddd_purchases", columns)

purchasesTable:addForeignConstraint("round_id", roundIdTable, "id")
purchasesTable:addForeignConstraint("player_id", playerIdTable, "id")
purchasesTable:addForeignConstraint("shop_item_id", shopItemIdTable, "id")

purchasesTable:addIndex("playerAndItemIndex", {"player_id", "shop_item_id"})

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