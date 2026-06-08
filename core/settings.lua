-- FreezyHub/core/settings.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local settings = {
    flyEnabled = false,
    noclipEnabled = false,
    farmEnabled = false,
    
    espEnabled = false,
    selfEspEnabled = false,
    teamCheckEnabled = true,
    espSizeMultiplier = 1.0,
    
    flySpeed = 50,
    farmDelay = 1.5,
    savedCFrame = nil,
    
    colors = {
        Self = Color3.fromRGB(168, 85, 247),
        Enemy = Color3.fromRGB(239, 68, 68),
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