concommand.Add("ddd_recalculate", function(ply, cmd, args, argStr)
  if (ply == NULL) then
    MsgC(lightBlue, "Purging potential data anomalies and recalculating aggregate data. This may take a long time.\n")
    DDD.Database.Tables.AggregateStats:cleanupAll()
    --DDD.Database.Tables.AggregateStats:recalculate()
    MsgC(lightBlue, "Aggregate Stats Recalculated. Now recalculated Aggregate Weapon Stats.\n")
    --DDD.Database.Tables.AggregateWeaponStats:recalculate()
    MsgC(lightBlue, "All aggregate data recalculated.\n")
  else
    MsgC(red, "This command may only be run through the server console.\n")
  end
end)

--[[
concommand.Add("ddd_cleanup", function(ply, cmd, args, argStr)
  if (ply == NULL) then
    MsgC(lightBlue, "Purging null values from the kill table.\n")
    DDD.Database.Tables.AggregateStats:cleanupKills()
    MsgC(lightBlue, "Cleanup complete.\n")
  else
    MsgC(red, "This command may only be run through the server console.\n")
  end
end)
]]
