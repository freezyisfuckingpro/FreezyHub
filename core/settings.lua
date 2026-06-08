-- core/settings.lua
local settings = {
    flyEnabled = false,
    noclipEnabled = false,
    farmEnabled = false,
    
    -- ESP Settings
    espEnabled = false,
    selfEspEnabled = false,
    teamCheckEnabled = true,
    espSizeMultiplier = 1.0,
    espBoxes = false,
    espSkeletons = false,
    espTracers = false,
    
    -- Aimbot & FOV Settings
    aimbotEnabled = false,
    aimbotTeamCheck = true,
    aimbotSmoothing = 1,          -- Höher = Langsamer/Legiter, 1 = Insta-Lock
    aimbotTargetPart = "Head",    -- "Head" oder "HumanoidRootPart"
    
    fovEnabled = false,
    fovRadius = 100,             -- Größe des Kreises
    fovColor = Color3.fromRGB(255, 255, 255),
    
    flySpeed = 50,
    farmDelay = 1.5,
    savedCFrame = nil,
    
    colors = {
        Self = Color3.fromRGB(168, 85, 247),
        Enemy = Color3.fromRGB(239, 68, 68),
        Box = Color3.fromRGB(239, 68, 68),
        Skeleton = Color3.fromRGB(255, 255, 0),
        Tracer = Color3.fromRGB(56, 189, 248),
        Team = Color3.fromRGB(34, 197, 94)
    },
    
    connections = {},
    espObjects = {}
}

function settings.addConnection(name, connection)
    if settings.connections[name] then settings.connections[name]:Disconnect() end
    settings.connections[name] = connection
end

return settings