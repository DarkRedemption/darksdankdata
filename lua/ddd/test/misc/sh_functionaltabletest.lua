local FunctionalTable = DDD.Misc.FunctionalTable
local tableTest = GUnit.Test:new("FunctionalTable")

local function lengthSpec()
  local t = FunctionalTable:new()
  local count = math.random(1, 100)
  GUnit.assert(t:length()):shouldEqual(0)

  for i = 1, count do
    t:insert(GUnit.Generators.StringGen.generateAlphaNum())
  end
  GUnit.assert(t:length()):shouldEqual(count)
end

local function equalitySpec()
  local t = FunctionalTable:new()
  local t2 = FunctionalTable:new()
  t:insert("x"):insert("y")
  t2:insert("x"):insert("y")
  GUnit.assert(t):shouldEqual(t2)
end

local function mapSpec()
  local t = FunctionalTable:new()
  t:insert("x"):insert("y")
  local newT = t:map(function(k, v) return v .. "a" end)
  GUnit.assert(newT:get(1)):shouldEqual("xa")
  GUnit.assert(newT:get(2)):shouldEqual("ya")
end

local function foreachSpec()
  GUnit.pending()
end

local function setSpec()
  local t = FunctionalTable:new()
  t:set(4, "x"):set("keystring", "y")
  GUnit.assert(t:get(4)):shouldEqual("x")
  GUnit.assert(t:get("keystring")):shouldEqual("y")
end

tableTest:addSpec("calculate the length of the table accurately", lengthSpec)
tableTest:addSpec("equal another table with the same values", equalitySpec)
tableTest:addSpec("map", mapSpec)
tableTest:addSpec("foreach", foreachSpec)
tableTest:addSpec("set keys manually", setSpec)
