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
    -- SPEED HACK (sehr stark für dieses Spiel)
    -- ==========================================
    local CardSpeed = ui.CreateCard(MainPage, "SPEED HACK", UDim2.new(0, 310, 0, 160), UDim2.new(0, 0, 0, 380), "⚡")

    local SpeedDesc = Instance.new("TextLabel", CardSpeed)
    SpeedDesc.Text = "Unendliche Geschwindigkeit + Multiplier"
    SpeedDesc.Font = Enum.Font.Gotham
    SpeedDesc.TextSize = 11
    SpeedDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    SpeedDesc.Position = UDim2.new(0, 16, 0, 45)
    SpeedDesc.Size = UDim2.new(1, -32, 0, 32)
    SpeedDesc.BackgroundTransparency = 1
    SpeedDesc.TextWrapped = true

    local speedMultiplier = 300

    ui.CreateToggle(CardSpeed, false, function(state)
        if state then
            task.spawn(function()
                while state do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if root and hum then
                        hum.WalkSpeed = speedMultiplier
                        hum.JumpPower = 150
                    end
                    task.wait(0.1)
                end
            end)
        end
    end)

    print("FreezyHub → Speed Hack bereit")

    return MainPage
end