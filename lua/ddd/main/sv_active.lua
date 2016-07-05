local blacklisted = false
local disabledByPop = false

function DDD:isActive()
end

function DDD:updateActive()
  self:checkMapBlastlist()
  self:checkPop()
  return DDD.CurrentRound.isActive()
end

function DDD:checkMapBlacklist()
end

function DDD:checkPop()
end