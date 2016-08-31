DDD = {}
DDD.Config = {}
DDD.CurrentRound = {}
DDD.Database = {}
DDD.Database.Tables = {}
DDD.Gui = {}
DDD.Gui.Achievements = {}
DDD.Gui.Rank = {}
DDD.Gui.Stats = {}
DDD.Rank = {}
DDD.Misc = {}
DDD.version = "v0.2.0-SNAPSHOT"

if SERVER then
  local roles = {
    Innocent = 0,
    Traitor = 1,
    Detective = 2
  }
  DDD.Database.Roles = roles

  AddCSLuaFile("ddd/main/misc/sh_inheritsfrom.lua")
  
  AddCSLuaFile("ddd/main/gui/cl_shared.lua")
  AddCSLuaFile("ddd/main/gui/cl_mainpanel.lua")
  AddCSLuaFile("ddd/main/gui/rank/cl_overall.lua")
  AddCSLuaFile("ddd/main/gui/rank/cl_detectiverank.lua")
  AddCSLuaFile("ddd/main/gui/rank/cl_innocentrank.lua")
  AddCSLuaFile("ddd/main/gui/rank/cl_traitorrank.lua")
  AddCSLuaFile("ddd/main/gui/stats/cl_overview.lua")
  AddCSLuaFile("ddd/main/gui/stats/cl_traitor.lua")
  AddCSLuaFile("ddd/main/gui/stats/cl_innocent.lua")
  AddCSLuaFile("ddd/main/gui/stats/cl_detective.lua")

  AddCSLuaFile("ddd/main/cl_command.lua")
  AddCSLuaFile("ddd/main/misc/sh_delayedtimer.lua")
  
  resource.AddFile("materials/ddd/icons/t.png")
  resource.AddFile("materials/ddd/icons/d.png")
  resource.AddFile("materials/ddd/icons/i.png")
  
  include("ddd/main/misc/sh_inheritsfrom.lua")
  include("ddd/main/misc/sv_enums.lua")
  include("ddd/main/misc/sv_logging.lua")
  include("ddd/main/overrides/sv_corpse.lua")
  --include("ddd/main/overrides/sv_c4.lua")
  include("ddd/main/database/sv_sqlitedb.lua")
  include("ddd/main/hooks/sv_hooks.lua")
  include("ddd/main/hooks/sv_combathooks.lua")
  include("ddd/main/hooks/sv_overridehooks.lua")
  include("ddd/main/config/sv_config.lua")
  include("ddd/main/gui/rank/sv_ranktable.lua")
  include("ddd/main/gui/stats/sv_overview.lua")
  include("ddd/main/sv_active.lua")
  include("ddd/test/sv_testinit.lua")
end

if CLIENT then
  include("ddd/main/misc/sh_inheritsfrom.lua")
  include("ddd/main/misc/sh_delayedtimer.lua")
  
  include("ddd/main/gui/cl_shared.lua")
  include("ddd/main/gui/cl_mainpanel.lua")
  include("ddd/main/gui/stats/cl_overview.lua")
  include("ddd/main/gui/stats/cl_traitor.lua")
  include("ddd/main/gui/stats/cl_innocent.lua")
  include("ddd/main/gui/stats/cl_detective.lua")
  include("ddd/main/gui/rank/cl_overall.lua")
  include("ddd/main/gui/rank/cl_detectiverank.lua")
  include("ddd/main/gui/rank/cl_innocentrank.lua")
  include("ddd/main/gui/rank/cl_traitorrank.lua")

  DDD.Misc.createDelayedTimer("DDDCommandPSA", 15, 3600, 0, function()
    local red = Color(255, 0, 0, 255)
    local yellow = Color(255, 255, 0, 255)
    chat.AddText(red, "This server is running Dark's Dank Data " .. DDD.version .. ".")
    chat.AddText(red, "DDD is currently in beta. Stats will be cleared when a stable version is released.")
    chat.AddText(red, "To see your rank, type ", yellow, "!dank")
  end)
end

include("ddd/main/cl_command.lua")