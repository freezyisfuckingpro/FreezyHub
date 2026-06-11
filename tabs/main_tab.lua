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
    -- GAMEPASS UNLOCKER - Speziell optimiert für +1 Speed Tastatur Flucht
    -- ==========================================
    local CardUnlocker = ui.CreateCard(MainPage, "GAMEPASS UNLOCKER", UDim2.new(0, 310, 0, 180), UDim2.new(0, 330, 0, 200), "🪙")

    local UnlockerDesc = Instance.new("TextLabel", CardUnlocker)
    UnlockerDesc.Text = "Versucht die 2999 Robux Spur + alle Gamepasses freizuschalten"
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
    UnlockerStatus.TextXAlignment = Enum.TextXAlignment.Left

    local function updateStatus(state)
        UnlockerStatus.Text = state and "🟢 AGGRESSIV AKTIV" or "⚪ Bereit"
        UnlockerStatus.TextColor3 = state and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(148, 163, 184)
    end

    local function enableUnlocker(state)
        settings.gamepassUnlockerEnabled = state
        if not state then return end

        -- Standard Marketplace Hooks
        pcall(function()
            hookfunction(MarketplaceService.UserOwnsGamePassAsync, function() return true end)
            hookfunction(MarketplaceService.PlayerOwnsAsset, function() return true end)
        end)

        pcall(function()
            local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if method:find("Owns") or method:find("Purchase") or method:find("Prompt") then
                    return true
                end
                return oldNamecall(self, ...)
            end)
        end)

        -- Sehr aggressiver Loop für dieses spezielle Spiel
        task.spawn(function()
            while settings.gamepassUnlockerEnabled do
                task.wait(0.6)

                -- Leaderstats + Speed Values
                local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                if leaderstats then
                    for _, v in ipairs(leaderstats:GetDescendants()) do
                        if v:IsA("NumberValue") or v:IsA("IntValue") then
                            v.Value = 999999999
                        end
                    end
                end

                -- Alle möglichen Gamepass / Spur / Speed Werte
                for _, v in ipairs(LocalPlayer:GetDescendants()) do
                    local name = v.Name:lower()
                    if name:find("speed") or name:find("spur") or name:find("pass") or name:find("vip") or name:find("multi") or name:find("boost") then
                        if v:IsA("BoolValue") then 
                            v.Value = true 
                        elseif v:IsA("NumberValue") or v:IsA("IntValue") then 
                            v.Value = 999999999 
                        end
                    end
                end

                -- Häufige RemoteEvents abfangen
                for _, remote in ipairs(workspace:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and remote.Name:lower():find("buy") or remote.Name:lower():find("purchase") then
                        remote:FireServer() -- Versuch zu triggern
                    end
                end

                LocalPlayer:SetAttribute("SpurOwned", true)
                LocalPlayer:SetAttribute("Gamepass", true)
                LocalPlayer:SetAttribute("SpeedMultiplier", 999999)
            end
        end)

        print("FreezyHub → +1 Speed Spur Unlocker gestartet")
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