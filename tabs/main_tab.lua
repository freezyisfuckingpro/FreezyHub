-- tabs/main_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Registrierung aller Buttons in der Navigationsleiste
    ui.CreateNavTab("Main Hacks", "🏠", "Main")
    ui.CreateNavTab("Visuals", "👁", "Visuals")
    ui.CreateNavTab("Player", "👤", "Player") 
    ui.CreateNavTab("Movement", "🏃", "Movement")
    ui.CreateNavTab("World", "🌐", "World")
    ui.CreateNavTab("Misc", "⚙", "Misc")

    -- Generiere leere Platzhalter-Seiten für die restlichen Menüs
    ui.CreatePage("Player")
    ui.CreatePage("Movement")
    ui.CreatePage("World")
    ui.CreatePage("Misc")

    local MainPage = ui.CreatePage("Main")
    
    -- Fly Card
    local CardFly = ui.CreateCard(MainPage, "FLY MODE", UDim2.new(0, 310, 0, 180), UDim2.new(0, 0, 0, 0), "✈")
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

    return MainPage
end