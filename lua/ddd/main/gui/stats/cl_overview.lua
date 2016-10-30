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
  list:SetPos(10, 15)
  list:SetSize(595, 355)
  list:SetMultiSelect(false)
  local nameColumn = list:AddColumn("Name")
  local valueColumn = list:AddColumn("Value")
  nameColumn:SetWidth(395)
  valueColumn:SetWidth(200)
  return list
end

local function calculateRoundsPlayed(table)
  return table["innocent_rounds"] +
         table["detective_rounds"] +
         table["traitor_rounds"]
end

local function calculateAllyKills(table)
  return table["innocent_innocent_kills"] +
         table["innocent_detective_kills"] +
         table["detective_innocent_kills"] +
         table["detective_detective_kills"] +
         table["traitor_traitor_kills"]
end

local function calculateAllyDeaths(table)
  return table["innocent_innocent_deaths"] +
         table["innocent_detective_deaths"] +
         table["detective_innocent_deaths"] +
         table["detective_detective_deaths"] +
         table["traitor_traitor_deaths"] -
         table["innocent_suicides"] -
         table["traitor_suicides"] -
         table["detective_suicides"]
end

local function calculateEnemyKills(table)
  return table["innocent_traitor_kills"] +
         table["detective_traitor_kills"] +
         table["traitor_innocent_kills"] +
         table["traitor_detective_kills"]
end

local function calculateEnemyDeaths(table)
  return table["innocent_traitor_deaths"] +
         table["detective_traitor_deaths"] +
         table["traitor_innocent_deaths"] +
         table["traitor_detective_deaths"]
end

local function calculateWorldDeaths(table)
  return table["innocent_world_deaths"] +
         table["traitor_world_deaths"] +
         table["detective_world_deaths"]
end

local function calculateSuicides(table)
  return table["innocent_suicides"] +
         table["traitor_suicides"] +
         table["detective_suicides"]
end

local function calculateKills(table)
  return calculateAllyKills(table) + calculateEnemyKills(table)
end

local function calculateDeaths(table)
  return calculateAllyDeaths(table) + calculateEnemyDeaths(table) + calculateWorldDeaths(table) + calculateSuicides(table)
end

local function calculateEnemyKD(table)
  local kd = calculateEnemyKills(table) / (calculateEnemyDeaths(table) + calculateWorldDeaths(table))
  return DDD.Gui.formatKD(kd)
end

local function calculateEnemyKDWithAllDeaths(table)
  local kd = calculateEnemyKills(table) / calculateDeaths(table)
  return DDD.Gui.formatKD(kd)
end

local function populateListView(list, table)
  if (table["TotalServerTime"]) then
    list:AddLine("Total Server Time", table["TotalServerTime"])
  end
  list:AddLine("Total Rounds Played", calculateRoundsPlayed(table))
  list:AddLine("Enemy K/D ", calculateEnemyKD(table))
  list:AddLine("Enemy K/D including times killed by allies", calculateEnemyKDWithAllDeaths(table))
  list:AddLine("Total K/D (includes ally kills and deaths)", DDD.Gui.formatKD(calculateKills(table) / calculateDeaths(table)))
  list:AddLine("Total Kills", calculateKills(table))
  list:AddLine("Total Deaths", calculateDeaths(table))
  list:AddLine("Enemy Kills", calculateEnemyKills(table))
  list:AddLine("Enemy Deaths", calculateEnemyDeaths(table))
  list:AddLine("Ally Kills", calculateAllyKills(table))
  list:AddLine("Ally Deaths", calculateAllyDeaths(table))
  list:AddLine("Ally K/D", DDD.Gui.formatKD(calculateAllyKills(table) / calculateAllyDeaths(table)))
  --list:AddLine("Assists", "Not Yet Implemented")
  --list:AddLine("Falls", "Not Yet Implemented")
  list:AddLine("Suicides", table["traitor_suicides"] + table["innocent_suicides"] + table["detective_suicides"])
  --list:AddLine("Discombobulators Used", "Not Yet Implemented")
  --list:AddLine("Incendiaries Used", "Not Yet Implemented")
  --list:AddLine("Smokes Used", "Not Yet Implemented")

  --list:AddLine("Total Innocent Deaths", table["InnocentD"])
  --list:AddLine("Times Killed By Another Innocent",

  list:AddLine("Total HP You Healed", tonumber(table["self_hp_healed"]))
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
