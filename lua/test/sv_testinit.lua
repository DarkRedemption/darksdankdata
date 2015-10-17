DDDTest = {}
DDDTest.Helpers = {}

local function loadTests()
  include("testhelpers/sv_testsqltable.lua")
  include("testhelpers/sv_tablesetup.lua")
  GUnit.load()
end

hook.Add("GUnitReady", "DDDLoadTests", function()
    loadTests()
end)

if GUnit then
  loadTests()
end