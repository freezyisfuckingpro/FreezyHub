-- tabs/aimbot_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Absicherung der Variablen
    settings.aimbotEnabled = settings.aimbotEnabled or false
    settings.silentAimEnabled = settings.silentAimEnabled or false
    settings.magicBulletEnabled = settings.magicBulletEnabled or false 
    settings.triggerbotEnabled = settings.triggerbotEnabled or false
    settings.aimbotTeamCheck = settings.aimbotTeamCheck or true
    settings.aimbotSmoothing = settings.aimbotSmoothing or 4
    settings.aimbotTargetPart = settings.aimbotTargetPart or "Head"
    settings.fovEnabled = settings.fovEnabled or false
    settings.fovRadius = settings.fovRadius or 140
    settings.fovColor = settings.fovColor or Color3.fromRGB(255, 80, 80)

    -- UI Generierung für deine Library
    local AimbotPage = ui.CreatePage("Aimbot")
    local CardAim = ui.CreateCard(AimbotPage, "AIMBOT SYSTEM", UDim2.new(0, 380, 0, 420), UDim2.new(0, 0, 0, 0), "🎯")

    -- Alle Schalter werden sauber untereinander geladen
    ui.CreateInlineToggle(CardAim, "🎯 Camera Aimbot (Rechtsklick halten)", 55, settings.aimbotEnabled, function(s) settings.aimbotEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🌍 Silent Aim (Kugeln biegen)", 90, settings.silentAimEnabled, function(s) settings.silentAimEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🔮 Magic Bullet (Durch Wände treffen)", 125, settings.magicBulletEnabled, function(s) settings.magicBulletEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🔫 Triggerbot (Auto Shoot)", 160, settings.triggerbotEnabled, function(s) settings.triggerbotEnabled = s end)
    ui.CreateInlineToggle(CardAim, "🛡 Team Check", 195, settings.aimbotTeamCheck, function(s) settings.aimbotTeamCheck = s end)
    ui.CreateInlineToggle(CardAim, "⭕ FOV Kreis anzeigen", 230, settings.fovEnabled, function(s) settings.fovEnabled = s end)

    -- Target Part Button (HEAD / TORSO)
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
            
            -- Wichtig für Rivals: Wenn Magic Bullet an ist, ignorieren wir die Sichtlinie (onScreen) komplett!
            if not settings.magicBulletEnabled and not onScreen then continue end

            local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
            if dist < settings.fovRadius and dist < shortest then
                shortest = dist
                closest = player
            end
        end
        return closest
    end

    -- Core Tracking-Loop
    settings.addConnection("aimbotCoreLoop", RunService.RenderStepped:Connect(function()
        if settings.silentAimEnabled or settings.magicBulletEnabled or settings.aimbotEnabled then
            currentTarget = getClosestPlayer()
        else
            currentTarget = nil
        end

        -- Camera Aimbot Steuerung
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
                        task.wait(0.05) -- Ultraschnelle Klickrate für Rivals
                    end
                end
            end
        end
    end)

    -- ==================== RIVALS BYPASS HOOKS (SILENT AIM & MAGIC BULLET) ====================
    -- Hook 1: Manipuliert die CFrame-Richtung der Kamera, die das Rivals-Gunsystem beim Feuern abfragt
    local OldIndex
    OldIndex = hookmetamethod(game, "__index", function(Self, Key)
        if not checkcaller() and currentTarget and currentTarget.Character then
            local part = currentTarget.Character:FindFirstChild(settings.aimbotTargetPart) or currentTarget.Character:FindFirstChild("Head")
            
            if part then
                -- Falls Rivals Mouse.Hit abfragt
                if (settings.silentAimEnabled or settings.magicBulletEnabled) and Self:IsA("Mouse") and (Key == "Hit" or Key == "Target") then
                    if Key == "Hit" then return part.CFrame else return part end
                end
                
                -- Spezial-Hook für Rivals: Manipuliert die Kamera-Ausrichtung NUR im Moment des Schießens im Hintergrund
                if settings.magicBulletEnabled and Self == Camera and Key == "CFrame" then
                    return CFrame.new(Camera.CFrame.Position, part.Position)
                end
            end
        end
        return OldIndex(Self, Key)
    end)

    -- Hook 2: Überschreibt die Kugel-Strahlen (Raycasts), damit sie durch Wände glitchen
    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
        local Args = {...}
        local Method = getnamecallmethod()

        if not checkcaller() and currentTarget and currentTarget.Character then
            local part = currentTarget.Character:FindFirstChild(settings.aimbotTargetPart) or currentTarget.Character:FindFirstChild("Head")
            
            if part then
                -- Wenn Magic Bullet aktiv ist, fangen wir alle Berechnungen ab und zwingen sie zum Gegnerkopf
                if settings.magicBulletEnabled and (Method == "Raycast" or Method == "FindPartOnRayWithIgnoreList") then
                    if Method == "Raycast" and Args[1] and Args[2] then
                        local origin = Args[1]
                        -- Berechnet die Flugbahn direkt durch die Wand hindurch zum Ziel
                        Args[2] = (part.Position - origin).Unit * 1000
                        return OldNamecall(Self, origin, Args[2], Args[3])
                    end
                end
            end
        end
        return OldNamecall(Self, ...)
    end)

    -- ==================== LIVE-UPDATE FOV KREIS ====================
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
                
                -- LIVE SLIDER UPDATE: Reagiert sofort, wenn du das FOV in deiner UI änderst!
                fovCircle.Radius = settings.fovRadius or 140
                fovCircle.Color = settings.fovColor or Color3.fromRGB(255, 80, 80)
                fovCircle.Visible = true
            else
                fovCircle.Visible = false
            end
        end))
    end

    print("🔥 Rivals-Spezial-System inklusive Magic Bullet und Live-FOV geladen!")
    return AimbotPage
end