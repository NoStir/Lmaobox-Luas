-- Enemy Head Dot ESP with optional tabbed menu configuration

local has_menu, menu_result = pcall(require, "menu")
local menu = has_menu and menu_result or nil

local espSettings = {
    dotColor = { r = 255, g = 0, b = 0, a = 255 },

    basePixelSize = 6,

    unzoomed_distanceMin = 200,
    unzoomed_scaleAtMinDistance = 2.0,
    unzoomed_distanceMax = 2500,
    unzoomed_scaleAtMaxDistance = 0.4,
    unzoomed_absoluteMinPixelSize = 2,
    unzoomed_absoluteMaxPixelSize = 25,

    zoomed_DotScaleFactor = 0.5,
    zoomed_absoluteMinPixelSize = 1,
    zoomed_absoluteMaxPixelSize = 15,

    menuToggleKey = E_ButtonCode.KEY_DELETE,
    activeSettingsTab = "General",
}

local HEAD_POSITION_UPDATE_INTERVAL = 0.03

local espSettingsWindow
local cachedHeadDots = {}
local lastHeadUpdateTime = 0
local lastMenuToggleState = false

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end

    if value > maxValue then
        return maxValue
    end

    return value
end

local function sanitizeSettings()
    espSettings.basePixelSize = math.max(1, math.floor(espSettings.basePixelSize))

    espSettings.unzoomed_distanceMin = math.max(0, math.floor(espSettings.unzoomed_distanceMin))
    espSettings.unzoomed_distanceMax = math.max(espSettings.unzoomed_distanceMin, math.floor(espSettings.unzoomed_distanceMax))

    espSettings.unzoomed_absoluteMinPixelSize = math.max(1, math.floor(espSettings.unzoomed_absoluteMinPixelSize))
    espSettings.unzoomed_absoluteMaxPixelSize = math.max(
        espSettings.unzoomed_absoluteMinPixelSize,
        math.floor(espSettings.unzoomed_absoluteMaxPixelSize)
    )

    espSettings.zoomed_absoluteMinPixelSize = math.max(1, math.floor(espSettings.zoomed_absoluteMinPixelSize))
    espSettings.zoomed_absoluteMaxPixelSize = math.max(
        espSettings.zoomed_absoluteMinPixelSize,
        math.floor(espSettings.zoomed_absoluteMaxPixelSize)
    )
end

local function drawDot(x, y, currentDotSize, r, g, b, a)
    if currentDotSize < 1 then
        return
    end

    draw.Color(r, g, b, a)

    local halfSize = currentDotSize / 2
    local x1 = math.floor(x - halfSize)
    local y1 = math.floor(y - halfSize)
    local x2 = math.floor(x + halfSize)
    local y2 = math.floor(y + halfSize)

    if x2 <= x1 then
        x2 = x1 + 1
    end

    if y2 <= y1 then
        y2 = y1 + 1
    end

    draw.FilledRect(x1, y1, x2, y2)
end

local function calculateDotSize(distance, isZoomed)
    sanitizeSettings()

    local calculatedPixelSize
    if isZoomed then
        calculatedPixelSize = espSettings.basePixelSize * espSettings.zoomed_DotScaleFactor
        calculatedPixelSize = clamp(
            calculatedPixelSize,
            espSettings.zoomed_absoluteMinPixelSize,
            espSettings.zoomed_absoluteMaxPixelSize
        )
    else
        local scaleFactor
        if distance <= espSettings.unzoomed_distanceMin then
            scaleFactor = espSettings.unzoomed_scaleAtMinDistance
        elseif distance >= espSettings.unzoomed_distanceMax then
            scaleFactor = espSettings.unzoomed_scaleAtMaxDistance
        else
            local range = espSettings.unzoomed_distanceMax - espSettings.unzoomed_distanceMin
            local progress = range > 0 and (distance - espSettings.unzoomed_distanceMin) / range or 0
            scaleFactor = espSettings.unzoomed_scaleAtMinDistance - (
                progress * (espSettings.unzoomed_scaleAtMinDistance - espSettings.unzoomed_scaleAtMaxDistance)
            )
        end

        calculatedPixelSize = espSettings.basePixelSize * scaleFactor
        calculatedPixelSize = clamp(
            calculatedPixelSize,
            espSettings.unzoomed_absoluteMinPixelSize,
            espSettings.unzoomed_absoluteMaxPixelSize
        )
    end

    return math.max(1, math.floor(calculatedPixelSize + 0.5))
end

local function rebuildHeadDotCache()
    local localPlayer = entities.GetLocalPlayer()
    if not localPlayer or not localPlayer:IsValid() or not localPlayer:IsAlive() then
        cachedHeadDots = {}
        return
    end

    local localPlayerTeam = localPlayer:GetTeamNumber()
    if localPlayerTeam == E_TeamNumber.TEAM_UNASSIGNED or localPlayerTeam == E_TeamNumber.TEAM_SPECTATOR then
        cachedHeadDots = {}
        return
    end

    local localPlayerOrigin = localPlayer:GetAbsOrigin()
    if not localPlayerOrigin then
        cachedHeadDots = {}
        return
    end

    local localPlayerIndex = localPlayer:GetIndex()
    local isZoomed = localPlayer:InCond(TFCond_Zoomed)
    local newDots = {}

    for _, player in ipairs(entities.FindByClass("CTFPlayer")) do
        if player
            and player:IsValid()
            and player:GetIndex() ~= localPlayerIndex
            and player:IsAlive()
            and not player:IsDormant()
        then
            local playerTeam = player:GetTeamNumber()
            if playerTeam ~= localPlayerTeam
                and playerTeam ~= E_TeamNumber.TEAM_UNASSIGNED
                and playerTeam ~= E_TeamNumber.TEAM_SPECTATOR
            then
                local playerOrigin = player:GetAbsOrigin()
                local hitboxes = player:GetHitboxes()
                local headHitboxData = hitboxes and hitboxes[E_Hitbox.HITBOX_HEAD + 1] or nil

                if playerOrigin and headHitboxData then
                    local mins, maxs = headHitboxData[1], headHitboxData[2]
                    if mins and maxs then
                        newDots[#newDots + 1] = {
                            worldPos = Vector3(
                                (mins.x + maxs.x) / 2,
                                (mins.y + maxs.y) / 2,
                                (mins.z + maxs.z) / 2
                            ),
                            size = calculateDotSize((localPlayerOrigin - playerOrigin):Length(), isZoomed),
                        }
                    end
                end
            end
        end
    end

    cachedHeadDots = newDots
end

local function drawCachedHeadDots()
    local color = espSettings.dotColor
    for _, dot in ipairs(cachedHeadDots) do
        local screenPos = client.WorldToScreen(dot.worldPos)
        if screenPos then
            drawDot(screenPos[1], screenPos[2], dot.size, color.r, color.g, color.b, color.a)
        end
    end
end

local function createFloatSlider(window, label, settingTable, settingKey, minVal, maxVal, step)
    step = step or 0.1
    window:createSlider(label, settingTable[settingKey], minVal, maxVal, function(value)
        local roundedValue = math.floor(value / step + 0.5) * step
        settingTable[settingKey] = tonumber(string.format("%.2f", roundedValue))
        sanitizeSettings()
    end)
end

local function createIntSlider(window, label, settingTable, settingKey, minVal, maxVal)
    window:createSlider(label, settingTable[settingKey], minVal, maxVal, function(value)
        settingTable[settingKey] = math.floor(value + 0.5)
        sanitizeSettings()
    end)
end

local function populateGeneralTab()
    espSettingsWindow:clearWidgets()
    createIntSlider(espSettingsWindow, "Base Pixel Size", espSettings, "basePixelSize", 1, 30)
    espSettingsWindow.height = espSettingsWindow:calculateHeight()
end

local function populateUnzoomedTab()
    espSettingsWindow:clearWidgets()
    createIntSlider(espSettingsWindow, "Min Distance", espSettings, "unzoomed_distanceMin", 50, 5000)
    createFloatSlider(espSettingsWindow, "Scale @ Min Dist", espSettings, "unzoomed_scaleAtMinDistance", 0.1, 5.0)
    createIntSlider(espSettingsWindow, "Max Distance", espSettings, "unzoomed_distanceMax", 50, 5000)
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

local function initializeMenu()
    if not menu or espSettingsWindow then
        return
    end

    espSettingsWindow = menu.createWindow("Head Dot ESP Settings", {
        x = 150,
        y = 100,
        width = 420,
        desiredItems = 8,
        onClose = function()
            printc(0, 255, 0, 255, "ESP Settings window closed.")
        end,
    })

    local tabPanel = espSettingsWindow:renderTabPanel()
    tabPanel:addTab("General", populateGeneralTab)
    tabPanel:addTab("Unzoomed", populateUnzoomedTab)
    tabPanel:addTab("Zoomed", populateZoomedTab)
    tabPanel:addTab("Color", populateColorTab)

    local originalSelectTab = tabPanel.selectTab
    tabPanel.selectTab = function(self, name)
        if menu._mouseState and menu._mouseState.activeDropdown then
            menu._mouseState.activeDropdown = nil
        end

        if originalSelectTab then
            originalSelectTab(self, name)
        end

        espSettings.activeSettingsTab = name
    end

    if espSettings.activeSettingsTab and tabPanel.tabs[espSettings.activeSettingsTab] then
        tabPanel:selectTab(espSettings.activeSettingsTab)
    elseif #tabPanel.tabOrder > 0 then
        tabPanel:selectTab(tabPanel.tabOrder[1])
    end

    espSettingsWindow:unfocus()
end

local function handleMenuToggle()
    if not menu then
        return
    end

    local currentKeyState = input.IsButtonDown(espSettings.menuToggleKey)
    if currentKeyState and not lastMenuToggleState then
        if not espSettingsWindow then
            initializeMenu()
        end

        if espSettingsWindow and not espSettingsWindow.isOpen then
            espSettingsWindow:focus()
        elseif espSettingsWindow then
            espSettingsWindow:unfocus()
        end
    end

    lastMenuToggleState = currentKeyState
end

local function onDraw()
    handleMenuToggle()

    if engine.Con_IsVisible() or engine.IsGameUIVisible() then
        return
    end

    local currentTime = globals.RealTime()
    if currentTime >= lastHeadUpdateTime + HEAD_POSITION_UPDATE_INTERVAL then
        rebuildHeadDotCache()
        lastHeadUpdateTime = currentTime
    end

    drawCachedHeadDots()
end

sanitizeSettings()
initializeMenu()

callbacks.Register("Draw", "EnemyHeadDotESP_MainDraw_Final", onDraw)
callbacks.Register("Unload", "EnemyHeadDotESP_Unload_Final", function()
    callbacks.Unregister("Draw", "EnemyHeadDotESP_MainDraw_Final")
    if menu and espSettingsWindow and menu.closeAll then
        menu.closeAll()
    end
    espSettingsWindow = nil
    printc(0, 255, 0, 255, "Enemy Head Dot ESP unloaded.")
end)

printc(0, 255, 0, 255, "Enemy Head Dot ESP loaded.")
if menu then
    printc(0, 200, 255, 255, "Press ", "DELETE", " to toggle ESP settings menu.")
else
    printc(255, 165, 0, 255, "menu.lua not found. Head Dot ESP settings window disabled.")
end
