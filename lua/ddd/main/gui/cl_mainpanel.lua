local function configureMainPanel(mainFrame)
  mainFrame:SetPos(0, 0)
  mainFrame:SetSize(640, 480)
  mainFrame:SetTitle("Dark's Dank Data")
  mainFrame:SetDraggable(true)
  mainFrame:Center()
end

--Creates and adds the main Property Sheet (tabbed window that lives inside the panel) to the mainFrame
local function addStatsPropertySheet(mainPropertySheet)
  net.Start("DDDGetStats")
  net.SendToServer()
  net.Receive("DDDGetStats", function(len, _)
      local statsTable = net.ReadTable()
      local statsPropertySheet = vgui.Create( "DPropertySheet", mainPropertySheet )
      statsPropertySheet:Dock(FILL)
      DDD.Gui.setSizeToParent(statsPropertySheet)
      DDD.Gui.createOverviewTab(statsPropertySheet, statsTable)
      DDD.Gui.createTraitorTab(statsPropertySheet, statsTable)
      DDD.Gui.createInnocentTab(statsPropertySheet, statsTable)
      DDD.Gui.createDetectiveTab(statsPropertySheet, statsTable)
      mainPropertySheet:AddSheet("Stats", statsPropertySheet, "icon16/chart_bar.png")
    end)
end

local function addRankPropertySheet(mainPropertySheet)
    local rankPropertySheet = vgui.Create( "DPropertySheet", mainPropertySheet )
    DDD.Gui.Rank.createEnemyKdTab(rankPropertySheet)
    DDD.Gui.Rank.createEnemyKillTab(rankPropertySheet)
    rankPropertySheet:Dock(FILL)
    DDD.Gui.setSizeToParent(rankPropertySheet)
    mainPropertySheet:AddSheet("Rank", rankPropertySheet, "icon16/chart_bar.png")
end

function DDD.createMainFrame()
  local mainFrame = vgui.Create( "DFrame" )
  local mainPropertySheet = vgui.Create( "DPropertySheet", mainFrame )
  mainPropertySheet:Dock(FILL)
  configureMainPanel(mainFrame)
  --addRankPropertySheet(mainPropertySheet)
  addStatsPropertySheet(mainPropertySheet)
  mainFrame:MakePopup()
end