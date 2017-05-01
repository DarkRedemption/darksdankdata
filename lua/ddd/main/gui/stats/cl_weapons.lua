local capitalRoles = {}
capitalRoles[0] = "Innocent"
capitalRoles[1] = "Traitor"
capitalRoles[2] = "Detective"

local function displayWeaponStats(list, aggregateWeaponStatsRow, weaponNameList)
  local function comparisonFunction(left, right)
    local r = DDD.Config.AggregateWeaponStatsTranslation[right] or right
    local l = DDD.Config.AggregateWeaponStatsTranslation[left] or left
    return r > l
  end

  local sortedWeaponList = table.Copy(weaponNameList)
  table.sort(sortedWeaponList, comparisonFunction)

  local displayInfo = {
    kills = "Kills",
    deaths = "Deaths"
  }

  for index, itemName in ipairs(sortedWeaponList) do

    local adjustedItemName = DDD.Config.AggregateWeaponStatsTranslation[itemName] or itemName

    for infoColumnNameSegment, infoDisplay in pairs(displayInfo) do
      for opponentRoleId, opponentRoleName in pairs(DDD.roleIdToRole) do
        local columnNotFound = false
        local values = {}
        local display = adjustedItemName .. " " .. capitalRoles[opponentRoleId] .. " ".. infoDisplay

        for roleId, roleName in pairs(DDD.roleIdToRole) do
          local capitalRoleName = capitalRoles[roleId]
          local columnName = itemName .. "_" .. roleName .. "_" .. opponentRoleName .. "_" .. infoColumnNameSegment
          if aggregateWeaponStatsRow[columnName] then
            values[roleId] = aggregateWeaponStatsRow[columnName]
          else
            columnNotFound = true
          end
        end

        if !columnNotFound then
          list:AddLine(display, values[0] + values[1] + values[2], values[0], values[1], values[2])
        end
    end

    end
  end
end


local function createWeaponsText(overviewPanel)
  local playerName = LocalPlayer():Nick()
  local steamId = LocalPlayer():SteamID()
  local string = "Weapon Stats for player " .. playerName .. " (Steam ID: " .. steamId .. ")"
  local label = vgui.Create( "DLabel", overviewPanel )
  label:SetColor(Color(255, 255, 255))
  label:SetText( string )
  label:SizeToContents()
  local newCenter = DDD.Gui.determineHorizontalCenter(label)
  label:CenterHorizontal()
  --print(newCenter)
  --label:SetPos(newCenter, 0)
end

local function createListView(overviewPanel)
  local list = vgui.Create("DListView", overviewPanel)
  list:SetPos(10, 15)
  list:SetSize(595, 355)
  list:SetMultiSelect(false)
  local nameColumn = list:AddColumn("Name")
  local overallColumn = list:AddColumn("Overall")
  local innoColumn = list:AddColumn("As Innocent")
  local traitorColumn = list:AddColumn("As Traitor")
  local detectiveColumn = list:AddColumn("As Detective")
  nameColumn:SetWidth(295)
  overallColumn:SetWidth(75)
  innoColumn:SetWidth(75)
  traitorColumn:SetWidth(75)
  detectiveColumn:SetWidth(75)
  return list
end

local function calculateWinRate(table)
  return table["traitor_rounds_won"] / table["traitor_rounds"]
end

local function displayPurchases(list, table, itemNameList)
  for index, itemName in pairs(itemNameList) do
    local adjustedItemName = DDD.Config.ShopItemNames[itemName] or itemName
    list:AddLine("Times " .. adjustedItemName .. " Purchased", table["traitor_" .. itemName .. "_purchases"])
  end
end

local function populateListView(list, table, weaponNameList)
  displayWeaponStats(list, table, weaponNameList)
end

function DDD.Gui.createWeaponsTab(mainPropertySheet, statsTable, weaponNameList)
  local weaponsPanel = vgui.Create( "DPanel", mainPropertySheet )
  weaponsPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0) ) end
  DDD.Gui.setSizeToParent(weaponsPanel)
  createWeaponsText(weaponsPanel)
  local list = createListView(weaponsPanel)
  mainPropertySheet:AddSheet( "Weapons", weaponsPanel, "icon16/shield.png")
  populateListView(list, statsTable, weaponNameList)
end
