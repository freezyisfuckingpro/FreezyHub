-- FreezyHub/init.lua
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("FreezyHubV2") then CoreGui.FreezyHubV2:Destroy() end

-- Dein spezifischer GitHub-Pfad zu den Raw-Dateien
local baseUrl = "https://raw.githubusercontent.com/freezyisfuckingpro/FreezyHub/main/FreezyHub/"

-- Laden der Module direkt von GitHub via HttpGet
local settings = loadstring(game:HttpGet(baseUrl .. "core/settings.lua"))()
local ui = loadstring(game:HttpGet(baseUrl .. "core/ui_library.lua"))()

-- Haupt-UI-Container initialisieren
local MainFrame = ui.CreateMainContainer()

-- Tabs von GitHub laden und Parameter übergeben
local tabs = {}
tabs.main = loadstring(game:HttpGet(baseUrl .. "tabs/main_tab.lua"))()(ui, settings)
tabs.visuals = loadstring(game:HttpGet(baseUrl .. "tabs/visuals_tab.lua"))()(ui, settings)

-- Standard-Tab beim Start öffnen
ui.ShowTab("Main")