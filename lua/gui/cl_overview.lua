local function createOverviewText(overviewPanel)
  local playerName = LocalPlayer():Nick()
  local steamId = LocalPlayer():SteamID()
  local string = "Overview for player " .. playerName .. " (Steam ID: " .. steamId .. ")"
  local label = vgui.Create( "DLabel", overviewPanel )
  label:SetColor(Color(0, 0, 0))
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

local function calculateAllyKills(table)
  return table["InnocentInnocentK"] + 
         table["InnocentDetectiveK"] + 
         table["DetectiveInnocentK"] +
         table["DetectiveDetectiveK"] +
         table["TraitorTraitorK"]         
end

local function calculateAllyDeaths(table)
  return table["InnocentInnocentD"] + 
         table["InnocentDetectiveD"] + 
         table["DetectiveInnocentD"] +
         table["DetectiveDetectiveD"] +
         table["TraitorTraitorD"] -
         table["InnocentSuicides"] -
         table["TraitorSuicides"] -
         table["DetectiveSuicides"]
end

local function calculateEnemyKills(table)
  return table["InnocentTraitorK"] + 
         table["DetectiveTraitorK"] + 
         table["TraitorInnocentK"] +
         table["TraitorDetectiveK"]
end

local function calculateEnemyDeaths(table)
  return table["InnocentTraitorD"] + 
         table["DetectiveTraitorD"] + 
         table["TraitorInnocentD"] +
         table["TraitorDetectiveD"]
end

local function calculateNonAllyKD(table)
  return (table["K"] - calculateAllyKills(table)) / table["D"]
end

local function populateListView(list, table)
  list:AddLine("Total Rounds Played", table["InnocentRounds"] + table["DetectiveRounds"] + table["TraitorRounds"])
  list:AddLine("Enemy K/D", calculateNonAllyKD(table))
  list:AddLine("Total K/D (Including Ally Kills)", table["K"] / table["D"])
  list:AddLine("Total Kills", table["K"])
  list:AddLine("Total Deaths", table["D"])
  list:AddLine("Enemy Kills", calculateEnemyKills(table))
  list:AddLine("Enemy Deaths", calculateEnemyDeaths(table))
  list:AddLine("Ally Kills", calculateAllyKills(table))
  list:AddLine("Ally Deaths", calculateAllyDeaths(table))
  list:AddLine("Ally K/D", calculateAllyKills(table) / calculateAllyDeaths(table))
  list:AddLine("Assists", "Not Yet Implemented")
  list:AddLine("Falls", "Not Yet Implemented")
  list:AddLine("Suicides", table["TraitorSuicides"] + table["InnocentSuicides"] + table["DetectiveSuicides"])
  list:AddLine("Discombobulators Used", "Not Yet Implemented")
  list:AddLine("Incendiaries Used", "Not Yet Implemented")
  list:AddLine("Smokes Used", "Not Yet Implemented")

  --list:AddLine("Total Innocent Deaths", table["InnocentD"])
  --list:AddLine("Times Killed By Another Innocent",
  
  list:AddLine("Total HP You Healed", tonumber(table["TotalHPYouHealed"]))
  list:AddLine("Total HP Others Healed Using Your Health Stations", tonumber(table["TotalHPOthersHealed"]))
  --SetValue example. Parameters: Column Number (Starts at 1), Value
  --kd:SetValue(2, "Infinite")
end

function DDD.Gui.createOverviewTab(mainPropertySheet, statsTable)
  local overviewPanel = vgui.Create( "DPanel", mainPropertySheet )
  overviewPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 255, 255 ) ) end
  DDD.Gui.setSizeToParent(overviewPanel)
  createOverviewText(overviewPanel)
  local list = createListView(overviewPanel)
  mainPropertySheet:AddSheet( "Overview", overviewPanel, "icon16/chart_bar.png")
  populateListView(list, statsTable)
end

local function getOverviewData(overviewPanel)
  
end