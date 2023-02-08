local menu_ref = gui.Reference("Misc", "General", "Extra")
local radar_check = gui.Checkbox(menu_ref, "check_radar", "Engine Radar", false)
radar_check:SetDescription("Spot enemys on radar.")

local function Call_Radar()
  if radar_check:GetValue() then
    for index, Player in pairs(entities.FindByClass("CCSPlayer")) do
      Player:SetProp("m_bSpotted", 1)
    end
  else
    for index, Player in pairs(entities.FindByClass("CCSPlayer")) do
      Player:SetProp("m_bSpotted", 0)
    end
  end
end

callbacks.Register("Draw", Call_Radar)