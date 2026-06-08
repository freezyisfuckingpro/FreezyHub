-- tabs/aimbot_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Absicherung für Variablen
    if settings.aimbotEnabled == nil then settings.aimbotEnabled = false end
    if settings.aimbotTeamCheck == nil then settings.aimbotTeamCheck = true end
    if settings.aimbotSmoothing == nil then settings.aimbotSmoothing = 1 end
    if settings.aimbotTargetPart == nil then settings.aimbotTargetPart = "Head" end
    if settings.fovEnabled == nil then settings.fovEnabled = false end
    if settings.fovRadius == nil then settings.fovRadius = 100 end

    local AimbotPage = ui.CreatePage("Aimbot")
    
    -- Linke Karte: Aimbot-Steuerung
    local CardAim = ui.CreateCard(AimbotPage, "COMBAT ASSISTANCE SYSTEMS", UDim2.new(0, 360, 0, 300), UDim2.new(0, 0, 0, 0), "🎯")
    
    ui.CreateInlineToggle(CardAim, "🎯 Enable Aimbot (Hold Right-Click)", 55, settings.aimbotEnabled, function(state) settings.aimbotEnabled = state end)
    ui.CreateInlineToggle(CardAim, "🛡 Aimbot Team-Check", 90, settings.aimbotTeamCheck, function(state) settings.aimbotTeamCheck = state end)
    ui.CreateInlineToggle(CardAim, "⭕ Show FOV Radius Circle", 125, settings.fovEnabled, function(state) settings.fovEnabled = state end)

    -- Ziel-Körperteil Toggle (Button-Wechsler)
    local partBtnFrame = Instance.new("Frame", CardAim)
    partBtnFrame.Size = UDim2.new(1, -32, 0, 30); partBtnFrame.Position = UDim2.new(0, 16, 0, 160); partBtnFrame.BackgroundTransparency = 1
    
    local partLbl = Instance.new("TextLabel", partBtnFrame)
    partLbl.Text = "🎯 TARGET BONE:"; partLbl.Font = Enum.Font.GothamBold; partLbl.TextSize = 11; partLbl.TextColor3 = Color3.fromRGB(148, 163, 184); partLbl.Size = UDim2.new(0, 120, 1, 0); partLbl.BackgroundTransparency = 1; partLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local partBtn = Instance.new("TextButton", partBtnFrame)
    partBtn.Size = UDim2.new(0, 120, 0, 24); partBtn.Position = UDim2.new(1, -120, 0.5, -12); partBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59); partBtn.Text = settings.aimbotTargetPart:upper(); partBtn.Font = Enum.Font.GothamBold; partBtn.TextColor3 = Color3.fromRGB(56, 189, 248); partBtn.TextSize = 10
    Instance.new("UICorner", partBtn).CornerRadius = UDim.new(0, 5)
    
    partBtn.MouseButton1Click:Connect(function()
        if settings.aimbotTargetPart == "Head" then
            settings.aimbotTargetPart = "HumanoidRootPart"
            partBtn.Text = "TORSO (HRP)"
        else
            settings.aimbotTargetPart = "Head"
            partBtn.Text = "HEAD"
        end
    end)

    -- Rechte Karte: Slider für FOV & Smoothing
    local CardSliders = ui.CreateCard(AimbotPage, "AIM CONVERGENCE SETTINGS", UDim2.new(0, 260, 0, 300), UDim2.new(0, 380, 0, 0), "⚙")

    -- Funktion zur Erstellung eines universellen Sliders
    local function createAimSlider(title, min, max, default, y, suffix, callback)
        local lbl = Instance.new("TextLabel", CardSliders)
        lbl.Text = title; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 9; lbl.TextColor3 = Color3.fromRGB(71, 85, 105); lbl.Position = UDim2.new(0, 14, 0, y); lbl.Size = UDim2.new(0, 180, 0, 15); lbl.BackgroundTransparency = 1
        
        local track = Instance.new("Frame", CardSliders)
        track.Size = UDim2.new(1, -95, 0, 6); track.Position = UDim2.new(0, 14, 0, y + 25); track.BackgroundColor3 = Color3.fromRGB(30, 41, 59); track.BorderSizePixel = 0
        Instance.new("UICorner", track)
        
        local fill = Instance.new("Frame", track)
        local startPerc = (default - min) / (max - min)
        fill.Size = UDim2.new(startPerc, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(56, 189, 248); fill.BorderSizePixel = 0
        Instance.new("UICorner", fill)
        
        local btn = Instance.new("TextButton", track)
        btn.Size = UDim2.new(0, 12, 0, 12); btn.Position = UDim2.new(startPerc, -6, 0.5, -6); btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); btn.Text = ""
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        
        local box = Instance.new("Frame", CardSliders)
        box.Size = UDim2.new(0, 55, 0, 22); box.Position = UDim2.new(1, -70, 0, y + 15); box.BackgroundColor3 = Color3.fromRGB(20, 30, 54)
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
        
        local valLbl = Instance.new("TextLabel", box)
        valLbl.Size = UDim2.new(1, 0, 1, 0); valLbl.Text = tostring(default) .. suffix; valLbl.Font = Enum.Font.GothamMedium; valLbl.TextSize = 10; valLbl.TextColor3 = Color3.fromRGB(255, 255, 255); valLbl.BackgroundTransparency = 1
        
        local dragging = false
        btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        
        settings.addConnection(title .. "slider", RunService.RenderStepped:Connect(function()
            if dragging then
                local mousePos = UserInputService:GetMouseLocation().X
                local trackPos = track.AbsolutePosition.X
                local trackWidth = track.AbsoluteSize.X
                local percentage = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
                btn.Position = UDim2.new(percentage, -6, 0.5, -6)
                fill.Size = UDim2.new(percentage, 0, 1, 0)
                local exactVal = min + (percentage * (max - min))
                valLbl.Text = string.format("%.0f", exactVal) .. suffix
                callback(exactVal)
            end
        end))
    end

    createAimSlider("AIM FOV RADIUS", 30, 400, settings.fovRadius, 45, "px", function(val) settings.fovRadius = val end)
    createAimSlider("AIM SMOOTHING (LEGIT)", 1, 15, settings.aimbotSmoothing, 115, "x", function(val) settings.aimbotSmoothing = val end)

    ----------------------------------------
    -- FOV KREIS DRAWING ENGINE (Sicher über Roblox Drawing API)
    ----------------------------------------
    local FovCircle = Drawing.new("Circle")
    FovCircle.Thickness = 1.5
    FovCircle.NumSides = 64
    FovCircle.Filled = false
    FovCircle.Transparency = 0.7

    settings.addConnection("fovRenderLoop", RunService.RenderStepped:Connect(function()
        if settings.fovEnabled and settings.aimbotEnabled then
            local mouseLocation = UserInputService:GetMouseLocation()
            FovCircle.Position = Vector2.new(mouseLocation.X, mouseLocation.Y)
            FovCircle.Radius = settings.fovRadius
            FovCircle.Color = settings.colors.Enemy
            FovCircle.Visible = true
        else
            FovCircle.Visible = false
        end
    end))

    ----------------------------------------
    -- AIMBOT MATHEMATIK & LOCK SYSTEM
    ----------------------------------------
    local function getClosestPlayerToMouse()
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mouseLocation = UserInputService:GetMouseLocation()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                local targetPart = player.Character:FindFirstChild(settings.aimbotTargetPart)

                if humanoid.Health > 0 and targetPart then
                    if not settings.aimbotTeamCheck or player.Team ~= LocalPlayer.Team then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        
                        if onScreen then
                            local distanceToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude
                            
                            -- Überprüfen, ob der Spieler innerhalb des eingestellten FOV-Kreises ist
                            if distanceToMouse < settings.fovRadius and distanceToMouse < shortestDistance then
                                closestPlayer = player
                                shortestDistance = distanceToMouse
                            end
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    local isRightMouseDown = false
    settings.addConnection("aimInputBegan", UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = true end
    end))
    settings.addConnection("aimInputEnded", UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then isRightMouseDown = false end
    end))

    -- Der eigentliche Aimbot-Loop (Läuft jeden Frame)
    settings.addConnection("aimbotLoop", RunService.RenderStepped:Connect(function()
        if settings.aimbotEnabled and isRightMouseDown then
            local targetPlayer = getClosestPlayerToMouse()
            if targetPlayer and targetPlayer.Character then
                local targetPart = targetPlayer.Character:FindFirstChild(settings.aimbotTargetPart)
                if targetPart then
                    -- Kamera-Vektor-Berechnung mit Smoothing-Teiler
                    local currentCamCFrame = Camera.CFrame
                    local targetCFrame = CFrame.new(currentCamCFrame.Position, targetPart.Position)
                    
                    Camera.CFrame = currentCamCFrame:Lerp(targetCFrame, 1 / (settings.aimbotSmoothing or 1))
                end
            end
        end
    end))

    -- Cleanup, falls der Hub geschlossen wird
    settings.addConnection("fovCleanup", {Disconnect = function() FovCircle:Destroy() end})

    return AimbotPage
end