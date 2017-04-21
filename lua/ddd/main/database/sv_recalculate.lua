local lightBlue = Color(0, 255, 255, 255)

local function deleteBadRows(badRows, tableName)
  if (badRows) then
    for key, value in pairs(badRows) do
      local deleteQuery = "DELETE FROM " .. tableName .. " WHERE id == " .. value["id"]
      sql.Query(deleteQuery)
    end
  end
end


--Basically it cleans up everything that needs to be cleaned up
--by passing in the player_id name from that particular table.
local function cleanupAll(tables)
  local t = tables

  local cleanableTables = {}
  cleanableTables["player_id"] = {t.Purchases, t.ShotsFired, t.RadioCommandUsed}
  cleanableTables["victim_id"] = {t.CombatDamage, t.PlayerKill, t.WorldKill, t.WorldDamage, t.PlayerPushKill}
  cleanableTables["attacker_id"] = {t.CombatDamage, t.PlayerKill, t.PlayerPushKill}
  cleanableTables["finder_id"] = {t.CorpseIdentified, t.Dna}
  cleanableTables["corpse_owner_id"] = {t.CorpseIdentified}
  cleanableTables["dna_owner_id"] = {t.Dna}
  cleanableTables["deployer_id"] = {t.Healing}
  cleanableTables["user_id"] = {t.Healing}

  for columnName, tablesToClean in pairs(cleanableTables) do
    for index, tableToClean in pairs(tablesToClean) do

      local selectQuery = [[
               SELECT t.id,
               t.round_id,
               t.]] .. columnName .. [[,
               player_role.role_id as player_role
               FROM ]] .. tableToClean.tableName .. [[ AS t
               LEFT JOIN ]] .. t.RoundRoles.tableName .. [[ AS player_role
               ON t.round_id == player_role.round_id
               AND t.]] .. columnName .. [[ == player_role.player_id
               WHERE (player_role is null)
           ]]

      local badRows = sql.Query(selectQuery)

      deleteBadRows(badRows, tableToClean.tableName)

    end
  end

end

--Changes Vanilla shop items that were saved by EquipmentItems ID and
-- converts them to their EquipmentItems name.
local function fixShopItem(tables)
  local t = tables
  local tableName = t.ShopItem.tableName
  local armorQuery = "UPDATE " .. tableName .. " SET name = 'item_armor' WHERE name == '1'"
  local radarQuery = "UPDATE " .. tableName .. " SET name = 'item_radar' WHERE name == '2'"
  local disguiserQuery = "UPDATE " .. tableName .. " SET name = 'item_disg' WHERE name == '4'"

  sql.Query(armorQuery)
  sql.Query(radarQuery)
  sql.Query(disguiserQuery)
end

local function fixWeaponNames(tables)
  local t = tables
  local tableName = t.WeaponId.tableName
  local changes = {
    ttt_c4 = "weapon_ttt_c4",
  }

  --Some old names have spaces, which must be defined here.
  changes["an explosion"] = "explosive_barrel"

  local armorQuery = "UPDATE " .. tableName .. " SET name = 'ttt_c4' WHERE name == 'weapon_ttt_c4'"
  local radarQuery = "UPDATE " .. tableName .. " SET name = 'item_radar' WHERE name == '2'"
  local disguiserQuery = "UPDATE " .. tableName .. " SET name = 'item_disg' WHERE name == '4'"

  sql.Query(armorQuery)
  sql.Query(radarQuery)
  sql.Query(disguiserQuery)
end

local function recalculate(tables)
    MsgC(lightBlue, "Purging potential data anomalies and recalculating aggregate data. This may take a long time.\n")
    MsgC(lightBlue, "Fixing data anomalies...\n")
    cleanupAll(tables)
    fixShopItem(tables)
    MsgC(lightBlue, "Recalculating General Data...\n")
    tables.AggregateStats:recalculate()
    MsgC(lightBlue, "Recalculating Weapon Data...\n")
    tables.AggregateWeaponStats:recalculate()
    MsgC(lightBlue, "Recalculating Purchase Data...\n")
    tables.AggregatePurchaseStats:recalculate()
    MsgC(lightBlue, "All aggregate data recalculated.\n")
end

concommand.Add("ddd_recalculate", function(ply, cmd, args, argStr)
  if (ply == NULL) then
    recalculate(DDD.Database.Tables)
  else
    MsgC(red, "This command may only be run through the server console.\n")
  end
end)

DDD.Database.recalculate = recalculate --For Testing
