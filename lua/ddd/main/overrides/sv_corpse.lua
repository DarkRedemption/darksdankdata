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
    
    --Check for credits looted by deducing they have been looted after the search
    --without modifying the original function.
    local oldShowSearch = CORPSE.ShowSearch
    function CORPSE.ShowSearch(ply, rag, covert, long_range)
      if not IsValid(ply) or not IsValid(rag) then return end
      
      local credits = CORPSE.GetCredits(rag, 0)
      oldShowSearch(ply, rag, covert, long_range)
      
      if credits > 0 and CORPSE.GetCredits(rag, 0) == 0 then
        hook.Call("DDDCreditsLooted", GAMEMODE, ply, rag, credits)
      end
    end
    
  end)