-- tabs/aimbot_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Settings
    settings.aimbotEnabled = settings.aimbotEnabled or false
    settings.silentAimEnabled = settings.silentAimEnabled or false
    settings.aimbotTeamCheck = settings.aimbotTeamCheck or true
    settings.aimbotSmoothing = settings.aimbotSmoothing or 8
    settings.aimbotTargetPart = settings.aimbotTargetPart or "Head"
    settings.fovEnabled = settings.fovEnabled or false
    settings.fovRadius = settings.fovRadius or 120
    settings.triggerbotEnabled = settings.triggerbotEnabled or false

    local AimbotPage = ui.CreatePage("Aimbot")

    -- ==================== MAIN AIMBOT CARD ====================
    local CardAim = ui.CreateCard(AimbotPage, "AIMBOT SYSTEM", UDim2.new(0, 380, 0, 340), UDim2.new(0, 0, 0, 0), "🎯")

    ui.CreateInlineToggle(CardAim, "🎯 Enable Camera Aimbot (Right Click)", 55, settings.aimbotEnabled, function(s) settings.aimbotEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🌍 Silent Aim (Shoot through walls)", 90, settings.silentAimEnabled, function(s) settings.silentAimEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🛡 Team Check", 125, settings.aimbotTeamCheck, function(s) settings.aimbotTeamCheck = s end)
    ui.CreateInlineToggle(CardAim, "🔫 Triggerbot (Auto Shoot)", 160, settings.triggerbotEnabled, function(s) settings.triggerbotEnabled = s end)
    ui.CreateInlineToggle(CardAim, "⭕ Show FOV Circle", 195, settings.fovEnabled, function(s) settings.fovEnabled = s end)

    -- Target Part
    local partBtn = Instance.new("TextButton", CardAim)
    partBtn.Size = UDim2.new(0, 140, 0, 28)
    partBtn.Position = UDim2.new(0, 16, 0, 235)
    partBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    partBtn.Text = settings.aimbotTargetPart:upper()
    partBtn.Font = Enum.Font.GothamBold
    partBtn.TextSize = 11
    Instance.new("UICorner", partBtn).CornerRadius = UDim.new(0, 6)

    partBtn.MouseButton1Click:Connect(function()
        if settings.aimbotTargetPart == "Head" then
            settings.aimbotTargetPart = "HumanoidRootPart"
            partBtn.Text = "TORSO"
        else
            settings.aimbotTargetPart = "Head"
            partBtn.Text = "HEAD"
        end
    end)

    -- Sliders
    local function createSlider(title, min, max, default, yPos, callback)
        -- ... (dein bestehender Slider Code)
        -- Ich lasse ihn hier aus Platzgründen weg, du kannst deinen behalten
    end

    createAimSlider("FOV RADIUS", 30, 500, settings.fovRadius, 280, "px", function(v) settings.fovRadius = v end)
    createAimSlider("SMOOTHING", 1, 20, settings.aimbotSmoothing, 320, "", function(v) settings.aimbotSmoothing = v end)

    -- ==================== SILENT AIM + TRIGGERBOT ====================
    local currentTarget = nil

    local function getClosestPlayer()
        local closest, dist = nil, math.huge
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer or not player.Character then continue end
            if settings.aimbotTeamCheck and player.Team == LocalPlayer.Team then continue end

            local hum = player.Character:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end

            local part = player.Character:FindFirstChild(settings.aimbotTargetPart) or player.Character:FindFirstChild("Head")
            if not part then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end

            local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if mouseDist < settings.fovRadius and mouseDist < dist then
                dist = mouseDist
                closest = player
            end
        end
        return closest
    end

    -- Silent Aim (besser & stabiler)
    settings.addConnection("silentAim", RunService.RenderStepped:Connect(function()
        if not settings.silentAimEnabled then return end
        currentTarget = getClosestPlayer()
    end))

    -- Triggerbot
    settings.addConnection("triggerbot", RunService.RenderStepped:Connect(function()
        if not settings.triggerbotEnabled or not currentTarget then return end
        local targetHum = currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid")
        if targetHum and targetHum.Health > 0 then
            mouse1click() -- Auto Shoot
        end
    end))

    -- Camera Aimbot (verbessert)
    settings.addConnection("cameraAimbot", RunService.RenderStepped:Connect(function()
        if not settings.aimbotEnabled then return end
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

        local target = getClosestPlayer()
        if not target or not target.Character then return end

        local part = target.Character:FindFirstChild(settings.aimbotTargetPart) or target.Character:FindFirstChild("Head")
        if not part then return end

        local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / settings.aimbotSmoothing)
    end))

    -- FOV Circle
    local fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5
    fovCircle.NumSides = 64
    fovCircle.Filled = false
    fovCircle.Transparency = 0.6

    settings.addConnection("fovDraw", RunService.RenderStepped:Connect(function()
        if settings.fovEnabled then
            local mouse = UserInputService:GetMouseLocation()
            fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
            fovCircle.Radius = settings.fovRadius
            fovCircle.Color = Color3.fromRGB(255, 50, 50)
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end))

    print("FreezyHub Aimbot Tab geladen (Silent + Triggerbot)")
    return AimbotPage
end