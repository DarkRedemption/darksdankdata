local function calculateTraitorTotalKD(table)
  local kd = (table["traitor_innocent_kills"] + table["traitor_detective_kills"] + table["traitor_traitor_kills"]) /
         (table["traitor_innocent_deaths"]  + table["traitor_detective_deaths"]  + table["traitor_traitor_deaths"] + table["traitor_world_deaths"])
  return DDD.Gui.formatKD(kd)
end

local function calculateTraitorEnemyKD(table)
  local kd = (table["traitor_innocent_kills"] + table["traitor_detective_kills"]) /
         (table["traitor_innocent_deaths"]  + table["traitor_detective_deaths"]  + table["traitor_traitor_deaths"] + table["traitor_world_deaths"])
  return DDD.Gui.formatKD(kd)
end

local function createTraitorText(overviewPanel)
  local playerName = LocalPlayer():Nick()
  local steamId = LocalPlayer():SteamID()
  local string = "Traitor Stats for player " .. playerName .. " (Steam ID: " .. steamId .. ")"
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
  local valueColumn = list:AddColumn("Value")
  nameColumn:SetWidth(395)
  valueColumn:SetWidth(200)
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

local function populateListView(list, table, itemNameList)
  list:AddLine("Total T Rounds", table["traitor_rounds"])
  list:AddLine("T Rounds Won", table["traitor_rounds_won"])
  list:AddLine("T Rounds Lost", table["traitor_rounds_lost"])
  list:AddLine("Traitor Win Rate", DDD.Gui.formatPercentage(calculateWinRate(table)))
  list:AddLine("Enemy K/D", calculateTraitorEnemyKD(table))
  --list:AddLine("Peak Enemy K/D", "0")
  --list:AddLine("Non-C4 Enemy K/D", "0")
  --list:AddLine("C4 Only Enemy K/D", "0")
  list:AddLine("Total K/D (includes ally kills)", calculateTraitorTotalKD(table))
  list:AddLine("Enemy Kills", tonumber(table["traitor_innocent_kills"]) + tonumber(table["traitor_detective_kills"]))
  list:AddLine("Innocent Kills", table["traitor_innocent_kills"])
  list:AddLine("Detective Kills", table["traitor_detective_kills"])
  list:AddLine("T Buddy Kills", table["traitor_traitor_kills"])
  list:AddLine("Times Killed by Innocents", table["traitor_innocent_deaths"])
  list:AddLine("Times Killed by Detectives", table["traitor_detective_deaths"])
  list:AddLine("Times Killed by T Buddies", table["traitor_traitor_deaths"] - table["traitor_suicides"])
  list:AddLine("Times Killed by the World", table["traitor_world_deaths"])
  list:AddLine("Suicides", table["traitor_suicides"])
  --list:AddLine("Times DNA Scanning Didn't Help The Innocent Kill You", "Not Yet Implemented")
  --list:AddLine("Rounds DNA Scanner Stolen", "Not Yet Implemented")

  list:AddLine("C4 Kills", table["traitor_innocent_ttt_c4_kills"] + table["traitor_detective_ttt_c4_kills"] + table["traitor_traitor_ttt_c4_kills"])
  list:AddLine("C4 Enemy Kills", table["traitor_innocent_ttt_c4_kills"] + table["traitor_detective_ttt_c4_kills"])
  list:AddLine("C4 Ally Kills", table["traitor_traitor_ttt_c4_kills"])
  list:AddLine("C4 Deaths", table["traitor_innocent_ttt_c4_deaths"] + table["traitor_detective_ttt_c4_deaths"] +
                            table["traitor_traitor_ttt_c4_deaths"])
  --list:AddLine("Enemy Kill Assists", "Not Yet Implemented")

  displayPurchases(list, table, itemNameList)
end

function DDD.Gui.createTraitorTab(mainPropertySheet, statsTable, itemNameList)
  local traitorPanel = vgui.Create( "DPanel", mainPropertySheet )
  traitorPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 0, 0) ) end
  DDD.Gui.setSizeToParent(traitorPanel)
  createTraitorText(traitorPanel)
  local list = createListView(traitorPanel)
  mainPropertySheet:AddSheet( "Traitor", traitorPanel, "materials/ddd/icons/t.png")
  populateListView(list, statsTable, itemNameList)
end
