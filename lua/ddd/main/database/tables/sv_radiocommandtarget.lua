local tables = DDD.Database.Tables
local roles = DDD.Database.Roles

local columns = { id = "INTEGER PRIMARY KEY",
                  command_used_id = "INTEGER NOT NULL",
                  target_id = "INTEGER NOT NULL"
                }
                
--This table is the only time I can see statuses being used, so statuses will not have their own table.

local foreignKeyTable = DDD.Database.ForeignKeyTable:new()
foreignKeyTable:addConstraint("command_used_id", tables.RadioCommandUsed, "id")
foreignKeyTable:addConstraint("target_id", tables.PlayerId, "id")

local radioCommandTargetTable = DDD.SqlTable:new("ddd_radio_command_target", columns, foreignKeyTable)

local function getTargetSteamId(target)
  if (target:GetClass() == "prop_ragdoll") then
    return CORPSE.GetPlayerSteamID(target, "")
  else
    return target:SteamID()
  end
end

--[[
Adds a row indicating that a radio command was used on a target.
PARAM target:Player or Ragdoll - The target, who is either a player or a corpse.
PARAM commandUsedId:Integer - The id from the RadioCommandUsed table that was targeted.
]]
function radioCommandTargetTable:addCommandTarget(target, commandUsedId)
  local foreignPlayerTable = self:getForeignTableByColumn("target_id")
  local targetSteamId = getTargetSteamId(target)
  local targetId = self:getForeignTableByColumn("target_id"):getPlayerIdBySteamId(targetSteamId)
  
  local insertTable = {
    command_used_id = commandUsedId,
    target_id = targetId
  }
  return self:insertTable(insertTable)
end

DDD.Database.Tables.RadioCommandTarget = radioCommandTargetTable
radioCommandTargetTable:create()