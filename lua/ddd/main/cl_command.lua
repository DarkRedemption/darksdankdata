function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

local function checkForDDDCommand(ply, text)
  if (text:len() < 5) then return false end
  if (string.starts(string.lower(text), "!dank")) then
    if (LocalPlayer() == ply) then
      DDD.createMainFrame()
    end
    return true
  end
  return false
end

hook.Add("OnPlayerChat", "DDDChatCommand", function(ply, text, team, isDead)
    if (checkForDDDCommand(ply, text)) then
      return true
    end
  end)

concommand.Add("ddd", DDD.createMainFrame)