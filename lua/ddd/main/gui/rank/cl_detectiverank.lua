local traitorKd = "Traitor K/D"
local traitorKills = "Traitors Killed"
local roundsPlayed = "Rounds Played"
local winRate = "Win Rate (%)"
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

local function populateList(list, rankTableEntry, columnName)
  list.thirdColumn:SetName(columnName)
  for key, value in pairs(rankTableEntry) do
    list:AddLine(key, value["last_known_name"], value["value"])
  end
end

local function updateListView(list, value, rankTable)
  currentValue = value
  if (value == traitorKd) then
    populateList(list, rankTable["detective_traitor_kd"], traitorKd)
  elseif (value == traitorKills) then
    populateList(list, rankTable["detective_traitor_kills"], traitorKills)
  elseif (value == roundsPlayed) then
    populateList(list, rankTable["detective_rounds_played"], roundsPlayed)
  elseif (value == winRate) then
    populateList(list, rankTable["detective_win_rate"], winRate)
  end
end

local function createComboBox(panel)
  local comboBox = vgui.Create( "DComboBox", panel)
  comboBox:SetPos(5, 5)
  comboBox:SetSize(150, 20)
  comboBox:AddChoice(traitorKd)
  comboBox:AddChoice(traitorKills)
  comboBox:AddChoice(roundsPlayed)
  comboBox:AddChoice(winRate)
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
