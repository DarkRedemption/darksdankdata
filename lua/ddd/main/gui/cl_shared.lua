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
