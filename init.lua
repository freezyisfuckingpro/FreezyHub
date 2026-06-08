-- init.lua
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("FreezyHubV2") then CoreGui.FreezyHubV2:Destroy() end

-- Dein GitHub-Pfad
local baseUrl = "https://raw.githubusercontent.com/freezyisfuckingpro/FreezyHub/main/"

-- Module laden
local settings = loadstring(game:HttpGet(baseUrl .. "core/settings.lua"))()
local ui = loadstring(game:HttpGet(baseUrl .. "core/ui_library.lua"))()

-- GUI Hauptcontainer erstellen
ui.CreateMainContainer(settings)

-- Tabs laden und UI + Settings sauber übergeben
local mainTabLoader = loadstring(game:HttpGet(baseUrl .. "tabs/main_tab.lua"))()
mainTabLoader(ui, settings)

local visualsTabLoader = loadstring(game:HttpGet(baseUrl .. "tabs/visuals_tab.lua"))()
visualsTabLoader(ui, settings)

-- Startseite festlegen
ui.ShowTab("Main")