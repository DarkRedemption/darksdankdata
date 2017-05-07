DDD = {}
DDD.Config = {}
DDD.CurrentRound = {}
DDD.Database = {}
DDD.Database.Tables = {}
DDD.Gui = {}
DDD.Gui.Achievements = {}
DDD.Gui.Rank = {}
DDD.Gui.PlayerStats = {}
DDD.Gui.WeaponStats = {}
DDD.Rank = {}
DDD.Misc = {}
DDD.version = "v0.2.0-SNAPSHOT"

local roles = {
  Innocent = 0,
  Traitor = 1,
  Detective = 2
}
DDD.Database.Roles = roles

local function serverOnInit()
  include("ddd/main/overrides/sv_corpse.lua")
  include("ddd/main/overrides/sv_health_station.lua")
  include("ddd/main/overrides/sv_c4.lua")
  include("ddd/main/database/sv_sqlitedb.lua")
  include("ddd/main/hooks/sv_hooks.lua")
  include("ddd/main/hooks/sv_combathooks.lua")
  include("ddd/main/database/sv_recalculate.lua")

  include("ddd/main/gui/rank/sv_ranktable.lua")
  include("ddd/test/sv_testinit.lua")
end

if SERVER then
  AddCSLuaFile("ddd/main/config/sh_config.lua")
  AddCSLuaFile("ddd/main/misc/sh_common.lua")
  AddCSLuaFile("ddd/main/misc/sh_option.lua")

  AddCSLuaFile("ddd/main/gui/cl_shared.lua")
  AddCSLuaFile("ddd/main/gui/cl_mainpanel.lua")
  AddCSLuaFile("ddd/main/gui/rank/cl_overall.lua")
  AddCSLuaFile("ddd/main/gui/rank/cl_detectiverank.lua")
  AddCSLuaFile("ddd/main/gui/rank/cl_innocentrank.lua")
  AddCSLuaFile("ddd/main/gui/rank/cl_traitorrank.lua")
  AddCSLuaFile("ddd/main/gui/playerstats/cl_overview.lua")
  AddCSLuaFile("ddd/main/gui/playerstats/cl_traitor.lua")
  AddCSLuaFile("ddd/main/gui/playerstats/cl_innocent.lua")
  AddCSLuaFile("ddd/main/gui/playerstats/cl_detective.lua")
  AddCSLuaFile("ddd/main/gui/weaponstats/cl_weapons.lua")
  AddCSLuaFile("ddd/main/gui/achievements/cl_achievements.lua")

  AddCSLuaFile("ddd/main/cl_command.lua")
  AddCSLuaFile("ddd/main/misc/sh_delayedtimer.lua")
  AddCSLuaFile("ddd/main/misc/sv_votedisableddd.lua")

  resource.AddFile("materials/ddd/icons/t.png")
  resource.AddFile("materials/ddd/icons/d.png")
  resource.AddFile("materials/ddd/icons/i.png")

  include("ddd/main/misc/sv_logging.lua")
  include("ddd/main/config/sv_config.lua")
  include("ddd/main/misc/sh_common.lua")
  include("ddd/main/misc/sv_common.lua")
  include('ddd/main/misc/sh_option.lua')
  include("ddd/main/misc/sv_enums.lua")

  include("ddd/main/hooks/sv_overridehooks.lua")
  include("ddd/main/gui/playerstats/sv_getstats.lua")
  include("ddd/main/gui/weaponstats/sv_getweaponstats.lua")
  include("ddd/main/sv_active.lua")

  include("ddd/main/misc/sv_votedisableddd.lua")

  --load files that MUST be loaded only at init-time
  hook.Add("Initialize", "DDDInitializeOnGamemodeLoad", serverOnInit)
end

if CLIENT then
  include("ddd/main/config/sh_config.lua")

  include("ddd/main/misc/sh_common.lua")
  include("ddd/main/misc/sh_delayedtimer.lua")

  include("ddd/main/gui/cl_shared.lua")
  include("ddd/main/gui/cl_mainpanel.lua")
  include("ddd/main/gui/playerstats/cl_overview.lua")
  include("ddd/main/gui/playerstats/cl_traitor.lua")
  include("ddd/main/gui/playerstats/cl_innocent.lua")
  include("ddd/main/gui/playerstats/cl_detective.lua")
  include("ddd/main/gui/weaponstats/cl_weapons.lua")
  include("ddd/main/gui/rank/cl_overall.lua")
  include("ddd/main/gui/rank/cl_detectiverank.lua")
  include("ddd/main/gui/rank/cl_innocentrank.lua")
  include("ddd/main/gui/rank/cl_traitorrank.lua")
  include("ddd/main/gui/achievements/cl_achievements.lua")

  include("ddd/main/misc/sv_votedisableddd.lua")

  local red = Color(255, 0, 0, 255)
  local yellow = Color(255, 255, 0, 255)

  DDD.Misc.createDelayedTimer("DDDCommandPSA", 15, 3600, 0, function()
    chat.AddText(red, "This server is running Dark's Dank Data " .. DDD.version .. ".")
    chat.AddText(red, "To see your rank, type ", yellow, "!dank")
  end)

  DDD.Misc.createDelayedTimer("DDDDisableCommandPSA", 25, 3600, 0, function()
    chat.AddText(red, "Want to disable Dark's Dank Data to mess around without ruining your stats?")
    chat.AddText(red, "Type ", yellow, "!votedisableddd <rounds>", red, " or use in console ", yellow, "ulx votedisableddd <rounds>" )
  end)
end

include("ddd/main/cl_command.lua")
