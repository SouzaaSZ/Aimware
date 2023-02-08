local menu_ref = gui.Reference("Misc", "General", "Extra")
local disconnect_check = gui.Checkbox(menu_ref, "check_disconnect", "Auto-Disconnect Match", false)
disconnect_check:SetDescription("Automatically disconnect in end matches.")

local function Call_Disconnect(event)
  if disconnect_check:GetValue() then
    if event:GetName() == "cs_win_panel_match" then
      client.Command("disconnect", true)
    end
  end
end
client.AllowListener("cs_win_panel_match")
callbacks.Register("FireGameEvent", Call_Disconnect)
