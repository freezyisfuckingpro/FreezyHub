-- tabs/visuals_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local VisualsPage = ui.CreatePage("Visuals")
    
    local CardEsp = ui.CreateCard(VisualsPage, "PLAYER & SELF ESP SYSTEMS", UDim2.new(0, 390, 0, 240), UDim2.new(0, 0, 0, 0), "👁")
    local EspDesc = Instance.new("TextLabel", CardEsp)
    EspDesc.Text = "Erweiterte Visualisierungssysteme für Feinde, Teams und dich selbst."; EspDesc.Font = Enum.Font.Gotham; EspDesc.TextSize = 11; EspDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    EspDesc.Position = UDim2.new(0, 16, 0, 45); EspDesc.Size = UDim2.new(1, -32, 0, 30); EspDesc.BackgroundTransparency = 1; EspDesc.TextWrapped = true; EspDesc.TextXAlignment = Enum.TextXAlignment.Left

    ui.CreateInlineToggle(CardEsp, "👤 Enable Self ESP (Show Me)", 85, false, function(state)
        settings.selfEspEnabled = state
    end)

    ui.CreateInlineToggle(CardEsp, "🛡 Enable Team-Check", 125, true, function(state)
        settings.teamCheckEnabled = state
    end)

    local SizeTitle = Instance.new("TextLabel", CardEsp)
    SizeTitle.Text = "ESP BOX SIZE MULTIPLIER"; SizeTitle.Font = Enum.Font.GothamBold; SizeTitle.TextSize = 9; SizeTitle.TextColor3 = Color3.fromRGB(71, 85, 105)
    SizeTitle.Position = UDim2.new(0, 16, 0, 165); SizeTitle.Size = UDim2.new(0, 180, 0, 15); SizeTitle.BackgroundTransparency = 1

    local SizeTrack = Instance.new("Frame", CardEsp)
    SizeTrack.Size = UDim2.new(1, -115, 0, 6); SizeTrack.Position = UDim2.new(0, 16, 0, 195); SizeTrack.BackgroundColor3 = Color3.fromRGB(30, 41, 59); SizeTrack.BorderSizePixel = 0
    Instance.new("UICorner", SizeTrack)

    local SizeFill = Instance.new("Frame", SizeTrack)
    SizeFill.Size = UDim2.new(0.33, 0, 1, 0); SizeFill.BackgroundColor3 = Color3.fromRGB(56, 189, 248); SizeFill.BorderSizePixel = 0
    Instance.new("UICorner", SizeFill)

    local SizeSliderBtn = Instance.new("TextButton", SizeTrack)
    SizeSliderBtn.Size = UDim2.new(0, 14, 0, 14); SizeSliderBtn.Position = UDim2.new(0.33, -7, 0.5, -7); SizeSliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); SizeSliderBtn.Text = ""
    Instance.new("UICorner", SizeSliderBtn).CornerRadius = UDim.new(1, 0)

    local SizeBox = Instance.new("Frame", CardEsp)
    SizeBox.Size = UDim2.new(0, 55, 0, 24); SizeBox.Position = UDim2.new(1, -85, 0, 185); SizeBox.BackgroundColor3 = Color3.fromRGB(20, 30, 54)
    Instance.new("UICorner", SizeBox).CornerRadius = UDim.new(0, 6)

    local SizeValue = Instance.new("TextLabel", SizeBox)
    SizeValue.Size = UDim2.new(1, 0, 1, 0); SizeValue.Text = "1.0x"; SizeValue.Font = Enum.Font.GothamMedium; SizeValue.TextSize = 11; SizeValue.TextColor3 = Color3.fromRGB(255, 255, 255); SizeValue.BackgroundTransparency = 1

    local draggingSizeSlider = false
    SizeSliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSizeSlider = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSizeSlider = false end end)
    settings.addConnection("sizeSlider", RunService.RenderStepped:Connect(function()
        if draggingSizeSlider then
            local mousePos = UserInputService:GetMouseLocation().X
            local trackPos = SizeTrack.AbsolutePosition.X
            local trackWidth = SizeTrack.AbsoluteSize.X
            local percentage = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
            SizeSliderBtn.Position = UDim2.new(percentage, -7, 0.5, -7)
            SizeFill.Size = UDim2.new(percentage, 0, 1, 0)
            settings.espSizeMultiplier = 0.4 + (percentage * 1.2)
            SizeValue.Text = string.format("%.1fx", settings.espSizeMultiplier)
        end
    end))

    local CardColors = ui.CreateCard(VisualsPage, "COLOR PROFILES", UDim2.new(0, 230, 0, 240), UDim2.new(0, 410, 0, 0), "🎨")
    local function createColorIndicator(text, color, y)
        local frame = Instance.new("Frame", CardColors)
        frame.Size = UDim2.new(1, -32, 0, 24); frame.Position = UDim2.new(0, 16, 0, y); frame.BackgroundTransparency = 1
        
        local dot = Instance.new("Frame", frame)
        dot.Size = UDim2.new(0, 12, 0, 12); dot.Position = UDim2.new(0, 0, 0.5, -6); dot.BackgroundColor3 = color; dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
        
        local lbl = Instance.new("TextLabel", frame)
        lbl.Text = text; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextColor3 = Color3.fromRGB(148, 163, 184); lbl.Position = UDim2.new(0, 22, 0, 0); lbl.Size = UDim2.new(1, -22, 1, 0); lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left
    end
    createColorIndicator("You (Self ESP)", settings.colors.Self, 55)
    createColorIndicator("Enemies / Free Agents", settings.colors.Enemy, 90)
    createColorIndicator("Friendly Team", settings.colors.Team, 125)

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
                    local box = Instance.new("Frame", ui.MainFrame.Parent:FindFirstChild("FreezyHubV2"))
                    box.Name = player.Name .. "_ESPBox"
                    box.BackgroundTransparency = 1
                    box.BorderSizePixel = 0
                    
                    local stroke = Instance.new("UIStroke", box)
                    stroke.Thickness = 1.5
                    stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    
                    objects.Box = box
                    objects.Stroke = stroke
                end
                
                local calculatedHeight = math.abs(topScreen.Y - bottomScreen.Y)
                local height = math.clamp(calculatedHeight, 5, 600) * settings.espSizeMultiplier
                local width = (height / 1.5)
                
                objects.Box.Visible = true
                objects.Box.Position = UDim2.new(0, topScreen.X - (width / 2), 0, topScreen.Y)
                objects.Box.Size = UDim2.new(0, width, 0, height)
                objects.Stroke.Color = designColor 

                if not objects.NameTag then
                    local tag = Instance.new("TextLabel", ui.MainFrame.Parent:FindFirstChild("FreezyHubV2"))
                    tag.Name = player.Name .. "_ESPTag"
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
-- DDD