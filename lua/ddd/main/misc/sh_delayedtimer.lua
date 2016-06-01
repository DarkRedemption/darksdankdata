function DDD.Misc.createDelayedTimer(timerName, initialDelay, repeatTime, timesToRepeat, func)
  timer.Simple(initialDelay, function()
      func()
      timer.Create(timerName, repeatTime, timesToRepeat, func)
    end
    )
end