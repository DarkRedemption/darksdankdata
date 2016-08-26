local traitorKd = "Traitor K/D" 
local traitorKills = "Traitors Killed"
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

local function populateWithDetectiveEnemyKd(list, rankTable)
  list.thirdColumn:SetName(traitorKd)
  for key, value in pairs(rankTable["detective_traitor_kd"]) do
    list:AddLine(key, value["last_known_name"], value["detective_traitor_kd"])
  end
end

local function populateWithDetectiveEnemyKills(list, rankTable)
  list.thirdColumn:SetName(traitorKills)
  for key, value in pairs(rankTable["detective_traitor_kills"]) do
    list:AddLine(key, value["last_known_name"], value["detective_traitor_kills"])
  end
end

local function populateWithDetectiveRoundsPlayed(list, rankTable)
  list.thirdColumn:SetName(roundsPlayed)
  for key, value in pairs(rankTable["detective_rounds_played"]) do
    list:AddLine(key, value["last_known_name"], value["detective_rounds_played"])
  end
end

local function updateListView(list, value, rankTable)
  currentValue = value
  if (value == traitorKd) then
    populateWithDetectiveEnemyKd(list, rankTable)
  elseif (value == traitorKills) then
    populateWithDetectiveEnemyKills(list, rankTable)
  elseif (value == roundsPlayed) then
    populateWithDetectiveRoundsPlayed(list, rankTable)
  end
end

local function createComboBox(panel)
  local comboBox = vgui.Create( "DComboBox", panel)
  comboBox:SetPos(5, 5)
  comboBox:SetSize(150, 20)
  comboBox:AddChoice(traitorKd)
  comboBox:AddChoice(traitorKills)
  comboBox:AddChoice(roundsPlayed)
  return comboBox
end

function DDD.Gui.Rank.createDetectiveTab(rankPropertySheet, rankTable)
  local panel = vgui.Create( "DPanel", rankPropertySheet )
  panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 255 ) ) end 
  DDD.Gui.setSizeToParent(panel)
  local comboBox = createComboBox(panel)
  local list = createListView("Value")
  list:SetParent(panel)
  
  comboBox.OnSelect = function(panel, index, value)
    list:Clear()
    updateListView(list, value, rankTable)
  end
  
  comboBox:ChooseOptionID(1)
  rankPropertySheet:AddSheet("Detective Ranks", panel, "materials/ddd/icons/d.png")
end