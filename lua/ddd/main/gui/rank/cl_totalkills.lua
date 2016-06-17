local function populateListView(list)
  list:AddLine(1, "Dark Redemption", 9001)
end

local function createListView(panel)
  local list = vgui.Create("DListView", panel)
  list:SetPos(25, 25)
  list:SetSize(550, 350)
  list:SetMultiSelect(false)
  local rankColumn = list:AddColumn("Rank")
  local nameColumn = list:AddColumn("Name")
  local killsColumn = list:AddColumn("Total Enemy Kills")
  rankColumn:SetWidth(100)
  nameColumn:SetWidth(200)
  killsColumn:SetWidth(300)
  return list
end

function DDD.Gui.Rank.createEnemyKillTab(rankPropertySheet)
  local panel = vgui.Create( "DPanel", rankPropertySheet )
  panel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 255, 0 ) ) end 
  DDD.Gui.setSizeToParent(panel)
  local list = createListView(panel)
  rankPropertySheet:AddSheet( "Enemy Kills", panel, "materials/ddd/icons/i.png")
  populateListView(list)
end