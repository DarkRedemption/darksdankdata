local enemyKd = "Enemy K/D"
local enemyKills = "Enemies Killed"
local innocentKills = "Innocents Killed"
local detectiveKills = "Detectives Killed"
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
  if (value == enemyKd) then
    populateList(list, rankTable["traitor_enemy_kd"], enemyKd)
  elseif (value == enemyKills) then
    populateList(list, rankTable["traitor_enemy_kills"], enemyKills)
  elseif (value == innocentKills) then
    populateList(list, rankTable["traitor_innocent_kills"], innocentKills)
  elseif (value == detectiveKills) then
    populateList(list, rankTable["traitor_detective_kills"], detectiveKills)
  elseif (value == roundsPlayed) then
    populateList(list, rankTable["traitor_rounds_played"], roundsPlayed)
  elseif (value == winRate) then
    populateList(list, rankTable["traitor_win_rate"], winRate)
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
  comboBox:AddChoice(winRate)
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
    list:Clear()
    updateListView(list, value, rankTable)
  end

  comboBox:ChooseOptionID(1)
  rankPropertySheet:AddSheet( "Traitor Ranks", panel, "materials/ddd/icons/t.png")
end
