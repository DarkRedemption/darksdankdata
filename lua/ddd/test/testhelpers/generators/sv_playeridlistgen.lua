function DDDTest.Helpers.Generators.makePlayerIdList(tables, minSize, maxSize)
  local list = {}
  local size = 0
  
  if (!maxSize) then
    size = minSize
  else
    size = math.random(minSize, maxSize)
  end
  
  for i = 1, size do
    local player = GUnit.Generators.FakePlayer:new()
    local playerId = tables.PlayerId:addPlayer(player)
    player.tableId = playerId --Not normally part of the player class, but easier than seperating it.
    table.insert(list, player)
  end
  
  return list
end