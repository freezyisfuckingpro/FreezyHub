-- core/ui_library.lua
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ui = {}
ui.pageRefs = {}
ui.navButtons = {}
ui.currentTab = nil
ui.MainFrame = nil
ui.ContentArea = nil
ui.NavContainer = nil

function ui.CreateMainContainer(settings)
    local FreezyHubV2 = Instance.new("ScreenGui")
    FreezyHubV2.Name = "FreezyHubV2"
    FreezyHubV2.Parent = CoreGui
    FreezyHubV2.ResetOnSpawn = false
    FreezyHubV2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = FreezyHubV2
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
    MainFrame.Position = UDim2.new(0.5, -425, 0.5, -280)
    MainFrame.Size = UDim2.new(0, 850, 0, 560)
    MainFrame.BorderSizePixel = 0
    ui.MainFrame = MainFrame

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 14)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(24, 33, 50)
    MainStroke.Thickness = 1.5

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Name = "Sidebar"
    Sidebar.BackgroundColor3 = Color3.fromRGB(13, 20, 35)
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)

    local SidebarFix = Instance.new("Frame", Sidebar)
    SidebarFix.Size = UDim2.new(0, 20, 1, 0)
    SidebarFix.Position = UDim2.new(1, -20, 0, 0)
    SidebarFix.BackgroundColor3 = Color3.fromRGB(13, 20, 35)
    SidebarFix.BorderSizePixel = 0

    local LogoFrame = Instance.new("Frame", Sidebar)
    LogoFrame.Size = UDim2.new(1, 0, 0, 70)
    LogoFrame.BackgroundTransparency = 1

    local LogoIcon = Instance.new("TextLabel", LogoFrame)
    LogoIcon.Text = "❄"; LogoIcon.Font = Enum.Font.GothamBold; LogoIcon.TextSize = 24; LogoIcon.TextColor3 = Color3.fromRGB(56, 189, 248)
    LogoIcon.Position = UDim2.new(0, 20, 0.5, -12); LogoIcon.Size = UDim2.new(0, 24, 0, 24); LogoIcon.BackgroundTransparency = 1

    local LogoText = Instance.new("TextLabel", LogoFrame)
    LogoText.Text = "FREEZY HUB"; LogoText.Font = Enum.Font.GothamBold; LogoText.TextSize = 15; LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.Position = UDim2.new(0, 50, 0, 18); LogoText.Size = UDim2.new(0, 100, 0, 20); LogoText.BackgroundTransparency = 1; LogoText.TextXAlignment = Enum.TextXAlignment.Left

    local SubText = Instance.new("TextLabel", LogoFrame)
    SubText.Text = "BYPASS SYSTEM v2.3"; SubText.Font = Enum.Font.Gotham; SubText.TextSize = 9; SubText.TextColor3 = Color3.fromRGB(100, 116, 139)
    SubText.Position = UDim2.new(0, 50, 0, 36); SubText.Size = UDim2.new(0, 100, 0, 12); SubText.BackgroundTransparency = 1; SubText.TextXAlignment = Enum.TextXAlignment.Left

    local NavContainer = Instance.new("Frame", Sidebar)
    NavContainer.Name = "NavContainer"
    NavContainer.Position = UDim2.new(0, 12, 0, 80)
    NavContainer.Size = UDim2.new(1, -24, 0, 340)
    NavContainer.BackgroundTransparency = 1
    ui.NavContainer = NavContainer

    local NavLayout = Instance.new("UIListLayout", NavContainer)
    NavLayout.Padding = UDim.new(0, 6)

    -- Profil
    local UserFrame = Instance.new("Frame", Sidebar)
    UserFrame.Size = UDim2.new(1, -20, 0, 54); UserFrame.Position = UDim2.new(0, 10, 1, -110); UserFrame.BackgroundColor3 = Color3.fromRGB(18, 27, 47)
    Instance.new("UICorner", UserFrame).CornerRadius = UDim.new(0, 8)

    local Avatar = Instance.new("ImageLabel", UserFrame)
    Avatar.Size = UDim2.new(0, 34, 0, 34); Avatar.Position = UDim2.new(0, 10, 0.5, -17)
    Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

    local UserName = Instance.new("TextLabel", UserFrame)
    UserName.Text = "@" .. LocalPlayer.Name; UserName.Font = Enum.Font.GothamBold; UserName.TextSize = 11; UserName.TextColor3 = Color3.fromRGB(255, 255, 255)
    UserName.Position = UDim2.new(0, 52, 0, 12); UserName.Size = UDim2.new(0, 100, 0, 14); UserName.BackgroundTransparency = 1; UserName.TextXAlignment = Enum.TextXAlignment.Left

    local PremiumBadge = Instance.new("TextLabel", UserFrame)
    PremiumBadge.Text = "👑 Premium User"; PremiumBadge.Font = Enum.Font.GothamMedium; PremiumBadge.TextSize = 9; PremiumBadge.TextColor3 = Color3.fromRGB(56, 189, 248)
    PremiumBadge.Position = UDim2.new(0, 52, 0, 28); PremiumBadge.Size = UDim2.new(0, 100, 0, 12); PremiumBadge.BackgroundTransparency = 1; PremiumBadge.TextXAlignment = Enum.TextXAlignment.Left

    local StatusText = Instance.new("TextLabel", Sidebar)
    StatusText.Text = "STATUS: ACTIVE V2.3"; StatusText.Font = Enum.Font.GothamBold; StatusText.TextSize = 9; StatusText.TextColor3 = Color3.fromRGB(34, 197, 94)
    StatusText.Position = UDim2.new(0, 12, 1, -40); StatusText.Size = UDim2.new(0, 150, 0, 20); StatusText.BackgroundTransparency = 1; StatusText.TextXAlignment = Enum.TextXAlignment.Left

    -- TopBar
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, -180, 0, 60); TopBar.Position = UDim2.new(0, 180, 0, 0); TopBar.BackgroundTransparency = 1

    local WelcomeText = Instance.new("TextLabel", TopBar)
    WelcomeText.Text = "Welcome back, " .. LocalPlayer.DisplayName .. " 👋"; WelcomeText.Font = Enum.Font.GothamMedium; WelcomeText.TextSize = 12; WelcomeText.TextColor3 = Color3.fromRGB(148, 163, 184)
    WelcomeText.Position = UDim2.new(0, 25, 0.5, -8); WelcomeText.Size = UDim2.new(0, 300, 0, 16); WelcomeText.BackgroundTransparency = 1; WelcomeText.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 24, 0, 24); CloseBtn.Position = UDim2.new(1, -38, 0, 18); CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 10
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    -- Content Area
    local Content = Instance.new("Frame", MainFrame)
    Content.Name = "ContentArea"
    Content.Position = UDim2.new(0, 205, 0, 60)
    Content.Size = UDim2.new(1, -230, 1, -140)
    Content.BackgroundTransparency = 1
    ui.ContentArea = Content

    -- Footer
    local Footer = Instance.new("Frame", MainFrame)
    Footer.Position = UDim2.new(0, 205, 1, -65); Footer.Size = UDim2.new(1, -230, 0, 50); Footer.BackgroundTransparency = 1
    local FooterLayout = Instance.new("UIListLayout", Footer)
    FooterLayout.FillDirection = Enum.FillDirection.Horizontal; FooterLayout.Padding = UDim.new(0, 10)

    local function createFooterBtn(name, icon)
        local btn = Instance.new("TextButton", Footer)
        btn.Size = UDim2.new(0, 150, 1, 0); btn.BackgroundColor3 = Color3.fromRGB(14, 22, 40); btn.Text = ""
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", btn).Color = Color3.fromRGB(22, 32, 54)
        
        local ico = Instance.new("TextLabel", btn)
        ico.Text = icon; ico.Font = Enum.Font.GothamBold; ico.TextSize = 12; ico.TextColor3 = Color3.fromRGB(56, 189, 248)
        ico.Position = UDim2.new(0, 12, 0.5, -7); ico.Size = UDim2.new(0, 16, 0, 14); ico.BackgroundTransparency = 1
        
        local lbl = Instance.new("TextLabel", btn)
        lbl.Text = name; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11; lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Position = UDim2.new(0, 34, 0, 0); lbl.Size = UDim2.new(1, -34, 1, 0); lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left
        return btn
    end

    local RejoinBtn = createFooterBtn("Rejoin Server", "🔄")
    local ResetBtn = createFooterBtn("Reset Char", "💀")
    local AfkBtn = createFooterBtn("Anti AFK", "☕")

    local VerText = Instance.new("TextLabel", MainFrame)
    VerText.Text = "FREEZY HUB v2.3.0 | F1 to toggle"; VerText.Font = Enum.Font.Gotham; VerText.TextSize = 10; VerText.TextColor3 = Color3.fromRGB(71, 85, 105)
    VerText.Position = UDim2.new(0.5, -100, 1, -14); VerText.Size = UDim2.new(0, 200, 0, 12); VerText.BackgroundTransparency = 1

    -- Button Klicks
    CloseBtn.MouseButton1Click:Connect(function()
        for _, conn in pairs(settings.connections) do if conn then conn:Disconnect() end end
        for _, objects in pairs(settings.espObjects) do if objects.Remove then objects.Remove() end end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end
        FreezyHubV2:Destroy()
    end)

    ResetBtn.MouseButton1Click:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Health = 0 end
    end)

    RejoinBtn.MouseButton1Click:Connect(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)

    local antiAfkActive = false
    AfkBtn.MouseButton1Click:Connect(function()
        antiAfkActive = not antiAfkActive
        local stroke = AfkBtn:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = antiAfkActive and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(22, 32, 54) end
        if antiAfkActive then
            local vu = game:GetService("VirtualUser")
            settings.addConnection("antiAfk", LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end))
        else
            if settings.connections.antiAfk then settings.connections.antiAfk:Disconnect() end
        end
    end)

    settings.addConnection("toggleUI", UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.F1 then MainFrame.Visible = not MainFrame.Visible end
    end))

    return MainFrame
end

function ui.CreateNavTab(name, icon, pageName)
    local btn = Instance.new("TextButton", ui.NavContainer)
    btn.Name = name .. "Btn"; btn.Size = UDim2.new(1, 0, 0, 38); btn.BackgroundTransparency = 1; btn.BackgroundColor3 = Color3.fromRGB(23, 37, 68); btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local ind = Instance.new("Frame", btn) 
    ind.Name = "Indicator"; ind.Size = UDim2.new(0, 3, 0, 16); ind.Position = UDim2.new(0, 0, 0.5, -8); ind.BackgroundColor3 = Color3.fromRGB(56, 189, 248); ind.BorderSizePixel = 0; ind.Visible = false
    
    local lbl = Instance.new("TextLabel", btn)
    lbl.Name = "BtnText"; lbl.Size = UDim2.new(1, -40, 1, 0); lbl.Position = UDim2.new(0, 36, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium; lbl.Text = name; lbl.TextSize = 12; lbl.TextColor3 = Color3.fromRGB(148, 163, 184); lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local ico = Instance.new("TextLabel", btn)
    ico.Name = "BtnIcon"; ico.Size = UDim2.new(0, 20, 1, 0); ico.Position = UDim2.new(0, 10, 0, 0); ico.BackgroundTransparency = 1
    ico.Font = Enum.Font.GothamBold; ico.Text = icon; ico.TextSize = 12; ico.TextColor3 = Color3.fromRGB(148, 163, 184)

    ui.navButtons[pageName] = btn
    btn.MouseButton1Click:Connect(function() ui.ShowTab(pageName) end)
    return btn
end

function ui.CreatePage(name)
    local page = Instance.new("Frame", ui.ContentArea)
    page.Name = name .. "Page"; page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.Visible = false 
    ui.pageRefs[name] = page
    return page
end

function ui.CreateCard(parentPage, name, size, pos, icon)
    local card = Instance.new("Frame", parentPage)
    card.Name = name .. "Card"; card.Size = size; card.Position = pos; card.BackgroundColor3 = Color3.fromRGB(14, 22, 40); card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", card).Color = Color3.fromRGB(22, 32, 54)
    
    local title = Instance.new("TextLabel", card)
    title.Text = name; title.Font = Enum.Font.GothamBold; title.TextSize = 12; title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Position = UDim2.new(0, 42, 0, 14); title.Size = UDim2.new(0, 150, 0, 16); title.BackgroundTransparency = 1; title.TextXAlignment = Enum.TextXAlignment.Left
    
    local ico = Instance.new("TextLabel", card)
    ico.Text = icon; ico.Font = Enum.Font.GothamBold; ico.TextSize = 14; ico.TextColor3 = Color3.fromRGB(56, 189, 248)
    ico.Position = UDim2.new(0, 16, 0, 14); ico.Size = UDim2.new(0, 20, 0, 16); ico.BackgroundTransparency = 1
    
    return card
end

function ui.CreateToggle(parentCard, active, callback)
    local switch = Instance.new("TextButton", parentCard)
    switch.Size = UDim2.new(0, 36, 0, 20); switch.Position = UDim2.new(1, -52, 0, 12)
    switch.BackgroundColor3 = active and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(30, 41, 59); switch.Text = ""
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", switch)
    circle.Size = UDim2.new(0, 14, 0, 14); circle.Position = active and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3); circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    switch.MouseButton1Click:Connect(function()
        active = not active
        switch.BackgroundColor3 = active and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(30, 41, 59)
        circle:TweenPosition(active and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3), "Out", "Quad", 0.15, true)
        callback(active)
    end)
end

function ui.CreateInlineToggle(parentCard, text, yPos, active, callback)
    local container = Instance.new("Frame", parentCard)
    container.Size = UDim2.new(1, -32, 0, 30); container.Position = UDim2.new(0, 16, 0, yPos); container.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", container)
    lbl.Text = text; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11; lbl.TextColor3 = Color3.fromRGB(148, 163, 184)
    lbl.Size = UDim2.new(0, 200, 1, 0); lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local switch = Instance.new("TextButton", container)
    switch.Size = UDim2.new(0, 32, 0, 18); switch.Position = UDim2.new(1, -32, 0.5, -9)
    switch.BackgroundColor3 = active and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(30, 41, 59); switch.Text = ""
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", switch)
    circle.Size = UDim2.new(0, 12, 0, 12); circle.Position = active and UDim2.new(1, -15, 0, 3) or UDim2.new(0, 3, 0, 3); circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    switch.MouseButton1Click:Connect(function()
        active = not active
        switch.BackgroundColor3 = active and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(30, 41, 59)
        circle:TweenPosition(active and UDim2.new(1, -15, 0, 3) or UDim2.new(0, 3, 0, 3), "Out", "Quad", 0.12, true)
        callback(active)
    end)
end

function ui.ShowTab(pageName)
    if ui.currentTab == pageName then return end
    for name, page in pairs(ui.pageRefs) do page.Visible = false end
    for name, btn in pairs(ui.navButtons) do
        btn.BackgroundTransparency = 1
        btn.Indicator.Visible = false
        btn.BtnText.TextColor3 = Color3.fromRGB(148, 163, 184)
        btn.BtnIcon.TextColor3 = Color3.fromRGB(148, 163, 184)
    end
    if ui.pageRefs[pageName] then
        ui.pageRefs[pageName].Visible = true
        local btn = ui.navButtons[pageName]
        if btn then
            btn.BackgroundTransparency = 0 
            btn.Indicator.Visible = true
            btn.BtnText.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BtnIcon.TextColor3 = Color3.fromRGB(56, 189, 248)
        end
        ui.currentTab = pageName
    end
end

return ui
--d