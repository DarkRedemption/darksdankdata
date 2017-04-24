--Hooks created by overriding default TTT behavior

--From https://facepunch.com/showthread.php?t=1296788.
hook.Add("Initialize", "DDDEditWeaponBase", function()
	local weaponBase = weapons.GetStored("weapon_tttbase")
	if !weaponBase then return end
	weaponBase.DDDOldPrimaryAttack = weaponBase.PrimaryAttack
	function weaponBase:PrimaryAttack(worldsnd)
		self:DDDOldPrimaryAttack(worldsnd)
    hook.Call("TTT_PlayerShotWeapon", GAMEMODE, self.Owner, 1)
	end
end)

hook.Add("Initialize", "DDDEditKnifeBase", function()
	local weaponBase = weapons.GetStored("weapon_ttt_knife")
	if !weaponBase then return end

	weaponBase.DDDOldPrimaryAttack = weaponBase.PrimaryAttack
  weaponBase.DDDOldSecondaryAttack = weaponBase.SecondaryAttack

	function weaponBase:PrimaryAttack()
		self:DDDOldPrimaryAttack()
    hook.Call("TTT_PlayerShotWeapon", GAMEMODE, self.Owner, 1)
	end

  function weaponBase:SecondaryAttack()
		self:DDDOldSecondaryAttack()
    hook.Call("TTT_PlayerShotWeapon", GAMEMODE, self.Owner, 2)
	end
end)

hook.Add("Initialize", "DDDEditGrenadeBase", function()
	local weaponBase = weapons.GetStored("weapon_tttbasegrenade")
	if !weaponBase then return end
	weaponBase.DDDOldPrimaryAttack = weaponBase.PrimaryAttack
	function weaponBase:PrimaryAttack()
		self:DDDOldPrimaryAttack()
    hook.Call("TTT_PlayerShotWeapon", GAMEMODE, self.Owner, 1)
	end
end)


--TODO: Change this so it sends out the hook only if a location is a valid mark (won't cause failed teleports).
--[[
hook.Add("Initialize", "DDDEditTeleporterBase", function()
	local weaponBase = weapons.GetStored("weapon_ttt_teleport")
	if !weaponBase then return end
	weaponBase.DDDOldPrimaryAttack = weaponBase.PrimaryAttack
	function weaponBase:PrimaryAttack()
		self:DDDOldPrimaryAttack()
    hook.Call("TTT_PlayerShotWeapon", GAMEMODE, self.Owner, 1)
	end
end)
]]
