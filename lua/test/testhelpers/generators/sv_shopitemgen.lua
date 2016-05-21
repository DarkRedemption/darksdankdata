local ShopItemGen = {}
ShopItemGen.__index = ShopItemGen

function ShopItemGen:GetName()
  return self.name
end

function ShopItemGen:new()
  local newItem = {}
  setmetatable(newItem, self)
  newItem.name = GUnit.Generators.StringGen.generateAlphaNum()
  return newItem
end

DDDTest.Helpers.Generators.ShopItemGen = ShopItemGen