-- tabs/main_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local MarketplaceService = game:GetService("MarketplaceService")

    -- Nav Tabs
    ui.CreateNavTab("Main Hacks", "🏠", "Main")
    ui.CreateNavTab("Visuals", "👁", "Visuals")
    ui.CreateNavTab("Player", "👤", "Player")
    ui.CreateNavTab("Movement", "🏃", "Movement")
    ui.CreateNavTab("World", "🌐", "World")
    ui.CreateNavTab("Misc", "⚙", "Misc")
    ui.CreateNavTab("Aimbot & FOV", "🎯", "Aimbot")

    -- Seiten erstellen
    ui.CreatePage("Movement")
    ui.CreatePage("World")
    ui.CreatePage("Misc")
    ui.CreatePage("Aimbot")

    local PlayerPage = ui.CreatePage("Player")
    local MainPage = ui.CreatePage("Main")

    -- ==========================================
    -- PLAYER PAGE
    -- ==========================================
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
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local ListLayout = Instance.new("UIListLayout", Scroll)
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function createPlayerRow(player)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 54)
        row.BackgroundColor3 = Color3.fromRGB(18, 27, 47)
        row.BorderSizePixel = 0
        row.Parent = Scroll
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
    end

    local function refreshPlayerList()
        for _, child in ipairs(Scroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local list = Players:GetPlayers()
        table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)
        for _, player in ipairs(list) do
            if player ~= LocalPlayer then createPlayerRow(player) end
        end
    end

    RefreshBtn.MouseButton1Click:Connect(refreshPlayerList)
    Players.PlayerAdded:Connect(refreshPlayerList)
    Players.PlayerRemoving:Connect(refreshPlayerList)
    refreshPlayerList()

    -- ==========================================
    -- FLY & NOCLIP
    -- ==========================================
    local function startFly()
        if settings.connections.fly then settings.connections.fly:Disconnect() end
        settings.connections.fly = RunService.RenderStepped:Connect(function()
            if not settings.flyEnabled then return end
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
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
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
    end

    -- ==========================================
    -- MAIN PAGE - CARDS
    -- ==========================================
    local CardFly = ui.CreateCard(MainPage, "FLY MODE", UDim2.new(0, 310, 0, 180), UDim2.new(0, 0, 0, 0), "✈")
    -- Fly UI (vereinfacht)
    local FlyDesc = Instance.new("TextLabel", CardFly)
    FlyDesc.Text = "Ermöglicht dir zu fliegen. Steuerung: WASD + Space/Shift."
    FlyDesc.Font = Enum.Font.Gotham; FlyDesc.TextSize = 11; FlyDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    FlyDesc.Position = UDim2.new(0, 16, 0, 45); FlyDesc.Size = UDim2.new(1, -32, 0, 32); FlyDesc.BackgroundTransparency = 1; FlyDesc.TextWrapped = true

    ui.CreateToggle(CardFly, settings.flyEnabled or false, function(state)
        settings.flyEnabled = state
        if state then startFly() else stopFly() end
    end)

    local CardNoclip = ui.CreateCard(MainPage, "NOCLIP", UDim2.new(0, 310, 0, 180), UDim2.new(0, 330, 0, 0), "🛡")
    ui.CreateToggle(CardNoclip, settings.noclipEnabled or false, function(state)
        settings.noclipEnabled = state
        if state then startNoclip() else stopNoclip() end
    end)

    -- Teleport Card (vereinfacht)
    local CardTp = ui.CreateCard(MainPage, "TELEPORT SYSTEM", UDim2.new(0, 310, 0, 160), UDim2.new(0, 0, 0, 200), "📍")
    -- ... (deine alten Save/Tp Buttons hier einfügen)

    -- ==========================================
    -- GAMEPASS UNLOCKER v2.4 (Advanced)
    -- ==========================================
    local CardUnlocker = ui.CreateCard(MainPage, "GAMEPASS UNLOCKER", UDim2.new(0, 310, 0, 180), UDim2.new(0, 330, 0, 200), "🪙")

    local UnlockerDesc = Instance.new("TextLabel", CardUnlocker)
    UnlockerDesc.Text = "Aggressiver Unlocker für GamePasses & In-App Käufe. Funktioniert in den meisten Spielen."
    UnlockerDesc.Font = Enum.Font.Gotham
    UnlockerDesc.TextSize = 11
    UnlockerDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    UnlockerDesc.Position = UDim2.new(0, 16, 0, 45)
    UnlockerDesc.Size = UDim2.new(1, -32, 0, 40)
    UnlockerDesc.BackgroundTransparency = 1
    UnlockerDesc.TextWrapped = true
    UnlockerDesc.TextXAlignment = Enum.TextXAlignment.Left

    local UnlockerStatus = Instance.new("TextLabel", CardUnlocker)
    UnlockerStatus.Size = UDim2.new(0, 260, 0, 20)
    UnlockerStatus.Position = UDim2.new(0, 16, 0, 125)
    UnlockerStatus.Font = Enum.Font.GothamBold
    UnlockerStatus.TextSize = 11
    UnlockerStatus.BackgroundTransparency = 1
    UnlockerStatus.TextXAlignment = Enum.TextXAlignment.Left

    local function updateUnlockerStatus(state)
        UnlockerStatus.Text = state and "🟢 Unlocker AKTIV - Alle Käufe freigeschaltet" or "⚪ Bereit zum Aktivieren"
        UnlockerStatus.TextColor3 = state and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(148, 163, 184)
    end

    local function createAdvancedGamepassUnlocker(state)
        settings.gamepassUnlockerEnabled = state
        LocalPlayer:SetAttribute("FreezyHub_GamepassUnlocker", state)

        if not state then return end

        -- Hook 1
        local oldUserOwns = hookfunction(MarketplaceService.UserOwnsGamePassAsync, function(self, userId, gamepassId)
            if settings.gamepassUnlockerEnabled and userId == LocalPlayer.UserId then return true end
            return oldUserOwns(self, userId, gamepassId)
        end)

        -- Hook 2
        local oldPlayerOwns = hookfunction(MarketplaceService.PlayerOwnsAsset, function(self, player, assetId)
            if settings.gamepassUnlockerEnabled and player == LocalPlayer then return true end
            return oldPlayerOwns(self, player, assetId)
        end)

        -- Hook 3: Namecall
        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if settings.gamepassUnlockerEnabled then
                if method == "UserOwnsGamePassAsync" or method == "PlayerOwnsAsset" then
                    return true
                end
                if method == "PromptGamePassPurchase" or method == "PromptPurchase" then
                    task.spawn(function()
                        MarketplaceService:ProcessReceipt({
                            PlayerId = LocalPlayer.UserId,
                            ProductId = args[1] or 0,
                            PurchaseId = "freezy-"..tick(),
                            CurrencyType = Enum.CurrencyType.Robux
                        })
                    end)
                    return
                end
            end
            return oldNamecall(self, ...)
        end)

        -- Aggressive Local Override
        task.spawn(function()
            while settings.gamepassUnlockerEnabled and task.wait(1.5) do
                for _, v in ipairs(LocalPlayer:GetDescendants()) do
                    if v:IsA("BoolValue") and (v.Name:lower():find("own") or v.Name:lower():find("pass") or v.Name:lower():find("vip") or v.Name:lower():find("premium")) then
                        v.Value = true
                    end
                end
                LocalPlayer:SetAttribute("HasGamepass", true)
                LocalPlayer:SetAttribute("VIP", true)
                LocalPlayer:SetAttribute("Premium", true)
            end
        end)

        print("FreezyHub → Advanced GamePass Unlocker aktiviert")
    end

    ui.CreateToggle(CardUnlocker, settings.gamepassUnlockerEnabled or false, function(state)
        createAdvancedGamepassUnlocker(state)
        updateUnlockerStatus(state)
    end)

    -- Initial Load
    if settings.gamepassUnlockerEnabled then
        task.defer(function()
            createAdvancedGamepassUnlocker(true)
            updateUnlockerStatus(true)
        end)
    end

    -- Character Respawn Handling
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if settings.flyEnabled then startFly() end
        if settings.noclipEnabled then startNoclip() end
    end)

    return MainPage
end