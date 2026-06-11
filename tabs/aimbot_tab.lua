-- tabs/aimbot_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Settings initialisieren
    settings.aimbotEnabled = settings.aimbotEnabled or false
    settings.silentAimEnabled = settings.silentAimEnabled or false
    settings.triggerbotEnabled = settings.triggerbotEnabled or false
    settings.aimbotTeamCheck = settings.aimbotTeamCheck or true
    settings.aimbotSmoothing = settings.aimbotSmoothing or 6
    settings.aimbotTargetPart = settings.aimbotTargetPart or "Head"
    settings.fovEnabled = settings.fovEnabled or true
    settings.fovRadius = settings.fovRadius or 140

    -- UI Seiten-Erstellung
    local AimbotPage = ui.CreatePage("Aimbot")
    local CardAim = ui.CreateCard(AimbotPage, "AIMBOT SYSTEM", UDim2.new(0, 380, 0, 380), UDim2.new(0, 0, 0, 0), "🎯")

    ui.CreateInlineToggle(CardAim, "🎯 Camera Aimbot (Rechtsklick halten)", 55, settings.aimbotEnabled, function(s) settings.aimbotEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🌍 Silent Aim (Schießen durch Wände)", 90, settings.silentAimEnabled, function(s) settings.silentAimEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🔫 Triggerbot (Auto Shoot)", 125, settings.triggerbotEnabled, function(s) settings.triggerbotEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🛡 Team Check", 160, settings.aimbotTeamCheck, function(s) settings.aimbotTeamCheck = s end)
    ui.CreateInlineToggle(CardAim, "⭕ FOV Kreis anzeigen", 195, settings.fovEnabled, function(s) settings.fovEnabled = s end)

    -- Target Part Switch Button
    local partBtn = Instance.new("TextButton", CardAim)
    partBtn.Size = UDim2.new(0, 160, 0, 32)
    partBtn.Position = UDim2.new(0, 16, 0, 235)
    partBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    partBtn.Text = settings.aimbotTargetPart == "Head" and "HEAD" or "TORSO"
    partBtn.Font = Enum.Font.GothamBold
    partBtn.TextColor3 = Color3.fromRGB(56, 189, 248)
    Instance.new("UICorner", partBtn).CornerRadius = UDim.new(0, 6)

    partBtn.MouseButton1Click:Connect(function()
        settings.aimbotTargetPart = settings.aimbotTargetPart == "Head" and "HumanoidRootPart" or "Head"
        partBtn.Text = settings.aimbotTargetPart == "Head" and "HEAD" or "TORSO"
    end)

    -- ==================== LOGIC ====================
    local currentTarget = nil

    local function getClosestPlayer()
        local closest, shortest = nil, math.huge
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer or not player.Character then continue end
            if settings.aimbotTeamCheck and player.Team == LocalPlayer.Team then continue end

            local hum = player.Character:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end

            local part = player.Character:FindFirstChild(settings.aimbotTargetPart) or player.Character:FindFirstChild("Head")
            if not part then continue end

            local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end

            local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
            if dist < settings.fovRadius and dist < shortest then
                shortest = dist
                closest = player
            end
        end
        return closest
    end

    -- Kombinierter, stabiler Tracking-Loop (Verhindert Lag-Spikes)
    settings.addConnection("aimbotLoop", RunService.RenderStepped:Connect(function()
        if settings.silentAimEnabled or settings.aimbotEnabled then
            currentTarget = getClosestPlayer()
        else
            currentTarget = nil
        end

        if settings.aimbotEnabled and currentTarget and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local part = currentTarget.Character:FindFirstChild(settings.aimbotTargetPart) or currentTarget.Character:FindFirstChild("Head")
            if part then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / math.max(settings.aimbotSmoothing, 1))
            end
        end
    end))

    -- Sicherer Triggerbot (Läuft in eigenem Thread, crasht die UI nicht mehr)
    task.spawn(function()
        while true do
            task.wait() -- Entlastet die CPU
            if settings.triggerbotEnabled and currentTarget then
                local hum = currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    if mouse1click then
                        mouse1click()
                        task.wait(0.08) -- Schussverzögerung (Sicherer Wert)
                    end
                end
            end
        end
    end)

    -- FOV Kreis mit Studio-Sicherheitscheck (Verhindert "nil value"-Absturz)
    local fovCircle = nil
    local pcallSuccess = pcall(function()
        if Drawing and Drawing.new then
            fovCircle = Drawing.new("Circle")
            fovCircle.Thickness = 1.6
            fovCircle.NumSides = 80
            fovCircle.Filled = false
            fovCircle.Transparency = 0.65
        end
    end)

    if pcallSuccess and fovCircle then
        settings.addConnection("fovCircleUpdate", RunService.RenderStepped:Connect(function()
            if settings.fovEnabled then
                local mouse = UserInputService:GetMouseLocation()
                fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
                fovCircle.Radius = settings.fovRadius
                fovCircle.Color = Color3.fromRGB(255, 80, 80)
                fovCircle.Visible = true
            else
                fovCircle.Visible = false
            end
        end))
    end

    print("✅ UI-Tab erfolgreich ohne Abstürze geladen!")
    return AimbotPage
end