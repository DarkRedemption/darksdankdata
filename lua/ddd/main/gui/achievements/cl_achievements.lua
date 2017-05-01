local function buildDDDAchievementPanel(self)
   local mainPanel = CLSCORE.Panel
   local mainPanelChildren = mainPanel:GetChildren()
   PrintTable(mainPanelChildren)
   --[[
   local w, h = dpanel:GetSize()

   local title = wintitle[WIN_INNOCENT]
   local endtime = self.StartTime
   for i=#self.Events, 1, -1 do
      local e = self.Events[i]
      if e.id == EVENT_FINISH then
         endtime = e.t

         -- when win is due to timeout, innocents win
         local wintype = e.win
         if wintype == WIN_TIMELIMIT then wintype = WIN_INNOCENT end

         title = wintitle[wintype]
         break
      end
   end

   local roundtime = endtime - self.StartTime

   local numply = table.Count(self.Players)
   local numtr = table.Count(self.TraitorIDs)


   local bg = vgui.Create("ColoredBox", dpanel)
   bg:SetColor(Color(50, 50, 50, 255))
   bg:SetSize(w,h)
   bg:SetPos(0,0)

   local winlbl = vgui.Create("DLabel", dpanel)
   winlbl:SetFont("WinHuge")
   winlbl:SetText( T(title.txt) )
   winlbl:SetTextColor(COLOR_WHITE)
   winlbl:SizeToContents()
   local xwin = (w - winlbl:GetWide())/2
   local ywin = 30
   winlbl:SetPos(xwin, ywin)

   bg.PaintOver = function()
                     draw.RoundedBox(8, xwin - 15, ywin - 5, winlbl:GetWide() + 30, winlbl:GetTall() + 10, title.c)
                  end

   local ysubwin = ywin + winlbl:GetTall()
   local partlbl = vgui.Create("DLabel", dpanel)

   local plytxt = PT(numtr == 1 and "hilite_players2" or "hilite_players1",
                     {numplayers = numply, numtraitors = numtr})

   partlbl:SetText(plytxt)
   partlbl:SizeToContents()
   partlbl:SetPos(xwin, ysubwin + 8)

   local timelbl = vgui.Create("DLabel", dpanel)
   timelbl:SetText(PT("hilite_duration", {time= util.SimpleTime(roundtime, "%02i:%02i")}))
   timelbl:SizeToContents()
   timelbl:SetPos(xwin + winlbl:GetWide() - timelbl:GetWide(), ysubwin + 8)

   -- Awards
   local wa = math.Round(w * 0.9)
   local ha = h - ysubwin - 40
   local xa = (w - wa) / 2
   local ya = h - ha

   local awardp = vgui.Create("DPanel", dpanel)
   awardp:SetSize(wa, ha)
   awardp:SetPos(xa, ya)
   awardp:SetPaintBackground(false)

   -- Before we pick awards, seed the rng in a way that is the same on all
   -- clients. We can do this using the round start time. To make it a bit more
   -- random, involve the round's duration too.
   math.randomseed(self.StartTime + endtime)

   -- Attempt to generate every award, then sort the succeeded ones based on
   -- priority/interestingness
   local award_choices = {}
   for k, afn in pairs(AWARDS) do
      local a = afn(self.Events, self.Scores, self.Players, self.TraitorIDs, self.DetectiveIDs)
      if ValidAward(a) then
         table.insert(award_choices, a)
      end
   end

   local num_choices = table.Count(award_choices)
   local max_awards = 5

   -- sort descending by priority
   table.SortByMember(award_choices, "priority")

   -- put the N most interesting awards in the menu
   for i=1,max_awards do
      local a = award_choices[i]
      if a then
         self:AddAward((i - 1) * 42, wa, a, awardp)
      end
   end
]]
end


local function setupAchievementsTab()
  local oldShowPanel = CLSCORE.ShowPanel

  --Going to need to detect Detailed Events and make a compatibility file for it.
  --Alternatively, just instruct users to disable the CLPanel override and let DDD check
  function CLSCORE:ShowPanel()
    oldShowPanel(self)
    if DDD:enabled() then
      buildDDDAchievementPanel(self)
    end
  end

end


hook.Add("Initialize", "DDDAchievementsTabConstructor", function()
  if DDD.Config.showAchievementPanel then
    setupAchievementsTab()
  end
end)
