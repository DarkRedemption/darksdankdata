local LogLevel = {}
LogLevel.__index = LogLevel

function LogLevel:new(name, priority, color)
  local newLogLevel = {}
  setmetatable(newLogLevel, self)
  newLogLevel.name = name
  newLogLevel.priority = priority
  newLogLevel.color = color
  return newLogLevel
end

local red = Color(255, 0, 0, 255)
local lightBlue = Color(0, 255, 255, 255)
local white = Color(255, 255, 255, 255)
local yellow = Color(255, 255, 0, 255)
local noColor = Color(0, 0, 0, 0)

local Logging = {}
Logging.LogLevels = {}

Logging.LogLevels.Disabled = LogLevel:new("Disabled", 0, noColor)
Logging.LogLevels.Error = LogLevel:new("Error", 1, red)
Logging.LogLevels.Warning = LogLevel:new("Warning", 2, yellow)
Logging.LogLevels.Debug = LogLevel:new("Debug", 3, lightBlue) 
Logging.LogLevels.Info = LogLevel:new("Info", 4, white)

Logging.logLevel = Logging.LogLevels.Warning --Default
Logging.enabled = true

function Logging.getTimestamp()
  return os.date("%x %I:%M:%S %p", os.time())
end

function Logging:log(logLevel, str)
  if (self.logLevel.priority >= logLevel.priority && Logging.enabled) then
    MsgC(logLevel.color, "(" .. self.getTimestamp() .. ") DDD[" .. logLevel.name .. "]: " .. str .. "\n")
  end
end

function Logging.logInfo(str)
  Logging:log(Logging.LogLevels.Info, str)
end

function Logging.logDebug(str)
  Logging:log(Logging.LogLevels.Debug, str)
end

function Logging.logWarning(str)
  Logging:log(Logging.LogLevels.Warning, str)
end

function Logging.logError(str)
  Logging:log(Logging.LogLevels.Error, str)
end

function Logging:disable()
  self.enabled = false
end

function Logging:enable()
  self.enabled = true
end

DDD.Logging = Logging
DDD.Logging.LogLevel = LogLevel