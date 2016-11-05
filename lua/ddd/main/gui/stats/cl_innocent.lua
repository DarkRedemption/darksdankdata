local function calculateInnocentAllKD(table)
  local kd = (table["innocent_traitor_kills"] +
              table["innocent_innocent_kills"] +
              table["innocent_detective_kills"]) /
             (table["innocent_traitor_deaths"] +
              table["innocent_detective_deaths"] +
              table["innocent_innocent_deaths"] +
              table["innocent_world_deaths"])

  return DDD.Gui.formatKD(kd)
end

local function calculateInnocentNonAllyKD(table)
  local kd = table["innocent_traitor_kills"] /
            (table["innocent_traitor_deaths"] +
             table["innocent_detective_deaths"] +
             table["innocent_innocent_deaths"] +
             table["innocent_world_deaths"])

  return DDD.Gui.formatKD(kd)
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
  return table["innocent_rounds_won"] / table["innocent_rounds"]
end

local function populateListView(list, table)
  list:AddLine("Total Inno Rounds", table["innocent_rounds"])
  list:AddLine("Inno Rounds Won", table["innocent_rounds_won"])
  list:AddLine("Inno Rounds Lost", table["innocent_rounds_lost"])
  list:AddLine("Innocent Win Rate", DDD.Gui.formatPercentage(calculateWinRate(table)))
  list:AddLine("Enemy K/D", calculateInnocentNonAllyKD(table))
  --list:AddLine("Peak Enemy K/D", "0")
  list:AddLine("Total K/D (includes ally kills)", calculateInnocentAllKD(table))
  list:AddLine("Traitors Killed", table["innocent_traitor_kills"])
  list:AddLine("Innocents Killed", table["innocent_innocent_kills"])
  list:AddLine("Detectives Killed", table["innocent_detective_kills"])
  list:AddLine("Total Allies Killed", table["innocent_innocent_kills"] + table["innocent_detective_kills"])
  list:AddLine("Times Killed by Traitors", table["innocent_traitor_deaths"])
  list:AddLine("Times Killed by Innocents", table["innocent_innocent_deaths"] - table["innocent_suicides"])
  list:AddLine("Times Killed by Detectives", table["innocent_detective_deaths"])
  list:AddLine("Times Killed by the World", table["innocent_world_deaths"])
   list:AddLine("Total Times Killed by Allies", table["innocent_innocent_deaths"] + table["innocent_detective_deaths"] - table["innocent_suicides"])
   list:AddLine("Suicides", table["innocent_suicides"])
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
