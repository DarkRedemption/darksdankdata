local function createRankText(rankPanel)
  local text = "Overview for player " .. playerName .. " (Steam ID: " .. steamId .. ")"
  local label = vgui.Create( "DLabel", rankPanel )
  label:SetColor(Color(0, 0, 0))
  label:SetText( text )
  label:SizeToContents()
  local newCenter = DDD.Gui.determineHorizontalCenter(label)
  label:CenterHorizontal()
  --print(newCenter)
  --label:SetPos(newCenter, 0)
end

local function createListView(rankPanel)
  local list = vgui.Create("DListView", rankPanel)
  list:SetPos(25, 25)
  list:SetSize(550, 350)
  list:SetMultiSelect(false)
  local nameColumn = list:AddColumn("Name")
  local valueColumn = list:AddColumn("Value")
  nameColumn:SetWidth(300)
  valueColumn:SetWidth(200)
  return list
end

function DDD.Gui.createRankingTab(mainPropertySheet, rankTable)
  local panel = vgui.Create( "DPanel", mainPropertySheet )
  panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 255, 255 ) ) end
  DDD.Gui.setSizeToParent(panel)
  createRankText(panel)
  local list = createListView(panel)
  mainPropertySheet:AddSheet("Overview", panel, "icon16/chart_bar.png")
  populateListView(list, rankTable)
end