-- tabs/main_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local MarketplaceService = game:GetService("MarketplaceService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Nav
    ui.CreateNavTab("Main Hacks", "🏠", "Main")
    ui.CreateNavTab("Visuals", "👁", "Visuals")
    ui.CreateNavTab("Player", "👤", "Player")
    ui.CreateNavTab("Movement", "🏃", "Movement")
    ui.CreateNavTab("World", "🌐", "World")
    ui.CreateNavTab("Misc", "⚙", "Misc")

    local MainPage = ui.CreatePage("Main")
    local PlayerPage = ui.CreatePage("Player")

    -- ==========================================
    -- PLAYER LIST (unverändert)
    -- ==========================================
    local PlayerCard = ui.CreateCard(PlayerPage, "PLAYER LIST", UDim2.new(0, 700, 0, 460), UDim2.new(0, 0, 0, 0), "👥")
    -- ... (Player List Code bleibt gleich wie in deiner letzten Version)

    local RefreshBtn = Instance.new("TextButton", PlayerCard) -- ... (Rest wie vorher)

    -- ==========================================
    -- FLY, NOCLIP, TP (unverändert)
    -- ==========================================
    local CardFly = ui.CreateCard(MainPage, "FLY MODE", UDim2.new(0, 310, 0, 180), UDim2.new(0, 0, 0, 0), "✈")
    ui.CreateToggle(CardFly, settings.flyEnabled or false, function(state)
        settings.flyEnabled = state
        -- Fly Code wie vorher...
    end)

    local CardNoclip = ui.CreateCard(MainPage, "NOCLIP", UDim2.new(0, 310, 0, 180), UDim2.new(0, 330, 0, 0), "🛡")
    ui.CreateToggle(CardNoclip, settings.noclipEnabled or false, function(state)
        settings.noclipEnabled = state
        -- Noclip Code wie vorher...
    end)

    local CardTp = ui.CreateCard(MainPage, "TELEPORT SYSTEM", UDim2.new(0, 310, 0, 160), UDim2.new(0, 0, 0, 200), "📍")
    -- Save & TP Buttons wie vorher...

    -- ==========================================
    -- GAMEPASS UNLOCKER - Optimiert für +1 Speed (weniger Lag)
    -- ==========================================
    local CardUnlocker = ui.CreateCard(MainPage, "GAMEPASS UNLOCKER", UDim2.new(0, 310, 0, 180), UDim2.new(0, 330, 0, 200), "🪙")

    local UnlockerDesc = Instance.new("TextLabel", CardUnlocker)
    UnlockerDesc.Text = "Unendlichkeitsspur (2.999 Robux) + Boosts"
    UnlockerDesc.Font = Enum.Font.Gotham
    UnlockerDesc.TextSize = 11
    UnlockerDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    UnlockerDesc.Position = UDim2.new(0, 16, 0, 45)
    UnlockerDesc.Size = UDim2.new(1, -32, 0, 40)
    UnlockerDesc.BackgroundTransparency = 1
    UnlockerDesc.TextWrapped = true

    local UnlockerStatus = Instance.new("TextLabel", CardUnlocker)
    UnlockerStatus.Size = UDim2.new(0, 260, 0, 20)
    UnlockerStatus.Position = UDim2.new(0, 16, 0, 125)
    UnlockerStatus.Font = Enum.Font.GothamBold
    UnlockerStatus.TextSize = 11
    UnlockerStatus.BackgroundTransparency = 1

    local function updateStatus(state)
        UnlockerStatus.Text = state and "🟢 AKTIV - Warte 10-20 Sek" or "⚪ Deaktiviert"
        UnlockerStatus.TextColor3 = state and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(148, 163, 184)
    end

    local unlockerConnection = nil

    local function enableUnlocker(state)
        settings.gamepassUnlockerEnabled = state
        if not state then 
            if unlockerConnection then unlockerConnection:Disconnect() end
            return 
        end

        -- Marketplace Hooks
        pcall(function()
            hookfunction(MarketplaceService.UserOwnsGamePassAsync, function() return true end)
            hookfunction(MarketplaceService.PlayerOwnsAsset, function() return true end)
        end)

        pcall(function()
            local old = hookmetamethod(game, "__namecall", function(self, ...)
                if getnamecallmethod():find("Owns") or getnamecallmethod():find("Purchase") then
                    return true
                end
                return old(self, ...)
            end)
        end)

        -- Optimierter Loop (weniger Lag)
        unlockerConnection = RunService.Heartbeat:Connect(function()
            if not settings.gamepassUnlockerEnabled then return end

            -- Leaderstats
            local ls = LocalPlayer:FindFirstChild("leaderstats")
            if ls then
                for _, v in ipairs(ls:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        v.Value = 999999999999
                    end
                end
            end

            -- Wichtige Werte gezielter suchen
            for _, v in ipairs(LocalPlayer:GetDescendants()) do
                local name = v.Name:lower()
                if name:find("spur") or name:find("unendlich") or name:find("speed") or name:find("boost") then
                    if v:IsA("BoolValue") then v.Value = true end
                    if v:IsA("NumberValue") or v:IsA("IntValue") then 
                        v.Value = 999999999999 
                    end
                end
            end

            LocalPlayer:SetAttribute("Unendlichkeitsspur", true)
            LocalPlayer:SetAttribute("SpurOwned", true)
        end)

        print("FreezyHub → Unendlichkeitsspur Unlocker gestartet")
    end

    ui.CreateToggle(CardUnlocker, settings.gamepassUnlockerEnabled or false, function(state)
        enableUnlocker(state)
        updateStatus(state)
    end)

    if settings.gamepassUnlockerEnabled then
        task.defer(enableUnlocker, true)
    end

    return MainPage
end