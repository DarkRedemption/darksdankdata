--[[
Sets the LogLevel. In production, you generally shouldn't need more detail above Warning unless things are breaking.
But if they are, set it to Debug or Info to get more details to send to me. If you want less, set it to Error.
--]]
DDD.Logging.LogLevel = DDD.Logging.LogLevels.Warning

--[[
The minimum number of players before stats are tracked.
Default is 8 as that is when a Detective spawns and it becomes a "real" TTT game.
]]
DDD.Config.MinPlayers = 2

--[[
Got some fun but very unbalanced maps that could ruin someone's stats?
Blacklist them here and stats will never be tracked on them.
]]
DDD.Config.MapBlacklist = {"ttt_crazy_cubes_b4", "ttt_thismapsucksdontpickit_b0"}

--[[
This is a list of items that are considered weapons, but cannot be used
to actually kill people. This list prevents them from being added to the
aggregate weapon stats table out of efficiency.
]]
DDD.Config.AggregateWeaponStatsFilter = {
  "weapon_base",
  "weapon_ttt_base",
  "weapon_ttt_unarmed",
  "weapon_ttt_wtester",
  "weapon_ttt_decoy",
  "weapon_ttt_beacon",
  "weapon_ttt_health_station",
  "weapon_ttt_smokegrenade",
  "weapon_ttt_radio",
  "weapon_ttt_binoculars",
  "weapon_ttt_basegrenade",
  "weapon_ttt_defuser",
  "weapon_ttt_cse",
  "weapon_zm_carry",

  --These items have been known to be re-enabled in mods,
  --and are placed here for convenience.
  "weapon_fists",
  "weapon_medkit"
}

--[[
A dictionary of weaponClass -> in-game name.
]]
DDD.Config.AggregateWeaponStatsTranslation = {
  weapon_zm_shotgun = "Shotgun"
}

--[[
A dictionary of entityName -> display name.
Used to make the personal stat display not show the entity name of the item,
but the name that everyone knows the item by.
Vanilla servers will not need to add to this list,
but servers that have additions to their T or D shops will.
]]
DDD.Config.ShopItemNames = {
  weapon_ttt_flaregun = "Flare Gun",
  weapon_ttt_knife = "Knife",
  weapon_ttt_teleport = "Teleporter",
  weapon_ttt_radio = "Radio",
  weapon_ttt_push = "Newton Launcher",
  weapon_ttt_sipistol = "Silent Pistol",
  weapon_ttt_decoy = "Decoy",
  weapon_ttt_phammer = "Poltergeist",
  weapon_ttt_c4 = "C4",
  weapon_ttt_cse = "Visualizer",
  weapon_ttt_defuser = "Defuser",
  weapon_ttt_binoculars = "Binoculars",
  weapon_ttt_stungun = "UMP",
  weapon_ttt_health_station = "Health Station"
}

--Tables don't like mixing numbers and strings
DDD.Config.ShopItemNames["1"] = "Armor"
DDD.Config.ShopItemNames["2"] = "Radar"
DDD.Config.ShopItemNames["4"] = "Disguiser"
