-- tabs/visuals_tab.lua
return function(ui, settings)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Absicherung, falls Werte in settings fehlen
    if settings.espBoxes == nil then settings.espBoxes = false end
    if settings.espSkeletons == nil then settings.espSkeletons = false end
    if settings.espTracers == nil then settings.espTracers = false end
    if not settings.colors then settings.colors = {} end
    
    settings.colors.Box = settings.colors.Box or Color3.fromRGB(239, 68, 68)
    settings.colors.Skeleton = settings.colors.Skeleton or Color3.fromRGB(255, 255, 0)
    settings.colors.Tracer = settings.colors.Tracer or Color3.fromRGB(56, 189, 248)
    settings.colors.Self = settings.colors.Self or Color3.fromRGB(168, 85, 247)
    settings.colors.Team = settings.colors.Team or Color3.fromRGB(34, 197, 94)

    local VisualsPage = ui.CreatePage("Visuals")
    
    -- Linke Karte: Switches
    local CardEsp = ui.CreateCard(VisualsPage, "PLAYER VISUAL SYSTEMS", UDim2.new(0, 360, 0, 300), UDim2.new(0, 0, 0, 0), "👁")
    local EspDesc = Instance.new("TextLabel", CardEsp)
    EspDesc.Text = "Erweiterte Visualisierungssysteme für Feinde, Teams und dich selbst."; EspDesc.Font = Enum.Font.Gotham; EspDesc.TextSize = 11; EspDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
    EspDesc.Position = UDim2.new(0, 16, 0, 45); EspDesc.Size = UDim2.new(1, -32, 0, 20); EspDesc.BackgroundTransparency = 1; EspDesc.TextWrapped = true; EspDesc.TextXAlignment = Enum.TextXAlignment.Left

    ui.CreateInlineToggle(CardEsp, "🔲 Master ESP Switches (Global Toggle)", 75, settings.espEnabled or false, function(state) settings.espEnabled = state end)
    ui.CreateInlineToggle(CardEsp, "📦 Draw 2D Corner Boxes", 110, settings.espBoxes or false, function(state) settings.espBoxes = state end)
    ui.CreateInlineToggle(CardEsp, "☠ Draw 3D Skeletons (Bones)", 145, settings.espSkeletons or false, function(state) settings.espSkeletons = state end)
    ui.CreateInlineToggle(CardEsp, "📏 Draw Snaplines (Tracers)", 180, settings.espTracers or false, function(state) settings.espTracers = state end)
    ui.CreateInlineToggle(CardEsp, "👤 Enable Self ESP (Show Me)", 215, settings.selfEspEnabled or false, function(state) settings.selfEspEnabled = state end)
    ui.CreateInlineToggle(CardEsp, "🛡 Enable Team-Check (Hide Friends)", 250, settings.teamCheckEnabled or true, function(state) settings.teamCheckEnabled = state end)

    -- Rechte Karte: Farbeditor
    local CardColors = ui.CreateCard(VisualsPage, "COLOR CONFIGURATOR", UDim2.new(0, 260, 0, 300), UDim2.new(0, 380, 0, 0), "🎨")
    
    local colorPalette = {
        Color3.fromRGB(239, 68, 68), Color3.fromRGB(56, 189, 248), Color3.fromRGB(34, 197, 94),
        Color3.fromRGB(245, 158, 11), Color3.fromRGB(168, 85, 247), Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(244, 63, 94)
    }

    local function createColorSelector(text, colorKey, y)
        local frame = Instance.new("Frame", CardColors)
        frame.Size = UDim2.new(1, -24, 0, 30); frame.Position = UDim2.new(0, 12, 0, y); frame.BackgroundTransparency = 1
        
        local lbl = Instance.new("TextLabel", frame)
        lbl.Text = text; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11; lbl.TextColor3 = Color3.fromRGB(148, 163, 184); lbl.Size = UDim2.new(1, -70, 1, 0); lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local colorBtn = Instance.new("TextButton", frame)
        colorBtn.Size = UDim2.new(0, 50, 0, 20); colorBtn.Position = UDim2.new(1, -55, 0.5, -10); colorBtn.BackgroundColor3 = settings.colors[colorKey]; colorBtn.Text = "»"; colorBtn.Font = Enum.Font.GothamBold; colorBtn.TextColor3 = Color3.fromRGB(255,255,255); colorBtn.TextSize = 12
        Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 4)

        local currentColorIndex = 1
        colorBtn.MouseButton1Click:Connect(function()
            currentColorIndex = currentColorIndex + 1
            if currentColorIndex > #colorPalette then currentColorIndex = 1 end
            local nextColor = colorPalette[currentColorIndex]
            settings.colors[colorKey] = nextColor
            colorBtn.BackgroundColor3 = nextColor
        end)
    end
    
    createColorSelector("📦 Box Color", "Box", 45)
    createColorSelector("☠ Skeleton Color", "Skeleton", 80)
    createColorSelector("📏 Tracer Color", "Tracer", 115)
    createColorSelector("👤 Self ESP Color", "Self", 150)
    createColorSelector("🛡 Friendly Team Color", "Team", 185)

    -- Slider für Skalierung
    local SizeTitle = Instance.new("TextLabel", CardColors)
    SizeTitle.Text = "ESP SIZE MULTIPLIER"; SizeTitle.Font = Enum.Font.GothamBold; SizeTitle.TextSize = 9; SizeTitle.TextColor3 = Color3.fromRGB(71, 85, 105)
    SizeTitle.Position = UDim2.new(0, 14, 0, 225); SizeTitle.Size = UDim2.new(0, 180, 0, 15); SizeTitle.BackgroundTransparency = 1

    local SizeTrack = Instance.new("Frame", CardColors)
    SizeTrack.Size = UDim2.new(1, -95, 0, 6); SizeTrack.Position = UDim2.new(0, 14, 0, 255); SizeTrack.BackgroundColor3 = Color3.fromRGB(30, 41, 59); SizeTrack.BorderSizePixel = 0
    Instance.new("UICorner", SizeTrack)

    local SizeFill = Instance.new("Frame", SizeTrack)
    SizeFill.Size = UDim2.new(0.33, 0, 1, 0); SizeFill.BackgroundColor3 = Color3.fromRGB(56, 189, 248); SizeFill.BorderSizePixel = 0
    Instance.new("UICorner", SizeFill)

    local SizeSliderBtn = Instance.new("TextButton", SizeTrack)
    SizeSliderBtn.Size = UDim2.new(0, 12, 0, 12); SizeSliderBtn.Position = UDim2.new(0.33, -6, 0.5, -6); SizeSliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); SizeSliderBtn.Text = ""
    Instance.new("UICorner", SizeSliderBtn).CornerRadius = UDim.new(1, 0)

    local SizeBox = Instance.new("Frame", CardColors)
    SizeBox.Size = UDim2.new(0, 50, 0, 22); SizeBox.Position = UDim2.new(1, -65, 0, 245); SizeBox.BackgroundColor3 = Color3.fromRGB(20, 30, 54)
    Instance.new("UICorner", SizeBox).CornerRadius = UDim.new(0, 5)

    local SizeValue = Instance.new("TextLabel", SizeBox)
    SizeValue.Size = UDim2.new(1, 0, 1, 0); SizeValue.Text = "1.0x"; SizeValue.Font = Enum.Font.GothamMedium; SizeValue.TextSize = 10; SizeValue.TextColor3 = Color3.fromRGB(255, 255, 255); SizeValue.BackgroundTransparency = 1

    local draggingSizeSlider = false
    SizeSliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSizeSlider = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSizeSlider = false end end)
    settings.addConnection("sizeSlider", RunService.RenderStepped:Connect(function()
        if draggingSizeSlider then
            local mousePos = UserInputService:GetMouseLocation().X
            local trackPos = SizeTrack.AbsolutePosition.X
            local trackWidth = SizeTrack.AbsoluteSize.X
            local percentage = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
            SizeSliderBtn.Position = UDim2.new(percentage, -6, 0.5, -6)
            SizeFill.Size = UDim2.new(percentage, 0, 1, 0)
            settings.espSizeMultiplier = 0.4 + (percentage * 1.6)
            SizeValue.Text = string.format("%.1fx", settings.espSizeMultiplier)
        end
    end))

    local SkeletonPairs = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"Head", "Torso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
        {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
    }

    local function createDrawingLine(parent)
        local line = Instance.new("Frame", parent)
        line.BorderSizePixel = 0; line.AnchorPoint = Vector2.new(0.5, 0.5); line.Visible = false
        return line
    end

    local function createESP(player)
        -- Sucht dynamisch nach deiner aktiven UI-Instanz im CoreGui
        local container = ui.MainFrame and ui.MainFrame.Parent
        if not container then return end

        local objects = { Corners = {}, Bones = {}, Tracer = nil, NameTag = nil }

        -- 4 Ecken á 2 Frames (horizontal + vertikal) = 100% Sicher ohne UIStroke!
        for i = 1, 4 do
            table.insert(objects.Corners, {h = createDrawingLine(container), v = createDrawingLine(container)})
        end

        for i = 1, #SkeletonPairs do table.insert(objects.Bones, createDrawingLine(container)) end
        objects.Tracer = createDrawingLine(container)

        local function removeESP()
            for _, c in pairs(objects.Corners) do c.h:Destroy(); c.v:Destroy() end
            for _, b in pairs(objects.Bones) do b:Destroy() end
            if objects.Tracer then objects.Tracer:Destroy() end
            if objects.NameTag then objects.NameTag:Destroy() end
            settings.espObjects[player.UserId] = nil
        end

        local function updateESP()
            local cleanClear = function()
                for _, c in pairs(objects.Corners) do c.h.Visible = false; c.v.Visible = false end
                for _, b in pairs(objects.Bones) do b.Visible = false end
                if objects.Tracer then objects.Tracer.Visible = false end
                if objects.NameTag then objects.NameTag.Visible = false end
            end

            if player == LocalPlayer and not settings.selfEspEnabled then cleanClear(); return end
            
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChild("Humanoid")

            if not settings.espEnabled or not root or not humanoid or humanoid.Health <= 0 then cleanClear(); return end
            if settings.teamCheckEnabled and player ~= LocalPlayer and player.Team == LocalPlayer.Team then cleanClear(); return end

            local cframe, size = character:GetBoundingBox()
            local topWorld = (cframe * CFrame.new(0, size.Y / 2, 0)).Position
            local bottomWorld = (cframe * CFrame.new(0, -size.Y / 2, 0)).Position

            local topScreen, topOnScreen = Camera:WorldToViewportPoint(topWorld)
            local bottomScreen, bottomOnScreen = Camera:WorldToViewportPoint(bottomWorld)

            local isTeam = (player ~= LocalPlayer and player.Team == LocalPlayer.Team)
            local currentBoxColor = isTeam and settings.colors.Team or (player == LocalPlayer and settings.colors.Self or settings.colors.Box)
            local currentSkelColor = isTeam and settings.colors.Team or (player == LocalPlayer and settings.colors.Self or settings.colors.Skeleton)
            local currentTracerColor = isTeam and settings.colors.Team or settings.colors.Tracer

            ----------------------------------------
            -- 1. BOX RENDER ENGINE
            ----------------------------------------
            if topOnScreen and bottomOnScreen then
                local calculatedHeight = math.abs(topScreen.Y - bottomScreen.Y)
                local height = math.clamp(calculatedHeight, 6, 700) * (settings.espSizeMultiplier or 1)
                local width = (height / 1.4)
                local boxX = topScreen.X - (width / 2)
                local boxY = topScreen.Y

                if settings.espBoxes then
                    local cLength = math.clamp(width * 0.25, 4, 30)
                    local cThick = 1.5

                    local positions = {
                        {x = boxX, y = boxY, dx = 1, dy = 1},
                        {x = boxX + width, y = boxY, dx = -1, dy = 1},
                        {x = boxX, y = boxY + height, dx = 1, dy = -1},
                        {x = boxX + width, y = boxY + height, dx = -1, dy = -1}
                    }

                    for i, pos in ipairs(positions) do
                        local corner = objects.Corners[i]
                        corner.h.Visible = true; corner.h.BackgroundColor3 = currentBoxColor
                        corner.h.Size = UDim2.new(0, cLength, 0, cThick)
                        corner.h.Position = UDim2.new(0, pos.x + (cLength/2 * pos.dx) - (pos.dx == -1 and cThick or 0), 0, pos.y)
                        
                        corner.v.Visible = true; corner.v.BackgroundColor3 = currentBoxColor
                        corner.v.Size = UDim2.new(0, cThick, 0, cLength)
                        corner.v.Position = UDim2.new(0, pos.x, 0, pos.y + (cLength/2 * pos.dy) - (pos.dy == -1 and cThick or 0))
                    end
                else
                    for _, c in pairs(objects.Corners) do c.h.Visible = false; c.v.Visible = false end
                end

                if not objects.NameTag then
                    local tag = Instance.new("TextLabel", container)
                    tag.BackgroundTransparency = 1
                    tag.Font = Enum.Font.GothamBold; tag.TextSize = 10; tag.TextStrokeTransparency = 0.4; tag.TextStrokeColor3 = Color3.fromRGB(0,0,0)
                    objects.NameTag = tag
                end
                
                local distance = math.round((root.Position - Camera.CFrame.Position).Magnitude)
                objects.NameTag.Visible = true
                objects.NameTag.Text = (player == LocalPlayer) and "⭐ [YOU]" or string.format("👤 %s [%dM]", player.DisplayName, distance)
                objects.NameTag.TextColor3 = currentBoxColor
                objects.NameTag.Position = UDim2.new(0, topScreen.X, 0, boxY - 14)
                objects.NameTag.Size = UDim2.new(0, 0, 0, 0)
            else
                for _, c in pairs(objects.Corners) do c.h.Visible = false; c.v.Visible = false end
                if objects.NameTag then objects.NameTag.Visible = false end
            end

            ----------------------------------------
            -- 2. SKELETON RENDER ENGINE
            ----------------------------------------
            if settings.espSkeletons then
                local boneIndex = 1
                for _, pair in ipairs(SkeletonPairs) do
                    local part1 = character:FindFirstChild(pair[1])
                    local part2 = character:FindFirstChild(pair[2])

                    if part1 and part2 then
                        local v1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
                        local v2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)

                        if onScreen1 and onScreen2 then
                            local line = objects.Bones[boneIndex]
                            if line then
                                local dist = (Vector2.new(v1.X, v1.Y) - Vector2.new(v2.X, v2.Y)).Magnitude
                                line.Visible = true; line.BackgroundColor3 = currentSkelColor
                                line.Size = UDim2.new(0, dist, 0, 1.5)
                                line.Position = UDim2.new(0, (v1.X + v2.X)/2, 0, (v1.Y + v2.Y)/2)
                                line.Rotation = math.deg(math.atan2(v2.Y - v1.Y, v2.X - v1.X))
                                boneIndex = boneIndex + 1
                            end
                        end
                    end
                end
                for i = boneIndex, #objects.Bones do objects.Bones[i].Visible = false end
            else
                for _, b in pairs(objects.Bones) do b.Visible = false end
            end

            ----------------------------------------
            -- 3. TRACER RENDER ENGINE
            ----------------------------------------
            if settings.espTracers and topOnScreen and player ~= LocalPlayer then
                local line = objects.Tracer
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                local targetPos = Vector2.new(bottomScreen.X, bottomScreen.Y)
                local dist = (screenCenter - targetPos).Magnitude

                line.Visible = true; line.BackgroundColor3 = currentTracerColor
                line.Size = UDim2.new(0, dist, 0, 1)
                line.Position = UDim2.new(0, (screenCenter.X + targetPos.X) / 2, 0, (screenCenter.Y + targetPos.Y) / 2)
                line.Rotation = math.deg(math.atan2(targetPos.Y - screenCenter.Y, targetPos.X - screenCenter.X))
            else
                if objects.Tracer then objects.Tracer.Visible = false end
            end
        end

        objects.Update = updateESP
        objects.Remove = removeESP
        settings.espObjects[player.UserId] = objects
    end

    local function beginEspLoop()
        for _, player in pairs(Players:GetPlayers()) do createESP(player) end
        settings.addConnection("espAdded", Players.PlayerAdded:Connect(createESP))
        settings.addConnection("espRemoving", Players.PlayerRemoving:Connect(function(player)
            if settings.espObjects[player.UserId] then settings.espObjects[player.UserId].Remove() end
        end))
        settings.addConnection("espRender", RunService.RenderStepped:Connect(function()
            for _, objects in pairs(settings.espObjects) do if objects.Update then objects.Update() end end
        end))
    end
    
    beginEspLoop()
    return VisualsPage
end