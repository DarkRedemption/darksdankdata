hook.Add("Initialize", "DDDHealthStationOverrides", function()
    local healthStationBase = weapons.GetStored("weapon_ttt_health_station")
    
    local oldHealthDrop = healthStationBase.HealthDrop
    
    function healthStationBase:HealthDrop()
      oldHealthDrop(self)
      
      local owner = self.Owner
      if !IsValid(owner) then return end
      
      local stations = ents.FindByClass("ttt_health_station")
      for key, station in pairs(stations) do
        local stationOwner = station:GetPlacer()
        if IsValid(stationOwner) and stationOwner == owner and station.DDDOwnerId == nil then
          station.DDDOwnerId = DDD.Database.Tables.PlayerId:getPlayerId(owner)
        end
      end
    end
  end)