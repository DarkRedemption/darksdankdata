local function configureMainPanel(mainFrame)
  mainFrame:SetPos(0, 0)
  mainFrame:SetSize(640, 480)
  mainFrame:SetTitle("Dark's Dank Data")
  mainFrame:SetDraggable(true)
  mainFrame:Center()
end

--Creates and adds the main Property Sheet (tabbed window that lives inside the panel) to the mainFrame
local function addPlayerStatsPropertySheet(mainPropertySheet)
  net.Start("DDDGetStats")
  net.SendToServer()
  net.Receive("DDDGetStats", function(len, _)
      local weaponClassNames = net.ReadTable()
      local traitorItemNames = net.ReadTable()
      local detectiveItemNames = net.ReadTable()
      local statsTable = net.ReadTable()
      local statsPropertySheet = vgui.Create("DPropertySheet", mainPropertySheet)

      statsPropertySheet:Dock(FILL)
      DDD.Gui.setSizeToParent(statsPropertySheet)
      DDD.Gui.PlayerStats.createOverviewTab(statsPropertySheet, statsTable)
      DDD.Gui.PlayerStats.createTraitorTab(statsPropertySheet, statsTable, traitorItemNames)
      DDD.Gui.PlayerStats.createInnocentTab(statsPropertySheet, statsTable)
      DDD.Gui.PlayerStats.createDetectiveTab(statsPropertySheet, statsTable, detectiveItemNames)
      mainPropertySheet:AddSheet("Stats",
                                  statsPropertySheet,
                                  "icon16/chart_bar.png",
                                  false,
                                  false,
                                  "Your personal stats on this server.")
    end)
end

local function addRankPropertySheet(mainPropertySheet)
  net.Start("DDDGetRankings")
  net.SendToServer()
  net.Receive("DDDGetRankings", function(len, _)
    local rankTable = net.ReadTable()
    local rankPropertySheet = vgui.Create("DPropertySheet", mainPropertySheet)

    DDD.Gui.Rank.createOverallTab(rankPropertySheet, rankTable)
    DDD.Gui.Rank.createDetectiveTab(rankPropertySheet, rankTable)
    DDD.Gui.Rank.createInnocentTab(rankPropertySheet, rankTable)
    DDD.Gui.Rank.createTraitorTab(rankPropertySheet, rankTable)
    rankPropertySheet:Dock(FILL)
    DDD.Gui.setSizeToParent(rankPropertySheet)
    mainPropertySheet:AddSheet("Rank",
                                rankPropertySheet,
                                "icon16/award_star_gold_2.png",
                                false,
                                false,
                                "View the best players on the server in various categories.")
  end)
end

local function addWeaponStatsPropertySheet(mainPropertySheet)
  net.Start("DDDGetWeaponStats")
  net.SendToServer()
  net.Receive("DDDGetWeaponStats", function(len, _)
    local weaponClassNames = net.ReadTable()
    local statsTable = net.ReadTable()
    local weaponStatsPropertySheet = vgui.Create("DPropertySheet", mainPropertySheet)

    weaponStatsPropertySheet:Dock(FILL)
    DDD.Gui.setSizeToParent(weaponStatsPropertySheet)
    DDD.Gui.WeaponStats.createOverallWeaponsTab(weaponStatsPropertySheet, statsTable, weaponClassNames)
    DDD.Gui.WeaponStats.createInnocentWeaponsTab(weaponStatsPropertySheet, statsTable, weaponClassNames)
    DDD.Gui.WeaponStats.createDetectiveWeaponsTab(weaponStatsPropertySheet, statsTable, weaponClassNames)
    DDD.Gui.WeaponStats.createTraitorWeaponsTab(weaponStatsPropertySheet, statsTable, weaponClassNames)
    mainPropertySheet:AddSheet("Weapon Stats",
                                weaponStatsPropertySheet,
                                "icon16/award_star_gold_2.png",
                                false,
                                false,
                                "Your stats relating to your weapon usage.")
  end)
end

function DDD.createMainFrame()
  local mainFrame = vgui.Create( "DFrame" )
  local mainPropertySheet = vgui.Create( "DPropertySheet", mainFrame )
  mainPropertySheet:Dock(FILL)
  configureMainPanel(mainFrame)
  addRankPropertySheet(mainPropertySheet)
  addPlayerStatsPropertySheet(mainPropertySheet)
  addWeaponStatsPropertySheet(mainPropertySheet)
  mainFrame:MakePopup()
end
