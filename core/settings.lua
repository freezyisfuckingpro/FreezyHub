-- core/settings.lua
local settings = {
    flyEnabled = false,
    noclipEnabled = false,
    farmEnabled = false,
    
    -- ESP Master Switches
    espEnabled = false,
    selfEspEnabled = false,
    teamCheckEnabled = true,
    espSizeMultiplier = 1.0,
    
    -- Neue ESP Render-Zustände
    espBoxes = false,
    espSkeletons = false,
    espTracers = false,
    
    flySpeed = 50,
    farmDelay = 1.5,
    savedCFrame = nil,
    
    -- Vollständiges Farbprofil für alle Einzel-Features
    colors = {
        Self = Color3.fromRGB(168, 85, 247),     -- Lila für dich selbst
        Enemy = Color3.fromRGB(239, 68, 68),    -- Standard Gegner-Farbe
        Box = Color3.fromRGB(239, 68, 68),      -- Custom Farbe für Boxen
        Skeleton = Color3.fromRGB(255, 255, 0),  -- Custom Farbe für Skeletons
        Tracer = Color3.fromRGB(56, 189, 248),   -- Custom Farbe für Tracers
        Team = Color3.fromRGB(34, 197, 94)       -- Grün für dein Team
    },
    
    connections = {},
    espObjects = {}
}

function settings.addConnection(name, connection)
    if settings.connections[name] then settings.connections[name]:Disconnect() end
    settings.connections[name] = connection
end

return settings