DDDTest = {}
DDDTest.Helpers = {}

include("testhelpers/sv_testsqltable.lua")
include("testhelpers/sv_tablesetup.lua")
  
local function loadTests()
  --TODO: See if the includes can be made to work here.
  GUnit.load()
end

hook.Add("GUnitReady", "DDDLoadTests", function()
    loadTests()
end)

if GUnit then
  loadTests()
end