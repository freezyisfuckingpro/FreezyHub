-- tabs/aimbot_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Settings Absicherung & Standardwerte
    settings.aimbotEnabled = settings.aimbotEnabled or false
    settings.silentAimEnabled = settings.silentAimEnabled or false
    settings.magicBulletEnabled = settings.magicBulletEnabled or false -- NEU: Magic Bullet Switch
    settings.triggerbotEnabled = settings.triggerbotEnabled or false
    settings.aimbotTeamCheck = settings.aimbotTeamCheck or true
    settings.aimbotSmoothing = settings.aimbotSmoothing or 6
    settings.aimbotTargetPart = settings.aimbotTargetPart or "Head"
    settings.fovEnabled = settings.fovEnabled or false
    settings.fovRadius = settings.fovRadius or 140
    settings.fovColor = settings.fovColor or Color3.fromRGB(255, 80, 80)

    -- UI Page & Card Erstellung
    local AimbotPage = ui.CreatePage("Aimbot")
    local CardAim = ui.CreateCard(AimbotPage, "AIMBOT SYSTEM", UDim2.new(0, 380, 0, 420), UDim2.new(0, 0, 0, 0), "🎯")

    -- UI Elemente (Reihenfolge & Abstände angepasst für das neue Feature)
    ui.CreateInlineToggle(CardAim, "🎯 Camera Aimbot (Rechtsklick halten)", 55, settings.aimbotEnabled, function(s) settings.aimbotEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🌍 Silent Aim (Normale Umleitung)", 90, settings.silentAimEnabled, function(s) settings.silentAimEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🔮 Magic Bullet (Durch Wände treffen)", 125, settings.magicBulletEnabled, function(s) settings.magicBulletEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🔫 Triggerbot (Auto Shoot)", 160, settings.triggerbotEnabled, function(s) settings.triggerbotEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🛡 Team Check", 195, settings.aimbotTeamCheck, function(s) settings.aimbotTeamCheck = s end)
    ui.CreateInlineToggle(CardAim, "⭕ FOV Kreis anzeigen", 230, settings.fovEnabled, function(s) settings.fovEnabled = s end)

    -- Target Part Switch Button
    local partBtn = Instance.new("TextButton")
    partBtn.Parent = CardAim
    partBtn.Size = UDim2.new(0, 160, 0, 32)
    partBtn.Position = UDim2.new(0, 16, 0, 275)
    partBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    partBtn.Text = settings.aimbotTargetPart == "Head" and "TARGET: HEAD" or "TARGET: TORSO"
    partBtn.Font = Enum.Font.GothamBold
    partBtn.TextColor3 = Color3.fromRGB(56, 189, 248)
    partBtn.TextSize = 13
    
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

    -- ==================== TARGET FINDER ====================
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
            -- Bei Magic Bullet erlauben wir Ziele AUßERHALB der Wand-Sichtlinie, bei normalem Aim nur "onScreen"
            if not settings.magicBulletEnabled and not onScreen then continue end

            local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
            if dist < settings.fovRadius and dist < shortest then
                shortest = dist
                closest = player
            end
        end
        return closest
    end

    -- Haupt-Tracking-Loop
    settings.addConnection("aimbotCoreLoop", RunService.RenderStepped:Connect(function()
        if settings.silentAimEnabled or settings.magicBulletEnabled or settings.aimbotEnabled then
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

    -- ==================== TRIGGERBOT ====================
    task.spawn(function()
        while true do
            task.wait()
            if settings.triggerbotEnabled and currentTarget then
                local hum = currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    if mouse1click then
                        mouse1click()
                        task.wait(0.07)
                    end
                end
            end
        end
    end)

    -- ==================== MAGIC BULLET & SILENT AIM HOOKS ====================
    -- Hook 1: Mouse.Hit / Mouse.Target Umleitung
    local OldIndex
    OldIndex = hookmetamethod(game, "__index", function(Self, Key)
        if (settings.silentAimEnabled or settings.magicBulletEnabled) and currentTarget and not checkcaller() then
            if Self:IsA("Mouse") and (Key == "Hit" or Key == "Target") then
                local part = currentTarget.Character and currentTarget.Character:FindFirstChild(settings.aimbotTargetPart)
                if part then
                    if Key == "Hit" then
                        return part.CFrame
                    elseif Key == "Target" then
                        return part
                    end
                end
            end
        end
        return OldIndex(Self, Key)
    end)

    -- Hook 2: Raycast-Manipulation (Echtes Schießen durch Wände)
    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
        local Args = {...}
        local Method = getnamecallmethod()

        if currentTarget and not checkcaller() then
            -- MAGIC BULLET HOOK (Ignoriert alle Raycast-Treffer auf Wände und leitet direkt um)
            if settings.magicBulletEnabled and Method == "Raycast" then
                local part = currentTarget.Character and currentTarget.Character:FindFirstChild(settings.aimbotTargetPart)
                if part then
                    local origin = Args[1]
                    -- Berechnet die Richtung exakt zum Gegner-Körperteil, anstatt wo du hinkuckst
                    Args[2] = (part.Position - origin).Unit * 1000 
                    return OldNamecall(Self, origin, Args[2], Args[3])
                end
            
            -- NORMALER SILENT AIM HOOK (Standard-Strahlenmanipulation)
            elseif settings.silentAimEnabled and (Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRayWithWhitelist" or Method == "Raycast") then
                local part = currentTarget.Character and currentTarget.Character:FindFirstChild(settings.aimbotTargetPart)
                if part then
                    if Method == "Raycast" and Args[1] and Args[2] then
                        local origin = Args[1]
                        Args[2] = (part.Position - origin).Unit * 1000
                        return OldNamecall(Self, origin, Args[2], Args[3])
                    end
                end
            end
        end
        return OldNamecall(Self, ...)
    end)

    -- ==================== DYNAMISCHER FOV KREIS ====================
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
                
                -- DYNAMISCHES UPDATE: Holt sich die Werte direkt Live aus deinen Settings/Slidern!
                fovCircle.Radius = settings.fovRadius or 140
                fovCircle.Color = settings.fovColor or Color3.fromRGB(255, 80, 80)
                fovCircle.Visible = true
            else
                fovCircle.Visible = false
            end
        end))
    end

    print("✅ Aimbot + Dynamic FOV + Magic Bullet erfolgreich geladen!")
    return AimbotPage
end