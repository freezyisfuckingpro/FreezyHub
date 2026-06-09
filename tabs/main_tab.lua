-- tabs/main_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local function disconnectConnection(name)
        if settings.connections[name] then
            settings.connections[name]:Disconnect()
            settings.connections[name] = nil
        end
    end

    local function getRootAndHumanoid()
        local character = LocalPlayer.Character
        if not character then return nil, nil end
        return character:FindFirstChild("HumanoidRootPart"), character:FindFirstChild("Humanoid")
    end

    local function applyFly(state)
        disconnectConnection("fly")
        disconnectConnection("flyRespawn")

        if not state then
            local root, humanoid = getRootAndHumanoid()
            if humanoid then humanoid.PlatformStand = false end
            if root then root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
            return
        end

        local function updateFly()
            local root, humanoid = getRootAndHumanoid()
            if not settings.flyEnabled or not root or not humanoid then return end

            humanoid.PlatformStand = true

            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

            root.AssemblyLinearVelocity = moveDirection * settings.flySpeed
        end

        settings.addConnection("fly", RunService.RenderStepped:Connect(updateFly))
        settings.addConnection("flyRespawn", Players.CharacterAdded:Connect(function()
            task.defer(function()
                if settings.flyEnabled then
                    applyFly(true)
                end
            end)
        end))
    end

    local function applyNoclip(state)
        disconnectConnection("noclip")
        disconnectConnection("noclipRespawn")

        if not state then
            local character = LocalPlayer.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            return
        end

        settings.addConnection("noclip", RunService.Stepped:Connect(function()
            if not settings.noclipEnabled then return end
            local character = LocalPlayer.Character
            if not character then return end
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end))

        settings.addConnection("noclipRespawn", Players.CharacterAdded:Connect(function()
            task.defer(function()
                if settings.noclipEnabled then
                    applyNoclip(true)
                end
            end)
        end))
    end

    -- Registrierung aller Nav-Knöpfe in der Seitenleiste
    ui.CreateNavTab("Main Hacks", "🏠", "Main")
    ui.CreateNavTab("Visuals", "👁", "Visuals")
    ui.CreateNavTab("Player", "👤", "Player")
    ui.CreateNavTab("Movement", "🏃", "Movement")
    ui.CreateNavTab("World", "🌐", "World")
    ui.CreateNavTab("Misc", "⚙", "Misc")
    ui.CreateNavTab("Aimbot & FOV", "🎯", "Aimbot")

    -- Leere Platzhalter-Seiten für die restlichen Menüs erzeugen
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
        applyFly(state)
    end)

    -- Noclip Card
    local CardNoclip = ui.CreateCard(MainPage, "NOCLIP", UDim2.new(0, 310, 0, 180), UDim2.new(0, 330, 0, 0), "🛡")
    local NoclipDesc = Instance.new("TextLabel", CardNoclip)
    NoclipDesc.Text = "Deaktiviert Kollisionen. Du kannst durch Wände gehen."; NoclipDesc.Font = Enum.Font.Gotham; NoclipDesc.TextSize = 11; NoclipDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    NoclipDesc.Position = UDim2.new(0, 16, 0, 45); NoclipDesc.Size = UDim2.new(1, -32, 0, 32); NoclipDesc.BackgroundTransparency = 1; NoclipDesc.TextWrapped = true; NoclipDesc.TextXAlignment = Enum.TextXAlignment.Left

    ui.CreateToggle(CardNoclip, false, function(state)
        settings.noclipEnabled = state
        applyNoclip(state)
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

    -- Player list card
    local PlayerPage = ui.CreatePage("Player")
    local CardPlayers = ui.CreateCard(PlayerPage, "PLAYER LIST", UDim2.new(0, 360, 0, 380), UDim2.new(0, 0, 0, 0), "👤")

    local PlayerList = Instance.new("ScrollingFrame", CardPlayers)
    PlayerList.Size = UDim2.new(1, -24, 1, -70)
    PlayerList.Position = UDim2.new(0, 12, 0, 52)
    PlayerList.BackgroundTransparency = 1
    PlayerList.ScrollBarThickness = 4
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local PlayerLayout = Instance.new("UIListLayout", PlayerList)
    PlayerLayout.Padding = UDim.new(0, 6)

    local function refreshPlayerList()
        for _, obj in ipairs(PlayerList:GetChildren()) do
            if obj:IsA("Frame") then obj:Destroy() end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local row = Instance.new("Frame")
                row.Parent = PlayerList
                row.Size = UDim2.new(1, -8, 0, 38)
                row.BackgroundColor3 = Color3.fromRGB(20, 30, 54)
                row.BorderSizePixel = 0
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

                local nameLabel = Instance.new("TextLabel", row)
                nameLabel.Size = UDim2.new(1, -110, 1, 0)
                nameLabel.Position = UDim2.new(0, 10, 0, 0)
                nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.Font = Enum.Font.GothamMedium
                nameLabel.TextSize = 11
                nameLabel.BackgroundTransparency = 1

                local tpBtn = Instance.new("TextButton", row)
                tpBtn.Size = UDim2.new(0, 44, 0, 24)
                tpBtn.Position = UDim2.new(1, -92, 0.5, -12)
                tpBtn.Text = "TP"
                tpBtn.Font = Enum.Font.GothamBold
                tpBtn.TextSize = 10
                tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                tpBtn.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
                Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
                tpBtn.MouseButton1Click:Connect(function()
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root and targetRoot then
                        root.CFrame = targetRoot.CFrame + Vector3.new(0, 4, 0)
                    end
                end)

                local bringBtn = Instance.new("TextButton", row)
                bringBtn.Size = UDim2.new(0, 56, 0, 24)
                bringBtn.Position = UDim2.new(1, -34, 0.5, -12)
                bringBtn.Text = "BRING"
                bringBtn.Font = Enum.Font.GothamBold
                bringBtn.TextSize = 10
                bringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                bringBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
                Instance.new("UICorner", bringBtn).CornerRadius = UDim.new(0, 6)
                bringBtn.MouseButton1Click:Connect(function()
                    local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root and targetRoot then
                        targetRoot.CFrame = root.CFrame + Vector3.new(0, 4, 0)
                    end
                end)
            end
        end
    end

    refreshPlayerList()
    settings.addConnection("playerListRefresh", Players.PlayerAdded:Connect(refreshPlayerList))
    settings.addConnection("playerListRemove", Players.PlayerRemoving:Connect(refreshPlayerList))

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
