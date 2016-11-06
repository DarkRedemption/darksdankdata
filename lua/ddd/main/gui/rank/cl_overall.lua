local enemyKd = "Overall Enemy K/D"
--local serverTime = "Server Time"
local enemyKills = "Total Enemies Killed"
local roundsPlayed = "Total Rounds Played"
local winRate = "Overall Win Rate (%)"
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
  if (value == enemyKd) then
    populateList(list, rankTable["overall_enemy_kd"], enemyKd)
  elseif (value == enemyKills) then
    populateList(list, rankTable["total_enemy_kills"], enemyKills)
  elseif (value == roundsPlayed) then
    populateList(list, rankTable["total_rounds_played"], roundsPlayed)
  elseif (value == winRate) then
    populateList(list, rankTable["overall_win_rate"], winRate)
  end
end

local function createComboBox(panel)
  local comboBox = vgui.Create( "DComboBox", panel)
  comboBox:SetPos(5, 5)
  comboBox:SetSize(150, 20)
  --comboBox:SetValue("options")
  comboBox:AddChoice(enemyKd)
  --comboBox:AddChoice(serverTime)
  comboBox:AddChoice(enemyKills)
  comboBox:AddChoice(roundsPlayed)
  comboBox:AddChoice(winRate)
  return comboBox
end

function DDD.Gui.Rank.createOverallTab(rankPropertySheet, rankTable)
  local panel = vgui.Create( "DPanel", rankPropertySheet )
  panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 255, 255 ) ) end
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

  comboBox:ChooseOptionID(1)
  rankPropertySheet:AddSheet("Overall", panel, "icon16/chart_bar.png")
end
