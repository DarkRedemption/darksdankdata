DDD = {}
DDD.CurrentRound = {}
DDD.Database = {}
DDD.Database.Tables = {}
DDD.Gui = {}
DDD.Misc = {}

if SERVER then
  local roles = { 
    Traitor = 0,
    Innocent = 1,
    Detective = 2
  }
  DDD.Database.Roles = roles
  
  AddCSLuaFile("misc/sh_inheritsfrom.lua")
  AddCSLuaFile("gui/cl_shared.lua")
  AddCSLuaFile("gui/cl_mainpanel.lua")
  AddCSLuaFile("gui/cl_overview.lua")
  AddCSLuaFile("gui/cl_traitor.lua")
  AddCSLuaFile("gui/cl_innocent.lua")
  AddCSLuaFile("gui/cl_detective.lua")
  AddCSLuaFile("main/cl_command.lua")
  resource.AddFile("materials/ddd/icons/t.png")
  resource.AddFile("materials/ddd/icons/d.png")
  resource.AddFile("materials/ddd/icons/i.png")
  include("misc/sh_inheritsfrom.lua")
  include("misc/sv_enums.lua")
  include("misc/sv_tuple2.lua")
  include("misc/sv_logging.lua")
  include("database/sv_sqlitedb.lua")
  include("config/sv_config.lua")
  include("gui/sv_overview.lua")
  include("main/sv_currentround.lua")
  
  include("test/sv_testinit.lua")
end

if CLIENT then
  include("misc/sh_inheritsfrom.lua")
end

include("gui/cl_shared.lua")
include("gui/cl_mainpanel.lua")
include("gui/cl_overview.lua")
include("gui/cl_traitor.lua")
include("gui/cl_innocent.lua")
include("gui/cl_detective.lua")
include("main/cl_command.lua")