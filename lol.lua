-- Auto Armor | Da Hood
-- F1 to toggle on/off

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local enabled = true
local buying = false
local savedPosition = nil

-- Screen width for centering
local screenWidth = workspace.CurrentCamera.ViewportSize.X
local charWidth = 7

local statusLabel = Drawing.new("Text")
statusLabel.Text = "Damon <3 | ON"
statusLabel.Size = 15
statusLabel.Color = Color3.fromRGB(100, 220, 130)
statusLabel.Transparency = 1
statusLabel.Outline = true
statusLabel.Position = Vector2.new((screenWidth / 2) - (#"Damon <3 | ON" * charWidth / 2), 16)
statusLabel.Visible = true

local function updateStatus()
    if enabled then
        local t = "Damon <3 | ON"
        statusLabel.Text = t
        statusLabel.Color = Color3.fromRGB(100, 220, 130)
        statusLabel.Position = Vector2.new((screenWidth / 2) - (#t * charWidth / 2), 16)
    else
        local t = "Damon <3 | OFF"
        statusLabel.Text = t
        statusLabel.Color = Color3.fromRGB(200, 200, 200)
        statusLabel.Position = Vector2.new((screenWidth / 2) - (#t * charWidth / 2), 16)
    end
end

local function pressShift()
    keypress(0xA0)
    task.wait(0.1)
    keyrelease(0xA0)
    task.wait(0.15)
end

local function getHRP()
    local char = localPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function buyArmor()
    if buying then return end
    buying = true
    print("[AutoArmor] Buying now")

    local char = localPlayer.Character
    if not char then buying = false return end

    local hrp = getHRP()
    if not hrp then buying = false return end

    local bodyEffects = char:FindFirstChild("BodyEffects")
    local armorVal = bodyEffects and bodyEffects:FindFirstChild("Armor")
    if not armorVal then buying = false return end

    local block = game.Workspace.Ignored.Shop:FindFirstChild("[High-Medium Armor] - $2589")
    if not block then print("[AutoArmor] No block") buying = false return end

    local head = block:FindFirstChild("Head")
    if not head then print("[AutoArmor] No head") buying = false return end

    -- Save position as local copy so it cannot be overwritten between runs
    local returnPos = Vector3.new(hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
    savedPosition = returnPos
    print("[AutoArmor] Saved: " .. tostring(returnPos))

    -- Unequip tool
    print("[AutoArmor] Unequipping")
    keypress(0x31) task.wait(0.05) keyrelease(0x31) task.wait(0.05)
    keypress(0x32) task.wait(0.05) keyrelease(0x32) task.wait(0.05)
    keypress(0x33) task.wait(0.05) keyrelease(0x33) task.wait(0.05)
    keypress(0x33) task.wait(0.05) keyrelease(0x33) task.wait(0.1)

    -- Teleport to shop
    print("[AutoArmor] Teleporting to shop")
    hrp.Position = head.Position + Vector3.new(0, 2.5, 0)
    task.wait(0.15)

    -- Look down
    mousemoverel(0, 9999)
    task.wait(0.1)
    mousemoverel(0, 9999)
    task.wait(0.1)

    -- Exit shiftlock
    pressShift()
    task.wait(0.1)

    mousemoverel(0, 9999)
    task.wait(0.1)

    -- Spam click
    print("[AutoArmor] Clicking...")
    local attempts = 0
    while attempts < 50 do
        if not enabled then
            print("[AutoArmor] Cancelled")
            break
        end
        mousemoverel(0, 9999)
        mouse1click()
        task.wait(0.1)
        if armorVal.Value > 0 then
            print("[AutoArmor] Bought after " .. attempts + 1 .. " clicks!")
            break
        end
        attempts += 1
    end

    -- Reset camera BEFORE re-entering shiftlock
    print("[AutoArmor] Resetting camera")
    mousemoverel(0, -9999) -- snap to max up
    task.wait(0.05)
    mousemoverel(0, 3600)  -- tilt down to comfortable angle
    task.wait(0.1)

    -- Re-enter shiftlock
    pressShift()
    task.wait(0.1)

    -- Re-fetch hrp in case it changed
    hrp = getHRP()
    if hrp and savedPosition then
        print("[AutoArmor] Teleporting back to " .. tostring(savedPosition))
        hrp.Position = savedPosition
    else
        print("[AutoArmor] ERROR: Could not get HRP for tp back")
    end

    print("[AutoArmor] Done!")
    task.wait(1)
    buying = false
end

-- Poll loop
task.spawn(function()
    task.wait(2)
    while true do
        task.wait(0.1)
        if not enabled or buying then continue end

        local char = localPlayer.Character
        if not char then continue end

        local bodyEffects = char:FindFirstChild("BodyEffects")
        if not bodyEffects then continue end

        local armorVal = bodyEffects:FindFirstChild("Armor")
        if not armorVal then continue end

        if armorVal.Value <= 0 then
            buyArmor()
        end
    end
end)

-- F1 toggle
task.spawn(function()
    local wasPressed = false
    while true do
        task.wait(0.05)
        local pressed = iskeypressed(0x70)
        if pressed and not wasPressed then
            enabled = not enabled
            updateStatus()
            print("[AutoArmor] " .. (enabled and "ON" or "OFF"))
        end
        wasPressed = pressed
    end
end)

print("[AutoArmor] Loaded! Damon <3 auto armor is ON. Press F1 to toggle.")
