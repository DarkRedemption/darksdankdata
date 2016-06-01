local function populateListView(list)
  list:AddLine(1, "Dark Redemption", 2.00)
end

local function createListView(panel)
  local list = vgui.Create("DListView", panel)
  list:SetPos(5, 5)
  list:SetSize(560, 350)
  list:SetMultiSelect(true)
  local rankColumn = list:AddColumn("Rank")
  local nameColumn = list:AddColumn("Name")
  local kdColumn = list:AddColumn("Overall Enemy K/D")
  rankColumn:SetWidth(100)
  nameColumn:SetWidth(300)
  kdColumn:SetWidth(100)
  return list
end

function DDD.Gui.Rank.createEnemyKdTab(rankPropertySheet)
  local panel = vgui.Create( "DPanel", rankPropertySheet )
  panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 255, 255 ) ) end 
  DDD.Gui.setSizeToParent(panel)
  local list = createListView(panel)
  rankPropertySheet:AddSheet( "Overall Enemy K/D", panel, "icon16/chart_bar.png")
  populateListView(list)
end