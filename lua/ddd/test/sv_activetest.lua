local activeTest = GUnit.Test:new("StatsActive")
local currentRoundBackup = {}
local currentConfigBackup = {}

local function beforeEach()
  currentRoundBackup = table.Copy(DDD.CurrentRound)
  currentConfigBackup = table.Copy(DDD.Config)
  
  --Since we are testing one failure at a time, make the default be enabled() returns true
  DDD.CurrentRound.isActive = true
  DDD.CurrentRound.blacklisted = false
  DDD.CurrentRound.disabledByPop = false
end

local function afterEach()
  DDD.CurrentRound = table.Copy(currentRoundBackup)
  DDD.Config = table.Copy(currentConfigBackup)
end

local function isActiveSpec()
  GUnit.assert(DDD:enabled()):isTrue()
end

local function popTooLowSpec()
  DDD.CurrentRound.disabledByPop = true
  GUnit.assert(DDD:enabled()):isFalse()
end

local function blacklistSpec()
  DDD.CurrentRound.blacklisted = true
  GUnit.assert(DDD:enabled()):isFalse()
end

local function roundNotStartedSpec()
  DDD.CurrentRound.isActive = false
  GUnit.assert(DDD:enabled()):isFalse()
end

local function blacklistFunctionSpec()
  local blacklistedMap = GUnit.Generators.StringGen.generateAlphaNum()
  DDD.Config.MapBlacklist = {blacklistedMap}
  
  for i = 1, 100 do
    local randomMap = GUnit.Generators.StringGen.generateAlphaNum()
    GUnit.assert(DDD.CurrentRound.isMapBlacklisted(randomMap)):isFalse()
  end
  
  GUnit.assert(DDD.CurrentRound.isMapBlacklisted(blacklistedMap)):isTrue()
end

local function popTooLowFunctionSpec()  
  for i = 1, 100 do
    local minPop = math.random(4, 32)
    local currentPopTooLow = math.random(0, minPop - 1)
    local currentPopHighEnough = math.random(minPop, 99)
    DDD.Config.MinPlayers = minPop
    GUnit.assert(DDD.CurrentRound.isPopTooLow(currentPopTooLow)):isTrue()
    GUnit.assert(DDD.CurrentRound.isPopTooLow(currentPopHighEnough)):isFalse()
  end
end


activeTest:beforeEach(beforeEach)
activeTest:afterEach(afterEach)

activeTest:addSpec("return true if everything is in order", isActiveSpec)
activeTest:addSpec("return false if the population is less than what is defined in the config setting", popTooLowSpec)
activeTest:addSpec("return false if the map is blacklisted", blacklistSpec)
activeTest:addSpec("return false if the round hasn't started", roundNotStartedSpec)
activeTest:addSpec("return true that the map is blacklisted if set as such in the config file", blacklistFunctionSpec)
activeTest:addSpec("return true that population is too low if set as such in the config file", popTooLowFunctionSpec)