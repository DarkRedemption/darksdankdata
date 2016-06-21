DDD = {}
DDD.CurrentRound = {}
DDD.Database = {}
DDD.Database.Tables = {}
DDD.Gui = {}
DDD.Gui.Achievements = {}
DDD.Gui.Rank = {}
DDD.Gui.Stats = {}
DDD.Misc = {}
DDD.version = "v0.1.0-RC2"

if SERVER then
  local roles = {
    Innocent = 0,
    Traitor = 1,
    Detective = 2
  }
  DDD.Database.Roles = roles
  
  --AddDir("materials/ddd/icons")
  AddCSLuaFile("ddd/main/misc/sh_inheritsfrom.lua")
  AddCSLuaFile("ddd/main/gui/cl_shared.lua")
  AddCSLuaFile("ddd/main/gui/cl_mainpanel.lua")
  AddCSLuaFile("ddd/main/gui/cl_overview.lua")
  AddCSLuaFile("ddd/main/gui/cl_traitor.lua")
  AddCSLuaFile("ddd/main/gui/cl_innocent.lua")
  AddCSLuaFile("ddd/main/gui/cl_detective.lua")
  AddCSLuaFile("ddd/main/gui/rank/cl_totalkills.lua")
  AddCSLuaFile("ddd/main/gui/rank/cl_enemykd.lua")
  AddCSLuaFile("ddd/main/cl_command.lua")
  AddCSLuaFile("ddd/main/misc/sh_delayedtimer.lua")
  resource.AddFile("materials/ddd/icons/t.png")
  resource.AddFile("materials/ddd/icons/d.png")
  resource.AddFile("materials/ddd/icons/i.png")
  include("ddd/main/misc/sh_inheritsfrom.lua")
  include("ddd/main/misc/sv_enums.lua")
  include("ddd/main/misc/sv_logging.lua")
  include("ddd/main/overrides/sv_corpse.lua")
  include("ddd/main/database/sv_sqlitedb.lua")
  include("ddd/main/config/sv_config.lua")
  include("ddd/main/gui/sv_overview.lua")
  include("ddd/main/sv_currentround.lua") 
  include("ddd/test/sv_testinit.lua")
end

if CLIENT then
  include("ddd/main/misc/sh_inheritsfrom.lua")
  include("ddd/main/misc/sh_delayedtimer.lua")
  DDD.Misc.createDelayedTimer("DDDCommandPSA", 15, 3600, 0, function()
    local red = Color(255, 0, 0, 255)
    local yellow = Color(255, 255, 0, 255)
    chat.AddText(red, "This server is running Dark's Dank Data " .. DDD.version .. ".")
    chat.AddText(red, "Type ", yellow, "!dank", red, " to see your stats.")
  end)
end

include("ddd/main/gui/cl_shared.lua")
include("ddd/main/gui/cl_mainpanel.lua")
include("ddd/main/gui/cl_overview.lua")
include("ddd/main/gui/cl_traitor.lua")
include("ddd/main/gui/cl_innocent.lua")
include("ddd/main/gui/cl_detective.lua")
include("ddd/main/gui/rank/cl_totalkills.lua")
include("ddd/main/gui/rank/cl_enemykd.lua")
include("ddd/main/cl_command.lua")