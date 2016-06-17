-- Damage Enums, reversed to take their numerical value and return a string.
-- May be used in the future, as I was intending to track damage types for damage and kill statistics.
-- However, it has limited use and seems computationally expensive to do every time someone is attacked or killed.
-- https://wiki.garrysmod.com/page/Enums/DMG
DDD.Misc.Enums = {}

local damageTypeEnum = {}
damageTypeEnum[DMG_GENERIC] = "DMG_GENERIC"
damageTypeEnum[DMG_CRUSH] = "DMG_CRUSH"
damageTypeEnum[DMG_BULLET] = "DMG_BULLET"
damageTypeEnum[DMG_SLASH] = "DMG_SLASH"
damageTypeEnum[DMG_BURN] = "DMG_BURN"
damageTypeEnum[DMG_FALL] = "DMG_FALL"
damageTypeEnum[DMG_CLUB] = "DMG_CLUB"
damageTypeEnum[DMG_SHOCK] = "DMG_SHOCK"
damageTypeEnum[DMG_SONIC] = "DMG_SONIC"
damageTypeEnum[DMG_ENERGYBEAM] = "DMG_ENERGYBEAM"
damageTypeEnum[DMG_NEVERGIB] = "DMG_NEVERGIB"
damageTypeEnum[DMG_ALWAYSGIB] = "DMG_ALWAYSGIB"
damageTypeEnum[DMG_DROWN] = "DMG_DROWN"
damageTypeEnum[DMG_PARALYZE] = "DMG_PARALYZE"
damageTypeEnum[DMG_NERVEGAS] = "DMG_NERVEGAS"
damageTypeEnum[DMG_POISON] = "DMG_POISON"
damageTypeEnum[DMG_ACID] = "DMG_ACID"
damageTypeEnum[DMG_AIRBOAT] = "DMG_AIRBOAT"
damageTypeEnum[DMG_BLAST_SURFACE] = "DMG_BLAST_SURFACE"
damageTypeEnum[DMG_BUCKSHOT] = "DMG_BUCKSHOT"
damageTypeEnum[DMG_DIRECT] = "DMG_DIRECT"
damageTypeEnum[DMG_DISSOLVE] = "DMG_DISSOLVE"
damageTypeEnum[DMG_DROWNRECOVER] = "DMG_DROWNRECOVER"
damageTypeEnum[DMG_PHYSGUN] = "DMG_PHYSGUN"
damageTypeEnum[DMG_PLASMA] = "DMG_PLASMA"
damageTypeEnum[DMG_PREVENT_PHYSICS_FORCE] = "DMG_PREVENT_PHYSICS_FORCE"
damageTypeEnum[DMG_RADIATION] = "DMG_RADIATION"
damageTypeEnum[DMG_REMOVENORAGDOLL] = "DMG_REMOVENORAGDOLL"
damageTypeEnum[DMG_SLOWBURN] = "DMG_SLOWBURN"

DDD.Misc.Enums.DamageTypeEnum = damageTypeEnum