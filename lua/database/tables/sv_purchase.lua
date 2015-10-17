local roundIdTable = DDD.Database.Tables.RoundId
local playerIdTable = DDD.Database.Tables.PlayerId
local shopItemIdTable = DDD.Database.Tables.ShopItemId

local columns = [[ ( id INTEGER PRIMARY KEY,
                        round_id INTEGER NOT NULL,
                        player_id INTEGER NOT NULL, 
                        shop_item_id INTEGER NOT NULL,
                        round_time REAL NOT NULL,
                        FOREIGN KEY(round_id) REFERENCES ]] .. roundIdTable.tableName .. [[(id),
                        FOREIGN KEY(player_id) REFERENCES ]] .. playerIdTable.tableName .. [[(id),
                        FOREIGN KEY(shop_item_id) REFERENCES ]] .. shopItemIdTable.tableName .. [[(id))]]
                        
local purchasesTable = DDD.Table:new("ddd_purchases", columns)

function purchasesTable:addPurchase(playerId, itemId)
  local queryTable = {
    round_id = DDD.CurrentRound.roundId,
    player_id = playerId,
    shop_item_id = itemId,
    round_time = DDD.CurrentRound:getCurrentRoundTime()
  }
  return self:insertTable(queryTable)
end

purchasesTable:create()
DDD.Database.Tables.Purchases = purchasesTable


