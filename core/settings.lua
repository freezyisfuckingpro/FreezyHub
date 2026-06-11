-- core/settings.lua
local settings = {
    flyEnabled = false,
    noclipEnabled = false,
    farmEnabled = false,
    gamepassUnlockerEnabled = false,
    
    -- ESP Settings
    espEnabled = false,
    selfEspEnabled = false,
    teamCheckEnabled = true,
    espSizeMultiplier = 1.0,
    espBoxes = false,
    espSkeletons = false,
    espTracers = false,
    
    -- Aimbot & FOV Settings (Perfekt abgestimmt auf Rivals)
    aimbotEnabled = false,
    silentAimEnabled = false,     
    magicBulletEnabled = false,   -- NEU: Schalter für Wand-Bypass
    triggerbotEnabled = false,    
    aimbotTeamCheck = true,
    aimbotSmoothing = 4,          -- Optimaler Standardwert für Rivals
    aimbotTargetPart = "Head",    -- "Head" oder "HumanoidRootPart" (Torso)
    
    fovEnabled = false,
    fovRadius = 140,              -- Lässt sich jetzt über deinen Slider live anpassen
    fovColor = Color3.fromRGB(255, 80, 80),
    
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