-- FreezyHub/tabs/visuals_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local VisualsPage = ui.CreatePage("Visuals")
    local CardEsp = ui.CreateCard(VisualsPage, "PLAYER & SELF ESP SYSTEMS", UDim2.new(0, 390, 0, 240), UDim2.new(0, 0, 0, 0), "👁")

    local function createESP(player)
        local objects = { Box = nil, NameTag = nil }

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
                    local stroke = Instance.new("UIStroke", box)
                    stroke.Thickness = 1.5
                    objects.Box = box
                end
                
                local calculatedHeight = math.abs(topScreen.Y - bottomScreen.Y)
                local height = math.clamp(calculatedHeight, 5, 600) * settings.espSizeMultiplier
                local width = (height / 1.5)
                
                objects.Box.Visible = true
                objects.Box.Position = UDim2.new(0, topScreen.X - (width / 2), 0, topScreen.Y)
                objects.Box.Size = UDim2.new(0, width, 0, height)
                objects.Box.UIStroke.Color = designColor
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
            settings.addConnection("espRender", RunService.RenderStepped:Connect(function()
                for _, objects in pairs(settings.espObjects) do
                    if objects.Update then objects.Update() end
                end
            end))
        else
            if settings.connections.espAdded then settings.connections.espAdded:Disconnect() end
            if settings.connections.espRender then settings.connections.espRender:Disconnect() end
            for _, objects in pairs(settings.espObjects) do if objects.Remove then objects.Remove() end end
            settings.espObjects = {}
        end
    end)

    return VisualsPage
end