local optionTest = GUnit.Test:new("option")
local Option = DDD.Misc.Option

local function getSomeSpec()
  local some = Option:Some("x")
  GUnit.assert(some:get()):shouldEqual("x")
end

local function getNoneSpec()
  GUnit.pending()
end

local function equalityFunctionSpec()
  local optionOneTable = getmetatable(Option:Some("x"))
  local optionTwoTable = getmetatable(Option:Some("x"))
  GUnit.assert(optionOneTable.__eq):shouldEqual(optionTwoTable.__eq)
end

local function metaTableSpec()
  local optionOneTable = getmetatable(Option:Some("x"))
  local optionTwoTable = getmetatable(Option:Some("x"))
  GUnit.assert(optionOneTable):shouldEqual(optionTwoTable)
end

local function someEqualitySpec()
  GUnit.assert(Option:Some("x")):shouldEqual(Option:Some("x"))
end

local function noneEqualitySpec()
  GUnit.assert(Option:None()):shouldEqual(Option:None())
end

local function someGetOrElseSpec()
  local some = Option:Some("x")
  local f = function() return "y" end
  GUnit.assert(some:getOrElse(f)):shouldEqual("x")
end

local function noneGetOrElseSpec()
  local none = Option:None()
  local f = function() return "y" end
  GUnit.assert(none:getOrElse(f)):shouldEqual("y")
end

local function someMapSpec()
  local some = Option:Some("x")
  local f = function(x) return x .. "y" end
  GUnit.assert(some:map(f)):shouldEqual(Option:Some("xy"))
end

local function noneMapSpec()
  local none = Option:None()
  local f = function(x) return x .. "y" end
  GUnit.assert(none:map(f)):shouldEqual(Option:None())
end

local function flatMapSpec()
  local some = Option:Some("x")
  local f = function(x) return Option:Some(x .. "y") end
  local result = some:flatMap(f)
  print(result:get())
  GUnit.assert(result):shouldEqual(Option:Some("xy"))
end

optionTest:addSpec("succeed when getting a Some", getSomeSpec)
optionTest:addSpec("fail when getting a None", getNoneSpec)
optionTest:addSpec("have equivalent equality functions", equalityFunctionSpec)
optionTest:addSpec("have equivalent metatables", metaTableSpec)
optionTest:addSpec("equal another Some with the same internal value", someEqualitySpec)
optionTest:addSpec("equal another None", noneEqualitySpec)
optionTest:addSpec("Not return the orElse value if Some", someGetOrElseSpec)
optionTest:addSpec("return the orElse value if None", noneGetOrElseSpec)
optionTest:addSpec("map over a some", someMapSpec)
optionTest:addSpec("still just be none if mapped over a none", noneMapSpec)
optionTest:addSpec("collapse another option into one with a flatmap", flatMapSpec)
