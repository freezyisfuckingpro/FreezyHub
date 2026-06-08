-- init.lua
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("FreezyHubV2") then CoreGui.FreezyHubV2:Destroy() end

-- Dein spezifischer GitHub-Pfad
local baseUrl = "https://raw.githubusercontent.com/freezyisfuckingpro/FreezyHub/main/"

-- Module laden
local settings = loadstring(game:HttpGet(baseUrl .. "core/settings.lua"))()
local ui = loadstring(game:HttpGet(baseUrl .. "core/ui_library.lua"))()

-- GUI erstellen
ui.CreateMainContainer(settings)

-- Tabs laden
loadstring(game:HttpGet(baseUrl .. "tabs/main_tab.lua"))()(ui, settings)
loadstring(game:HttpGet(baseUrl .. "tabs/visuals_tab.lua"))()(ui, settings)
loadstring(game:HttpGet(baseUrl .. "tabs/aimbot_tab.lua"))()(ui, settings) -- Hier wird das neue Tab eingehängt!

-- Start-Tab öffnen
ui.ShowTab("Main")