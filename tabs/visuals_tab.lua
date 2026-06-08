-- tabs/visuals_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local VisualsPage = ui.CreatePage("Visuals")
    local CardEsp = ui.CreateCard(VisualsPage, "PLAYER & SELF ESP SYSTEMS", UDim2.new(0, 390, 0, 240), UDim2.new(0, 0, 0, 0), "👁")

    ui.CreateInlineToggle(CardEsp, "👤 Enable Self ESP (Show Me)", 85, false, function(state)
        settings.selfEspEnabled = state
    end)

    ui.CreateInlineToggle(CardEsp, "🛡 Enable Team-Check", 125, true, function(state)
        settings.teamCheckEnabled = state
    end)

    local function createESP(player)
        local objects = { Box = nil, NameTag = nil, Stroke = nil }

        local function removeESP()
            if objects.Box then objects.Box:Destroy() end
            if objects.NameTag then objects.NameTag:Destroy() end
            settings.espObjects[player.UserId] = nil
        end

        local function updateESP()
            if player == LocalPlayer and not settings.selfEspEnabled then
                if objects.Box then objects.Box.Visible = false end
                if objects.NameTag then objects.NameTag.Visible = false end
                return
            end

            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChild("Humanoid")

            if not settings.espEnabled or not root or not humanoid or humanoid.Health <= 0 then
                if objects.Box then objects.Box.Visible = false end
                if objects.NameTag then objects.NameTag.Visible = false end
                return
            end

            if settings.teamCheckEnabled and player ~= LocalPlayer and player.Team == LocalPlayer.Team then
                if objects.Box then objects.Box.Visible = false end
                if objects.NameTag then objects.NameTag.Visible = false end
                return
            end

            local cframe, size = character:GetBoundingBox()
            local topWorld = (cframe * CFrame.new(0, size.Y / 2, 0)).Position
            local bottomWorld = (cframe * CFrame.new(0, -size.Y / 2, 0)).Position

            local topScreen, topOnScreen = Camera:WorldToViewportPoint(topWorld)
            local bottomScreen, bottomOnScreen = Camera:WorldToViewportPoint(bottomWorld)

            if topOnScreen and bottomOnScreen then
                local designColor = settings.colors.Enemy
                if player == LocalPlayer then
                    designColor = settings.colors.Self
                elseif player.Team == LocalPlayer.Team then
                    designColor = settings.colors.Team
                end

                if not objects.Box then
                    local box = Instance.new("Frame")
                    box.Parent = ui.MainFrame.Parent
                    box.BackgroundTransparency = 1
                    
                    local stroke = Instance.new("UIStroke")
                    stroke.Thickness = 1.5
                    stroke.Parent = box
                    
                    objects.Box = box
                    objects.Stroke = stroke
                end
                
                local calculatedHeight = math.abs(topScreen.Y - bottomScreen.Y)
                local height = math.clamp(calculatedHeight, 5, 600) * settings.espSizeMultiplier
                local width = (height / 1.5)
                
                objects.Box.Visible = true
                objects.Box.Position = UDim2.new(0, topScreen.X - (width / 2), 0, topScreen.Y)
                objects.Box.Size = UDim2.new(0, width, 0, height)
                objects.Stroke.Color = designColor -- Behoben: Greift direkt auf gespeicherte Referenz zu

                if not objects.NameTag then
                    local tag = Instance.new("TextLabel", ui.MainFrame.Parent)
                    tag.BackgroundTransparency = 1
                    tag.Font = Enum.Font.GothamBold; tag.TextSize = 10; tag.TextStrokeTransparency = 0.5; tag.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                    objects.NameTag = tag
                end
                
                local distance = math.round((root.Position - Camera.CFrame.Position).Magnitude)
                objects.NameTag.Visible = true
                objects.NameTag.Text = (player == LocalPlayer) and "[YOU] " .. player.DisplayName or player.DisplayName .. string.format(" [%dM]", distance)
                objects.NameTag.TextColor3 = designColor
                objects.NameTag.Position = UDim2.new(0, topScreen.X, 0, topScreen.Y - 14)
                objects.NameTag.Size = UDim2.new(0, 0, 0, 0)
            else
                if objects.Box then objects.Box.Visible = false end
                if objects.NameTag then objects.NameTag.Visible = false end
            end
        end

        objects.Update = updateESP
        objects.Remove = removeESP
        settings.espObjects[player.UserId] = objects
    end

    ui.CreateToggle(CardEsp, false, function(state)
        settings.espEnabled = state
        if settings.espEnabled then
            for _, player in pairs(Players:GetPlayers()) do createESP(player) end
            settings.addConnection("espAdded", Players.PlayerAdded:Connect(createESP))
            settings.addConnection("espRemoving", Players.PlayerRemoving:Connect(function(player)
                if settings.espObjects[player.UserId] then settings.espObjects[player.UserId].Remove() end
            end))
            settings.addConnection("espRender", RunService.RenderStepped:Connect(function()
                for _, objects in pairs(settings.espObjects) do
                    if objects.Update then objects.Update() end
                end
            end))
        else
            if settings.connections.espAdded then settings.connections.espAdded:Disconnect() end
            if settings.connections.espRemoving then settings.connections.espRemoving:Disconnect() end
            if settings.connections.espRender then settings.connections.espRender:Disconnect() end
            for _, objects in pairs(settings.espObjects) do if objects.Remove then objects.Remove() end end
            settings.espObjects = {}
        end
    end)

    return VisualsPage
end