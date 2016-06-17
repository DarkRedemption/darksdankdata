local rankTable = {}
rankTable.__index = rankTable

local function getEnemyKdRank()

end

local function getEnemyKillRank()
  
end

function rankTable:update()
  
end

function rankTable:new()
  local newTable = {}
  setmetatable(newTable, self)
  return newTable
end