local function configureMainPanel(mainFrame)
  mainFrame:SetPos(0, 0)
  mainFrame:SetSize(640, 480)
  mainFrame:SetTitle("Dark's Dank Data")
  mainFrame:SetDraggable(true)
  mainFrame:Center()
end

local function createTraitorTab(mainPropertySheet)
  local overviewPanel = vgui.Create( "DPanel", mainPropertySheet )
  overviewPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 0, 0 ) ) end 
  mainPropertySheet:AddSheet( "Traitor", overviewPanel, "icon16/cross.png")
end

--Creates and adds the main Property Sheet (tabbed window that lives inside the panel) to the mainFrame
local function addMainPropertySheet(mainFrame)
  net.Start("DDDGetStats")
  net.SendToServer()
  net.Receive("DDDGetStats", function(len, _)
      print("Stats received!")
      local statsTable = net.ReadTable()
      local mainPropertySheet = vgui.Create( "DPropertySheet", mainFrame )
      mainPropertySheet:Dock(FILL)
      DDD.Gui.setSizeToParent(mainPropertySheet)
      DDD.Gui.createOverviewTab(mainPropertySheet, statsTable)
      DDD.Gui.createTraitorTab(mainPropertySheet, statsTable)
      DDD.Gui.createInnocentTab(mainPropertySheet, statsTable)
      DDD.Gui.createDetectiveTab(mainPropertySheet, statsTable)      
    end)
end

function DDD.createMainFrame()
  local mainFrame = vgui.Create( "DFrame" )
  configureMainPanel(mainFrame)
  addMainPropertySheet(mainFrame)
  mainFrame:MakePopup()
end