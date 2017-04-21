local function calculateDetectiveTotalKD(table)
  local kd = (table["detective_traitor_kills"] +
              table["detective_innocent_kills"] +
              table["detective_detective_kills"]) /
              (table["detective_traitor_deaths"] +
              table["detective_detective_deaths"] +
              table["detective_innocent_deaths"] +
              table["detective_world_deaths"])

  return DDD.Gui.formatKD(kd)
end

local function calculateDetectiveEnemyKD(table)
  local kd = table["detective_traitor_kills"] /
         (table["detective_traitor_deaths"] + table["detective_detective_deaths"] + table["detective_innocent_deaths"] + table["detective_world_deaths"])

  return DDD.Gui.formatKD(kd)
end

local function createDetectiveText(overviewPanel)
  local playerName = LocalPlayer():Nick()
  local steamId = LocalPlayer():SteamID()
  local string = "Detective Stats for player " .. playerName .. " (Steam ID: " .. steamId .. ")"
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
  return table["detective_rounds_won"] / table["detective_rounds"]
end


local displayPurchases(list, table)

end

local function populateListView(list, table)
  list:AddLine("Total D Rounds", table["detective_rounds"])
  list:AddLine("D Rounds Won", table["detective_rounds_won"])
  list:AddLine("D Rounds Lost", table["detective_rounds_lost"])
  list:AddLine("Detective Win Rate", DDD.Gui.formatPercentage(calculateWinRate(table)))
  list:AddLine("Enemy K/D", calculateDetectiveEnemyKD(table))
  --list:AddLine("Peak Enemy K/D", "Not Yet Implemented")
  list:AddLine("Total K/D (includes ally kills)", calculateDetectiveTotalKD(table))
  list:AddLine("Traitors Killed", table["detective_traitor_kills"])
  list:AddLine("Innocents Killed", table["detective_innocent_kills"])
  list:AddLine("Detective Partners Killed", table["detective_detective_kills"])
  list:AddLine("Total Allies Killed", table["detective_innocent_kills"] + table["detective_detective_kills"])
  list:AddLine("Times Killed by Traitors", table["detective_traitor_deaths"])
  list:AddLine("Times Killed by Innocents", table["detective_innocent_deaths"])
  list:AddLine("Times Killed by Fellow Detectives", table["detective_detective_deaths"] - table["detective_suicides"])
  list:AddLine("Times Killed by Allies (Innocents + Detectives)", table["detective_innocent_deaths"] + table["detective_detective_deaths"])
  list:AddLine("Times Killed by the World", table["detective_world_deaths"])
  list:AddLine("Suicides", table["detective_suicides"])
  --list:AddLine("Total HP Others Healed Using Your Health Stations", tonumber(table["TotalHPOthersHealed"]))

  list:AddLine("Times Radar Purchased", table["detective_radar_purchases"])
  list:AddLine("Times Visualizer purchased", table["detective_visualizer_purchases"])
  list:AddLine("Times Defuser purchased", table["detective_defuser_purchases"])
  list:AddLine("Times Teleporter purchased", table["detective_teleporter_purchases"])
  list:AddLine("Times Binoculars purchased", table["detective_binoculars_purchases"])
  list:AddLine("Times UMP purchased", table["detective_ump_purchases"])
  list:AddLine("Times Health Station purchased", table["detective_healthstation_purchases"])
end

function DDD.Gui.createDetectiveTab(mainPropertySheet, statsTable)
  local detectivePanel = vgui.Create( "DPanel", mainPropertySheet )
  detectivePanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 255 ) ) end
  DDD.Gui.setSizeToParent(detectivePanel)
  createDetectiveText(detectivePanel)
  local list = createListView(detectivePanel)
  mainPropertySheet:AddSheet( "Detective", detectivePanel, "materials/ddd/icons/d.png")
  populateListView(list, statsTable)
end
