local capitalRoles = {}
capitalRoles[0] = "Innocent"
capitalRoles[1] = "Traitor"
capitalRoles[2] = "Detective"

local map = DDD.map

function DDD.Gui.setSizeToParent(panel)
  local parent = panel:GetParent()
  panel:SetSize(parent:GetSize())
end

local function getCenteredDimension(parentDimension, childDimension)
  local difference = parentDimension - childDimension
  if difference < 0 then return 0 else return (difference / 2) end
end

function DDD.Gui.determineHorizontalCenter(panel)
  local parent = panel:GetParent()
  local parentWidth, parentHeight = parent:GetSize()
  local panelWidth, panelHeight = panel:GetSize()
  local newWidth = getCenteredDimension(parentWidth, panelWidth)
  return newWidth
end

function DDD.Gui.formatKD(kd)
  return string.format("%.3f", kd)
end

function DDD.Gui.formatPercentage(percentage)
  local percentAsDecimal = string.format("%.5f", percentage)
  return tostring(percentAsDecimal * 100.0 .. "%")
end

local function makeAdjustedWeaponNameList(weaponNameList)
  local newList = map(weaponNameList, function(index, weaponName)
    return index, (DDD.Config.AggregateWeaponStatsTranslation[itemName] or itemName)
  end)

  table.sort(newList)

  return newList
end

function DDD.Gui.displayWeaponStats(list, table, weaponNameList, roleId)
  local capitalRoleName = capitalRoles[roleId]
  local roleName = DDD.roleIdToRole[roleId]
  local displayInfo = {
    kills = "Kills",
    deaths = "Deaths"
  }

  for index, itemName in pairs(weaponNameList) do

    local adjustedItemName = DDD.Config.AggregateWeaponStatsTranslation[itemName] or itemName

    for opponentRoleId, opponentRoleName in pairs(DDD.roleIdToRole) do

      for infoColumnNameSegment, infoDisplay in pairs(displayInfo) do

        local display = adjustedItemName .. " " .. capitalRoles[opponentRoleId] .. " " .. infoDisplay
        local columnName = itemName .. "_" .. roleName .. "_" .. opponentRoleName .. "_" .. infoColumnNameSegment
        if table[columnName] then
          list:AddLine(display, table[columnName])
        end

      end

    end

  end
end
