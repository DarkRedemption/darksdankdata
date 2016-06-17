function DDDTest.Helpers.getRandomPair(array)
  GUnit.assert(#array):greaterThan(1)
  if (#array == 2) then return array[1], array[2] end
  
  local arrayId = math.random(1, #array)
  local function getSecondId()
    local secondArrayId = math.random(1, #array)
    if (arrayId == secondArrayId) then
      return getSecondId()
    else
      return secondArrayId
    end
  end
  
  return array[arrayId], array[getSecondId()]
end