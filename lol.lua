-- Auto Armor | Da Hood
-- F1 to toggle on/off

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local enabled = true -- ON by default
local buying = false
local savedPosition = nil

-- Watermark
local statusLabel = Drawing.new("Text")
statusLabel.Text = "Auto Armor | ON"
statusLabel.Size = 13
statusLabel.Color = Color3.fromRGB(100, 220, 130)
statusLabel.Transparency = 1
statusLabel.Outline = true
statusLabel.Position = Vector2.new(25, 25)
statusLabel.Visible = true

local function updateStatus()
    if enabled then
        statusLabel.Text = "Auto Armor | ON"
        statusLabel.Color = Color3.fromRGB(100, 220, 130)
    else
        statusLabel.Text = "Auto Armor | OFF"
        statusLabel.Color = Color3.fromRGB(200, 200, 200)
    end
end

local function pressShift()
    keypress(0xA0)
    task.wait(0.1)
    keyrelease(0xA0)
    task.wait(0.15)
end

local function buyArmor()
    if buying then return end
    buying = true
    print("[AutoArmor] Buying now")

    local char = localPlayer.Character
    if not char then buying = false return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then buying = false return end

    local bodyEffects = char:FindFirstChild("BodyEffects")
    local armorVal = bodyEffects and bodyEffects:FindFirstChild("Armor")
    if not armorVal then buying = false return end

    local block = game.Workspace.Ignored.Shop:FindFirstChild("[High-Medium Armor] - $2589")
    if not block then print("[AutoArmor] No block") buying = false return end

    local head = block:FindFirstChild("Head")
    if not head then print("[AutoArmor] No head") buying = false return end

    -- Save position right away
    savedPosition = hrp.Position
    print("[AutoArmor] Saved: " .. tostring(savedPosition))

    -- Unequip tool
    print("[AutoArmor] Unequipping")
    keypress(0x31) task.wait(0.05) keyrelease(0x31) task.wait(0.05)
    keypress(0x32) task.wait(0.05) keyrelease(0x32) task.wait(0.05)
    keypress(0x33) task.wait(0.05) keyrelease(0x33) task.wait(0.05)
    keypress(0x33) task.wait(0.05) keyrelease(0x33) task.wait(0.1)

    -- Teleport onto block
    print("[AutoArmor] Teleporting to shop")
    hrp.Position = head.Position + Vector3.new(0, 2.5, 0)
    task.wait(0.15)

    -- Look down multiple times to make sure it sticks
    mousemoverel(0, 9999)
    task.wait(0.1)
    mousemoverel(0, 9999)
    task.wait(0.1)

    -- Exit shiftlock
    pressShift()
    task.wait(0.1)

    -- Look down again after shiftlock exit
    mousemoverel(0, 9999)
    task.wait(0.1)

    -- Spam click until armor bought or hit limit
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

    -- Re-enter shiftlock
    pressShift()

    -- Always tp back no matter what
    task.wait(0.1)
    print("[AutoArmor] Teleporting back")
    hrp.Position = savedPosition
    print("[AutoArmor] Done!")

    task.wait(1)
    buying = false
end

-- Poll loop
task.spawn(function()
    task.wait(2) -- wait for character to fully load on startup
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

print("[AutoArmor] Loaded! Auto armor is ON. Press F1 to toggle.")
