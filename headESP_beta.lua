-- Enemy Head Dot ESP with Tabbed Menu Configuration
-- Final Version

-- 1. Include the Menu Library
-- you need to have the menu.lua file in the same directory as this script
-- https://github.com/compuserscripts/lmaomenu/blob/main/menu.lua
local menu = require("menu") -- Ensure menu.lua is accessible

-- 2. ESP Settings Table
local espSettings = {
    dotColor = {r = 255, g = 0, b = 0, a = 255},

    basePixelSize = 6,

    -- Unzoomed Scaling
    unzoomed_distanceMin = 200,
    unzoomed_scaleAtMinDistance = 2.0,
    unzoomed_distanceMax = 2500,
    unzoomed_scaleAtMaxDistance = 0.4,
    unzoomed_absoluteMinPixelSize = 2,
    unzoomed_absoluteMaxPixelSize = 25,

    -- Zoomed Scaling
    zoomed_DotScaleFactor = 0.5,
    zoomed_absoluteMinPixelSize = 1,
    zoomed_absoluteMaxPixelSize = 15,

    menuToggleKey = E_ButtonCode.KEY_DELETE,
    activeSettingsTab = "General" -- Default active tab
}

-- Global reference for the settings window
local espSettingsWindow

-- Helper: Draw the ESP dot
local function drawDot(x, y, currentDotSize, r, g, b, a)
    draw.Color(r, g, b, a)
    local halfSize = currentDotSize / 2 -- Use halfSize for centering
    -- Calculate coordinates ensuring the dot is centered at x, y
    local x1 = x - halfSize
    local y1 = y - halfSize
    local x2 = x + halfSize
    local y2 = y + halfSize

    local finalX1 = math.floor(x1)
    local finalY1 = math.floor(y1)
    local finalX2 = math.floor(x2)
    local finalY2 = math.floor(y2)

    -- Ensure the rectangle has at least 1 pixel width/height if size is >= 1
    if currentDotSize >= 1 then
        if finalX2 <= finalX1 then finalX2 = finalX1 + 1 end
        if finalY2 <= finalY1 then finalY2 = finalY1 + 1 end
    else -- If dot size is effectively 0, draw nothing or a single pixel if desired
        return -- Or draw.FilledRect(math.floor(x), math.floor(y), math.floor(x)+1, math.floor(y)+1)
    end
    draw.FilledRect(finalX1, finalY1, finalX2, finalY2)
end

-- Main ESP Drawing Logic
local function onDrawEsp()
    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer or not localPlayer:IsValid() or not localPlayer:IsAlive() then return end

    local localPlayerTeam = localPlayer:GetTeamNumber()
    if localPlayerTeam == E_TeamNumber.TEAM_UNASSIGNED or localPlayerTeam == E_TeamNumber.TEAM_SPECTATOR then return end

    local localPlayerOrigin = localPlayer:GetAbsOrigin()
    if not localPlayerOrigin then return end

    local isZoomed = localPlayer:InCond(TFCond_Zoomed)
    local currentDrawColor = espSettings.dotColor
    local players = entities.FindByClass("CTFPlayer")
    if not players then return end

    for i = 1, #players do
        local player = players[i]
        if not player or not player:IsValid() or player:GetIndex() == localPlayer:GetIndex() then goto continue end
        if not player:IsAlive() or player:IsDormant() then goto continue end

        local playerTeam = player:GetTeamNumber()
        if playerTeam == localPlayerTeam or playerTeam == E_TeamNumber.TEAM_UNASSIGNED or playerTeam == E_TeamNumber.TEAM_SPECTATOR then goto continue end

        local playerOrigin = player:GetAbsOrigin()
        if not playerOrigin then goto continue end

        local calculatedPixelSize
        if isZoomed then
            calculatedPixelSize = espSettings.basePixelSize * espSettings.zoomed_DotScaleFactor
            calculatedPixelSize = math.max(espSettings.zoomed_absoluteMinPixelSize, calculatedPixelSize)
            calculatedPixelSize = math.min(espSettings.zoomed_absoluteMaxPixelSize, calculatedPixelSize)
        else
            local distance = (localPlayerOrigin - playerOrigin):Length()
            local currentScaleFactor
            if distance <= espSettings.unzoomed_distanceMin then
                currentScaleFactor = espSettings.unzoomed_scaleAtMinDistance
            elseif distance >= espSettings.unzoomed_distanceMax then
                currentScaleFactor = espSettings.unzoomed_scaleAtMaxDistance
            else
                local range = espSettings.unzoomed_distanceMax - espSettings.unzoomed_distanceMin
                if range == 0 then
                    currentScaleFactor = espSettings.unzoomed_scaleAtMinDistance
                else
                    local progress = (distance - espSettings.unzoomed_distanceMin) / range
                    currentScaleFactor = espSettings.unzoomed_scaleAtMinDistance - (progress * (espSettings.unzoomed_scaleAtMinDistance - espSettings.unzoomed_scaleAtMaxDistance))
                end
            end
            calculatedPixelSize = espSettings.basePixelSize * currentScaleFactor
            calculatedPixelSize = math.max(espSettings.unzoomed_absoluteMinPixelSize, calculatedPixelSize)
            calculatedPixelSize = math.min(espSettings.unzoomed_absoluteMaxPixelSize, calculatedPixelSize)
        end

        local finalDotSize = math.floor(calculatedPixelSize + 0.5) -- Round to nearest int
        if finalDotSize < 1 then finalDotSize = 1 end -- Ensure dot is at least 1 pixel if calculated size is > 0

        local hitboxes = player:GetHitboxes()
        if not hitboxes then goto continue end

        local headHitboxIndex = E_Hitbox.HITBOX_HEAD + 1
        local headHitboxData = hitboxes[headHitboxIndex]

        if headHitboxData then
            local mins, maxs = headHitboxData[1], headHitboxData[2]
            if mins and maxs then
                local headCenterWorld = Vector3((mins.x + maxs.x) / 2, (mins.y + maxs.y) / 2, (mins.z + maxs.z) / 2)
                local screenPos = client.WorldToScreen(headCenterWorld)
                if screenPos then
                    drawDot(math.floor(screenPos[1]), math.floor(screenPos[2]), finalDotSize,
                            currentDrawColor.r, currentDrawColor.g, currentDrawColor.b, currentDrawColor.a)
                end
            end
        end
        ::continue::
    end
end

-- Helper functions for creating sliders in the menu
local createFloatSlider = function(window, label, settingTable, settingKey, minVal, maxVal, step)
    step = step or 0.1
    window:createSlider(label, settingTable[settingKey], minVal, maxVal, function(value)
        local roundedValue = math.floor(value / step + 0.5) * step
        settingTable[settingKey] = tonumber(string.format("%.1f", roundedValue)) -- Ensure one decimal place
    end)
end
local createIntSlider = function(window, label, settingTable, settingKey, minVal, maxVal)
    window:createSlider(label, settingTable[settingKey], minVal, maxVal, function(value)
        settingTable[settingKey] = math.floor(value)
    end)
end

-- Tab Content Population Functions
local function populateGeneralTab()
    espSettingsWindow:clearWidgets() -- Use clearWidgets as per menu.lua example
    createIntSlider(espSettingsWindow, "Base Pixel Size", espSettings, "basePixelSize", 1, 30)
    espSettingsWindow.height = espSettingsWindow:calculateHeight()
end

local function populateUnzoomedTab()
    espSettingsWindow:clearWidgets()
    createIntSlider(espSettingsWindow, "Min Distance", espSettings, "unzoomed_distanceMin", 50, 5000)
    createFloatSlider(espSettingsWindow, "Scale @ Min Dist", espSettings, "unzoomed_scaleAtMinDistance", 0.1, 5.0)
    createIntSlider(espSettingsWindow, "Max Distance", espSettings, "unzoomed_distanceMax", 10, 1000)
    createFloatSlider(espSettingsWindow, "Scale @ Max Dist", espSettings, "unzoomed_scaleAtMaxDistance", 0.1, 3.0)
    createIntSlider(espSettingsWindow, "Abs Min Pixels", espSettings, "unzoomed_absoluteMinPixelSize", 1, 20)
    createIntSlider(espSettingsWindow, "Abs Max Pixels", espSettings, "unzoomed_absoluteMaxPixelSize", 1, 50)
    espSettingsWindow.height = espSettingsWindow:calculateHeight()
end

local function populateZoomedTab()
    espSettingsWindow:clearWidgets()
    createFloatSlider(espSettingsWindow, "Dot Scale Factor", espSettings, "zoomed_DotScaleFactor", 0.1, 10.0)
    createIntSlider(espSettingsWindow, "Abs Min Pixels", espSettings, "zoomed_absoluteMinPixelSize", 1, 10)
    createIntSlider(espSettingsWindow, "Abs Max Pixels", espSettings, "zoomed_absoluteMaxPixelSize", 1, 20)
    espSettingsWindow.height = espSettingsWindow:calculateHeight()
end

local function populateColorTab()
    espSettingsWindow:clearWidgets()
    createIntSlider(espSettingsWindow, "Dot R", espSettings.dotColor, "r", 0, 255)
    createIntSlider(espSettingsWindow, "Dot G", espSettings.dotColor, "g", 0, 255)
    createIntSlider(espSettingsWindow, "Dot B", espSettings.dotColor, "b", 0, 255)
    createIntSlider(espSettingsWindow, "Dot A", espSettings.dotColor, "a", 0, 255)
    espSettingsWindow.height = espSettingsWindow:calculateHeight()
end

-- Initialize Menu Window and Tabs
local function initializeMenu()
    espSettingsWindow = menu.createWindow("Head Dot ESP Settings", {
        x = 150,
        y = 100,
        width = 420, -- Adjusted for potentially better text fit with sliders
        desiredItems = 8, -- Less critical with tabs, actual height is dynamic
        onClose = function() printc(0,255,0,255, "ESP Settings window closed.") end
    })

    local tabPanel = espSettingsWindow:renderTabPanel()

    tabPanel:addTab("General", populateGeneralTab)
    tabPanel:addTab("Unzoomed", populateUnzoomedTab)
    tabPanel:addTab("Zoomed", populateZoomedTab)
    tabPanel:addTab("Color", populateColorTab)

    -- Override selectTab to handle active dropdowns and store current tab
    local originalSelectTab = tabPanel.selectTab
    tabPanel.selectTab = function(self, name)
        if menu._mouseState and menu._mouseState.activeDropdown then -- Check if _mouseState exists
            menu._mouseState.activeDropdown = nil
        end
        if originalSelectTab then
            originalSelectTab(self, name)
        end
        espSettings.activeSettingsTab = name
    end
    
    -- Select initial tab
    if espSettings.activeSettingsTab and tabPanel.tabs[espSettings.activeSettingsTab] then
        tabPanel:selectTab(espSettings.activeSettingsTab)
    elseif #tabPanel.tabOrder > 0 then
        tabPanel:selectTab(tabPanel.tabOrder[1])
    end

    espSettingsWindow:unfocus() -- Start with menu closed
end

-- Menu Toggle Logic
local lastMenuToggleState = false
local function handleMenuToggle()
    local currentKeyState = input.IsButtonDown(espSettings.menuToggleKey)
    if currentKeyState and not lastMenuToggleState then
        if not espSettingsWindow then initializeMenu() end -- Initialize if first time

        if not espSettingsWindow.isOpen then
            espSettingsWindow:focus()
            -- Tab content is populated on selection, no explicit update call needed here
        else
            espSettingsWindow:unfocus()
        end
    end
    lastMenuToggleState = currentKeyState
end

-- Main Draw Callback for the script
local function onDraw()
    handleMenuToggle()

    
        onDrawEsp()
    
end

-- Register Callbacks
callbacks.Register("Draw", "EnemyHeadDotESP_MainDraw_Final", onDraw)
callbacks.Register("Unload", "EnemyHeadDotESP_Unload_Final", function()
    callbacks.Unregister("Draw", "EnemyHeadDotESP_MainDraw_Final")
    if espSettingsWindow then
        menu.closeAll() -- Use menu library's function to close its windows
    end
    espSettingsWindow = nil
    printc(0, 255, 0, 255, "Enemy Head Dot ESP (Final) unloaded.")
end)

-- Script Initialization
initializeMenu()
printc(0, 255, 0, 255, "Enemy Head Dot ESP (Final) loaded.")
printc(0, 200, 255, 255, "Press ", "DELETE", " to toggle ESP settings menu.")