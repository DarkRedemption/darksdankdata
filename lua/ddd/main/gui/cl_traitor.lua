local function calculateTraitorTotalKD(table)
  return (table["traitor_innocent_kills"] + table["traitor_detective_kills"] + table["traitor_traitor_kills"]) / 
         (table["traitor_innocent_deaths"]  + table["traitor_detective_deaths"]  + table["traitor_traitor_deaths"] + table["traitor_world_deaths"]) 
end

local function calculateTraitorEnemyKD(table)
  return (table["traitor_innocent_kills"] + table["traitor_detective_kills"]) / 
         (table["traitor_innocent_deaths"]  + table["traitor_detective_deaths"]  + table["traitor_traitor_deaths"] + table["traitor_world_deaths"]) 
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
  list:AddLine("Enemy Kills", tonumber(table["traitor_innocent_kills"]) + tonumber(table["traitor_detective_kills"]))
  list:AddLine("Innocent Kills", table["traitor_innocent_kills"])
  list:AddLine("Detective Kills", table["traitor_detective_kills"])
  list:AddLine("T Buddy Kills", table["traitor_traitor_kills"])
  list:AddLine("Times Killed by Innocents", table["traitor_innocent_deaths"])
  list:AddLine("Times Killed by Detectives", table["traitor_detective_deaths"])
  list:AddLine("Times Killed by T Buddies", table["traitor_traitor_deaths"] - table["TraitorSuicides"])
  list:AddLine("Times Killed by the World", table["traitor_world_deaths"])
  --list:AddLine("Times DNA Scanning Didn't Help The Innocent Kill You", "Not Yet Implemented")
  --list:AddLine("Rounds DNA Scanner Stolen", "Not Yet Implemented")
  
  list:AddLine("C4 Kills", table["TraitorInnocentC4K"] + table["TraitorDetectiveC4K"] + table["TraitorTraitorC4K"])
  list:AddLine("C4 Enemy Kills", table["TraitorInnocentC4K"] + table["TraitorDetectiveC4K"])
  list:AddLine("C4 Ally Kills", table["TraitorTraitorC4K"])
  list:AddLine("C4 Deaths", table["TraitorInnocentC4D"] + table["TraitorDetectiveC4D"] + table["TraitorDetectiveC4D"])
  --list:AddLine("Enemy Kill Assists", "Not Yet Implemented")
  
  list:AddLine("Times Body Armor Purchased", table["traitor_armor_purchases"])
  list:AddLine("Times Radar Purchased", table["traitor_radar_purchases"])
  list:AddLine("Times Disguiser Purchased", table["traitor_disguiser_purchases"])
  list:AddLine("Times Flare Gun Purchased", table["traitor_flaregun_purchases"])
  list:AddLine("Times Knife Purchased", table["traitor_knife_purchases"])
  list:AddLine("Times Teleporter Purchased", table["traitor_teleporter_purchases"])
  list:AddLine("Times Radio Purchased", table["traitor_radio_purchases"])
  list:AddLine("Times Newton Launcher Purchased", table["traitor_newtonlauncher_purchases"])
  list:AddLine("Times Silent Pistol Purchased", table["traitor_silentpistol_purchases"])
  list:AddLine("Times Decoy Purchased", table["traitor_decoy_purchases"])
  list:AddLine("Times Poltergeist Purchased", table["traitor_poltergeist_purchases"])
  list:AddLine("Times C4 Purchased", table["traitor_c4_purchases"])
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