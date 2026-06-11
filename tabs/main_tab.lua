-- tabs/main_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local MarketplaceService = game:GetService("MarketplaceService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Nav Tabs
    ui.CreateNavTab("Main Hacks", "🏠", "Main")
    ui.CreateNavTab("Visuals", "👁", "Visuals")
    ui.CreateNavTab("Player", "👤", "Player")
    ui.CreateNavTab("Movement", "🏃", "Movement")
    ui.CreateNavTab("World", "🌐", "World")
    ui.CreateNavTab("Misc", "⚙", "Misc")

    -- Seiten
    ui.CreatePage("Movement")
    ui.CreatePage("World")
    ui.CreatePage("Misc")
    local PlayerPage = ui.CreatePage("Player")
    local MainPage = ui.CreatePage("Main")

    -- ==========================================
    -- PLAYER PAGE
    -- ==========================================
    local PlayerCard = ui.CreateCard(PlayerPage, "PLAYER LIST", UDim2.new(0, 700, 0, 460), UDim2.new(0, 0, 0, 0), "👥")
    
    local PlayerDesc = Instance.new("TextLabel", PlayerCard)
    PlayerDesc.Text = "Teleportiere zu Spielern oder ziehe sie zu dir."
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
    Scroll.ScrollBarThickness = 4
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 6)

    local function createPlayerRow(player)
        if player == LocalPlayer then return end
        local row = Instance.new("Frame", Scroll)
        row.Size = UDim2.new(1, 0, 0, 54)
        row.BackgroundColor3 = Color3.fromRGB(18, 27, 47)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

        -- Avatar, Name, Buttons... (wie vorher)
        local avatar = Instance.new("ImageLabel", row)
        avatar.Size = UDim2.new(0, 34, 0, 34)
        avatar.Position = UDim2.new(0, 10, 0.5, -17)
        avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId
        Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

        local name = Instance.new("TextLabel", row)
        name.Text = player.Name
        name.Position = UDim2.new(0, 54, 0, 10)
        name.Size = UDim2.new(0, 200, 0, 16)
        name.Font = Enum.Font.GothamBold
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.BackgroundTransparency = 1

        local tpBtn = Instance.new("TextButton", row)
        tpBtn.Text = "TP to"
        tpBtn.Size = UDim2.new(0, 80, 0, 28)
        tpBtn.Position = UDim2.new(1, -176, 0.5, -14)
        tpBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 8)

        local bringBtn = Instance.new("TextButton", row)
        bringBtn.Text = "Bring"
        bringBtn.Size = UDim2.new(0, 80, 0, 28)
        bringBtn.Position = UDim2.new(1, -88, 0.5, -14)
        bringBtn.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
        Instance.new("UICorner", bringBtn).CornerRadius = UDim.new(0, 8)

        tpBtn.MouseButton1Click:Connect(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root and target then root.CFrame = target.CFrame + Vector3.new(0, 5, 0) end
        end)

        bringBtn.MouseButton1Click:Connect(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root and target then target.CFrame = root.CFrame + Vector3.new(0, 5, 0) end
        end)
    end

    local function refreshList()
        Scroll:ClearAllChildren()
        for _, p in Players:GetPlayers() do
            createPlayerRow(p)
        end
    end
    RefreshBtn.MouseButton1Click:Connect(refreshList)
    Players.PlayerAdded:Connect(refreshList)
    Players.PlayerRemoving:Connect(refreshList)
    refreshList()

    -- ==========================================
    -- FLY + NOCLIP
    -- ==========================================
    local function startFly()
        if settings.connections.fly then settings.connections.fly:Disconnect() end
        settings.connections.fly = RunService.RenderStepped:Connect(function()
            if not settings.flyEnabled then return end
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then return end

            hum.PlatformStand = true
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end

            root.AssemblyLinearVelocity = dir * settings.flySpeed
        end)
    end

    local function stopFly()
        if settings.connections.fly then settings.connections.fly:Disconnect() end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end

    local function startNoclip()
        if settings.connections.noclip then settings.connections.noclip:Disconnect() end
        settings.connections.noclip = RunService.Stepped:Connect(function()
            if not settings.noclipEnabled then return end
            local char = LocalPlayer.Character
            if char then
                for _, part in char:GetDescendants() do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end

    local function stopNoclip()
        if settings.connections.noclip then settings.connections.noclip:Disconnect() end
    end

    -- ==========================================
    -- MAIN CARDS
    -- ==========================================
    local CardFly = ui.CreateCard(MainPage, "FLY MODE", UDim2.new(0, 310, 0, 180), UDim2.new(0, 0, 0, 0), "✈")
    ui.CreateToggle(CardFly, settings.flyEnabled, function(s) 
        settings.flyEnabled = s
        if s then startFly() else stopFly() end 
    end)

    local CardNoclip = ui.CreateCard(MainPage, "NOCLIP", UDim2.new(0, 310, 0, 180), UDim2.new(0, 330, 0, 0), "🛡")
    ui.CreateToggle(CardNoclip, settings.noclipEnabled, function(s) 
        settings.noclipEnabled = s
        if s then startNoclip() else stopNoclip() end 
    end)

    -- TELEPORT SYSTEM
    local CardTp = ui.CreateCard(MainPage, "TELEPORT SYSTEM", UDim2.new(0, 310, 0, 160), UDim2.new(0, 0, 0, 200), "📍")
    local SaveBtn = Instance.new("TextButton", CardTp)
    SaveBtn.Size = UDim2.new(1, -32, 0, 38)
    SaveBtn.Position = UDim2.new(0, 16, 0, 55)
    SaveBtn.Text = "💾 Save Position"
    SaveBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 54)
    Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 8)

    local TpBtn = Instance.new("TextButton", CardTp)
    TpBtn.Size = UDim2.new(1, -32, 0, 38)
    TpBtn.Position = UDim2.new(0, 16, 0, 105)
    TpBtn.Text = "🚀 Teleport to Waypoint"
    TpBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 54)
    Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 8)

    SaveBtn.MouseButton1Click:Connect(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            settings.savedCFrame = root.CFrame
            SaveBtn.Text = "✓ Saved!"
            task.wait(1)
            SaveBtn.Text = "💾 Save Position"
        end
    end)

    TpBtn.MouseButton1Click:Connect(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and settings.savedCFrame then
            root.CFrame = settings.savedCFrame
            TpBtn.Text = "✓ Teleported!"
            task.wait(1)
            TpBtn.Text = "🚀 Teleport to Waypoint"
        end
    end)

    -- ==========================================
    -- GAMEPASS UNLOCKER (stabilere Version)
    -- ==========================================
    local CardUnlocker = ui.CreateCard(MainPage, "GAMEPASS UNLOCKER", UDim2.new(0, 310, 0, 180), UDim2.new(0, 330, 0, 200), "🪙")

    local UnlockerDesc = Instance.new("TextLabel", CardUnlocker)
    UnlockerDesc.Text = "Unlockt GamePasses & In-App Käufe lokal."
    UnlockerDesc.Font = Enum.Font.Gotham
    UnlockerDesc.TextSize = 11
    UnlockerDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    UnlockerDesc.Position = UDim2.new(0, 16, 0, 45)
    UnlockerDesc.Size = UDim2.new(1, -32, 0, 40)
    UnlockerDesc.BackgroundTransparency = 1
    UnlockerDesc.TextWrapped = true

    local UnlockerStatus = Instance.new("TextLabel", CardUnlocker)
    UnlockerStatus.Position = UDim2.new(0, 16, 0, 125)
    UnlockerStatus.Size = UDim2.new(0, 260, 0, 20)
    UnlockerStatus.Font = Enum.Font.GothamBold
    UnlockerStatus.TextSize = 11
    UnlockerStatus.BackgroundTransparency = 1

    local function updateStatus(state)
        UnlockerStatus.Text = state and "🟢 AKTIV" or "⚪ Bereit"
        UnlockerStatus.TextColor3 = state and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(148, 163, 184)
    end

    local function unlocker(state)
        settings.gamepassUnlockerEnabled = state
        if not state then return end

        -- Hooks (mit pcall für mehr Stabilität)
        pcall(function()
            local old = hookfunction(MarketplaceService.UserOwnsGamePassAsync, function(...) 
                if settings.gamepassUnlockerEnabled then return true end
                return old(...)
            end)
        end)

        pcall(function()
            local oldName = hookmetamethod(game, "__namecall", function(self, ...)
                if settings.gamepassUnlockerEnabled and (getnamecallmethod() == "UserOwnsGamePassAsync" or getnamecallmethod() == "PlayerOwnsAsset") then
                    return true
                end
                return oldName(self, ...)
            end)
        end)

        print("FreezyHub GamePass Unlocker aktiviert")
    end

    ui.CreateToggle(CardUnlocker, settings.gamepassUnlockerEnabled, function(s)
        unlocker(s)
        updateStatus(s)
    end)

    if settings.gamepassUnlockerEnabled then unlocker(true) end

    return MainPage
end