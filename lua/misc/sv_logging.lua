local Tuple2 = DDD.Misc.Tuple2

local Logging = {}
Logging.LogLevels = {}

Logging.LogLevels.Info = Tuple2:new(1, "Info")
Logging.LogLevels.Debug = Tuple2:new(2, "Debug") 
Logging.LogLevels.Warning = Tuple2:new(3, "Warning")
Logging.LogLevels.Error = Tuple2:new(4, "Error")
Logging.LogLevels.Disabled = Tuple2:new(5, "")

Logging.LogLevel = Logging.LogLevels.Warning --Default
Logging.enabled = true

function Logging:log(logLevel, str)
  if (self.LogLevel._1 <= logLevel._1 && Logging.enabled) then
    print("(" .. os.time() .. ") DDD[" .. logLevel._2 .. "]: " .. str)
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