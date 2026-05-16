local weapons_default = {"asniper", "hpistol", "lmg", "pistol", "rifle", "scout", "smg", "shotgun", "sniper", "zeus",
                         "shared"}
local menu_vars, switzer_vars, switzer_ui, fonts = {}, {}, {}, {}
local xview, yview, zview = client.GetConVar("viewmodel_offset_x"), client.GetConVar("viewmodel_offset_y"),
    client.GetConVar("viewmodel_offset_z")
local user_id = cheat.GetUserID()

local gui_get, gui_set = gui.GetValue, gui.SetValue
fonts.Water = draw.CreateFont("Calibri Bold", 12.5)

----------------------------------------------------------- Smart Cache -----------------------------------------------------------------------
local SMART_CACHE = {}

local function SetConVar(ConVar, Value)
    if Value ~= SMART_CACHE[ConVar] then
        client.SetConVar(ConVar, Value, true)
        SMART_CACHE[ConVar] = Value
    end
end

----------------------------------------------------------- Switzer Ids ---------------------------------------------------------------
local user_data = {
    [354692] = {
        name = "Souza",
        register = "3/04/2021",
        id = "1",
        build = "(Beta)",
        title = "Administrator"
    }
}

local user = user_data[user_id] or {
    name = cheat.GetUserName(),
    title = "User",
    register = "N/A",
    id = user_id,
    build = "Live"
}

------------------------------------------------------------ Menu & UI ---------------------------------------------------------------------------
switzer_ui.MENU_NEW_TAB = gui.Window("hook_switzer", "Switzer", 500, 250, 650, 500)
switzer_ui.MENU_NEW_TAB:SetOpenKey(gui_get("adv.menukey"))

switzer_ui.SWITZER_TAB_VAR = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "SwitzerHook Tabs", 10, 10, 300, 100)
switzer_ui.SWITZER_TABS = gui.Combobox(switzer_ui.SWITZER_TAB_VAR, "TABS_SWITZER", "Menu", "General",
    "Aimbot/Indicators", "Miscellaneous")

-- Informations (Otimizado com as quebras que você pediu)
switzer_ui.infor_lua = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "Informations", 10, 85, 300, 140)
switzer_ui.info_text = gui.Text(switzer_ui.infor_lua, "Welcome Back: " .. user.name .. "\
\
Title: " .. user.title .. "\
\
Joined: " .. user.register .. "\
\
Last Update: 5/14/2024")

-- Support (Exatamente como você enviou)
switzer_ui.contact_lua = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "Support", 320, 10, 310, 250)
switzer_ui.suport_me = gui.Text(switzer_ui.contact_lua, "If you have any questions, come across a bug or\
\
experience any issues with the script please\
\
create a ticket or in bug channel on\
\
Discord.gg/AV4SNyx54y and provide a\
\
detailed description of your problem.")

-- Groups
switzer_ui.aim_general = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "Aimbot", 320, 10, 300, 250)
switzer_ui.SWITZER_MISC = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "Hud and Customization", 320, 10, 300, 250)
switzer_ui.SWITZER_WT = gui.Groupbox(switzer_ui.MENU_NEW_TAB, "Watermark", 10, 195, 300, 180)

-- Controles de UI
switzer_vars.switzer_mark_dev = gui.Checkbox(switzer_ui.SWITZER_MISC, "mark_switzer_dev", "Watermark", true)
switzer_vars.sw_mode_water = gui.Combobox(switzer_ui.SWITZER_WT, "water_mode_sw", "Watermark UI", "Old", "Modern")
switzer_vars.switzer_mark = gui.Combobox(switzer_ui.SWITZER_WT, "mark_switzer", "Watermark", "Left", "Right")
switzer_vars.SWT_COLOR = gui.ColorPicker(switzer_vars.switzer_mark, "COLOR_SWT", "Watermark Color", 155, 155, 155, 255)
switzer_vars.SWT_COLORBG = gui.ColorPicker(switzer_vars.switzer_mark, "COLOR_SWTBG", "Watermark Color", 45, 45, 55, 255)
switzer_vars.WT_OPT = gui.Multibox(switzer_ui.SWITZER_WT, "Watermark customization.")
switzer_vars.switzer_mark_uid = gui.Checkbox(switzer_vars.WT_OPT, "mark_switzer_uid", "Uid", true)
switzer_vars.switzer_mark_build = gui.Checkbox(switzer_vars.WT_OPT, "mark_switzer_build", "Build", true)

switzer_vars.custom_view = gui.Checkbox(switzer_ui.SWITZER_MISC, "VIEW_CUSTOM", "Custom Viewmodel", false)
switzer_vars.SLIDER_VIEWX = gui.Slider(switzer_ui.SWITZER_MISC, "VIEWX_SLIDER", "Viewmodel Offset X", xview, -2, 2.5,
    0.1)
switzer_vars.SLIDER_VIEWY = gui.Slider(switzer_ui.SWITZER_MISC, "VIEWY_SLIDER", "Viewmodel Offset Y", yview, -2, 2, 0.1)
switzer_vars.SLIDER_VIEWZ = gui.Slider(switzer_ui.SWITZER_MISC, "VIEWZ_SLIDER", "Viewmodel Offset Z", zview, -2, 2, 0.1)

switzer_vars.aftoggler = gui.Checkbox(switzer_ui.aim_general, "af_toggler", "Automatic Fire", false)
switzer_vars.aptoggler = gui.Checkbox(switzer_ui.aim_general, "ap_toggler", "Through Wall", false)
switzer_vars.smktoggle = gui.Checkbox(switzer_ui.aim_general, "smk_toggler", "Through Smoke", false)
switzer_vars.SLIDER_DLY_TGR = gui.Slider(switzer_ui.aim_general, "DLY_TGR_SLIDER", "Trigger Delay", 0, 0, 500, 5)

----------------------------------------------------------- Logic ---------------------------------------------------------------

local function SetWeaponOption(option, value)
    for i = 1, #weapons_default do
        gui_set("lbot.weapon.vis." .. weapons_default[i] .. "." .. option, value)
    end
end

local function Aimbot_Tab(lp)
    if not lp or not lp:IsAlive() or not gui_get("lbot.master") then
        return
    end
    gui_set("lbot.trg.autofire", switzer_vars.aftoggler:GetValue())
    SetWeaponOption("autowall", switzer_vars.aptoggler:GetValue() and 1 or 0)
    SetWeaponOption("smoke", switzer_vars.smktoggle:GetValue() and 1 or 0)
end

local function View_Model(lp)
    if not lp then
        return
    end
    if switzer_vars.custom_view:GetValue() then
        SetConVar("viewmodel_offset_x", switzer_vars.SLIDER_VIEWX:GetValue())
        SetConVar("viewmodel_offset_y", switzer_vars.SLIDER_VIEWY:GetValue())
        SetConVar("viewmodel_offset_z", switzer_vars.SLIDER_VIEWZ:GetValue())
    else
        SetConVar("viewmodel_offset_x", xview)
        SetConVar("viewmodel_offset_y", yview)
        SetConVar("viewmodel_offset_z", zview)
    end
end

local function Disable_Menu()
    local VIEW = switzer_vars.custom_view:GetValue()
    local SWTAB = switzer_ui.SWITZER_TABS:GetValue()
    local MK_DEV = switzer_vars.switzer_mark_dev:GetValue()

    if user.title ~= "Administrator" then
        switzer_vars.switzer_mark_dev:SetValue(true)
        switzer_vars.switzer_mark_dev:SetInvisible(true)
    end

    switzer_vars.switzer_mark:SetInvisible(not MK_DEV)
    switzer_vars.sw_mode_water:SetInvisible(not MK_DEV)
    switzer_ui.SWITZER_WT:SetInvisible(not MK_DEV)
    switzer_ui.aim_general:SetInvisible(SWTAB ~= 1)
    switzer_ui.SWITZER_MISC:SetInvisible(SWTAB ~= 2)
    switzer_ui.contact_lua:SetInvisible(SWTAB ~= 0)
    switzer_vars.SLIDER_VIEWX:SetInvisible(not VIEW)
    switzer_vars.SLIDER_VIEWY:SetInvisible(not VIEW)
    switzer_vars.SLIDER_VIEWZ:SetInvisible(not VIEW)
end

----------------------------------------------------------- Watermark & Callbacks ---------------------------------------------------------------

local function Water_Switzer_Mark()
    if not switzer_vars.switzer_mark_dev:GetValue() then
        return
    end
    local modern = switzer_vars.sw_mode_water:GetValue() == 1
    local watermarkText = "SwitzerHook | " .. user.name
    if switzer_vars.switzer_mark_uid:GetValue() then
        watermarkText = watermarkText .. " | Uid: " .. user.id
    end
    if switzer_vars.switzer_mark_build:GetValue() then
        watermarkText = watermarkText .. " | " .. user.build
    end

    draw.SetFont(fonts.Water)
    local w, h = draw.GetTextSize(watermarkText)
    local wp, hp = modern and 20 or 10, modern and 15 or 10
    local screen_x, screen_y = draw.GetScreenSize()
    local start_x = switzer_vars.switzer_mark:GetValue() == 0 and 0 or (screen_x - (wp + w) - (modern and 3 or 12))
    local start_y = screen_y * (modern and 0.0050 or 0.0130)

    local bg_r, bg_g, bg_b, bg_a = switzer_vars.SWT_COLORBG:GetValue()
    local r_left, r_right = start_x + (modern and 13 or 7), start_x + (wp + w) + (modern and 0 or 5)
    draw.Color(bg_r, bg_g, bg_b, bg_a)
    draw.FilledRect(r_left, start_y, r_right, start_y - 5 + h + hp + (modern and 0 or 7))
    draw.Color(255, 255, 255, 255)
    draw.Text(start_x + wp / 2 + 6, start_y + hp / 2 - (modern and 3 or 1), watermarkText)
    local r, g, b, a = switzer_vars.SWT_COLOR:GetValue()
    draw.Color(r, g, b, a)
    draw.FilledRect(r_left, start_y, r_right, start_y + (modern and 1 or -4))
end

callbacks.Register("Draw", function()
    Water_Switzer_Mark()
    Disable_Menu()
end)

callbacks.Register("CreateMove", function()
    local lp = entities.GetLocalPlayer()
    View_Model(lp)
    Aimbot_Tab(lp)
end)

----------------------------------------------------------- Indicators ---------------------------------------------------------------

local renderer_indicator = (function()
    local font = {}
    for scale, size in pairs {
        [1] = 26,
        [1.25] = 37,
        [1.5] = 44,
        [1.75] = 51,
        [2] = 59
    } do
        font[scale] = {draw.CreateFont("Calibri Bold", size), size}
    end
    local indicators = {}
    callbacks.Register("Draw", function()
        indicators = {}
    end)

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
        if not lp or not lp:IsAlive() or not gui_get("lbot.master") then
            return
        end

        if chk_aw:GetValue() and switzer_vars.aptoggler:GetValue() then
            local r, g, b, a = chk_aw_color:GetValue()
            renderer_indicator(r, g, b, a, "AW")
        end
        if af_enable:GetValue() and gui_get("lbot.trg.enable") and switzer_vars.aftoggler:GetValue() then
            local r, g, b, a = af_color:GetValue()
            renderer_indicator(r, g, b, a, "AF")
        end

        local delay = switzer_vars.SLIDER_DLY_TGR:GetValue()
        if SMART_CACHE["last_delay"] ~= delay then
            for i = 1, #weapons_default do
                gui_set("lbot.trg.weapon." .. weapons_default[i] .. ".delay", delay)
            end
            SMART_CACHE["last_delay"] = delay
        end

        if trg_delay_enable:GetValue() then
            local r, g, b, a = trg_delay_color:GetValue()
            renderer_indicator(r, g, b, a, delay, "ms")
        end

        if chk_smk:GetValue() and switzer_vars.smktoggle:GetValue() then
            local r, g, b, a = chk_smk_color:GetValue()
            renderer_indicator(r, g, b, a, "TS")
        end
    end)
end, print)

callbacks.Register("Unload", function()
    SetConVar("viewmodel_offset_x", xview)
    SetConVar("viewmodel_offset_y", yview)
    SetConVar("viewmodel_offset_z", zview)
end)
