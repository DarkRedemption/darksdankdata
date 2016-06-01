local ShopItemGen = {}
ShopItemGen.__index = ShopItemGen

function ShopItemGen:GetName()
  return self.name
end

function ShopItemGen:new()
  local newItem = {}
  setmetatable(newItem, self)
  
  local isString = math.random(0, 1)
  if isString then
    newItem.name = GUnit.Generators.StringGen.generateAlphaNum()
  else
    newItem.name = math.random(1, 10)
  end
  
  return newItem
end

DDDTest.Helpers.Generators.ShopItemGen = ShopItemGen