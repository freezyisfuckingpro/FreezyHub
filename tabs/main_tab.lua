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

    -- Platzhalter-Seiten für die übrigen Menüs
    ui.CreatePage("Movement")
    ui.CreatePage("World")
    ui.CreatePage("Misc")
    ui.CreatePage("Aimbot")
    local PlayerPage = ui.CreatePage("Player")
    local MainPage = ui.CreatePage("Main")

    -- Player List Card
    local PlayerCard = ui.CreateCard(PlayerPage, "PLAYER LIST", UDim2.new(0, 700, 0, 460), UDim2.new(0, 0, 0, 0), "👥")
    local PlayerDesc = Instance.new("TextLabel", PlayerCard)
    PlayerDesc.Text = "Teleportiere zu Spielern oder ziehe sie zu dir. Die Liste aktualisiert sich automatisch." 
    PlayerDesc.Font = Enum.Font.Gotham
    PlayerDesc.TextSize = 11
    PlayerDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    PlayerDesc.Position = UDim2.new(0, 16, 0, 42)
    PlayerDesc.Size = UDim2.new(1, -32, 0, 30)
    PlayerDesc.BackgroundTransparency = 1
    PlayerDesc.TextWrapped = true
    PlayerDesc.TextXAlignment = Enum.TextXAlignment.Left

    local RefreshBtn = Instance.new("TextButton", PlayerCard)
    RefreshBtn.Size = UDim2.new(0, 110, 0, 30)
    RefreshBtn.Position = UDim2.new(1, -126, 0, 12)
    RefreshBtn.Text = "🔄 Refresh"
    RefreshBtn.Font = Enum.Font.GothamBold
    RefreshBtn.TextSize = 10
    RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 54)
    Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 8)

    local Scroll = Instance.new("ScrollingFrame", PlayerCard)
    Scroll.Size = UDim2.new(1, -24, 1, -82)
    Scroll.Position = UDim2.new(0, 12, 0, 78)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollDirection = Enum.ScrollDirection.Y
    Scroll.ClipsDescendants = true

    local ListHolder = Instance.new("Frame", Scroll)
    ListHolder.Size = UDim2.new(1, -8, 0, 0)
    ListHolder.BackgroundTransparency = 1
    ListHolder.AutomaticSize = Enum.AutomaticSize.Y

    local ListLayout = Instance.new("UIListLayout", ListHolder)
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function createPlayerRow(player)
        local row = Instance.new("Frame")
        row.Name = "PlayerRow"
        row.Parent = ListHolder
        row.Size = UDim2.new(1, 0, 0, 54)
        row.BackgroundColor3 = Color3.fromRGB(18, 27, 47)
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

        local avatar = Instance.new("ImageLabel", row)
        avatar.Size = UDim2.new(0, 34, 0, 34)
        avatar.Position = UDim2.new(0, 10, 0.5, -17)
        avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
        Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(0, 220, 0, 16)
        nameLabel.Position = UDim2.new(0, 54, 0, 10)
        nameLabel.Text = player.Name
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left

        local roleLabel = Instance.new("TextLabel", row)
        roleLabel.Size = UDim2.new(0, 180, 0, 14)
        roleLabel.Position = UDim2.new(0, 54, 0, 28)
        roleLabel.Text = player == LocalPlayer and "You" or (player.Team and player.Team.Name or "Neutral")
        roleLabel.Font = Enum.Font.Gotham
        roleLabel.TextSize = 10
        roleLabel.TextColor3 = Color3.fromRGB(148, 163, 184)
        roleLabel.BackgroundTransparency = 1
        roleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local tpBtn = Instance.new("TextButton", row)
        tpBtn.Size = UDim2.new(0, 80, 0, 28)
        tpBtn.Position = UDim2.new(1, -176, 0.5, -14)
        tpBtn.Text = "TP to"
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.TextSize = 10
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 8)

        local bringBtn = Instance.new("TextButton", row)
        bringBtn.Size = UDim2.new(0, 80, 0, 28)
        bringBtn.Position = UDim2.new(1, -88, 0.5, -14)
        bringBtn.Text = "Bring"
        bringBtn.Font = Enum.Font.GothamBold
        bringBtn.TextSize = 10
        bringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        bringBtn.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
        Instance.new("UICorner", bringBtn).CornerRadius = UDim.new(0, 8)

        tpBtn.MouseButton1Click:Connect(function()
            local me = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if me and target then
                me.CFrame = target.CFrame + Vector3.new(0, 4, 0)
            end
        end)

        bringBtn.MouseButton1Click:Connect(function()
            local me = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if me and target then
                target.CFrame = me.CFrame + Vector3.new(0, 4, 0)
            end
        end)

        return row
    end

    local function refreshPlayerList()
        for _, child in ipairs(ListHolder:GetChildren()) do
            if child.Name == "PlayerRow" then
                child:Destroy()
            end
        end

        local list = Players:GetPlayers()
        table.sort(list, function(a, b)
            return a.Name:lower() < b.Name:lower()
        end)

        for _, player in ipairs(list) do
            createPlayerRow(player)
        end

        Scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(0, #list * 60))
    end

    RefreshBtn.MouseButton1Click:Connect(function()
        task.defer(refreshPlayerList)
    end)
    Players.PlayerAdded:Connect(function()
        task.defer(refreshPlayerList)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(refreshPlayerList)
    end)
    task.defer(refreshPlayerList)
    
    local function startFly()
        if settings.connections.fly then settings.connections.fly:Disconnect() end

        settings.connections.fly = RunService.RenderStepped:Connect(function()
            if not settings.flyEnabled then return end

            local character = LocalPlayer.Character
            if not character then return end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local root = character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not root then return end

            humanoid.PlatformStand = true

            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0, 1, 0) end

            root.AssemblyLinearVelocity = moveDirection * settings.flySpeed
        end)
    end

    local function stopFly()
        if settings.connections.fly then settings.connections.fly:Disconnect() end
        settings.connections.fly = nil

        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end

    local function startNoclip()
        if settings.connections.noclip then settings.connections.noclip:Disconnect() end

        settings.connections.noclip = RunService.Stepped:Connect(function()
            if not settings.noclipEnabled then return end

            local character = LocalPlayer.Character
            if not character then return end

            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    end

    local function stopNoclip()
        if settings.connections.noclip then settings.connections.noclip:Disconnect() end
        settings.connections.noclip = nil
    end

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

    ui.CreateToggle(CardFly, settings.flyEnabled or false, function(state)
        settings.flyEnabled = state
        if state then
            startFly()
        else
            stopFly()
        end
    end)

    -- Noclip Card
    local CardNoclip = ui.CreateCard(MainPage, "NOCLIP", UDim2.new(0, 310, 0, 180), UDim2.new(0, 330, 0, 0), "🛡")
    local NoclipDesc = Instance.new("TextLabel", CardNoclip)
    NoclipDesc.Text = "Deaktiviert Kollisionen. Du kannst durch Wände gehen."; NoclipDesc.Font = Enum.Font.Gotham; NoclipDesc.TextSize = 11; NoclipDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    NoclipDesc.Position = UDim2.new(0, 16, 0, 45); NoclipDesc.Size = UDim2.new(1, -32, 0, 32); NoclipDesc.BackgroundTransparency = 1; NoclipDesc.TextWrapped = true; NoclipDesc.TextXAlignment = Enum.TextXAlignment.Left

    ui.CreateToggle(CardNoclip, settings.noclipEnabled or false, function(state)
        settings.noclipEnabled = state
        if state then
            startNoclip()
        else
            stopNoclip()
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

    if settings.flyEnabled then
        startFly()
    end
    if settings.noclipEnabled then
        startNoclip()
    end

    LocalPlayer.CharacterAdded:Connect(function()
        if settings.flyEnabled then
            task.defer(startFly)
        end
        if settings.noclipEnabled then
            task.defer(startNoclip)
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