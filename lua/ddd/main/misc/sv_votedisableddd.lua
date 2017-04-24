local lastCalled = 0

local cooldown = 1200

local function dddNotLoaded()
  if !DDD then
    ply:PrintMessage(HUD_PRINTTALK, "DDD not found. This vote would do nothing.")
    return true
  end
    return false
end

local function inCooldown(ply)
  local cooldownTimePassed = os.time() - lastCalled
  local cooldownTimeRemaining = cooldown - cooldownTimePassed
    if (cooldownTimePassed >= cooldown) then
      return false
    else
      ply:PrintMessage(HUD_PRINTTALK, "A vote to disable DDD has been called recently. Please wait.")
    end
  return true
end

local function voteDisableDDDDone(t, rounds, calling_ply)
  local results = t.results
  local winner
  local winnernum = 0

  for id, numvotes in pairs( results ) do
  	if numvotes > winnernum then
  		winner = id
  		winnernum = numvotes
  	end
  end

  local ratioNeeded = 0.7
  local minVotes = 4
  --local ratioNeeded = GetConVarNumber( "ulx_disabledddSuccessratio" )
  --local minVotes = GetConVarNumber( "ulx_disabledddMinvotes" )

  local str

  local unsuccessful = (winner ~= 1) or not winner or winnernum < minVotes or winnernum / t.voters < ratioNeeded
  if unsuccessful then
  		str = "Vote results: Vote was unsuccessful."
  else -- It's the server console, let's roll with it
  		str = "Vote results: Vote passed. Dark's Dank Data will be disabled starting next round."
  end

  ULib.tsay( _, str ) -- TODO, color?
  ulx.logString( str )
  if game.IsDedicated() then Msg( str .. "\n" ) end

  if unsuccessful then
    return
  elseif rounds == 0 then
    DDD.CurrentRound.disabledRoundsRemaining = -1
  else
    DDD.CurrentRound.disabledRoundsRemaining = rounds
  end

  return
end

local function voteDisableDDD( calling_ply, ... )
  if dddNotLoaded() or inCooldown(calling_ply) then return end
  lastCalled = os.time()

  local argv = { ... }
  local rounds = tonumber(argv[1])

  if rounds < 0 then
    ULib.tsayError( calling_ply, "Rounds cannot be negative.", true )
    return
	elseif ulx.voteInProgress then
		ULib.tsayError( calling_ply, "There is already a vote in progress. Please wait for the current one to end.", true )
		return
  elseif DDD.CurrentRound.blacklisted then
    ULib.tsayError( calling_ply, "This map is blacklisted from stat tracking, so it's already disabled!", true )
    return
  elseif (rounds == nil) then
    ULib.tsayError( calling_ply, "You have not specified the number of rounds to disable DDD, or entered an invalid value.", true )
	  return
  end

  local voteMessage = "Disable Dark's Dank Data for "
  if rounds == 0 then
    voteMessage = voteMessage .. "the rest of the map?"
  elseif rounds == 1 then
    voteMessage = voteMessage .. "1 round?"
  else
    voteMessage = voteMessage .. argv[1] .. " rounds?"
  end

	ulx.doVote( voteMessage, { "Yes", "No" }, voteDisableDDDDone, _, _, _, rounds, calling_ply )
	ulx.fancyLogAdmin( calling_ply, "#A started a vote to disable DDD for #s rounds.", argv[ 1 ] )

end

local function addDisableVote()
  local votedisable = ulx.command( "Voting", "ulx votedisableddd", voteDisableDDD, "!votedisableddd" )
  votedisable:addParam{ type=ULib.cmds.NumArg, min=0, default=1, hint="rounds; 0 = until map change" }
  votedisable:defaultAccess( ULib.ACCESS_ALL )
  votedisable:help( "Disable Dark's Dank Data tracking for x rounds, starting next round. 0 disables DDD for the rest of the map." )
end

if (ulx and ULib) then
  addDisableVote()
end

hook.Add("Initialize", "DDDAddDisableVoteIfUlx", addDisableVote)
