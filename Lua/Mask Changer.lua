local list_names = 
{
    'Dallas',
    'Battle Mask', 
    'Evil Clown', 
    'Anaglyph', 
    'Boar', 
    'Bunny', 
    'Bunny Gold', 
    'Chains', 
    'Chicken', 
    'Devil Plastic', 
    'Hoxton', 
    'Pumpkin', 
    'Samurai', 
    'Sheep Bloody', 
    'Sheep Gold', 
    'Sheep Model', 
    'Skull', 
    'Template', 
    'Wolf', 
    'Doll',
}

local ref = gui.Reference("Misc", "General", "Extra")
local masks = gui.Combobox(ref, "Mask Changer", "Masks", unpack(list_names))
masks:SetDescription("Mask Changer imported by Souza.")


local filepath = 
{
    'player/holiday/facemasks/facemask_dallas',
    'player/holiday/facemasks/facemask_battlemask', 
    'player/holiday/facemasks/evil_clown', 
    'player/holiday/facemasks/facemask_anaglyph', 
    'player/holiday/facemasks/facemask_boar', 
    'player/holiday/facemasks/facemask_bunny', 
    'player/holiday/facemasks/facemask_bunny_gold', 
    'player/holiday/facemasks/facemask_chains', 
    'player/holiday/facemasks/facemask_chicken', 
    'player/holiday/facemasks/facemask_devil_plastic', 
    'player/holiday/facemasks/facemask_hoxton', 
    'player/holiday/facemasks/facemask_pumpkin', 
    'player/holiday/facemasks/facemask_samurai', 
    'player/holiday/facemasks/facemask_sheep_bloody', 
    'player/holiday/facemasks/facemask_sheep_gold', 
    'player/holiday/facemasks/facemask_sheep_model', 
    'player/holiday/facemasks/facemask_skull', 
    'player/holiday/facemasks/facemask_template', 
    'player/holiday/facemasks/facemask_wolf', 
    'player/holiday/facemasks/porcelain_doll',
}
local names = 
{
    'facemask_dallas',
    'facemask_battlemask', 
    'evil_clown', 
    'facemask_anaglyph', 
    'facemask_boar', 
    'facemask_bunny', 
    'facemask_bunny_gold', 
    'facemask_chains', 
    'facemask_chicken', 
    'facemask_devil_plastic', 
    'facemask_hoxton', 
    'facemask_pumpkin', 
    'facemask_samurai', 
    'facemask_sheep_bloody', 
    'facemask_sheep_gold', 
    'facemask_sheep_model', 
    'facemask_skull', 
    'facemask_template', 
    'facemask_wolf', 
    'porcelain_doll',
}
local s = 0
local a = 0
local cache = 0
local mask_cache = 0
local number = 0

callbacks.Register("Draw",function()
    if gui.GetValue("esp.world.thirdperson") and a == 0 then
        s = 0
        a = a + 1
    end
    if s == 0 then
        number = masks:GetValue()+1
        cache = masks:GetValue()
        client.Command(string.format('ent_fire !self addoutput "targetname facemask"; prop_dynamic_create %s; ent_setname %s; ent_fire %s disablecollision; ent_fire %s setparent facemask; ent_fire %s setparentattachment facemask', filepath[number], names[number], names[number], names[number], names[number]))
        s = s + 1
    elseif gui.GetValue("esp.world.thirdperson") == false and a > 0 then
        client.Command(string.format('ent_remove %s', names[masks:GetValue()+1]))
        a = 0
    elseif cache ~= masks:GetValue() and s > 0 then
        client.Command(string.format('ent_remove %s', names[number]))
        s = 0 
    end
end)

callbacks.Register("Unload",function()
    client.Command(string.format('ent_remove %s', names[number]))
end)