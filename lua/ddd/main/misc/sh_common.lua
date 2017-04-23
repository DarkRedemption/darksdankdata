local roleIdToRole = {} -- The reverse of the main roles table, this is roleValue -> roleName instead.
roleIdToRole[0] = "innocent"
roleIdToRole[1] = "traitor"
roleIdToRole[2] = "detective"

DDD.roleIdToRole = roleIdToRole
