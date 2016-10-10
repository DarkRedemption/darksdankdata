concommand.Add("ddd_recalculate", function(ply, cmd, args, argStr)
  if (ply == NULL) then
    MsgC(lightBlue, "Recalculating aggregate data. This may take a long time.\n")
    DDD.Database.Tables.AggregateStats:recalculate()
    MsgC(lightBlue, "Aggregate Stats Recalculated. Now recalculated Aggregate Weapon Stats.\n")
    DDD.Database.Tables.AggregateWeaponStats:recalculate()
    MsgC(lightBlue, "All aggregate data recalculated.\n")
  else
    MsgC(red, "This command may only be run through the server console.\n")
  end
end)
