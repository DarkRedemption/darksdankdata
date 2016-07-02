hook.Add("Initialize", "DDDC4Overrides", function()
    local c4Base = weapons.GetStored("weapon_ttt_c4")
    if !c4Base then return end
    
    c4Base.DDDOldPrimaryAttack = c4Base.PrimaryAttack
    c4Base.DDDOldSecondaryAttack = c4Base.SecondaryAttack
    
    function c4Base:PrimaryAttack()
      self:DDDOldPrimaryAttack()
      if self.Planted then
        hook.Call("TTT_PlayerPlantedC4", GAMEMODE, self.Owner, 1)
      end
    end
    
    function c4Base:SecondaryAttack()
      self:DDDOldSecondaryAttack()
      if self.Planted then
        hook.Call("TTT_PlayerPlantedC4", GAMEMODE, self.Owner, 2)
      end
    end
    
    --From https://github.com/Tommy228/TTTDamagelogs.
    --Implemented here to avoid incompatibility it due to its popularity,
    --and since this implementation gives me everything I need regarding c4 disarms.
    
    local function SendDisarmResult(ply, idx, result, bomb)
      hook.Call("TTTC4Disarm", GAMEMODE, ply, result, bomb)
      umsg.Start("c4_disarm_result", ply)
      umsg.Short(idx)
      umsg.Bool(result)
      umsg.End()
    end
    
    local function ReceiveC4Disarm(ply, cmd, args)
      if (not IsValid(ply)) or (not ply:IsTerror()) or (not ply:Alive()) or #args != 2 then return end
      local idx = tonumber(args[1])
      local wire = tonumber(args[2])
      if not idx or not wire then return end
      local bomb = ents.GetByIndex(idx)
      if IsValid(bomb) and bomb:GetArmed() then
        if bomb:GetPos():Distance(ply:GetPos()) > 256 then
          return
        elseif bomb.SafeWires[wire] or ply:IsTraitor() or ply == bomb:GetOwner() then
          LANG.Msg(ply, "c4_disarmed")
          bomb:Disarm(ply)
          SendDisarmResult(ply, idx, true, bomb)
        else
          SendDisarmResult(ply, idx, false, bomb)
          bomb:FailedDisarm(ply)
        end
      end
    end
  concommand.Add("ttt_c4_disarm", ReceiveC4Disarm)

  end
)