local function calculateTraitorTotalKD(table)
  return (table["TraitorInnocentK"] + table["TraitorDetectiveK"] + table["TraitorTraitorK"]) / 
         (table["TraitorInnocentD"]  + table["TraitorDetectiveD"]  + table["TraitorTraitorD"])
end

local function calculateTraitorEnemyKD(table)
  return (table["TraitorInnocentK"] + table["TraitorDetectiveK"]) / 
         (table["TraitorInnocentD"]  + table["TraitorDetectiveD"]  + table["TraitorTraitorD"])
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

local function populateListView(list, table)
  list:AddLine("Total T Rounds", table["TraitorRounds"])
  list:AddLine("Enemy K/D", calculateTraitorEnemyKD(table))
  --list:AddLine("Peak Enemy K/D", "0")
  --list:AddLine("Non-C4 Enemy K/D", "0")
  --list:AddLine("C4 Only Enemy K/D", "0")
  list:AddLine("Total K/D (includes ally kills)", calculateTraitorTotalKD(table))
  list:AddLine("Enemy Kills", tonumber(table["TraitorInnocentK"]) + tonumber(table["TraitorDetectiveK"]))
  list:AddLine("Innocent Kills", table["TraitorInnocentK"])
  list:AddLine("Detective Kills", table["TraitorDetectiveK"])
  list:AddLine("T Buddy Kills", table["TraitorTraitorK"])
  list:AddLine("Times Killed by Innocents", table["TraitorInnocentD"])
  list:AddLine("Times Killed by Detectives", table["TraitorDetectiveD"])
  list:AddLine("Times Killed by T Buddies", table["TraitorTraitorD"] - table["TraitorSuicides"])
  --list:AddLine("Times DNA Scanning Didn't Help The Innocent Kill You", "Not Yet Implemented")
  --list:AddLine("Rounds DNA Scanner Stolen", "Not Yet Implemented")
  
  list:AddLine("C4 Kills", table["TraitorInnocentC4K"] + table["TraitorDetectiveC4K"] + table["TraitorTraitorC4K"])
  list:AddLine("C4 Enemy Kills", table["TraitorInnocentC4K"] + table["TraitorDetectiveC4K"])
  list:AddLine("C4 Ally Kills", table["TraitorTraitorC4K"])
  list:AddLine("C4 Deaths", table["TraitorInnocentC4D"] + table["TraitorDetectiveC4D"] + table["TraitorDetectiveC4D"])
  --list:AddLine("Enemy Kill Assists", "Not Yet Implemented")
  
  list:AddLine("Times Body Armor Purchased", table["TraitorArmorPurchases"])
  list:AddLine("Times Radar Purchased", table["TraitorRadarPurchases"])
  list:AddLine("Times Disguiser Purchased", table["TraitorDisguiserPurchases"])
  list:AddLine("Times Flare Gun Purchased", table["TraitorFlareGunPurchases"])
  list:AddLine("Times Knife Purchased", table["TraitorKnifePurchases"])
  list:AddLine("Times Teleporter Purchased", table["TraitorTeleporterPurchases"])
  list:AddLine("Times Radio Purchased", table["TraitorRadioPurchases"])
  list:AddLine("Times Newton Launcher Purchased", table["TraitorNewtonLauncherPurchases"])
  list:AddLine("Times Silent Pistol Purchased", table["TraitorSilentPistolPurchases"])
  list:AddLine("Times Decoy Purchased", table["TraitorDecoyPurchases"])
  list:AddLine("Times Poltergeist Purchased", table["TraitorPoltergeistPurchases"])
  list:AddLine("Times C4 Purchased", table["TraitorC4Purchases"])
end

function DDD.Gui.createTraitorTab(mainPropertySheet, statsTable)
  local traitorPanel = vgui.Create( "DPanel", mainPropertySheet )
  traitorPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 0, 0) ) end 
  DDD.Gui.setSizeToParent(traitorPanel)
  createTraitorText(traitorPanel)
  local list = createListView(traitorPanel)
  mainPropertySheet:AddSheet( "Traitor", traitorPanel, "materials/ddd/icons/t.png")
  populateListView(list, statsTable)
end