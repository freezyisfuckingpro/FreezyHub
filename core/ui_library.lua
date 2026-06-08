-- FreezyHub/core/ui_library.lua
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

function ui.CreateMainContainer()
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

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(24, 33, 50)
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    -- Dragging (Verschieben der GUI)
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

    -- Sidebar Basis
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(13, 20, 35)
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BorderSizePixel = 0
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 14)
    SidebarCorner.Parent = Sidebar

    -- Content Area für die Tabs
    local Content = Instance.new("Frame")
    Content.Name = "ContentArea"
    Content.Position = UDim2.new(0, 205, 0, 60)
    Content.Size = UDim2.new(1, -230, 1, -140)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame
    ui.ContentArea = Content

    return MainFrame
end

function ui.CreatePage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false 
    page.Parent = ui.ContentArea
    ui.pageRefs[name] = page
    return page
end

function ui.CreateCard(parentPage, name, size, pos, icon)
    local card = Instance.new("Frame")
    card.Name = name .. "Card"
    card.Size = size
    card.Position = pos
    card.BackgroundColor3 = Color3.fromRGB(14, 22, 40)
    card.BorderSizePixel = 0
    card.Parent = parentPage
    
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 12)
    cc.Parent = card
    
    local title = Instance.new("TextLabel")
    title.Text = name
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Position = UDim2.new(0, 42, 0, 14)
    title.Size = UDim2.new(0, 150, 0, 16)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card
    
    return card
end

function ui.CreateToggle(parentCard, active, callback)
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 36, 0, 20)
    switch.Position = UDim2.new(1, -52, 0, 12)
    switch.BackgroundColor3 = active and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(30, 41, 59)
    switch.Text = ""
    switch.Parent = parentCard
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = active and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = switch
    
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    
    switch.MouseButton1Click:Connect(function()
        active = not active
        switch.BackgroundColor3 = active and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(30, 41, 59)
        circle:TweenPosition(active and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3), "Out", "Quad", 0.15, true)
        callback(active)
    end)
end

function ui.ShowTab(pageName)
    if ui.currentTab == pageName then return end
    for name, page in pairs(ui.pageRefs) do page.Visible = false end
    if ui.pageRefs[pageName] then
        ui.pageRefs[pageName].Visible = true
        ui.currentTab = pageName
    end
end

return ui