--[[
Sets the LogLevel. In production, you generally shouldn't need more detail above Warning unless things are breaking.
But if they are, set it to Debug or Info to get more details to send to me. If you want less, set it to Error.
--]]
DDD.Logging.LogLevel = DDD.Logging.LogLevels.Warning

--[[
The minimum number of players before stats are tracked.
Default is 8 as that is when a Detective spawns and it becomes a "real" TTT game.
]]
DDD.Config.MinPlayers = 8

--[[
Got some fun but very unbalanced maps that could ruin someone's stats?
Blacklist them here and stats will never be tracked on them.
]]
DDD.Config.MapBlacklist = {"ttt_crazy_cubes_b4", "ttt_thismapsucksdontpickit_b0"}