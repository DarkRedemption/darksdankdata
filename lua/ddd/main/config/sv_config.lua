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
  "weapon_tttbase",
  "weapon_ttt_unarmed",
  "weapon_ttt_wtester",
  "weapon_ttt_decoy",
  "weapon_ttt_beacon",
  "weapon_ttt_health_station",
  "weapon_ttt_smokegrenade",
  "weapon_ttt_radio",
  "weapon_ttt_binoculars",
  "weapon_tttbasegrenade",
  "weapon_ttt_defuser",
  "weapon_ttt_cse",
  "weapon_zm_carry",

  --These items have been known to be re-enabled in mods,
  --and are placed here for convenience.
  "weapon_fists",
  "weapon_medkit",
  "weapon_flechettegun"
}

--[[
A list of weapons whose ClassName/filename differs from the entity
that deals the damage. Consider things like C4, which has the ClassName
weapon_ttt_c4, but it is deployed, a new entity is created called ttt_c4.
This deployed entity is the one that does the damage.
Since DDD autodetects weapons by ClassName, this list is to
convert items that it detects to their damage-dealing equivalent.
]]
DDD.Config.DeployedWeaponTranslation = {
  weapon_ttt_c4 = "ttt_c4"
}
