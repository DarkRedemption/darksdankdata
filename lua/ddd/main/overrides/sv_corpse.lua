hook.Add("Initialize", "DDDEditCorpseFunctions", function()
  function CORPSE.SetPlayerSteamID(rag, ply)
     -- don't have datatable strings, so use a dt entity for common case of
     -- still-connected player, and if the player is gone, fall back to nw string
     if (IsValid(ply)) then
        rag:SetNWString("steamid", ply:SteamID())
      end
    end
    
    function CORPSE.GetPlayerSteamID(rag, default)
      return rag:GetNWString("steamid", default)
    end
    
    local oldCorpseCreate = CORPSE.Create
    function CORPSE.Create(ply, attacker, dmginfo)
      local rag = oldCorpseCreate(ply, attacker, dmginfo)
      CORPSE.SetPlayerSteamID(rag, ply)
      return rag
    end
  end)