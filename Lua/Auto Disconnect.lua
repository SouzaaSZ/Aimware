local menu_ref = gui.Reference("Miscellaneous", "Features")
local disconnect_check = gui.Checkbox(menu_ref, "check_disconnect", "Auto-Disconnect Match", false)
disconnect_check:SetDescription("Automatically disconnect at the end of matches.")

local disconnected = false

client.AllowListener("cs_win_panel_match")
client.AllowListener("round_announce_match_start")
client.AllowListener("game_newmap")

local function Call_Disconnect(event)
if not event then return end

local name = event:GetName()

if name == "round_announce_match_start" or name == "game_newmap" then
disconnected = false
return
end

if name == "cs_win_panel_match" and disconnect_check:GetValue() and not disconnected then
disconnected = true
client.Command("disconnect", true)
end
end

callbacks.Register("FireGameEvent", "Call_Disconnect", Call_Disconnect)
