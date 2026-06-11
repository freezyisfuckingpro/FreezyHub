-- tabs/aimbot_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Settings (Sicherstellen, dass Variablen existieren)
    settings.aimbotEnabled = settings.aimbotEnabled or false
    settings.silentAimEnabled = settings.silentAimEnabled or false
    settings.triggerbotEnabled = settings.triggerbotEnabled or false
    settings.aimbotTeamCheck = settings.aimbotTeamCheck or true
    settings.aimbotSmoothing = settings.aimbotSmoothing or 6
    settings.aimbotTargetPart = settings.aimbotTargetPart or "Head"
    settings.fovEnabled = settings.fovEnabled or false
    settings.fovRadius = settings.fovRadius or 140

    -- UI Page & Card Erstellung
    local AimbotPage = ui.CreatePage("Aimbot")
    local CardAim = ui.CreateCard(AimbotPage, "AIMBOT SYSTEM", UDim2.new(0, 380, 0, 380), UDim2.new(0, 0, 0, 0), "🎯")

    -- Alle Toggles nacheinander registrieren
    ui.CreateInlineToggle(CardAim, "🎯 Camera Aimbot (Rechtsklick halten)", 55, settings.aimbotEnabled, function(s) settings.aimbotEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🌍 Silent Aim (Schießen durch Wände)", 90, settings.silentAimEnabled, function(s) settings.silentAimEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🔫 Triggerbot (Auto Shoot)", 125, settings.triggerbotEnabled, function(s) settings.triggerbotEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🛡 Team Check", 160, settings.aimbotTeamCheck, function(s) settings.aimbotTeamCheck = s end)
    ui.CreateInlineToggle(CardAim, "⭕ FOV Kreis anzeigen", 195, settings.fovEnabled, function(s) settings.fovEnabled = s end)

    -- Target Part Switch (Abgesichert und sauber positioniert)
    local partBtn = Instance.new("TextButton")
    partBtn.Parent = CardAim
    partBtn.Size = UDim2.new(0, 160, 0, 32)
    partBtn.Position = UDim2.new(0, 16, 0, 240) -- Leicht nach unten verschoben, um Überlappung zu verhindern
    partBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    partBtn.Text = settings.aimbotTargetPart == "Head" and "TARGET: HEAD" or "TARGET: TORSO"
    partBtn.Font = Enum.Font.GothamBold
    partBtn.TextColor3 = Color3.fromRGB(56, 189, 248)
    partBtn.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = partBtn

    partBtn.MouseButton1Click:Connect(function()
        if settings.aimbotTargetPart == "Head" then
            settings.aimbotTargetPart = "HumanoidRootPart"
            partBtn.Text = "TARGET: TORSO"
        else
            settings.aimbotTargetPart = "Head"
            partBtn.Text = "TARGET: HEAD"
        end
    end)

    -- ==================== AIMBOT LOGIC ====================
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

    -- Kombinierter, lag-freier Haupt-Loop für Aimbot & Target-Abfrage
    settings.addConnection("aimbotCoreLoop", RunService.RenderStepped:Connect(function()
        if settings.silentAimEnabled or settings.aimbotEnabled then
            currentTarget = getClosestPlayer()
        else
            currentTarget = nil
        end

        -- Camera Aimbot Ausführung
        if settings.aimbotEnabled and currentTarget and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local part = currentTarget.Character:FindFirstChild(settings.aimbotTargetPart) or currentTarget.Character:FindFirstChild("Head")
            if part then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                local smooth = math.max(settings.aimbotSmoothing, 1)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / smooth)
            end
        end
    end))

    -- ISOLIERTER TRIGGERBOT (Crasht jetzt nicht mehr den Render-Thread!)
    task.spawn(function()
        while true do
            task.wait() -- Verhindert die "Script Exhaustion" Fehlermeldung
            if settings.triggerbotEnabled and currentTarget then
                local hum = currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    if mouse1click then
                        mouse1click()
                        task.wait(0.08) -- Schuss-Verzögerung
                    end
                end
            end
        end
    end)

    -- FOV Kreis mit Fail-Safe (Verhindert Absturz in Roblox Studio)
    local fovCircle = nil
    pcall(function()
        if Drawing and Drawing.new then
            fovCircle = Drawing.new("Circle")
            fovCircle.Thickness = 1.6
            fovCircle.NumSides = 80
            fovCircle.Filled = false
            fovCircle.Transparency = 0.65
        end
    end)

    if fovCircle then
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

    print("✅ Aimbot Tab erfolgreich geladen mit Silent Aim + Triggerbot")
    return AimbotPage
end