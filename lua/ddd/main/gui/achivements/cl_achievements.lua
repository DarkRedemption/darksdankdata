
local function createAchievementsTab(dtabSheet)
  local dddTab = vgui.Create("DPanel", dtabsheet)

end


local function setupAchievementsTab()
  local oldShowPanel = CLSCORE.ShowPanel

  function CLSCORE:ShowPanel()
   local margin = 15

   local dpanel = vgui.Create("DFrame")
   local w, h = 700, 500
   dpanel:SetSize(700, 500)
   dpanel:Center()
   dpanel:SetTitle(T("report_title"))
   dpanel:SetVisible(true)
   dpanel:ShowCloseButton(true)
   dpanel:SetMouseInputEnabled(true)
   dpanel:SetKeyboardInputEnabled(true)
   dpanel.OnKeyCodePressed = util.BasicKeyHandler

   -- keep it around so we can reopen easily
   dpanel:SetDeleteOnClose(false)
   self.Panel = dpanel

   local dbut = vgui.Create("DButton", dpanel)
   local bw, bh = 100, 25
   dbut:SetSize(bw, bh)
   dbut:SetPos(w - bw - margin, h - bh - margin/2)
   dbut:SetText(T("close"))
   dbut.DoClick = function() dpanel:Close() end

   local dsave = vgui.Create("DButton", dpanel)
   dsave:SetSize(bw,bh)
   dsave:SetPos(margin, h - bh - margin/2)
   dsave:SetText(T("report_save"))
   dsave:SetTooltip(T("report_save_tip"))
   dsave:SetConsoleCommand("ttt_save_events")

   local dtabsheet = vgui.Create("DPropertySheet", dpanel)
   dtabsheet:SetPos(margin, margin + 15)
   dtabsheet:SetSize(w - margin*2, h - margin*3 - bh)
   local padding = dtabsheet:GetPadding()

   --DDD Achievements tab
   local dddAchievementsTab = createAchievementsTab(dtabSheet)

   -- Highlight tab
   local dtabhilite = vgui.Create("DPanel", dtabsheet)
   dtabhilite:SetPaintBackground(false)
   dtabhilite:StretchToParent(padding,padding,padding,padding)
   self:BuildHilitePanel(dtabhilite)

   dtabsheet:AddSheet(T("report_tab_hilite"), dtabhilite, "icon16/star.png", false, false, T("report_tab_hilite_tip"))

   -- Event log tab
   local dtabevents = vgui.Create("DPanel", dtabsheet)
--   dtab1:SetSize(650, 450)
   dtabevents:StretchToParent(padding, padding, padding, padding)
   self:BuildEventLogPanel(dtabevents)

   dtabsheet:AddSheet(T("report_tab_events"), dtabevents, "icon16/application_view_detail.png", false, false, T("report_tab_events_tip"))

   -- Score tab
   local dtabscores = vgui.Create("DPanel", dtabsheet)
   dtabscores:SetPaintBackground(false)
   dtabscores:StretchToParent(padding, padding, padding, padding)
   self:BuildScorePanel(dtabscores)

   dtabsheet:AddSheet(T("report_tab_scores"), dtabscores, "icon16/user.png", false, false, T("report_tab_scores_tip"))

   dpanel:MakePopup()

   -- makepopup grabs keyboard, whereas we only need mouse
   dpanel:SetKeyboardInputEnabled(false)
  end
end

--[[
hook.Add("Initialize", "DDDAchievementsTabConstructor", function()
  if DDD.Config.showAchievementPanel then
    setupAchievementsTab
  end
end)
]]
