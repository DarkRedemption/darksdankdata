-- TODO: Maybe implement it in the below manner instead.
-- Don't know enough about Lua to determine which would be better yet.
-- http://lua-users.org/wiki/SimpleTuples

local Tuple2 = {}

function Tuple2:new (item1, item2)
    local newTuple = {}
    setmetatable(newTuple, self)
    self.__index = self
    --Using Scala's tuple standards
    newTuple._1 = item1
    newTuple._2 = item2
    return newTuple
end

DDD.Misc.Tuple2 = Tuple2
