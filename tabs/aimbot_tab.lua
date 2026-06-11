-- tabs/aimbot_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Fehlende Variablen in den Settings dynamisch nachladen (damit es nicht abstürzt)
    settings.silentAimEnabled = settings.silentAimEnabled or false
    settings.triggerbotEnabled = settings.triggerbotEnabled or false

    -- === WICHTIG: HIER WIRD DIE PAGE AUS DEINEM FREEZY HUB GEHOLT ===
    -- Da die Seite "Aimbot & FOV" im Screenshot schon da ist, holen wir sie uns,
    -- anstatt eine komplett neue, leere Seite zu erstellen.
    local AimbotPage = ui.GetPage and ui.GetPage("Aimbot & FOV") or ui.CreatePage("Aimbot & FOV")

    -- Wir fügen die neuen Toggles direkt in die bestehende UI ein.
    -- Da Freezy Hub automatische Layouts nutzt, lassen wir die Zahlen-Offsets (55, 90, 125) weg!
    
    -- Überprüfen, ob die Library AddToggle oder CreateToggle nutzt
    local toggleFunc = AimbotPage.AddToggle or AimbotPage.CreateToggle
    
    if toggleFunc then
        toggleFunc(AimbotPage, "🌍 Silent Aim (Schießen durch Wände)", settings.silentAimEnabled, function(s) 
            settings.silentAimEnabled = s 
        end)
        
        toggleFunc(AimbotPage, "🔫 Triggerbot (Auto Shoot)", settings.triggerbotEnabled, function(s) 
            settings.triggerbotEnabled = s 
        end)
    else
        -- Fallback: Falls dein Hub die Toggles direkt über das globale UI-Objekt regelt
        if ui.CreateToggle then
            ui.CreateToggle(AimbotPage, "🌍 Silent Aim (Schießen durch Wände)", settings.silentAimEnabled, function(s) settings.silentAimEnabled = s end)
            ui.CreateToggle(AimbotPage, "🔫 Triggerbot (Auto Shoot)", settings.triggerbotEnabled, function(s) settings.triggerbotEnabled = s end)
        end
    end

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

    -- Zentraler, stabiler Tracking-Loop
    settings.addConnection("aimbotTrackingLoop", RunService.RenderStepped:Connect(function()
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
                -- Nutzt das Smoothing aus deiner settings.lua
                local smooth = math.max(settings.aimbotSmoothing, 1)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / smooth)
            end
        end
    end))

    -- Sicherer Triggerbot (In separatem Thread, friert die UI nicht ein)
    task.spawn(function()
        while true do
            task.wait()
            if settings.triggerbotEnabled and currentTarget then
                local hum = currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    if mouse1click then
                        mouse1click()
                        task.wait(0.07) -- Kurze Verzögerung zwischen den automatischen Klicks
                    end
                end
            end
        end
    end)

    -- FOV Kreis Update (Nutzt fovColor aus deiner settings.lua)
    local fovCircle = nil
    pcall(function()
        if Drawing and Drawing.new then
            fovCircle = Drawing.new("Circle")
            fovCircle.Thickness = 1.5
            fovCircle.NumSides = 60
            fovCircle.Filled = false
            fovCircle.Transparency = 0.7
        end
    end)

    if fovCircle then
        settings.addConnection("fovCircleRender", RunService.RenderStepped:Connect(function()
            if settings.fovEnabled then
                local mouse = UserInputService:GetMouseLocation()
                fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
                fovCircle.Radius = settings.fovRadius
                fovCircle.Color = settings.fovColor or Color3.fromRGB(255, 255, 255)
                fovCircle.Visible = true
            else
                fovCircle.Visible = false
            end
        end))
    end

    return AimbotPage
end