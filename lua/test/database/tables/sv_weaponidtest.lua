local weaponIdTest = GUnit.Test:new("WeaponIdTable")
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
    GUnit.assert(id):shouldEqual(i)
    local selectedWeaponId = tables.WeaponId:getWeaponId(randomWeaponName)
    GUnit.assert(selectedWeaponId):shouldEqual(i)
  end
end

local function uniqueWeaponIdSpec()
  for i = 1, 100 do
    local randomWeaponName = GUnit.Generators.StringGen.generateAlphaNum()
    local id = tables.WeaponId:addWeapon(randomWeaponName)
    GUnit.assert(id):shouldEqual(i)
    local addAgainId = tables.WeaponId:addWeapon(randomWeaponName)
    GUnit.assert(addAgainId):shouldEqual(false)
  end
end

weaponIdTest:beforeEach(beforeEach)
weaponIdTest:afterEach(afterEach)

weaponIdTest:addSpec("add a weapon id and select it", addWeaponIdSpec)
weaponIdTest:addSpec("not let you add an existing weapon", uniqueWeaponIdSpec)
