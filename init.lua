-- init.lua
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("FreezyHubV2") then CoreGui.FreezyHubV2:Destroy() end

-- Live-Quellen: zuerst main, dann master als Fallback
local baseUrls = {
    "https://raw.githubusercontent.com/freezyisfuckingpro/FreezyHub/main/",
    "https://raw.githubusercontent.com/freezyisfuckingpro/FreezyHub/master/"
}

local function loadRemoteFile(path)
    local lastError
    for _, baseUrl in ipairs(baseUrls) do
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(baseUrl .. path))()
        end)
        if ok and result ~= nil then
            return result
        end
        lastError = (lastError or "") .. "\n- " .. baseUrl .. path .. " -> " .. tostring(result)
    end
    error("Failed to load remote file: " .. path .. lastError)
end

-- Module laden
local settings = loadRemoteFile("core/settings.lua")
local ui = loadRemoteFile("core/ui_library.lua")

-- GUI erstellen
ui.CreateMainContainer(settings)

-- Tabs laden
loadRemoteFile("tabs/main_tab.lua")(ui, settings)
loadRemoteFile("tabs/visuals_tab.lua")(ui, settings)
loadRemoteFile("tabs/aimbot_tab.lua")(ui, settings)

-- Start-Tab öffnen
ui.ShowTab("Main")