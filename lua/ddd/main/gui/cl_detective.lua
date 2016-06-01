local function calculateDetectiveTotalKD(table)
  return (table["DetectiveTraitorK"] + table["DetectiveInnocentK"] + table["DetectiveDetectiveK"]) / 
         (table["DetectiveTraitorD"] + table["DetectiveDetectiveD"] + table["DetectiveInnocentD"])
end

local function calculateDetectiveEnemyKD(table)
  return table["DetectiveTraitorK"] / 
         (table["DetectiveTraitorD"] + table["DetectiveDetectiveD"] + table["DetectiveInnocentD"])
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

local function populateListView(list, table)
  list:AddLine("Total D Rounds", table["DetectiveRounds"])
  list:AddLine("Enemy K/D", calculateDetectiveEnemyKD(table))
  --list:AddLine("Peak Enemy K/D", "Not Yet Implemented")
  list:AddLine("Total K/D (includes ally kills)", calculateDetectiveTotalKD(table))
  list:AddLine("Traitors Killed", table["DetectiveTraitorK"])
  list:AddLine("Innocents Killed", table["DetectiveInnocentK"])
  list:AddLine("Detective Partners Killed", table["DetectiveDetectiveK"])
  list:AddLine("Total Allies Killed", table["DetectiveInnocentK"] + table["DetectiveDetectiveK"])
  list:AddLine("Times Killed By Traitors", table["DetectiveTraitorD"])
  list:AddLine("Times Killed By Innocents", table["DetectiveInnocentD"])
  list:AddLine("Times Killed By Fellow Detectives", table["DetectiveDetectiveD"] - table["DetectiveSuicides"])
  list:AddLine("Total Times Killed By Allies", table["DetectiveInnocentD"] + table["DetectiveDetectiveD"])
  --list:AddLine("Total HP Others Healed Using Your Health Stations", tonumber(table["TotalHPOthersHealed"]))
    
  list:AddLine("Times Radar Purchased", table["DetectiveRadarPurchases"])
  list:AddLine("Times Visualizer purchased", table["DetectiveVisualizerPurchases"])
  list:AddLine("Times Defuser purchased", table["DetectiveDefuserPurchases"])
  list:AddLine("Times Teleporter purchased", table["DetectiveTeleporterPurchases"])
  list:AddLine("Times Binoculars purchased", table["DetectiveBinocularsPurchases"])
  list:AddLine("Times UMP purchased", table["DetectiveUmpPurchases"])
  list:AddLine("Times Health Station purchased", table["DetectiveHealthStationPurchases"])
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