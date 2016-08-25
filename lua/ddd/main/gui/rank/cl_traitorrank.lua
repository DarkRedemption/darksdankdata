local enemyKd = "Enemy K/D" 
local enemyKills = "Enemies Killed"
local innocentKills = "Innocents Killed"
local detectiveKills = "Detectives Killed"
local roundsPlayed = "Rounds Played"

local currentValue = ""

local function createListView()
  local list = vgui.Create("DListView")
  list:SetPos(5, 30)
  list:SetSize(605, 350)
  list:SetMultiSelect(true)
  local rankColumn = list:AddColumn("Rank")
  local nameColumn = list:AddColumn("Name")
  local thirdColumn = list:AddColumn("Value")
  rankColumn:SetWidth(50)
  nameColumn:SetWidth(350)
  thirdColumn:SetWidth(200)
  list.thirdColumn = thirdColumn -- For easy access
  return list
end

local function populateWithTraitorEnemyKd(list, rankTable)
  list.thirdColumn:SetName(enemyKd)
  for key, value in pairs(rankTable["traitor_enemy_kd"]) do
    list:AddLine(key, value["last_known_name"], value["traitor_enemy_kd"])
  end
end

local function populateWithTraitorEnemyKills(list, rankTable)
  list.thirdColumn:SetName(enemyKills)
  for key, value in pairs(rankTable["traitor_enemy_kills"]) do
    list:AddLine(key, value["last_known_name"], value["traitor_enemy_kills"])
  end
end

local function populateWithTraitorInnocentKills(list, rankTable)
  list.thirdColumn:SetName(innocentKills)
  for key, value in pairs(rankTable["traitor_innocent_kills"]) do
    list:AddLine(key, value["last_known_name"], value["traitor_innocent_kills"])
  end
end

local function populateWithTraitorDetectiveKills(list, rankTable)
  list.thirdColumn:SetName(detectiveKills)
  for key, value in pairs(rankTable["traitor_detective_kills"]) do
    list:AddLine(key, value["last_known_name"], value["traitor_detective_kills"])
  end
end

local function populateWithTraitorRoundsPlayed(list, rankTable)
  list.thirdColumn:SetName(roundsPlayed)
  for key, value in pairs(rankTable["traitor_rounds_played"]) do
    list:AddLine(key, value["last_known_name"], value["traitor_rounds_played"])
  end
end

local function updateListView(list, value, rankTable)
  if (value != currentValue) then
    currentValue = value
    if (value == enemyKd) then
      populateWithTraitorEnemyKd(list, rankTable)
    elseif (value == enemyKills) then
      populateWithTraitorEnemyKills(list, rankTable)
    elseif (value == innocentKills) then
      populateWithTraitorInnocentKills(list, rankTable)
    elseif (value == detectiveKills) then
      populateWithTraitorDetectiveKills(list, rankTable)
    elseif (value == roundsPlayed) then
      populateWithTraitorRoundsPlayed(list, rankTable)
    end
  end
end

local function createComboBox(panel)
  local comboBox = vgui.Create( "DComboBox", panel)
  comboBox:SetPos(5, 5)
  comboBox:SetSize(150, 20)
  comboBox:AddChoice(enemyKd)
  comboBox:AddChoice(enemyKills)
  comboBox:AddChoice(innocentKills)
  comboBox:AddChoice(detectiveKills)
  comboBox:AddChoice(roundsPlayed)
  return comboBox
end

function DDD.Gui.Rank.createTraitorTab(rankPropertySheet, rankTable)
  local panel = vgui.Create( "DPanel", rankPropertySheet )
  panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 0, 0 ) ) end 
  DDD.Gui.setSizeToParent(panel)
  local comboBox = createComboBox(panel)
  local list = createListView("Value")
  list:SetParent(panel)
  
  comboBox.OnSelect = function(panel, index, value)
    if (currentValue != value) then
      list:Clear()
      updateListView(list, value, rankTable)
    end
  end
  
  rankPropertySheet:AddSheet( "Traitor Ranks", panel, "materials/ddd/icons/t.png")
end