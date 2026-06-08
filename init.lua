local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Alte GUI säubern, falls vorhanden
if CoreGui:FindFirstChild("FreezyHubV2") then CoreGui.FreezyHubV2:Destroy() end

-- ==================== GLOBALE VARIABLEN & STATES ====================
local flyEnabled = false
local noclipEnabled = false
local farmEnabled = false

-- Visuals Settings
local espEnabled = false 
local selfEspEnabled = false
local teamCheckEnabled = true
local espSizeMultiplier = 1.0 

local flySpeed = 50
local farmDelay = 1.5
local savedCFrame = nil

-- Farben Konfiguration
local colors = {
    Self = Color3.fromRGB(168, 85, 247), 
    Enemy = Color3.fromRGB(239, 68, 68),  
    Team = Color3.fromRGB(34, 197, 94)    
}

-- Verbindungs-Speicher für sauberes Cleanup
local connections = {
    fly = nil,
    noclip = nil,
    toggleUI = nil,
    slider = nil,
    sizeSlider = nil,
    espRender = nil,
    espAdded = nil,
    espRemoving = nil
}

local espObjects = {} 

local function addConnection(name, connection)
    if connections[name] then connections[name]:Disconnect() end
    connections[name] = connection
end

-- ==================== GUI ERSTELLUNG ====================
local FreezyHubV2 = Instance.new("ScreenGui")
FreezyHubV2.Name = "FreezyHubV2"
FreezyHubV2.Parent = CoreGui
FreezyHubV2.ResetOnSpawn = false
FreezyHubV2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN CONTAINER
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = FreezyHubV2
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
MainFrame.Position = UDim2.new(0.5, -425, 0.5, -280)
MainFrame.Size = UDim2.new(0, 850, 0, 560)
MainFrame.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(24, 33, 50)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Dragging Logik
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

-- ==================== SIDEBAR ====================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 20, 35)
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BorderSizePixel = 0

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 14)
SidebarCorner.Parent = Sidebar

local SidebarFix = Instance.new("Frame")
SidebarFix.Size = UDim2.new(0, 20, 1, 0)
SidebarFix.Position = UDim2.new(1, -20, 0, 0)
SidebarFix.BackgroundColor3 = Color3.fromRGB(13, 20, 35)
SidebarFix.BorderSizePixel = 0
SidebarFix.ZIndex = 0
SidebarFix.Parent = Sidebar

local LogoFrame = Instance.new("Frame")
LogoFrame.Size = UDim2.new(1, 0, 0, 70)
LogoFrame.BackgroundTransparency = 1
LogoFrame.Parent = Sidebar

local LogoIcon = Instance.new("TextLabel")
LogoIcon.Text = "❄"
LogoIcon.Font = Enum.Font.GothamBold
LogoIcon.TextSize = 24
LogoIcon.TextColor3 = Color3.fromRGB(56, 189, 248)
LogoIcon.Position = UDim2.new(0, 20, 0.5, -12)
LogoIcon.Size = UDim2.new(0, 24, 0, 24)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Parent = LogoFrame

local LogoText = Instance.new("TextLabel")
LogoText.Text = "FREEZY HUB"
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 15
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.Position = UDim2.new(0, 50, 0, 18)
LogoText.Size = UDim2.new(0, 100, 0, 20)
LogoText.BackgroundTransparency = 1
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = LogoFrame

local SubText = Instance.new("TextLabel")
SubText.Text = "BYPASS SYSTEM v2.3"
SubText.Font = Enum.Font.Gotham
SubText.TextSize = 9
SubText.TextColor3 = Color3.fromRGB(100, 116, 139)
SubText.Position = UDim2.new(0, 50, 0, 36)
SubText.Size = UDim2.new(0, 100, 0, 12)
SubText.BackgroundTransparency = 1
SubText.TextXAlignment = Enum.TextXAlignment.Left
SubText.Parent = LogoFrame

local NavContainer = Instance.new("Frame")
NavContainer.Position = UDim2.new(0, 12, 0, 80)
NavContainer.Size = UDim2.new(1, -24, 0, 340)
NavContainer.BackgroundTransparency = 1
NavContainer.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 6)
NavLayout.Parent = NavContainer

local pageRefs = {} 
local navButtons = {} 

local function createNavTab(name, icon, pageName)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundTransparency = 1 
    btn.BackgroundColor3 = Color3.fromRGB(23, 37, 68)
    btn.Text = ""
    btn.Parent = NavContainer
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    
    local ind = Instance.new("Frame") 
    ind.Name = "Indicator"
    ind.Size = UDim2.new(0, 3, 0, 16)
    ind.Position = UDim2.new(0, 0, 0.5, -8)
    ind.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
    ind.BorderSizePixel = 0
    ind.Visible = false
    ind.Parent = btn
    
    local lbl = Instance.new("TextLabel")
    lbl.Name = "BtnText"
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = name
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(148, 163, 184) 
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn
    
    local ico = Instance.new("TextLabel")
    ico.Name = "BtnIcon"
    ico.Size = UDim2.new(0, 20, 1, 0)
    ico.Position = UDim2.new(0, 10, 0, 0)
    ico.BackgroundTransparency = 1
    ico.Font = Enum.Font.GothamBold
    ico.Text = icon
    ico.TextSize = 12
    ico.TextColor3 = Color3.fromRGB(148, 163, 184) 
    ico.Parent = btn

    navButtons[pageName] = btn
    return btn
end

-- User Profil Bereich
local UserFrame = Instance.new("Frame")
UserFrame.Size = UDim2.new(1, -20, 0, 54)
UserFrame.Position = UDim2.new(0, 10, 1, -110)
UserFrame.BackgroundColor3 = Color3.fromRGB(18, 27, 47)
UserFrame.Parent = Sidebar

local UserCorner = Instance.new("UICorner")
UserCorner.CornerRadius = UDim.new(0, 8)
UserCorner.Parent = UserFrame

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 34, 0, 34)
Avatar.Position = UDim2.new(0, 10, 0.5, -17)
Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
Avatar.Parent = UserFrame
local AvCorner = Instance.new("UICorner")
AvCorner.CornerRadius = UDim.new(1, 0)
AvCorner.Parent = Avatar

local UserName = Instance.new("TextLabel")
UserName.Text = "@" .. LocalPlayer.Name
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 11
UserName.TextColor3 = Color3.fromRGB(255, 255, 255)
UserName.Position = UDim2.new(0, 52, 0, 12)
UserName.Size = UDim2.new(0, 100, 0, 14)
UserName.BackgroundTransparency = 1
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.Parent = UserFrame

local PremiumBadge = Instance.new("TextLabel")
PremiumBadge.Text = "👑 Premium User"
PremiumBadge.Font = Enum.Font.GothamMedium
PremiumBadge.TextSize = 9
PremiumBadge.TextColor3 = Color3.fromRGB(56, 189, 248)
PremiumBadge.Position = UDim2.new(0, 52, 0, 28)
PremiumBadge.Size = UDim2.new(0, 100, 0, 12)
PremiumBadge.BackgroundTransparency = 1
PremiumBadge.TextXAlignment = Enum.TextXAlignment.Left
PremiumBadge.Parent = UserFrame

local StatusText = Instance.new("TextLabel")
StatusText.Text = "STATUS: ACTIVE V2.3"
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 9
StatusText.TextColor3 = Color3.fromRGB(34, 197, 94)
StatusText.Position = UDim2.new(0, 12, 1, -40)
StatusText.Size = UDim2.new(0, 150, 0, 20)
StatusText.BackgroundTransparency = 1
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = Sidebar

-- ==================== TOP BAR & CONTROLS ====================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -180, 0, 60)
TopBar.Position = UDim2.new(0, 180, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local WelcomeText = Instance.new("TextLabel")
WelcomeText.Text = "Welcome back, " .. LocalPlayer.DisplayName .. " 👋"
WelcomeText.Font = Enum.Font.GothamMedium
WelcomeText.TextSize = 12
WelcomeText.TextColor3 = Color3.fromRGB(148, 163, 184)
WelcomeText.Position = UDim2.new(0, 25, 0.5, -8)
WelcomeText.Size = UDim2.new(0, 300, 0, 16)
WelcomeText.BackgroundTransparency = 1
WelcomeText.TextXAlignment = Enum.TextXAlignment.Left
WelcomeText.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -38, 0, 18)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.ZIndex = 2
CloseBtn.Parent = TopBar
local CbCorner = Instance.new("UICorner")
CbCorner.CornerRadius = UDim.new(0, 6)
CbCorner.Parent = CloseBtn

-- ==================== MAIN CONTENT AREA (PAGES) ====================
local Content = Instance.new("Frame")
Content.Name = "ContentArea"
Content.Position = UDim2.new(0, 205, 0, 60)
Content.Size = UDim2.new(1, -230, 1, -140)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false 
    page.Parent = Content
    pageRefs[name] = page
    return page
end

local function createCard(parentPage, name, size, pos, icon)
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
    
    local cs = Instance.new("UIStroke")
    cs.Color = Color3.fromRGB(22, 32, 54)
    cs.Thickness = 1
    cs.Parent = card
    
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
    
    local ico = Instance.new("TextLabel")
    ico.Text = icon
    ico.Font = Enum.Font.GothamBold
    ico.TextSize = 14
    ico.TextColor3 = Color3.fromRGB(56, 189, 248)
    ico.Position = UDim2.new(0, 16, 0, 14)
    ico.Size = UDim2.new(0, 20, 0, 16)
    ico.BackgroundTransparency = 1
    ico.Parent = card
    
    return card
end

local function createToggle(parentCard, active, callback)
    local switch = Instance.new("TextButton")
    switch.Name = "Toggle"
    switch.Size = UDim2.new(0, 36, 0, 20)
    switch.Position = UDim2.new(1, -52, 0, 12)
    switch.BackgroundColor3 = active and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(30, 41, 59)
    switch.Text = ""
    switch.Parent = parentCard
    
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(1, 0)
    sc.Parent = switch
    
    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = active and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = switch
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = circle
    
    switch.MouseButton1Click:Connect(function()
        active = not active
        switch.BackgroundColor3 = active and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(30, 41, 59)
        circle:TweenPosition(active and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3), "Out", "Quad", 0.15, true)
        callback(active)
    end)
end

local function createInlineToggle(parentCard, text, yPos, active, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -32, 0, 30)
    container.Position = UDim2.new(0, 16, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = parentCard

    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(148, 163, 184)
    lbl.Size = UDim2.new(0, 200, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 32, 0, 18)
    switch.Position = UDim2.new(1, -32, 0.5, -9)
    switch.BackgroundColor3 = active and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(30, 41, 59)
    switch.Text = ""
    switch.Parent = container
    
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(1, 0)
    sc.Parent = switch
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 12, 0, 12)
    circle.Position = active and UDim2.new(1, -15, 0, 3) or UDim2.new(0, 3, 0, 3)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = switch
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = circle
    
    switch.MouseButton1Click:Connect(function()
        active = not active
        switch.BackgroundColor3 = active and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(30, 41, 59)
        circle:TweenPosition(active and UDim2.new(1, -15, 0, 3) or UDim2.new(0, 3, 0, 3), "Out", "Quad", 0.12, true)
        callback(active)
    end)
end

-- ==================== TAB LOGIK ====================
local currentTab = nil
local function showTab(pageName)
    if currentTab == pageName then return end
    for name, page in pairs(pageRefs) do page.Visible = false end
    for name, btn in pairs(navButtons) do
        btn.BackgroundTransparency = 1
        btn.Indicator.Visible = false
        btn.BtnText.TextColor3 = Color3.fromRGB(148, 163, 184)
        btn.BtnIcon.TextColor3 = Color3.fromRGB(148, 163, 184)
    end
    if pageRefs[pageName] then
        pageRefs[pageName].Visible = true
        local btn = navButtons[pageName]
        if btn then
            btn.BackgroundTransparency = 0 
            btn.Indicator.Visible = true
            btn.BtnText.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BtnIcon.TextColor3 = Color3.fromRGB(56, 189, 248)
        end
        currentTab = pageName
    end
end

-- TABS INITIALISIEREN
local MainTabBtn = createNavTab("Main Hacks", "🏠", "Main")
local VisualsTabBtn = createNavTab("Visuals", "👁", "Visuals")
local PlayerTabBtn = createNavTab("Player", "👤", "Player") 
local MovementTabBtn = createNavTab("Movement", "🏃", "Movement")
local WorldTabBtn = createNavTab("World", "🌐", "World")
local MiscTabBtn = createNavTab("Misc", "⚙", "Misc")

MainTabBtn.MouseButton1Click:Connect(function() showTab("Main") end)
VisualsTabBtn.MouseButton1Click:Connect(function() showTab("Visuals") end)
PlayerTabBtn.MouseButton1Click:Connect(function() showTab("Player") end)
MovementTabBtn.MouseButton1Click:Connect(function() showTab("Movement") end)
WorldTabBtn.MouseButton1Click:Connect(function() showTab("World") end)
MiscTabBtn.MouseButton1Click:Connect(function() showTab("Misc") end)

createPage("Player")
createPage("Movement")
createPage("World")
createPage("Misc")

-- ---------------- PAGE 1: MAIN HACKS ----------------
local MainPage = createPage("Main")

local CardFly = createCard(MainPage, "FLY MODE", UDim2.new(0, 310, 0, 180), UDim2.new(0, 0, 0, 0), "✈")
local FlyDesc = Instance.new("TextLabel")
FlyDesc.Text = "Ermöglicht dir zu fliegen. Steuerung: WASD + Space/Shift."
FlyDesc.Font = Enum.Font.Gotham
FlyDesc.TextSize = 11
FlyDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
FlyDesc.Position = UDim2.new(0, 16, 0, 45)
FlyDesc.Size = UDim2.new(1, -32, 0, 32)
FlyDesc.BackgroundTransparency = 1
FlyDesc.TextWrapped = true
FlyDesc.TextXAlignment = Enum.TextXAlignment.Left
FlyDesc.Parent = CardFly

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Text = "GESCHWINDIGKEIT"
SpeedTitle.Font = Enum.Font.GothamBold
SpeedTitle.TextSize = 9
SpeedTitle.TextColor3 = Color3.fromRGB(71, 85, 105)
SpeedTitle.Position = UDim2.new(0, 16, 0, 95)
SpeedTitle.Size = UDim2.new(0, 150, 0, 15)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.Parent = CardFly

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, -85, 0, 6)
SliderTrack.Position = UDim2.new(0, 16, 0, 128)
SliderTrack.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
SliderTrack.BorderSizePixel = 0
SliderTrack.Parent = CardFly
Instance.new("UICorner", SliderTrack)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.2, 0, 1, 0) 
SliderFill.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderTrack
Instance.new("UICorner", SliderFill)

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(0, 14, 0, 14)
SliderBtn.Position = UDim2.new(0.2, -7, 0.5, -7) 
SliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderBtn.Text = ""
SliderBtn.Parent = SliderTrack
Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

local SliderBox = Instance.new("Frame")
SliderBox.Size = UDim2.new(0, 45, 0, 24)
SliderBox.Position = UDim2.new(1, -55, 0, 118)
SliderBox.BackgroundColor3 = Color3.fromRGB(20, 30, 54)
SliderBox.Parent = CardFly
Instance.new("UICorner", SliderBox).CornerRadius = UDim.new(0, 6)

local SliderValue = Instance.new("TextLabel")
SliderValue.Size = UDim2.new(1, 0, 1, 0)
SliderValue.Text = "50"
SliderValue.Font = Enum.Font.GothamMedium
SliderValue.TextSize = 11
SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderValue.BackgroundTransparency = 1
SliderValue.Parent = SliderBox

local CardNoclip = createCard(MainPage, "NOCLIP", UDim2.new(0, 310, 0, 180), UDim2.new(0, 330, 0, 0), "🛡")
local NoclipDesc = Instance.new("TextLabel")
NoclipDesc.Text = "Deaktiviert Kollisionen. Du kannst durch Wände gehen."
NoclipDesc.Font = Enum.Font.Gotham
NoclipDesc.TextSize = 11
NoclipDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
NoclipDesc.Position = UDim2.new(0, 16, 0, 45)
NoclipDesc.Size = UDim2.new(1, -32, 0, 32)
NoclipDesc.BackgroundTransparency = 1
NoclipDesc.TextWrapped = true
NoclipDesc.TextXAlignment = Enum.TextXAlignment.Left
NoclipDesc.Parent = CardNoclip

local CardTp = createCard(MainPage, "TELEPORT SYSTEM", UDim2.new(0, 310, 0, 160), UDim2.new(0, 0, 0, 200), "📍")
local SaveAction = Instance.new("TextButton")
SaveAction.Size = UDim2.new(1, -32, 0, 38)
SaveAction.Position = UDim2.new(0, 16, 0, 55)
SaveAction.BackgroundColor3 = Color3.fromRGB(20, 30, 54)
SaveAction.Text = "💾 Save Position"
SaveAction.Font = Enum.Font.GothamMedium
SaveAction.TextSize = 11
SaveAction.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveAction.Parent = CardTp
Instance.new("UICorner", SaveAction).CornerRadius = UDim.new(0, 8)

local TpAction = Instance.new("TextButton")
TpAction.Size = UDim2.new(1, -32, 0, 38)
TpAction.Position = UDim2.new(0, 16, 0, 105)
TpAction.BackgroundColor3 = Color3.fromRGB(20, 30, 54)
TpAction.Text = "🚀 Teleport to Waypoint"
TpAction.Font = Enum.Font.GothamMedium
TpAction.TextSize = 11
TpAction.TextColor3 = Color3.fromRGB(100, 116, 139) 
TpAction.Parent = CardTp
Instance.new("UICorner", TpAction).CornerRadius = UDim.new(0, 8)

local CardFarm = createCard(MainPage, "AUTO-FARM fields", UDim2.new(0, 310, 0, 160), UDim2.new(0, 330, 0, 200), "🌿")
local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(0, 135, 0, 32)
StatusLbl.Position = UDim2.new(0, 16, 0, 105)
StatusLbl.Text = "Bereit..."
StatusLbl.Font = Enum.Font.GothamMedium
StatusLbl.TextColor3 = Color3.fromRGB(56, 189, 248)
StatusLbl.BackgroundTransparency = 1
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Parent = CardFarm

-- ---------------- PAGE 2: VISUALS ----------------
local VisualsPage = createPage("Visuals")

local CardEsp = createCard(VisualsPage, "PLAYER & SELF ESP SYSTEMS", UDim2.new(0, 390, 0, 240), UDim2.new(0, 0, 0, 0), "👁")
local EspDesc = Instance.new("TextLabel")
EspDesc.Text = "Erweiterte Visualisierungssysteme für Feinde, Teams und dich selbst."
EspDesc.Font = Enum.Font.Gotham
EspDesc.TextSize = 11
EspDesc.TextColor3 = Color3.fromRGB(100, 116, 139)
EspDesc.Position = UDim2.new(0, 16, 0, 45)
EspDesc.Size = UDim2.new(1, -32, 0, 30)
EspDesc.BackgroundTransparency = 1
EspDesc.TextWrapped = true
EspDesc.TextXAlignment = Enum.TextXAlignment.Left
EspDesc.Parent = CardEsp

createInlineToggle(CardEsp, "👤 Enable Self ESP (Show Me)", 85, false, function(state)
    selfEspEnabled = state
end)

createInlineToggle(CardEsp, "🛡 Enable Team-Check", 125, true, function(state)
    teamCheckEnabled = state
end)

local SizeTitle = Instance.new("TextLabel")
SizeTitle.Text = "ESP BOX SIZE MULTIPLIER"
SizeTitle.Font = Enum.Font.GothamBold; SizeTitle.TextSize = 9; SizeTitle.TextColor3 = Color3.fromRGB(71, 85, 105)
SizeTitle.Position = UDim2.new(0, 16, 0, 165); SizeTitle.Size = UDim2.new(0, 180, 0, 15); SizeTitle.BackgroundTransparency = 1; SizeTitle.Parent = CardEsp

local SizeTrack = Instance.new("Frame")
SizeTrack.Size = UDim2.new(1, -115, 0, 6); SizeTrack.Position = UDim2.new(0, 16, 0, 195); SizeTrack.BackgroundColor3 = Color3.fromRGB(30, 41, 59); SizeTrack.Parent = CardEsp
Instance.new("UICorner", SizeTrack)

local SizeFill = Instance.new("Frame")
SizeFill.Size = UDim2.new(0.33, 0, 1, 0); SizeFill.BackgroundColor3 = Color3.fromRGB(56, 189, 248); SizeFill.Parent = SizeTrack
Instance.new("UICorner", SizeFill)

local SizeSliderBtn = Instance.new("TextButton")
SizeSliderBtn.Size = UDim2.new(0, 14, 0, 14); SizeSliderBtn.Position = UDim2.new(0.33, -7, 0.5, -7); SizeSliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); SizeSliderBtn.Text = ""; SizeSliderBtn.Parent = SizeTrack
Instance.new("UICorner", SizeSliderBtn).CornerRadius = UDim.new(1, 0)

local SizeBox = Instance.new("Frame")
SizeBox.Size = UDim2.new(0, 55, 0, 24); SizeBox.Position = UDim2.new(1, -85, 0, 185); SizeBox.BackgroundColor3 = Color3.fromRGB(20, 30, 54); SizeBox.Parent = CardEsp
Instance.new("UICorner", SizeBox).CornerRadius = UDim.new(0, 6)

local SizeValue = Instance.new("TextLabel")
SizeValue.Size = UDim2.new(1, 0, 1, 0); SizeValue.Text = "1.0x"; SizeValue.Font = Enum.Font.GothamMedium; SizeValue.TextSize = 11; SizeValue.TextColor3 = Color3.fromRGB(255, 255, 255); SizeValue.BackgroundTransparency = 1; SizeValue.Parent = SizeBox

local CardColors = createCard(VisualsPage, "COLOR PROFILES", UDim2.new(0, 230, 0, 240), UDim2.new(0, 410, 0, 0), "🎨")
local function createColorIndicator(text, color, y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -32, 0, 24)
    frame.Position = UDim2.new(0, 16, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = CardColors
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 0, 0.5, -6)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.Parent = frame
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(148, 163, 184)
    lbl.Position = UDim2.new(0, 22, 0, 0)
    lbl.Size = UDim2.new(1, -22, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
end
createColorIndicator("You (Self ESP)", colors.Self, 55)
createColorIndicator("Enemies / Free Agents", colors.Enemy, 90)
createColorIndicator("Friendly Team", colors.Team, 125)

showTab("Main")

-- ==================== FOOTER BAR ====================
local Footer = Instance.new("Frame")
Footer.Position = UDim2.new(0, 205, 1, -65)
Footer.Size = UDim2.new(1, -230, 0, 50)
Footer.BackgroundTransparency = 1
Footer.Parent = MainFrame

local FooterLayout = Instance.new("UIListLayout")
FooterLayout.FillDirection = Enum.FillDirection.Horizontal
FooterLayout.Padding = UDim.new(0, 10)
FooterLayout.Parent = Footer

local function createFooterBtn(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 150, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(14, 22, 40)
    btn.Text = ""
    btn.Parent = Footer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local bs = Instance.new("UIStroke", btn)
    bs.Color = Color3.fromRGB(22, 32, 54)
    
    local ico = Instance.new("TextLabel")
    ico.Text = icon; ico.Font = Enum.Font.GothamBold; ico.TextSize = 12; ico.TextColor3 = Color3.fromRGB(56, 189, 248)
    ico.Position = UDim2.new(0, 12, 0.5, -7); ico.Size = UDim2.new(0, 16, 0, 14); ico.BackgroundTransparency = 1; ico.Parent = btn
    
    local lbl = Instance.new("TextLabel")
    lbl.Text = name; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11; lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Position = UDim2.new(0, 34, 0, 0); lbl.Size = UDim2.new(1, -34, 1, 0); lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = btn
    return btn
end

local RejoinBtn = createFooterBtn("Rejoin Server", "🔄")
local ResetBtn = createFooterBtn("Reset Char", "💀")
local AfkBtn = createFooterBtn("Anti AFK", "☕")

local VerText = Instance.new("TextLabel")
VerText.Text = "FREEZY HUB v2.3.0 | F1 to toggle"
VerText.Font = Enum.Font.Gotham; VerText.TextSize = 10; VerText.TextColor3 = Color3.fromRGB(71, 85, 105)
VerText.Position = UDim2.new(0.5, -100, 1, -14); VerText.Size = UDim2.new(0, 200, 0, 12); VerText.BackgroundTransparency = 1; VerText.Parent = MainFrame

-- ==================== SLIDER LOGIKEN ====================
local draggingSlider = false
SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end end)
addConnection("slider", RunService.RenderStepped:Connect(function()
    if draggingSlider then
        local mousePos = UserInputService:GetMouseLocation().X
        local trackPos = SliderTrack.AbsolutePosition.X
        local trackWidth = SliderTrack.AbsoluteSize.X
        local percentage = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
        SliderBtn.Position = UDim2.new(percentage, -7, 0.5, -7)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        flySpeed = math.round(percentage * 250)
        SliderValue.Text = tostring(flySpeed)
    end
end))

local draggingSizeSlider = false
SizeSliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSizeSlider = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSizeSlider = false end end)
addConnection("sizeSlider", RunService.RenderStepped:Connect(function()
    if draggingSizeSlider then
        local mousePos = UserInputService:GetMouseLocation().X
        local trackPos = SizeTrack.AbsolutePosition.X
        local trackWidth = SizeTrack.AbsoluteSize.X
        local percentage = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
        SizeSliderBtn.Position = UDim2.new(percentage, -7, 0.5, -7)
        SizeFill.Size = UDim2.new(percentage, 0, 1, 0)
        espSizeMultiplier = 0.4 + (percentage * 1.2)
        SizeValue.Text = string.format("%.1fx", espSizeMultiplier)
    end
end))

-- ==================== CORESYSTEMS (FLY/NOCLIP) ====================
createToggle(CardFly, false, function(state)
    flyEnabled = state
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if flyEnabled and root and humanoid then
        humanoid.PlatformStand = true
        local flyConn = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not root.Parent then connections.fly:Disconnect() return end
            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0, 1, 0) end
            root.Velocity = moveDirection * flySpeed
        end)
        addConnection("fly", flyConn)
    else
        if connections.fly then connections.fly:Disconnect() end
        if humanoid then humanoid.PlatformStand = false end
        if root then root.Velocity = Vector3.new(0, 0, 0) end
    end
end)

createToggle(CardNoclip, false, function(state)
    noclipEnabled = state
    if noclipEnabled then
        addConnection("noclip", RunService.Stepped:Connect(function()
            if noclipEnabled and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end))
    else
        if connections.noclip then connections.noclip:Disconnect() end
    end
end)

SaveAction.MouseButton1Click:Connect(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        savedCFrame = root.CFrame
        SaveAction.Text = "✓ Position Saved!"; SaveAction.TextColor3 = Color3.fromRGB(34, 197, 94)
        TpAction.TextColor3 = Color3.fromRGB(56, 189, 248)
        task.wait(1)
        SaveAction.Text = "💾 Save Position"; SaveAction.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)
TpAction.MouseButton1Click:Connect(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and savedCFrame then
        root.CFrame = savedCFrame
        TpAction.Text = "✓ Teleport Success!"; TpAction.TextColor3 = Color3.fromRGB(34, 197, 94)
        task.wait(1)
        TpAction.Text = "🚀 Teleport to Waypoint"; TpAction.TextColor3 = Color3.fromRGB(56, 189, 248)
    end
end)

createToggle(CardFarm, false, function(state)
    farmEnabled = state
    StatusLbl.TextColor3 = state and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(56, 189, 248)
    StatusLbl.Text = state and "Aktiv am Farmen" or "Bereit..."
end)

-- ==================== ESP ENGINE ====================
local function createESP(player)
    local objects = { Box = nil, NameTag = nil, Stroke = nil }

    local function removeESP()
        if objects.Box then objects.Box:Destroy() end
        if objects.NameTag then objects.NameTag:Destroy() end
        espObjects[player.UserId] = nil
    end

    local function updateESP()
        if player == LocalPlayer and not selfEspEnabled then
            if objects.Box then objects.Box.Visible = false end
            if objects.NameTag then objects.NameTag.Visible = false end
            return
        end

        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")

        if not espEnabled or not root or not humanoid or humanoid.Health <= 0 then
            if objects.Box then objects.Box.Visible = false end
            if objects.NameTag then objects.NameTag.Visible = false end
            return
        end

        if teamCheckEnabled and player ~= LocalPlayer and player.Team == LocalPlayer.Team then
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
            local designColor = colors.Enemy
            if player == LocalPlayer then
                designColor = colors.Self
            elseif player.Team == LocalPlayer.Team then
                designColor = colors.Team
            end

            if not objects.Box then
                local box = Instance.new("Frame")
                box.Name = player.Name .. "_ESPBox"
                box.Parent = FreezyHubV2
                box.BackgroundTransparency = 1
                box.BorderSizePixel = 0
                
                local stroke = Instance.new("UIStroke")
                stroke.Thickness = 1.5
                stroke.LineJoinMode = Enum.LineJoinMode.Miter
                stroke.Parent = box
                
                objects.Box = box
                objects.Stroke = stroke
            end
            
            local calculatedHeight = math.abs(topScreen.Y - bottomScreen.Y)
            local height = math.clamp(calculatedHeight, 5, 600) * espSizeMultiplier
            local width = (height / 1.5)
            
            objects.Box.Visible = true
            objects.Box.Position = UDim2.new(0, topScreen.X - (width / 2), 0, topScreen.Y)
            objects.Box.Size = UDim2.new(0, width, 0, height)
            objects.Stroke.Color = designColor -- REPARIERT: Nutzt nun die direkte Referenz!

            if not objects.NameTag then
                local tag = Instance.new("TextLabel", FreezyHubV2)
                tag.Name = player.Name .. "_ESPTag"
                tag.BackgroundTransparency = 1
                tag.Font = Enum.Font.GothamBold
                tag.TextSize = 10
                tag.TextStrokeTransparency = 0.5
                tag.TextStrokeColor3 = Color3.fromRGB(0,0,0)
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
    espObjects[player.UserId] = objects
end

createToggle(CardEsp, false, function(state)
    espEnabled = state
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do createESP(player) end
        addConnection("espAdded", Players.PlayerAdded:Connect(createESP))
        addConnection("espRemoving", Players.PlayerRemoving:Connect(function(player)
            if espObjects[player.UserId] then espObjects[player.UserId].Remove() end
        end))
        addConnection("espRender", RunService.RenderStepped:Connect(function()
            for _, objects in pairs(espObjects) do
                if objects.Update then objects.Update() end
            end
        end))
    else
        if connections.espAdded then connections.espAdded:Disconnect() end
        if connections.espRemoving then connections.espRemoving:Disconnect() end
        if connections.espRender then connections.espRender:Disconnect() end
        for _, objects in pairs(espObjects) do if objects.Remove then objects.Remove() end end
        espObjects = {}
    end
end)

-- ==================== SYSTEM CONTROLS ====================
addConnection("toggleUI", UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F1 then MainFrame.Visible = not MainFrame.Visible end
end))

CloseBtn.MouseButton1Click:Connect(function()
    for _, conn in pairs(connections) do if conn then conn:Disconnect() end end
    for _, objects in pairs(espObjects) do if objects.Remove then objects.Remove() end end
    local char = LocalPlayer.Character
    if char then
        if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
        if char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) end
    end
    FreezyHubV2:Destroy()
end)

ResetBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then char.Humanoid.Health = 0 end
end)

RejoinBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

local antiAfkActive = false
AfkBtn.MouseButton1Click:Connect(function()
    antiAfkActive = not antiAfkActive
    AfkBtn.UIStroke.Color = antiAfkActive and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(22, 32, 54)
    if antiAfkActive then
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)