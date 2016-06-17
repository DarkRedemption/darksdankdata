---TTTPlayerRadioCommand (ply, cmd_name, cmd_target)
local tables = DDD.Database.Tables
local roles = DDD.Database.Roles

local columns = { id = "INTEGER PRIMARY KEY",
                  round_id = "INTEGER NOT NULL",
                  player_id = "INTEGER NOT NULL",
                  command_id = "INTEGER NOT NULL",
                  round_time = "REAL NOT NULL",
                  target_type = "INTEGER NOT NULL" --1 = player/identified corpse, 2 = disguised, 3 = unidentified corpse, 4 = nobody 
                }
                
local foreignKeyTable = DDD.Database.ForeignKeyTable:new()
foreignKeyTable:addConstraint("round_id", tables.RoundId, "id")
foreignKeyTable:addConstraint("player_id", tables.PlayerId, "id")
foreignKeyTable:addConstraint("command_id", tables.RadioCommand, "id")

local radioCommandUsedTable = DDD.SqlTable:new("ddd_radio_command_used", columns, foreignKeyTable)

--[[
Find the target type, then convert it into an integer
to allow for faster parsing by the database and easier sorting.
PARAM target:Player OR Ragdoll OR String - The target.
]]
local function getTargetType(target)
  if target == "quick_disg" then
    return 2
  elseif target == "quick_corpse" then
    return 3
  elseif target == "quick_nobody" then
    return 4
  end
  return 1
end

--[[
Adds a row containing a timestamp of when a radio command was used on a target.
PARAM player:Player - The player who made the radio callout.
PARAM command:String - The name of the ttt_radio command, such as "imwith" or "traitor".
PARAM target:Player OR Ragdoll OR String - The target of the callout.
]]
function radioCommandUsedTable:addCommandUsed(player, command, target)
  local foreignPlayerTable = self:getForeignTableByColumn("player_id")
  
  local insertTable = {
    round_id = self:getForeignTableByColumn("round_id"):getCurrentRoundId(),
    player_id = foreignPlayerTable:getPlayerId(player),
    command_id = self:getForeignTableByColumn("command_id"):getCommandId(command),
    round_time = DDD.CurrentRound:getCurrentRoundTime(),
    target_type = getTargetType(target)
  }
  return self:insertTable(insertTable)
end

radioCommandUsedTable:create()
DDD.Database.Tables.RadioCommandUsed = radioCommandUsedTable