--Load order is important. Be careful changing these!
include("sv_table.lua")
include("sv_sqltable.lua")
include("tables/sv_playerid.lua")
include("tables/sv_maps.lua")
include("tables/sv_rounds.lua")
include("tables/sv_weapon.lua")
include("tables/sv_playerkill.lua")
include("tables/sv_healing.lua")
include("tables/sv_roundrole.lua")
include("tables/sv_shopitem.lua")
include("tables/sv_purchase.lua")
include("tables/sv_entity.lua")
include("tables/sv_dna.lua")
include("tables/sv_roundresult.lua")
include("tables/sv_damagetype.lua")
include("queries/sv_queries.lua")
include("queries/sv_playerstats.lua")
include("tables/sv_worldkill.lua")
include("sv_hooks.lua")

if SERVER then  
  DDD.addPlayerIdHook()
end