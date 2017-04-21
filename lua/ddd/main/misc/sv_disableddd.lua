local function dddNotLoaded()
  if !DDD then
    ply:PrintMessage(HUD_PRINTTALK, "DDD not found. This vote would do nothing.")
    return true
  end
    return false
end

local function disableDDD(calling_ply, ...)
  if dddNotLoaded() then return end

  local args = { ... }
  local rounds = args[1]
  local announcementStr = "Dark's Dank Data has been manually disabled, starting next round, for "

  if rounds <= 0
    DDD.CurrentRound.disabledRoundsRemaining = -1
    announcementStr = announcementStr .. " the rest of the map."
  else
    DDD.CurrentRound.disabledRoundsRemaining = rounds
    announcementStr = announcementStr .. rounds .. " rounds."
  end

  ULib.tsay( _, announcementStr )
end

local function addDisableCommand()
  --TODO: Figure out correct category.
  if (ulx and ULib) then
    local votedisable = ulx.command( "Misc", "ulx disableddd", disableDDD, "!disableddd" )
    votedisable:addParam{ type=ULib.cmds.NumArg, min=0, default=1, hint="rounds; 0 = until map change" }
    votedisable:defaultAccess( ULib.ACCESS_ALL )
    votedisable:help( "Force disable Dark's Dank Data tracking for x rounds, starting next round. 0 disables DDD for the rest of the map." )
  end
end

--One command for reloading DDD through Lua autorefresh;
--The other for trying again if ULX loads after DDD
addDisableCommand()
hook.Add("Initialize", "DDDAddDisableVoteIfUlx", addDisableCommand)
