local capitalRoles = {}
capitalRoles[0] = "Innocent"
capitalRoles[1] = "Traitor"
capitalRoles[2] = "Detective"
capitalRoles[3] = "Overall"

local map = DDD.map
local foreach = DDD.foreach

local function displayWeaponStats(list, aggregateWeaponStatsRow, weaponNameList, roleId)
  local function comparisonFunction(left, right)
    local r = DDD.Config.AggregateWeaponStatsTranslation[right] or right
    local l = DDD.Config.AggregateWeaponStatsTranslation[left] or left
    return r > l
  end

  local sortedWeaponList = table.Copy(weaponNameList)
  local roleName = DDD.roleIdToRole[roleId]
  local capitalRoleName = capitalRoles[roleId]
  table.sort(sortedWeaponList, comparisonFunction)

  local displayInfo = {
    kills = "Kills",
    deaths = "Deaths"
  }

  for index, itemName in ipairs(sortedWeaponList) do

    local adjustedItemName = DDD.Config.AggregateWeaponStatsTranslation[itemName] or itemName

    for infoColumnNameSegment, infoDisplay in pairs(displayInfo) do
      local columnNotFound = false
      local values = {}
      local display = adjustedItemName .. " " .. infoDisplay

      for opponentRoleId, opponentRoleName in pairs(DDD.roleIdToRole) do
        local columnName = itemName .. "_" .. roleName .. "_" .. opponentRoleName .. "_" .. infoColumnNameSegment

        if aggregateWeaponStatsRow[columnName] != nil then
          print("setting value for roleid " .. opponentRoleId)
          values[opponentRoleId] = aggregateWeaponStatsRow[columnName]
        else
          columnNotFound = true
        end

      end

      if !columnNotFound then
        list:AddLine(display, values[0] + values[1] + values[2], values[0], values[1], values[2])
      end

    end
  end
end


local function createWeaponsText(overviewPanel)
  local playerName = LocalPlayer():Nick()
  local steamId = LocalPlayer():SteamID()
  local string = "Weapon Stats for player " .. playerName .. " (Steam ID: " .. steamId .. ")"
  local label = vgui.Create( "DLabel", overviewPanel )
  label:SetColor(Color(255, 255, 255))
  label:SetText( string )
  label:SizeToContents()
  local newCenter = DDD.Gui.determineHorizontalCenter(label)
  label:CenterHorizontal()
  --print(newCenter)
  --label:SetPos(newCenter, 0)
end

local function createListView(overviewPanel)
  local list = vgui.Create("DListView", overviewPanel)
  list:SetPos(10, 15)
  list:SetSize(595, 355)
  list:SetMultiSelect(false)
  local nameColumn = list:AddColumn("Name")
  local overallColumn = list:AddColumn("Overall")
  local innoColumn = list:AddColumn("Vs Innocent")
  local traitorColumn = list:AddColumn("Vs Traitor")
  local detectiveColumn = list:AddColumn("Vs Detective")
  nameColumn:SetWidth(295)
  overallColumn:SetWidth(75)
  innoColumn:SetWidth(75)
  traitorColumn:SetWidth(75)
  detectiveColumn:SetWidth(75)
  return list
end

local function getRoleIcon(roleId)
  if (roleId == ROLE_INNOCENT) then
    return "materials/ddd/icons/i.png"
  elseif (roleId == ROLE_TRAITOR) then
    return "materials/ddd/icons/t.png"
  elseif (roleId == ROLE_DETECTIVE) then
    return "materials/ddd/icons/d.png"
  elseif (roleId == 3) then
    return "icon16/chart_bar.png"
  end
end

local function getRoleColor(roleId)
  if (roleId == ROLE_INNOCENT) then
    return Color(0, 255, 0)
  elseif (roleId == ROLE_TRAITOR) then
    return Color(255, 0, 0)
  elseif (roleId == ROLE_DETECTIVE) then
    return Color(0, 0, 255)
  elseif (roleId == 3) then
    return Color(0, 0, 0)
  end
end

local function makeRoleTab(mainPropertySheet, statsTable, weaponNameList, roleId)
    local weaponsPanel = vgui.Create( "DPanel", mainPropertySheet )
    weaponsPanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, getRoleColor(roleId)) end
    DDD.Gui.setSizeToParent(weaponsPanel)
    createWeaponsText(weaponsPanel)
    local list = createListView(weaponsPanel)
    mainPropertySheet:AddSheet(capitalRoles[roleId], weaponsPanel, getRoleIcon(roleId))
    displayWeaponStats(list, statsTable, weaponNameList, roleId)
end

function DDD.Gui.WeaponStats.createOverallWeaponsTab(mainPropertySheet, statsTable, weaponNameList)
  --makeRoleTab(mainPropertySheet, statsTable, weaponNameList, 3)
end

function DDD.Gui.WeaponStats.createInnocentWeaponsTab(mainPropertySheet, statsTable, weaponNameList)
  makeRoleTab(mainPropertySheet, statsTable, weaponNameList, ROLE_INNOCENT)
end

function DDD.Gui.WeaponStats.createTraitorWeaponsTab(mainPropertySheet, statsTable, weaponNameList)
  makeRoleTab(mainPropertySheet, statsTable, weaponNameList, ROLE_TRAITOR)
end

function DDD.Gui.WeaponStats.createDetectiveWeaponsTab(mainPropertySheet, statsTable, weaponNameList)
  makeRoleTab(mainPropertySheet, statsTable, weaponNameList, ROLE_DETECTIVE)
end
