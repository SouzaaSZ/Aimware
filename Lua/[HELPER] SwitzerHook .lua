----------------------------------------------------------- Auto Updater -----------------------------------------------------------------------
local script_url = "https://raw.githubusercontent.com/SouzaaSZ/Aimware/refs/heads/main/Lua/%5BHELPER%5D%20SwitzerHook%20.lua"

local remote_code = http.Get(script_url)
if remote_code and remote_code ~= "" then
    local current_file = GetScriptName()
    local local_code = file.Read(current_file)
    
    -- Remove "\r" (Carriage Return) to ensure a perfect string comparison between Windows and GitHub
    local safe_remote = remote_code:gsub("\r", "")
    local safe_local = local_code and local_code:gsub("\r", "") or ""
    
    -- If the GitHub code is different from the currently running code:
    if safe_local ~= safe_remote then
        file.Write(current_file, remote_code)
        print("[SwitzerHook] Auto-update detected and downloaded! Please Unload and Load the script to apply changes.")
        return -- Stops execution of the old version immediately
    end
end
------------------------------------------------------------------------------------------------------------------------------------------------

local weapons_default = {"asniper", "hpistol", "lmg", "pistol", "rifle", "scout", "smg", "shotgun", "sniper", "zeus", "shared"}
local menu_vars, switzer_vars, switzer_ui, fonts = {}, {}, {}, {}
local xview, yview, zview = client.GetConVar("viewmodel_offset_x"), client.GetConVar("viewmodel_offset_y"), client.GetConVar("viewmodel_offset_z")
local user_id = cheat.GetUserID()

local gui_get, gui_set = gui.GetValue, gui.SetValue
fonts.Water = draw.CreateFont("Calibri Bold", 12.5)

----------------------------------------------------------- FFI & Setup -----------------------------------------------------------------------
ffi.cdef[[
    void keybd_event(unsigned char bVk, unsigned char bScan, unsigned long dwFlags, unsigned long dwExtraInfo);
    void mouse_event(unsigned long dwFlags, unsigned long dx, unsigned long dy, unsigned long dwData, unsigned long dwExtraInfo);
    void* GetForegroundWindow();
    void* FindWindowA(const char* lpClassName, const char* lpWindowName);
]]

local pressed_key = nil

-- Optimized FFI Table Mapping for Mouse Buttons (Cleaner and faster than multiple if/else)
local MOUSE_FLAGS = {
    [1] = {down = 0x0002, up = 0x0004, data = 0}, -- Mouse 1
    [2] = {down = 0x0008, up = 0x0010, data = 0}, -- Mouse 2
    [4] = {down = 0x0020, up = 0x0040, data = 0}, -- Mouse 3
    [5] = {down = 0x0080, up = 0x0100, data = 1}, -- Mouse 4
    [6] = {down = 0x0080, up = 0x0100, data = 2}  -- Mouse 5
}

-- Function to translate the menu key code and simulate the physical click in Windows via FFI
local function SimulateKey(key, is_pressed)
    local mouse_btn = MOUSE_FLAGS[key]
    if mouse_btn then
        ffi.C.mouse_event(is_pressed and mouse_btn.down or mouse_btn.up, 0, 0, mouse_btn.data, 0)
    else
        ffi.C.keybd_event(key, 0, is_pressed and 0 or 0x0002, 0) 
    end
end

-- Safety function that checks if the active window in Windows is Counter-Strike 2
local function IsGameInForeground()
    local active_window = ffi.C.GetForegroundWindow()
    local cs2_window = ffi.C.FindWindowA(nil, "Counter-Strike 2")
    return active_window ~= nil and cs2_window ~= nil and active_window == cs2_window
end

----------------------------------------------------------- Smart Cache System -----------------------------------------------------------------------
local CACHE = {}

-- Highly optimized function to update GUI/ConVars ONLY if their values actually changed (Saves massive FPS)
local function UpdateStateIfChanged(cache_key, current_value, update_func)
    if CACHE[cache_key] ~= current_value then
        update_func(current_value)
        CACHE[cache_key] = current_value
    end
end

----------------------------------------------------------- Switzer Ids ---------------------------------------------------------------
local user_data = {
    [354692] = { name = "Souza", register = "3/04/2021", id = "1", build = "(Beta)", title = "Administrator" }
}

local user = user_data[user_id] or {
    name = cheat.GetUserName(), title = "User", register = "N/A", id = user_id, build = "Live"
}

------------------------------------------------------------ Menu & UI (Do NOT change names) ---------------------------------------------------------------------------
switzer_ui.MENU_NEW_TAB = gui.Window("hook_switzer", "Switzer", 500, 250, 650, 500)
switzer_ui.MENU_NEW_TAB:SetOpenKey(gui_get("adv.menukey"))

switzer_ui.SWITZER_TAB_VAR = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "SwitzerHook Tabs", 10, 10, 300, 100)
switzer_ui.SWITZER_TABS = gui.Combobox(switzer_ui.SWITZER_TAB_VAR, "TABS_SWITZER", "Menu", "General", "Aimbot/Indicators", "Miscellaneous")

switzer_ui.infor_lua = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "Informations", 10, 85, 300, 140)
switzer_ui.info_text = gui.Text(switzer_ui.infor_lua, "Welcome Back: " .. user.name .. "\n\nTitle: " .. user.title .. "\n\nJoined: " .. user.register .. "\n\nLast Update: 5/17/2024")

switzer_ui.contact_lua = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "Support", 320, 10, 310, 250)
switzer_ui.suport_me = gui.Text(switzer_ui.contact_lua, "If you have any questions, come across a bug or\n\nexperience any issues with the script please\n\ncreate a ticket or in bug channel on\n\nDiscord.gg/AV4SNyx54y and provide a\n\ndetailed description of your problem.")

switzer_ui.aim_general = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "Aimbot", 320, 10, 300, 250)
switzer_ui.SWITZER_MISC = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "Hud and Customization", 320, 10, 300, 250)
switzer_ui.SWITZER_WT = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "Watermark", 10, 195, 300, 180)

switzer_vars.switzer_mark_dev = gui.Checkbox(switzer_ui.SWITZER_MISC, "mark_switzer_dev", "Watermark", true)
switzer_vars.sw_mode_water = gui.Combobox(switzer_ui.SWITZER_WT, "water_mode_sw", "Watermark UI", "Old", "Modern")
switzer_vars.switzer_mark = gui.Combobox(switzer_ui.SWITZER_WT, "mark_switzer", "Watermark", "Left", "Right")
switzer_vars.SWT_COLOR = gui.ColorPicker(switzer_vars.switzer_mark, "COLOR_SWT", "Watermark Color", 155, 155, 155, 255)
switzer_vars.SWT_COLORBG = gui.ColorPicker(switzer_vars.switzer_mark, "COLOR_SWTBG", "Watermark Color", 45, 45, 55, 255)
switzer_vars.WT_OPT = gui.Multibox(switzer_ui.SWITZER_WT, "Watermark customization.")
switzer_vars.switzer_mark_uid = gui.Checkbox(switzer_vars.WT_OPT, "mark_switzer_uid", "Uid", true)
switzer_vars.switzer_mark_build = gui.Checkbox(switzer_vars.WT_OPT, "mark_switzer_build", "Build", true)

switzer_vars.custom_view = gui.Checkbox(switzer_ui.SWITZER_MISC, "VIEW_CUSTOM", "Custom Viewmodel", false)
switzer_vars.SLIDER_VIEWX = gui.Slider(switzer_ui.SWITZER_MISC, "VIEWX_SLIDER", "Viewmodel Offset X", xview, -2, 2.5, 0.1)
switzer_vars.SLIDER_VIEWY = gui.Slider(switzer_ui.SWITZER_MISC, "VIEWY_SLIDER", "Viewmodel Offset Y", yview, -2, 2, 0.1)
switzer_vars.SLIDER_VIEWZ = gui.Slider(switzer_ui.SWITZER_MISC, "VIEWZ_SLIDER", "Viewmodel Offset Z", zview, -2, 2, 0.1)

switzer_vars.aftoggler = gui.Checkbox(switzer_ui.aim_general, "af_toggler", "Automatic Fire", false)
switzer_vars.nstoggler = gui.Checkbox(switzer_ui.aim_general, "ns_toggler", "No Spread", false)
switzer_vars.aptoggler = gui.Checkbox(switzer_ui.aim_general, "ap_toggler", "Through Wall", false)
switzer_vars.smktoggle = gui.Checkbox(switzer_ui.aim_general, "smk_toggler", "Through Smoke", false)
switzer_vars.SLIDER_DLY_TGR = gui.Slider(switzer_ui.aim_general, "DLY_TGR_SLIDER", "Trigger Delay", 0, 0, 500, 5)

----------------------------------------------------------- Logic ---------------------------------------------------------------

-- Applies settings to all weapons without repeating the loop unnecessarily
local function SetAllWeaponsOption(option, value)
    for i = 1, #weapons_default do
        gui_set("lbot.weapon.vis." .. weapons_default[i] .. "." .. option, value)
    end
end

-- Main function that manages the script's Aimbot (Cached to prevent FPS drops)
local function RunAimbotLogic(lp)
    if not lp or not lp:IsAlive() or not gui_get("lbot.master") or not IsGameInForeground() then
        if pressed_key then SimulateKey(pressed_key, false); pressed_key = nil end
        return
    end

    -- Cached updates (Runs the GUI update ONLY if the checkbox is clicked/changed)
    UpdateStateIfChanged("autofire", switzer_vars.aftoggler:GetValue(), function(v) gui_set("lbot.trg.autofire", v) end)
    UpdateStateIfChanged("autowall", switzer_vars.aptoggler:GetValue(), function(v) SetAllWeaponsOption("autowall", v and 1 or 0) end)
    UpdateStateIfChanged("smoke", switzer_vars.smktoggle:GetValue(), function(v) SetAllWeaponsOption("smoke", v and 1 or 0) end)
    UpdateStateIfChanged("nospread", switzer_vars.nstoggler:GetValue(), function(v) gui_set("lbot.trg.weapon.shared.accuracy.antispread", v) end)

    -- FFI Logic 
    local aimkey = gui_get("lbot.aim.key")
    if aimkey and aimkey ~= 0 and switzer_vars.aftoggler:GetValue() then
        if pressed_key ~= aimkey then
            if pressed_key then SimulateKey(pressed_key, false) end
            SimulateKey(aimkey, true)
            pressed_key = aimkey
        end
    elseif pressed_key then
        SimulateKey(pressed_key, false)
        pressed_key = nil
    end
end

-- Cached Viewmodel Updater
local function UpdateViewModel(lp)
    if not lp then return end
    local is_custom = switzer_vars.custom_view:GetValue()
    
    UpdateStateIfChanged("view_x", is_custom and switzer_vars.SLIDER_VIEWX:GetValue() or xview, function(v) client.SetConVar("viewmodel_offset_x", v, true) end)
    UpdateStateIfChanged("view_y", is_custom and switzer_vars.SLIDER_VIEWY:GetValue() or yview, function(v) client.SetConVar("viewmodel_offset_y", v, true) end)
    UpdateStateIfChanged("view_z", is_custom and switzer_vars.SLIDER_VIEWZ:GetValue() or zview, function(v) client.SetConVar("viewmodel_offset_z", v, true) end)
end

-- Cached Menu Visibility Manager
local function UpdateMenuVisibility()
    if user.title ~= "Administrator" and not CACHE["admin_lock"] then
        switzer_vars.switzer_mark_dev:SetValue(true)
        switzer_vars.switzer_mark_dev:SetInvisible(true)
        CACHE["admin_lock"] = true
    end

    local current_tab = switzer_ui.SWITZER_TABS:GetValue()
    local mark_dev_active = switzer_vars.switzer_mark_dev:GetValue()
    local view_active = switzer_vars.custom_view:GetValue()

    -- Process visibility ONLY if the tab or checkboxes change
    if CACHE["menu_tab"] ~= current_tab or CACHE["menu_dev"] ~= mark_dev_active or CACHE["menu_view"] ~= view_active then
        switzer_vars.switzer_mark:SetInvisible(not mark_dev_active)
        switzer_vars.sw_mode_water:SetInvisible(not mark_dev_active)
        switzer_ui.SWITZER_WT:SetInvisible(not mark_dev_active)
        
        switzer_ui.aim_general:SetInvisible(current_tab ~= 1)
        switzer_ui.SWITZER_MISC:SetInvisible(current_tab ~= 2)
        switzer_ui.contact_lua:SetInvisible(current_tab ~= 0)
        
        switzer_vars.SLIDER_VIEWX:SetInvisible(not view_active)
        switzer_vars.SLIDER_VIEWY:SetInvisible(not view_active)
        switzer_vars.SLIDER_VIEWZ:SetInvisible(not view_active)
        
        CACHE["menu_tab"], CACHE["menu_dev"], CACHE["menu_view"] = current_tab, mark_dev_active, view_active
    end
end

----------------------------------------------------------- Watermark & Callbacks ---------------------------------------------------------------

local cached_watermark_text = ""

-- Function responsible for drawing the custom Watermark optimally
local function DrawWatermark()
    if not switzer_vars.switzer_mark_dev:GetValue() then return end
    
    local cur_uid = switzer_vars.switzer_mark_uid:GetValue()
    local cur_build = switzer_vars.switzer_mark_build:GetValue()
    local modern = switzer_vars.sw_mode_water:GetValue() == 1

    -- Caches the string concatenation to save CPU usage
    if CACHE["wt_uid"] ~= cur_uid or CACHE["wt_build"] ~= cur_build then
        cached_watermark_text = "SwitzerHook | " .. user.name
        if cur_uid then cached_watermark_text = cached_watermark_text .. " | Uid: " .. user.id end
        if cur_build then cached_watermark_text = cached_watermark_text .. " | " .. user.build end
        CACHE["wt_uid"], CACHE["wt_build"] = cur_uid, cur_build
    end

    draw.SetFont(fonts.Water)
    local w, h = draw.GetTextSize(cached_watermark_text)
    local wp, hp = modern and 20 or 10, modern and 15 or 10
    local screen_x, screen_y = draw.GetScreenSize()
    
    local start_x = switzer_vars.switzer_mark:GetValue() == 0 and 0 or (screen_x - (wp + w) - (modern and 3 or 12))
    local start_y = screen_y * (modern and 0.0050 or 0.0130)

    local bg_r, bg_g, bg_b, bg_a = switzer_vars.SWT_COLORBG:GetValue()
    local r_left, r_right = start_x + (modern and 13 or 7), start_x + (wp + w) + (modern and 0 or 5)
    
    draw.Color(bg_r, bg_g, bg_b, bg_a)
    draw.FilledRect(r_left, start_y, r_right, start_y - 5 + h + hp + (modern and 0 or 7))
    
    draw.Color(255, 255, 255, 255)
    draw.Text(start_x + wp / 2 + 6, start_y + hp / 2 - (modern and 3 or 1), cached_watermark_text)
    
    local r, g, b, a = switzer_vars.SWT_COLOR:GetValue()
    draw.Color(r, g, b, a)
    draw.FilledRect(r_left, start_y, r_right, start_y + (modern and 1 or -4))
end

callbacks.Register("Draw", function()
    DrawWatermark()
    UpdateMenuVisibility()
end)

callbacks.Register("CreateMove", function()
    local lp = entities.GetLocalPlayer()
    UpdateViewModel(lp)
    RunAimbotLogic(lp)
end)

----------------------------------------------------------- Indicators ---------------------------------------------------------------

local RenderIndicator = (function()
    local font = {}
    for scale, size in pairs {[1]=26, [1.25]=37, [1.5]=44, [1.75]=51, [2]=59} do
        font[scale] = {draw.CreateFont("Calibri Bold", size), size}
    end
    local indicators = {}
    callbacks.Register("Draw", function() indicators = {} end)

    return function(r, g, b, a, ...)
        local _, sh = draw.GetScreenSize()
        local y = sh - 350
        draw.SetFont(font[1][1])
        local text = table.concat {...}
        local _, th = draw.GetTextSize(text)
        local offset = 38 * #indicators
        table.insert(indicators, true)
        draw.Color(r, g, b, a)
        draw.TextShadow(26, math.floor(y - offset + (26 - th) * 0.5), text)
    end
end)()

xpcall(function()
    switzer_vars.DEFAULT_INDICATORS = gui.Multibox(switzer_ui.aim_general, "Choose your indicators")
    local trg_delay_enable = gui.Checkbox(switzer_vars.DEFAULT_INDICATORS, "deft_dly_trg", "Trigger Delay", false)
    local trg_delay_color = gui.ColorPicker(trg_delay_enable, "deft_dly_trg_clr", "Color", 255, 255, 255, 255)
    local chk_smk = gui.Checkbox(switzer_vars.DEFAULT_INDICATORS, "deft_smk", "Through Smoke", false)
    local chk_smk_color = gui.ColorPicker(chk_smk, "deft_smk_clr", "Color", 255, 255, 255, 255)
    local af_enable = gui.Checkbox(switzer_vars.DEFAULT_INDICATORS, "deft_af", "Automatic Fire", false)
    local af_color = gui.ColorPicker(af_enable, "deft_af_clr", "Color", 150, 200, 60, 255)
    local chk_aw = gui.Checkbox(switzer_vars.DEFAULT_INDICATORS, "deft_ap", "Through Wall", false)
    local chk_aw_color = gui.ColorPicker(chk_aw, "deft_ap_clr", "Color", 150, 200, 60, 255)

    callbacks.Register("Draw", function()
        local lp = entities.GetLocalPlayer()
        if not lp or not lp:IsAlive() or not gui_get("lbot.master") then return end

        if chk_aw:GetValue() and switzer_vars.aptoggler:GetValue() then
            local r, g, b, a = chk_aw_color:GetValue()
            RenderIndicator(r, g, b, a, "AW")
        end
        if af_enable:GetValue() and gui_get("lbot.trg.enable") and switzer_vars.aftoggler:GetValue() then
            local r, g, b, a = af_color:GetValue()
            RenderIndicator(r, g, b, a, "AF")
        end

        local delay = switzer_vars.SLIDER_DLY_TGR:GetValue()
        UpdateStateIfChanged("trg_delay", delay, function(v)
            for i = 1, #weapons_default do gui_set("lbot.trg.weapon." .. weapons_default[i] .. ".delay", v) end
        end)

        if trg_delay_enable:GetValue() then
            local r, g, b, a = trg_delay_color:GetValue()
            RenderIndicator(r, g, b, a, delay, "ms")
        end

        if chk_smk:GetValue() and switzer_vars.smktoggle:GetValue() then
            local r, g, b, a = chk_smk_color:GetValue()
            RenderIndicator(r, g, b, a, "TS")
        end
    end)
end, print)

callbacks.Register("Unload", function()
    client.SetConVar("viewmodel_offset_x", xview, true)
    client.SetConVar("viewmodel_offset_y", yview, true)
    client.SetConVar("viewmodel_offset_z", zview, true)

    if pressed_key then SimulateKey(pressed_key, false) end
end)
