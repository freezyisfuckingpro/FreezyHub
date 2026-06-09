-- tabs/main_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Registrierung aller Nav-Knöpfe in der Seitenleiste
    ui.CreateNavTab("Main Hacks", "🏠", "Main")
    ui.CreateNavTab("Visuals", "👁", "Visuals")
    ui.CreateNavTab("Player", "👤", "Player")
    ui.CreateNavTab("Movement", "🏃", "Movement")
    ui.CreateNavTab("World", "🌐", "World")
    ui.CreateNavTab("Misc", "⚙", "Misc")
    ui.CreateNavTab("Aimbot & FOV", "🎯", "Aimbot")

    -- Leere Platzhalter-Seiten für die restlichen Menüs erzeugen
    ui.CreatePage("Player")
    ui.CreatePage("Movement")
    ui.CreatePage("World")
    ui.CreatePage("Misc")
    ui.CreatePage("Aimbot")
    local MainPage = ui.CreatePage("Main")

    -- Fly Card
    local CardFly = ui.CreateCard(MainPage, "FLY MODE", UDim2.new(0, 310, 0, 180), UDim2.new(0, 0, 0, 0), "✈")

    local FlyDesc = Instance.new("TextLabel", CardFly)
    FlyDesc.Text = "Ermöglicht dir zu fliegen. Steuerung: WASD + Space/Shift."; FlyDesc.Font = Enum.Font.Gotham; FlyDesc.TextSize = 11; FlyDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    FlyDesc.Position = UDim2.new(0, 16, 0, 45); FlyDesc.Size = UDim2.new(1, -32, 0, 32); FlyDesc.BackgroundTransparency = 1; FlyDesc.TextWrapped = true; FlyDesc.TextXAlignment = Enum.TextXAlignment.Left

    local SpeedTitle = Instance.new("TextLabel", CardFly)
    SpeedTitle.Text = "GESCHWINDIGKEIT"; SpeedTitle.Font = Enum.Font.GothamBold; SpeedTitle.TextSize = 9; SpeedTitle.TextColor3 = Color3.fromRGB(71, 85, 105)
    SpeedTitle.Position = UDim2.new(0, 16, 0, 95); SpeedTitle.Size = UDim2.new(0, 150, 0, 15); SpeedTitle.BackgroundTransparency = 1; SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left

    local SliderTrack = Instance.new("Frame", CardFly)
    SliderTrack.Size = UDim2.new(1, -85, 0, 6); SliderTrack.Position = UDim2.new(0, 16, 0, 128); SliderTrack.BackgroundColor3 = Color3.fromRGB(30, 41, 59); SliderTrack.BorderSizePixel = 0
    Instance.new("UICorner", SliderTrack)

    local SliderFill = Instance.new("Frame", SliderTrack)
    SliderFill.Size = UDim2.new(0.2, 0, 1, 0); SliderFill.BackgroundColor3 = Color3.fromRGB(56, 189, 248); SliderFill.BorderSizePixel = 0
    Instance.new("UICorner", SliderFill)

    local SliderBtn = Instance.new("TextButton", SliderTrack)
    SliderBtn.Size = UDim2.new(0, 14, 0, 14); SliderBtn.Position = UDim2.new(0.2, -7, 0.5, -7); SliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); SliderBtn.Text = ""
    Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

    local SliderBox = Instance.new("Frame", CardFly)
    SliderBox.Size = UDim2.new(0, 45, 0, 24); SliderBox.Position = UDim2.new(1, -55, 0, 118); SliderBox.BackgroundColor3 = Color3.fromRGB(20, 30, 54)
    Instance.new("UICorner", SliderBox).CornerRadius = UDim.new(0, 6)

    local SliderValue = Instance.new("TextLabel", SliderBox)
    SliderValue.Size = UDim2.new(1, 0, 1, 0); SliderValue.Text = "50"; SliderValue.Font = Enum.Font.GothamMedium; SliderValue.TextSize = 11; SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255); SliderValue.BackgroundTransparency = 1

    local draggingSlider = false
    SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end end)
    settings.addConnection("slider", RunService.RenderStepped:Connect(function()
        if draggingSlider then
            local mousePos = UserInputService:GetMouseLocation().X
            local trackPos = SliderTrack.AbsolutePosition.X
            local trackWidth = SliderTrack.AbsoluteSize.X
            local percentage = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
            SliderBtn.Position = UDim2.new(percentage, -7, 0.5, -7)
            SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            settings.flySpeed = math.round(percentage * 250)
            SliderValue.Text = tostring(settings.flySpeed)
        end
    end))

    ui.CreateToggle(CardFly, false, function(state)
        settings.flyEnabled = state
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if settings.flyEnabled and root and humanoid then
            humanoid.PlatformStand = true
            local flyConn = RunService.RenderStepped:Connect(function()
                if not settings.flyEnabled or not root.Parent then settings.connections.fly:Disconnect() return end
                local moveDirection = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0, 1, 0) end
                root.Velocity = moveDirection * settings.flySpeed
            end)
            settings.addConnection("fly", flyConn)
        else
            if settings.connections.fly then settings.connections.fly:Disconnect() end
            if humanoid then humanoid.PlatformStand = false end
            if root then root.Velocity = Vector3.new(0, 0, 0) end
        end
    end)

    -- Noclip Card
    local CardNoclip = ui.CreateCard(MainPage, "NOCLIP", UDim2.new(0, 310, 0, 180), UDim2.new(0, 330, 0, 0), "🛡")
    local NoclipDesc = Instance.new("TextLabel", CardNoclip)
    NoclipDesc.Text = "Deaktiviert Kollisionen. Du kannst durch Wände gehen."; NoclipDesc.Font = Enum.Font.Gotham; NoclipDesc.TextSize = 11; NoclipDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    NoclipDesc.Position = UDim2.new(0, 16, 0, 45); NoclipDesc.Size = UDim2.new(1, -32, 0, 32); NoclipDesc.BackgroundTransparency = 1; NoclipDesc.TextWrapped = true; NoclipDesc.TextXAlignment = Enum.TextXAlignment.Left

    ui.CreateToggle(CardNoclip, false, function(state)
        settings.noclipEnabled = state
        if settings.noclipEnabled then
            settings.addConnection("noclip", RunService.Stepped:Connect(function()
                if settings.noclipEnabled and LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                    end
                end
            end))
        else
            if settings.connections.noclip then settings.connections.noclip:Disconnect() end
        end
    end)

    -- Teleport CardD
    local CardTp = ui.CreateCard(MainPage, "TELEPORT SYSTEM", UDim2.new(0, 310, 0, 160), UDim2.new(0, 0, 0, 200), "📍")
    local SaveAction = Instance.new("TextButton", CardTp)
    SaveAction.Size = UDim2.new(1, -32, 0, 38); SaveAction.Position = UDim2.new(0, 16, 0, 55); SaveAction.BackgroundColor3 = Color3.fromRGB(20, 30, 54); SaveAction.Text = "💾 Save Position"; SaveAction.Font = Enum.Font.GothamMedium; SaveAction.TextSize = 11; SaveAction.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", SaveAction).CornerRadius = UDim.new(0, 8)

    local TpAction = Instance.new("TextButton", CardTp)
    TpAction.Size = UDim2.new(1, -32, 0, 38); TpAction.Position = UDim2.new(0, 16, 0, 105); TpAction.BackgroundColor3 = Color3.fromRGB(20, 30, 54); TpAction.Text = "🚀 Teleport to Waypoint"; TpAction.Font = Enum.Font.GothamMedium; TpAction.TextSize = 11; TpAction.TextColor3 = Color3.fromRGB(100, 116, 139)
    Instance.new("UICorner", TpAction).CornerRadius = UDim.new(0, 8)

    SaveAction.MouseButton1Click:Connect(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            settings.savedCFrame = root.CFrame
            SaveAction.Text = "✓ Position Saved!"; SaveAction.TextColor3 = Color3.fromRGB(34, 197, 94)
            TpAction.TextColor3 = Color3.fromRGB(56, 189, 248)
            task.wait(1)
            SaveAction.Text = "💾 Save Position"; SaveAction.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    TpAction.MouseButton1Click:Connect(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and settings.savedCFrame then
            root.CFrame = settings.savedCFrame
            TpAction.Text = "✓ Teleport Success!"; TpAction.TextColor3 = Color3.fromRGB(34, 197, 94)
            task.wait(1)
            TpAction.Text = "🚀 Teleport to Waypoint"; TpAction.TextColor3 = Color3.fromRGB(56, 189, 248)
        end
    end)

    -- Auto Farm Card
    local CardFarm = ui.CreateCard(MainPage, "AUTO-FARM fields", UDim2.new(0, 310, 0, 160), UDim2.new(0, 330, 0, 200), "🌿")
    local StatusLbl = Instance.new("TextLabel", CardFarm)
    StatusLbl.Size = UDim2.new(0, 135, 0, 32); StatusLbl.Position = UDim2.new(0, 16, 0, 105); StatusLbl.Text = "Bereit..."; StatusLbl.Font = Enum.Font.GothamMedium; StatusLbl.TextColor3 = Color3.fromRGB(56, 189, 248); StatusLbl.BackgroundTransparency = 1; StatusLbl.TextXAlignment = Enum.TextXAlignment.Left

    ui.CreateToggle(CardFarm, false, function(state)
        settings.farmEnabled = state
        StatusLbl.TextColor3 = state and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(56, 189, 248)
        StatusLbl.Text = state and "Aktiv am Farmen" or "Bereit..."
    end)

    return MainPage
end
