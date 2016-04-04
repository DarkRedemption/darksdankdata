local weaponIdTest = GUnit.Test:new("Weapon ID Table")

local tables = {}

local function beforeEach()
  DDD.Logging:disable()
  tables = DDDTest.Helpers.makeTables()
end

local function afterEach()
  DDD.Logging:enable()
  DDDTest.Helpers.dropAll(tables)
end

local function addWeaponIdSpec()
  for i = 1, 100 do
    local randomWeaponName = GUnit.Generators.StringGen.generateAlphaNum()
    local id = tables.WeaponId:addWeapon(randomWeaponName)
    assert(id == i)
    local selectedWeaponId = tables.WeaponId:getWeaponId(randomWeaponName)
    assert(selectedWeaponId == i, "Expected " .. selectedWeaponId .. ", got " .. i)
  end
end

local function uniqueWeaponIdSpec()
  for i = 1, 100 do
    local randomWeaponName = GUnit.Generators.StringGen.generateAlphaNum()
    local id = tables.WeaponId:addWeapon(randomWeaponName)
    assert(id == i)
    local readdId = tables.WeaponId:addWeapon(randomWeaponName)
    assert(readdId == false, "Expected 0, got " .. tostring(readdId))
  end
end

weaponIdTest:beforeEach(beforeEach)
weaponIdTest:afterEach(afterEach)

weaponIdTest:addSpec("add a weapon id and select it", addWeaponIdSpec)
weaponIdTest:addSpec("not let you add an existing weapon", uniqueWeaponIdSpec)
