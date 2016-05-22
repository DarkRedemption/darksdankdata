local columns = {
  id = "INTEGER PRIMARY KEY",
  weapon_class = "STRING UNIQUE NOT NULL"
}

local weaponIdTable = DDD.SqlTable:new("ddd_weapon_id", columns)

function weaponIdTable:addWeapon(weaponClass)
  local query = {
    weapon_class = weaponClass
    }
  return self:insertTable(query)
end

function weaponIdTable:getWeaponId(weaponClass)
  local query = "SELECT id FROM " .. self.tableName .. " WHERE weapon_class == '" .. weaponClass .. "'"
  local result = self:query("getWeaponId", query, 1, "id")
  return tonumber(result)
end

function weaponIdTable:getOrAddWeaponId(weaponClass)
  local id = self:getWeaponId(weaponClass)
  if (id < 1) then
    return self:addWeapon(weaponClass)
  else
    return id
  end
end

local function determineWeaponFromDamageInfo(damageInfo)
  local inflictor = damageInfo:GetInflictor()
  if inflictor:IsWeapon() or inflictor.Projectile or (inflictor:GetClass() == "ttt_c4") then
		return inflictor:GetClass()
  elseif damageInfo:IsDamageType(DMG_BLAST) then
    return "an explosion"
  elseif damageInfo:IsDamageType(DMG_DIRECT) or damageInfo:IsDamageType(DMG_BURN) then
		return "fire"
  elseif damageInfo:IsDamageType(DMG_CRUSH) then
		return "falling or prop damage"
  elseif damageInfo:IsDamageType(DMG_SLASH) then
		return "a sharp object"
  elseif damageInfo:IsDamageType(DMG_CLUB) then
		return "clubbed to death"
  elseif damageInfo:IsDamageType(DMG_SHOCK) then
		return "an electric shock"
	elseif damageInfo:IsDamageType(DMG_ENERGYBEAM) then
		return "a laser"
  elseif damageInfo:IsDamageType(DMG_SONIC) then
		return "a teleport collision"
  elseif damageInfo:IsDamageType(DMG_PHYSGUN) then
		return "a massive bulk"
  elseif inflictor:IsPlayer() then
		weapon = inflictor:GetActiveWeapon()
    if not IsValid(weapon) then
			return IsValid(inflictor.dying_wep) and inflictor.dying_wep
    else
      return weapon:GetClass()
    end
  end
end

local function determineTTTWeapon(weaponClass)
  if (weaponClass == "weapon_zm_revolver") then
    return "Deagle"
  elseif (weaponClass == "weapon_ttt_glock") then
    return "Glock"
  else
    return weaponClass
  end
end

function DDD.determineWeapon(damageInfo)
	if IsValid(damageInfo:GetInflictor()) then
		return determineWeaponFromDamageInfo(damageInfo)
	else
    return "UnknownWeapon"
  end
end

DDD.Database.Tables.WeaponId = weaponIdTable
weaponIdTable:create()