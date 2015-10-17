local function calculateInnocentAllKD(table)
  return (table["InnocentTraitorK"] + table["InnocentInnocentK"] + table["InnocentDetectiveK"]) / 
         (table["InnocentTraitorD"] + table["InnocentDetectiveD"] + table["InnocentInnocentD"])
end

local function calculateInnocentNonAllyKD(table)
  return table["InnocentTraitorK"] / (table["InnocentTraitorD"] + table["InnocentDetectiveD"] + table["InnocentInnocentD"])
end

local function createInnocentText(overviewPanel)
  local playerName = LocalPlayer():Nick()
  local steamId = LocalPlayer():SteamID()
  local string = "Innocent Stats for player " .. playerName .. " (Steam ID: " .. steamId .. ")"
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
  list:SetPos(25, 25)
  list:SetSize(550, 350)
  list:SetMultiSelect(false)
  local nameColumn = list:AddColumn("Name")
  local valueColumn = list:AddColumn("Value")
  nameColumn:SetWidth(300)
  valueColumn:SetWidth(200)
  return list
end

local function populateListView(list, table)
  list:AddLine("Total Inno Rounds", table["InnocentRounds"])
  list:AddLine("Enemy K/D", calculateInnocentNonAllyKD(table))
  --list:AddLine("Peak Enemy K/D", "0")
  list:AddLine("Total K/D (includes ally kills)", calculateInnocentAllKD(table))
  list:AddLine("Traitors Killed", table["InnocentTraitorK"])
  list:AddLine("Innocents Killed", table["InnocentInnocentK"])
  list:AddLine("Detectives Killed", table["InnocentDetectiveK"])
  list:AddLine("Total Allies Killed", table["InnocentInnocentK"] + table["InnocentDetectiveK"])
  list:AddLine("Times Killed by Traitors", table["InnocentTraitorD"])
  list:AddLine("Times Killed by Innocents", table["InnocentInnocentD"] - table["InnocentSuicides"])
  list:AddLine("Times Killed by Detectives", table["InnocentDetectiveD"])
   list:AddLine("Total Times Killed by Allies", table["InnocentInnocentD"] + table["InnocentDetectiveD"] - table["InnocentSuicides"])
   list:AddLine("Suicides", table["InnocentSuicides"])
  --list:AddLine("Detectives Saved", "0") --Kill a traitor actively attacking a detective
  --list:AddLine("Traitor Killstreaks Stopped", "0")
  --list:AddLine("Times You Soloed the Traitors When There Were 3+ of Them", "0")
  --list:AddLine("Mass RDMers killed", "0")
end


function DDD.Gui.createInnocentTab(mainPropertySheet, statsTable)
  local innocentPanel = vgui.Create( "DPanel", mainPropertySheet )
  innocentPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 255, 0 ) ) end 
  DDD.Gui.setSizeToParent(innocentPanel)
  createInnocentText(innocentPanel)
  local list = createListView(innocentPanel)
  mainPropertySheet:AddSheet( "Innocent", innocentPanel, "materials/ddd/icons/i.png")
  populateListView(list, statsTable)
end