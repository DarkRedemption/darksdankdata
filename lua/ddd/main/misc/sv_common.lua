local roleIdToRole = {} -- The reverse of the main roles table, this is roleValue -> roleName instead.
roleIdToRole[0] = "innocent"
roleIdToRole[1] = "traitor"
roleIdToRole[2] = "detective"

--[[
Checks to see if something exists in an array.
]]

local function arrayContains(arr, v)
  for key, value in pairs(arr) do
    if (value == v) then
      return true
    end
  end

  return false
end

DDD.roleIdToRole = roleIdToRole
DDD.arrayContains = arrayContains
