--[[
Holds all known TTT radio commands and assigns them a numeric identifier.
This table might be a bit overkill, but if there's another table I want to use radio commands for,
better safe than sorry.
]]

local columns = {
  id = "INTEGER PRIMARY KEY",
  command_name = "TEXT UNIQUE NOT NULL"
}

local radioCommandTable = DDD.SqlTable:new("ddd_radio_command", columns)

function radioCommandTable:addCommand(command)
  local row = {
    command_name = command
    }
  return self:insertTable(row)
end

function radioCommandTable:getCommandId(command)
  local query = "SELECT id FROM " .. self.tableName .. " WHERE command_name = '" .. command .. "'"
  local result = self:query("getCommandId", query, 1, "id")
  return tonumber(result)
end

function radioCommandTable:getOrAddCommand(command)
  local id = self:getCommandId(command)
  
  if (id > 0) then 
    return id
  else 
    return self:addCommand(command)
  end
end

DDD.Database.Tables.RadioCommand = radioCommandTable
radioCommandTable:create()