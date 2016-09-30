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

local function determineFireWeapon(damageInfo, victim)
  local inflictor = damageInfo:GetInflictor()
  if (victim && victim.ignite_info) then
    --[[Flaregun is the only known weapon that sets ignite info in Vanilla.]]
    return "weapon_ttt_flaregun" 
  elseif inflictor:GetClass() == "env_fire" then
    return "ttt_firegrenade_proj"
  else
    return "fire" --Unknown fire-based weapon
  end
  
end

local function determineWeaponFromDamageInfo(damageInfo, victim)
  local inflictor = damageInfo:GetInflictor()
  if inflictor:IsWeapon() or inflictor.Projectile or (inflictor:GetClass() == "ttt_c4") then
		return inflictor:GetClass()
  elseif damageInfo:IsDamageType(DMG_BLAST) then
    --TODO: Check if incendiary grenade blasts return explosion or their class with this code
    return "explosion"
  elseif damageInfo:IsDamageType(DMG_DIRECT) or damageInfo:IsDamageType(DMG_BURN) then
    return determineFireWeapon(damageInfo, victim)
  elseif damageInfo:IsDamageType(DMG_CRUSH) then
		return "falling_or_prop"
  elseif damageInfo:IsDamageType(DMG_SLASH) then
		return "edged_weapon"
  elseif damageInfo:IsDamageType(DMG_CLUB) then
		return "blunt_weapon"
  elseif damageInfo:IsDamageType(DMG_SHOCK) then
		return "electricity"
	elseif damageInfo:IsDamageType(DMG_ENERGYBEAM) then
		return "laser"
  elseif damageInfo:IsDamageType(DMG_SONIC) then
		return "weapon_ttt_teleport" --Unless there's something else that can telefrag...
  elseif damageInfo:IsDamageType(DMG_PHYSGUN) then
		return "physgun"
  elseif inflictor:IsPlayer() then
		local wep = inflictor:GetActiveWeapon()
    if not IsValid(wep) then
			return IsValid(inflictor.dying_wep) and inflictor.dying_wep
    else
      return wep:GetClass()
    end
  end
end

function DDD.determineWeapon(damageInfo, victim)
	if IsValid(damageInfo:GetInflictor()) then
    --return damageInfo:GetInflictor():GetClass()
		return determineWeaponFromDamageInfo(damageInfo, victim)
	else
    return "UnknownWeapon"
  end
end

DDD.Database.Tables.WeaponId = weaponIdTable
weaponIdTable:create()