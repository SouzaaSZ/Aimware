local reference = gui.Reference("Ragebot", "Anti-aim", "Extra")
local usr_x = gui.Slider(reference, "ot_keybinds_x", "Keybinds Position X", 100, 1, 1920);
local usr_y = gui.Slider(reference, "ot_keybinds_y", "Keybinds Position Y", 600, 1, 1080);
local smallFont = draw.CreateFont("Tahoma", 13, 300);
local itemwidth = 135;
local itemheight = 24;

function gradient(x1, y1, x2, y2, left)
  local w = x2 - x1
  local h = y2 - y1

  for i = 0, w do
    local a = (i / w) * 255

    draw.Color(a, 0, 0, 255)
    if left then
      draw.RoundedRectFill(x1 + i, y1, x1 + i + 1, y1 + h)
    else
      draw.RoundedRectFill(x1 + w - i, y1, x1 + w - i + 1, y1 + h)
    end
  end
end

function draw_keybinds()

  local me = entities.GetLocalPlayer()

  -- positions
  local posX = usr_x:GetValue();
  local posY = usr_y:GetValue();
  local outlineposX = posX - 1;
  local outlineposY = posY - 1;

  -- features
  lp = entities.GetLocalPlayer()
  velocity = lp:GetPropVector("localdata", "m_vecVelocity[0]"):Length()
  slowkey = gui.GetValue("rbot.accuracy.movement.slowkey")
  duckkey = gui.GetValue("rbot.antiaim.extra.fakecrouchkey")

  local Doubletap =  gui.GetValue("rbot.accuracy.attack.shared.fire") == "\"Defensive Warp Fire\""
  local Hide_Shots = gui.GetValue("rbot.accuracy.attack.shared.fire") == "\"Shift Fire\""
  local Slow_Walk = slowkey ~= 0 and velocity > 5 and input.IsButtonDown(slowkey)
  local Fake_duck = duckkey ~= 0 and input.IsButtonDown(duckkey)


  local modules = {};

  if Doubletap then
    table.insert(modules, "[double tap]  [toggled]");
  end


  if Hide_Shots then
    table.insert(modules, "[hide shots]  [toggled]");
  end

  if Slow_Walk  then
    table.insert(modules, "[slow walk]    [holding]");

  end

  if Fake_duck then
    table.insert(modules, "[fake duck]    [holding]");
  end

  if #modules > 0 and me ~= nil and me:IsAlive() then

    -- HEADER


    -- border
    draw.Color(5, 5, 5, 120)
    draw.RoundedRectFill(outlineposX, outlineposY - 35 , outlineposX + itemwidth + 2,  outlineposY - 2)

    -- gradient
    gradient(outlineposX + 3 + 4, outlineposY - 34 , outlineposX + itemwidth - 2 - 10,  outlineposY - 24, true)
    draw.Color(255, 0, 0, 255)
    draw.RoundedRectFill(outlineposX + itemwidth - 11, outlineposY - 34 , outlineposX + itemwidth + 1,  outlineposY - 24)
    draw.Color(0, 0, 0, 255)
    draw.RoundedRectFill(outlineposX + 1, outlineposY - 34 , outlineposX + 8,  outlineposY - 24)


    -- fill
    draw.Color(45, 48, 55, 255)
    draw.FilledRect(posX, posY - 31, posX + itemwidth,  posY - 6)
    draw.RoundedRectFill(posX, posY - 31, posX + itemwidth,  posY - 4)

    -- text
    draw.SetFont(smallFont);
    draw.Color(255, 255, 255, 255);
    draw.Text(outlineposX + 47, posY - 24, "keybinds")

    -- HEADER END


    -- FEATURES

    -- border
    draw.Color(5, 5, 5, 120)
    draw.RoundedRectFill(outlineposX, outlineposY, outlineposX + itemwidth + 2,  outlineposY + (itemheight * #modules) + 4)

    -- fill
    draw.Color(45, 48, 55, 255)
    draw.RoundedRectFill(posX, posY, posX + itemwidth,  posY + (itemheight * #modules) + 2)

    for i = 0, #modules do

      -- text
      draw.SetFont(smallFont);
      draw.Color(210, 210, 210, 255);
      draw.Text(posX + 9, posY + 5 + (itemheight * (i - 1) + 1), modules[i])

    end

    -- FEATURES END

  end
end

callbacks.Register("Draw", "draw_keybinds", draw_keybinds);