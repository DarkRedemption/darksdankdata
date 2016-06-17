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
