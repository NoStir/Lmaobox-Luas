local menu = {
    -- Menu Constants
    SCROLL_DELAY = 0.1,
    CHECK_INTERVAL = 5,

    -- Input Constants
    BACKSPACE_DELAY = 0.5,
    BACKSPACE_REPEAT_RATE = 0.03,
    ARROW_KEY_DELAY = 0.5,
    ARROW_REPEAT_RATE = 0.03,
    CTRL_ARROW_DELAY = 0.1,

    -- Global mouse state
    _mouseState = {
        lastState = false,
        released = false,
        isDragging = false,
        dragOffsetX = 0,
        dragOffsetY = 0,
        isDraggingScrollbar = false,
        wasScrollbarDragging = false,
        hasSeenMousePress = false,
        lastScrollTime = 0,
        activeDropdown = nil,
        eventHandled = false
    },

    -- Global menu state
    _state = {
        windows = {},
        activeWindow = nil,
        menuFont = nil,
        lastFontSetting = nil,
        activeWidget = nil,
        windowStack = {},
        lastInteractedWidget = nil,
        CurrentID = 1
    },

    -- Input state
    _inputState = {
        inputBuffer = "",
        cursorPosition = 0,
        selectionStart = nil,
        selectionEnd = nil,
        inputHistory = {},
        inputHistoryIndex = 0,
        clipboard = "",
        lastKeyState = {},
        capsLockEnabled = false,
        lastShiftState = false,
        lastArrowTime = 0,
        lastBackspaceTime = 0,
        viewLockState = {
            isLocked = false,
            pitch = 0,
            yaw = 0,
            roll = 0,
            renderPitch = 0,
            renderYaw = 0,
            renderRoll = 0
        }
    },

    -- Key repeat control
    _keyRepeatState = {
        INITIAL_DELAY = 0.5,
        REPEAT_RATE = 0.05,
        pressStartTimes = {},
        lastRepeatTimes = {},
        isRepeating = {},
        enabled = true,
        LastPressedKey = nil,
        frameInitialized = false,
        lastFrameKeys = {},
        keyPressCount = {}
    },

    -- Theme colors
    colors = {
        windowBg = {20, 20, 20, 255},
        titleBarBg = {30, 30, 30, 255},
        titleText = {255, 255, 255, 255},
        border = {50, 50, 50, 255},
        itemBg = {25, 25, 25, 255},
        itemHoverBg = {40, 40, 40, 255},
        itemActiveBg = {60, 60, 60, 255},
        close = {255, 255, 255, 255},
        closeHover = {255, 100, 100, 255},
        scrollbarBg = {40, 40, 40, 255},
        scrollbarHoverBg = {50, 50, 50, 255},
        scrollbarThumb = {80, 80, 80, 255},
        scrollbarThumbHover = {100, 100, 100, 255},
        scrollbarThumbActive = {120, 120, 120, 255},
        checkmark = {255, 255, 255, 255},
        sliderBar = {55, 100, 215, 255},
        progressBar = {55, 100, 215, 255},
        dropdownBg = {30, 30, 30, 255},
        dropdownBorder = {50, 50, 50, 255},
        dropdownText = {255, 255, 255, 255},
        tabBg = {25, 25, 25, 255},
        tabHoverBg = {40, 40, 40, 255},
        tabActiveBg = {60, 60, 60, 255},
        tabText = {255, 255, 255, 255},
        tabBar = {40, 40, 40, 255},
        tab = {50, 50, 50, 255},
        tabHover = {60, 60, 60, 255},
        tabActive = {70, 70, 70, 255},
        inputText = {255, 255, 255, 255},
        inputPlaceholder = {128, 128, 128, 255},
        inputSelection = {100, 149, 237, 100}
    },

    -- Input mapping
    _inputMap = {
        -- Numbers
        [KEY_0] = {normal = "0", shift = ")"},
        [KEY_1] = {normal = "1", shift = "!"},
        [KEY_2] = {normal = "2", shift = "@"},
        [KEY_3] = {normal = "3", shift = "#"},
        [KEY_4] = {normal = "4", shift = "$"},
        [KEY_5] = {normal = "5", shift = "%"},
        [KEY_6] = {normal = "6", shift = "^"},
        [KEY_7] = {normal = "7", shift = "&"},
        [KEY_8] = {normal = "8", shift = "*"},
        [KEY_9] = {normal = "9", shift = "("},
        
        -- Letters
        [KEY_A] = {normal = "a", shift = "A"},
        [KEY_B] = {normal = "b", shift = "B"},
        [KEY_C] = {normal = "c", shift = "C"},
        [KEY_D] = {normal = "d", shift = "D"},
        [KEY_E] = {normal = "e", shift = "E"},
        [KEY_F] = {normal = "f", shift = "F"},
        [KEY_G] = {normal = "g", shift = "G"},
        [KEY_H] = {normal = "h", shift = "H"},
        [KEY_I] = {normal = "i", shift = "I"},
        [KEY_J] = {normal = "j", shift = "J"},
        [KEY_K] = {normal = "k", shift = "K"},
        [KEY_L] = {normal = "l", shift = "L"},
        [KEY_M] = {normal = "m", shift = "M"},
        [KEY_N] = {normal = "n", shift = "N"},
        [KEY_O] = {normal = "o", shift = "O"},
        [KEY_P] = {normal = "p", shift = "P"},
        [KEY_Q] = {normal = "q", shift = "Q"},
        [KEY_R] = {normal = "r", shift = "R"},
        [KEY_S] = {normal = "s", shift = "S"},
        [KEY_T] = {normal = "t", shift = "T"},
        [KEY_U] = {normal = "u", shift = "U"},
        [KEY_V] = {normal = "v", shift = "V"},
        [KEY_W] = {normal = "w", shift = "W"},
        [KEY_X] = {normal = "x", shift = "X"},
        [KEY_Y] = {normal = "y", shift = "Y"},
        [KEY_Z] = {normal = "z", shift = "Z"},
        
        -- Special characters
        [KEY_SPACE] = {normal = " ", shift = " "},
        [KEY_MINUS] = {normal = "-", shift = "_"},
        [KEY_EQUAL] = {normal = "=", shift = "+"},
        [KEY_LBRACKET] = {normal = "[", shift = "{"},
        [KEY_RBRACKET] = {normal = "]", shift = "}"},
        [KEY_BACKSLASH] = {normal = "\\", shift = "|"},
        [KEY_SEMICOLON] = {normal = ";", shift = ":"},
        [KEY_APOSTROPHE] = {normal = "'", shift = "\""},
        [KEY_COMMA] = {normal = ",", shift = "<"},
        [KEY_PERIOD] = {normal = ".", shift = ">"},
        [KEY_SLASH] = {normal = "/", shift = "?"},
        [KEY_BACKQUOTE] = {normal = "`", shift = "~"}
    }
}

-- Helper Functions
local function getMousePos()
    local mousePos = input.GetMousePos()
    return math.floor(mousePos[1]), math.floor(mousePos[2])
end

local function setColor(color)
    if type(color) == "table" and #color >= 4 then
        draw.Color(color[1], color[2], color[3], color[4])
    end
end

local function isInBounds(pX, pY, pX2, pY2)
    local mX, mY = getMousePos()
    return (mX >= pX and mX <= pX2 and mY >= pY and mY <= pY2)
end

-- Input Helper Functions
function menu.isWordBoundary(char)
    return char == " " or char == "\t" or char == "\n" or char == nil or
           char:match("[%p%c]")
end

function menu.getNextCharLength(text, pos)
    if pos > #text then return 0 end
    local byte = text:byte(pos)
    if byte >= 240 then return 4
    elseif byte >= 224 then return 3
    elseif byte >= 192 then return 2
    else return 1 end
end

function menu.getPrevCharLength(text, pos)
    if pos <= 1 then return 0 end
    local byte = text:byte(pos - 1)
    if byte >= 128 and byte < 192 then
        if pos >= 4 and text:byte(pos - 4) >= 240 then return 4
        elseif pos >= 3 and text:byte(pos - 3) >= 224 then return 3
        elseif pos >= 2 and text:byte(pos - 2) >= 192 then return 2
        end
    end
    return 1
end

-- Add this function to handle character case based on Caps Lock and Shift
function menu.getCharacterCase(chars, shiftPressed)
    if chars.normal:match("%a") then
        local useUpperCase = (menu._inputState.capsLockEnabled and not shiftPressed) or 
                           (not menu._inputState.capsLockEnabled and shiftPressed)
        return useUpperCase and chars.shift or chars.normal
    else
        return shiftPressed and chars.shift or chars.normal
    end
end

-- Add these new clipboard functions
function menu.handleSelectAll(preservePrefix)
    if preservePrefix then
        menu._inputState.selectionStart = 1
        menu._inputState.selectionEnd = #menu._inputState.inputBuffer
        menu._inputState.cursorPosition = menu._inputState.selectionEnd
    else
        menu._inputState.selectionStart = 0
        menu._inputState.selectionEnd = #menu._inputState.inputBuffer
        menu._inputState.cursorPosition = menu._inputState.selectionEnd
    end
end

function menu.handleCopy()
    if menu._inputState.selectionStart and menu._inputState.selectionEnd then
        local start = math.min(menu._inputState.selectionStart, menu._inputState.selectionEnd)
        local finish = math.max(menu._inputState.selectionStart, menu._inputState.selectionEnd)
        menu._inputState.clipboard = menu._inputState.inputBuffer:sub(start + 1, finish)
    end
end

function menu.handleCut(preservePrefix)
    if menu._inputState.selectionStart and menu._inputState.selectionEnd then
        local start = math.min(menu._inputState.selectionStart, menu._inputState.selectionEnd)
        local finish = math.max(menu._inputState.selectionStart, menu._inputState.selectionEnd)
        
        -- Don't cut prefix if preservePrefix is true
        if preservePrefix and start == 0 then
            start = 1
        end
        
        -- Store cut text in clipboard
        menu._inputState.clipboard = menu._inputState.inputBuffer:sub(start + 1, finish)
        
        -- Remove selected text
        menu._inputState.inputBuffer = menu._inputState.inputBuffer:sub(1, start) ..
                                     menu._inputState.inputBuffer:sub(finish + 1)
        menu._inputState.cursorPosition = start
        menu._inputState.selectionStart = nil
        menu._inputState.selectionEnd = nil
        
        return true  -- Return true to indicate change
    end
    return false
end

function menu.handlePaste(maxLength, preservePrefix)
    if menu._inputState.clipboard and menu._inputState.clipboard ~= "" then
        if menu._inputState.selectionStart and menu._inputState.selectionEnd then
            local start = math.min(menu._inputState.selectionStart, menu._inputState.selectionEnd)
            local finish = math.max(menu._inputState.selectionStart, menu._inputState.selectionEnd)
            
            if preservePrefix and start == 0 then
                start = 1
            end
            
            local before = menu._inputState.inputBuffer:sub(1, start)
            local after = menu._inputState.inputBuffer:sub(finish + 1)
            
            if #before + #menu._inputState.clipboard + #after <= maxLength then
                menu._inputState.inputBuffer = before .. menu._inputState.clipboard .. after
                menu._inputState.cursorPosition = start + #menu._inputState.clipboard
                menu._inputState.selectionStart = nil
                menu._inputState.selectionEnd = nil
                return true  -- Return true to indicate change
            end
        else
            local before = menu._inputState.inputBuffer:sub(1, menu._inputState.cursorPosition)
            local after = menu._inputState.inputBuffer:sub(menu._inputState.cursorPosition + 1)
            
            if #before + #menu._inputState.clipboard + #after <= maxLength then
                menu._inputState.inputBuffer = before .. menu._inputState.clipboard .. after
                menu._inputState.cursorPosition = menu._inputState.cursorPosition + #menu._inputState.clipboard
                return true  -- Return true to indicate change
            end
        end
    end
    return false
end

local function truncateText(text, maxWidth, hasScrollbar, isHovered, extraText)
    local padding = 20
    local scrollbarWidth = hasScrollbar and 16 or 0
    local actualMaxWidth = math.floor(maxWidth - padding - scrollbarWidth)
    
    if isHovered and extraText then
        local extraWidth = draw.GetTextSize(extraText)
        actualMaxWidth = math.floor(actualMaxWidth - extraWidth - 5)
    end
    
    local fullWidth = draw.GetTextSize(text)
    if fullWidth <= actualMaxWidth then
        return text
    end
    
    -- Binary search for the right length
    local left, right = 1, #text
    while left <= right do
        local mid = math.floor((left + right) / 2)
        local truncated = text:sub(1, mid) .. "..."
        local width = draw.GetTextSize(truncated)
        
        if width == actualMaxWidth then
            return truncated
        elseif width < actualMaxWidth then
            left = mid + 1
        else
            right = mid - 1
        end
    end
    
    return text:sub(1, right) .. "..."
end

-- Widget class
local Widget = {}
Widget.__index = Widget

function Widget.new(type, config, window)
    local self = setmetatable({}, Widget)
    self.type = type
    self.config = config or {}
    self.window = window
    self.state = {
        isHovered = false,
        isActive = false,
        lastInteraction = 0,
        value = config.initialValue,
        checked = config.initialState,
        selected = config.initialSelected or 1,
        isOpen = false,
        scrollOffset = 0,
        -- Text input specific state
        inputBuffer = config.value or "",
        cursorPosition = #(config.value or ""),
        selectionStart = nil,
        selectionEnd = nil,
        -- Undo/redo specific state for each text input
        undoState = {
            undoStack = {},
            redoStack = {},
            maxSize = 100,
            lastSavedState = nil,
            lastUndoTime = 0,
            lastRedoTime = 0,
            lastRepeatTime = 0
        }
    }
    return self
end

-- TabPanel class
local TabPanel = {}
TabPanel.__index = TabPanel

function TabPanel.new(config, window)
    local self = setmetatable({}, TabPanel)
    self.type = 'tabpanel'
    self.config = config or {}
    self.window = window
    self.tabs = {}
    self.tabOrder = {}
    self.currentTab = nil
    self.itemHeight = 30  -- Fixed tab height
    self.state = {
        isHovered = false,
        isActive = false
    }
    self.initialized = false  -- Add this flag
    -- Set config defaults
    self.config.height = self.config.height or self.itemHeight
    return self
end

function TabPanel:addTab(name, contentFunc)
    if type(name) == "string" then
        self.tabs[name] = contentFunc
        table.insert(self.tabOrder, name)
        if self.currentTab == nil then
            self.currentTab = name
            -- Call the content function for the first tab
            if contentFunc then
                contentFunc()
            end
        end
    end
end

function TabPanel:selectTab(name)
    if self.tabs[name] and name ~= self.currentTab then
        self.currentTab = name
        -- Clear any active dropdown
        menu._mouseState.activeDropdown = nil
        -- Clear existing widgets
        self.window.widgets = {}
        -- Call content function for new tab
        if self.tabs[name] then
            self.tabs[name]()
        end
    end
end

-- Input Management Functions
function menu.createStateSnapshot()
    return {
        buffer = menu._inputState.inputBuffer,
        cursorPos = menu._inputState.cursorPosition,
        selectionStart = menu._inputState.selectionStart,
        selectionEnd = menu._inputState.selectionEnd,
        timestamp = globals.RealTime()
    }
end

-- Save state function for undo/redo
function menu.saveState()
    local widget = menu._state.activeWidget
    if not widget then return end
    
    local currentState = menu.createStateSnapshot()
    
    -- Save initial empty state if this is the first change
    if #widget.state.undoState.undoStack == 0 then
        local initialState = {
            buffer = "",
            cursorPos = 0,
            selectionStart = nil,
            selectionEnd = nil,
            timestamp = globals.RealTime()
        }
        table.insert(widget.state.undoState.undoStack, initialState)
    end
    
    -- Don't save if nothing has changed from last saved state
    if widget.state.undoState.lastSavedState and 
       widget.state.undoState.lastSavedState.buffer == currentState.buffer and
       widget.state.undoState.lastSavedState.cursorPos == currentState.cursorPos then
        return
    end
    
    -- Save current state
    table.insert(widget.state.undoState.undoStack, currentState)
    widget.state.undoState.lastSavedState = currentState
    widget.state.undoState.redoStack = {}  -- Clear redo stack on new change
    
    -- Maintain max stack size
    while #widget.state.undoState.undoStack > widget.state.undoState.maxSize do
        table.remove(widget.state.undoState.undoStack, 1)
    end
end

function menu.applyState(state)
    menu._inputState.inputBuffer = state.buffer
    menu._inputState.cursorPosition = state.cursorPos
    menu._inputState.selectionStart = state.selectionStart
    menu._inputState.selectionEnd = state.selectionEnd
end

-- Caps Lock and case conversion helpers
menu._inputState.capsLockEnabled = false
menu._inputState.lastKeyStates = {}  -- Track all key states
menu._inputState.keyRepeatStates = {}  -- Track key repeat states for clipboard operations

-- Improved case conversion function
function menu.getCharacterCase(chars, shiftPressed)
    if chars.normal:match("%a") then  -- Only apply to letters
        local useUpperCase = (menu._inputState.capsLockEnabled and not shiftPressed) or 
                           (not menu._inputState.capsLockEnabled and shiftPressed)
        return useUpperCase and chars.shift or chars.normal
    end
    -- For non-letters, just use shift state directly
    return shiftPressed and chars.shift or chars.normal
end

function TabPanel:render(menu, x, y)
    local tabCount = #self.tabOrder
    if tabCount == 0 then return self.itemHeight end

    local tabWidth = math.floor(self.window.width / tabCount)
    local remainingPixels = self.window.width - (tabWidth * tabCount)
    local currentX = 0
    
    -- Draw tab bar background
    setColor(menu.colors.titleBarBg)
    draw.FilledRect(x, y, x + self.window.width, y + self.itemHeight)
    
    -- Draw tabs
    for i, name in ipairs(self.tabOrder) do
        local tabX = math.floor(x + currentX)
        local currentTabWidth = i == tabCount and (tabWidth + remainingPixels) or tabWidth
        local tabRight = math.floor(tabX + currentTabWidth)
        local tabBottom = math.floor(y + self.itemHeight)
        
        -- Check if mouse is over this tab
        local isHovered = isInBounds(tabX, y, tabRight, tabBottom)
        
        -- Set colors based on state
        if name == self.currentTab then
            setColor(menu.colors.itemActiveBg)
        elseif isHovered then
            setColor(menu.colors.itemHoverBg)
            if menu._mouseState.released then
                self:selectTab(name)
            end
        else
            setColor(menu.colors.itemBg)
        end
        
        -- Draw tab background
        draw.FilledRect(tabX, y, tabRight, tabBottom)
        
        -- Draw tab text
        setColor(menu.colors.titleText)
        local textWidth = draw.GetTextSize(name)
        draw.Text(
            math.floor(tabX + (currentTabWidth/2) - (textWidth/2)), 
            math.floor(y + (self.itemHeight/2) - 8), 
            name
        )
        
        currentX = currentX + currentTabWidth
    end
    
    return self.itemHeight
end

-- Window class
local Window = {}
Window.__index = Window

function Window.new(title, config)
    local self = setmetatable({}, Window)
    
    -- Window properties
    self.title = title or "Window"
    self.x = math.floor(tonumber(config.x) or 100)
    self.y = math.floor(tonumber(config.y) or 100)
    self.width = math.floor(tonumber(config.width) or 400)
    self.desiredItems = math.floor(tonumber(config.desiredItems) or 10)
    self.titleBarHeight = math.floor(tonumber(config.titleBarHeight) or 30)
    self.itemHeight = math.floor(tonumber(config.itemHeight) or 25)
    self.footerHeight = math.floor(tonumber(config.footerHeight) or 30)
    
    -- State
    self.isOpen = false
    self.widgets = {}
    self.scrollOffset = 0
    self.interactionState = 'none'
    self.clickStartedInWindow = false
    self.clickStartedInTitleBar = false
    self.clickStartedInScrollbar = false
    self.clickStartRegion = nil
    self.clickStartX = 0
    self.clickStartY = 0
    self.zIndex = #menu._state.windows + 1
    self.previousWindow = nil
    
    -- Content
    self.height = self:calculateHeight()
    
    -- Callbacks
    self.onClose = config.onClose
    
    table.insert(menu._state.windows, self)
    
    return self
end

function Window:focus()
    local prevActive = menu._state.activeWindow
    
    if prevActive and prevActive ~= self then
        self.previousWindow = prevActive
        prevActive.isOpen = false
    end
    
    menu._state.activeWindow = self
    self.isOpen = true
    self.zIndex = #menu._state.windows + 1
    
    -- Sort windows by z-index
    table.sort(menu._state.windows, function(a, b)
        return a.zIndex < b.zIndex
    end)
end

function Window:unfocus()
    self.isOpen = false
    menu._state.activeWindow = self.previousWindow
    
    if self.previousWindow then
        self.previousWindow.isOpen = true
        self.previousWindow = nil
    end
end

function Window:createTextInput(config)
    local widget = Widget.new('textinput', {
        text = config.text or "Input",
        placeholder = config.placeholder or "",
        value = config.value or "",
        onChange = config.onChange,
        width = math.floor(self.width - 20),
        height = self.itemHeight,
        password = config.password or false,
        maxLength = config.maxLength or 1024,
        preservePrefix = config.preservePrefix or false
    }, self)
    table.insert(self.widgets, widget)
    return widget
end

-- Widget creation methods
function Window:createButton(text, onClick)
    local widget = Widget.new('button', {
        text = text,
        onClick = onClick,
        width = 200,
        height = self.itemHeight
    }, self)  -- Pass window reference
    table.insert(self.widgets, widget)
    return widget
end


function Window:createCheckbox(text, initialState, onChange)
    local widget = Widget.new('checkbox', {
        text = text,
        onChange = onChange,
        width = 200,
        height = self.itemHeight,
        initialState = initialState
    }, self)  -- Pass window reference
    table.insert(self.widgets, widget)
    return widget
end

function Window:createSlider(text, initialValue, min, max, onChange)
    local widget = Widget.new('slider', {
        text = text,
        min = min,
        max = max,
        onChange = onChange,
        width = 200,
        height = self.itemHeight,
        initialValue = initialValue
    }, self)  -- Pass window reference
    table.insert(self.widgets, widget)
    return widget
end

function Window:createProgressBar(text, initialValue, min, max)
    local widget = Widget.new('progress', {
        text = text,
        min = min,
        max = max,
        width = 200,
        height = math.floor(self.itemHeight / 2),  -- Floor this division
        initialValue = initialValue
    }, self)  -- Pass window reference
    table.insert(self.widgets, widget)
    return widget
end

function Window:createComboBox(text, options, initialSelected, onChange)
    local widget = Widget.new('combo', {
        text = text,
        options = options,
        onChange = onChange,
        width = 200,
        height = self.itemHeight,
        initialSelected = initialSelected
    }, self)  -- Pass window reference
    table.insert(self.widgets, widget)
    return widget
end

function Window:createList(items, onItemClick)
    local widget = Widget.new('list', {
        items = items or {},
        onItemClick = onItemClick,
        width = math.floor(self.width - 20),  -- Floor this subtraction
        itemHeight = self.itemHeight,
        visibleItems = self.desiredItems
    }, self)  -- Pass window reference
    table.insert(self.widgets, widget)
    return widget
end

function Window:calculateHeight()
    local contentHeight = 0
    
    -- Add tab panel height if exists
    if self._tabPanel then
        contentHeight = contentHeight + self._tabPanel.itemHeight
    end
    
    for _, widget in ipairs(self.widgets) do
        if widget.type == 'list' then
            local minVisibleItems = 3
            local visibleItems = math.max(minVisibleItems, math.min(#widget.config.items, widget.config.visibleItems))
            contentHeight = contentHeight + (visibleItems * widget.config.itemHeight)
        else
            contentHeight = contentHeight + widget.config.height
        end
        
        if widget.type == 'combo' and widget.state.isOpen then
            contentHeight = contentHeight + (#widget.config.options * self.itemHeight)
        end
        
        contentHeight = contentHeight + 5  -- Spacing between widgets
    end
    
    return math.floor(self.titleBarHeight + contentHeight + self.footerHeight)
end

function Window:clearWidgets()
    self.widgets = {}
    self.scrollOffset = 0
    self.height = self:calculateHeight()
end

function Window:_updateMouseState()
    local mouseState = input.IsButtonDown(MOUSE_LEFT)
    
    if mouseState and not menu._mouseState.lastState then
        menu._mouseState.hasSeenPress = true
        menu._mouseState.eventHandled = false
        
        local mX, mY = getMousePos()
        
        if isInBounds(self.x, self.y, self.x + self.width, self.y + self.height) then
            self:focus()
            self.clickStartedInWindow = true
            menu._state.activeWindow = self
            
            if isInBounds(self.x, self.y, self.x + self.width, self.y + self.titleBarHeight) then
                self.clickStartedInTitleBar = true
                self.interactionState = 'dragging'
                self.clickStartRegion = 'titlebar'
                menu._mouseState.dragOffsetX = mX - self.x
                menu._mouseState.dragOffsetY = mY - self.y
            else
                self.interactionState = 'clicking'
                self.clickStartRegion = 'content'
            end
            
            -- Clear active dropdown when clicking in a different window
            if menu._mouseState.activeDropdown and 
               menu._mouseState.activeDropdown.window ~= self then
                menu._mouseState.activeDropdown.state.isOpen = false
                menu._mouseState.activeDropdown = nil
            end
        end
    end
    
    menu._mouseState.released = menu._mouseState.lastState and not mouseState
    menu._mouseState.lastState = mouseState
    
    if menu._mouseState.released then
        if menu._mouseState.isDraggingScrollbar then
            menu._mouseState.isDraggingScrollbar = false
            menu._state.activeWidget = nil
            return true
        end
        
        menu._mouseState.isDragging = false
        self.clickStartedInTitleBar = false
        self.interactionState = 'none'
        self.clickStartRegion = nil
    end
    
    return false
end

function Window:_handleCloseButton()
    local closeText = "×"
    local closeWidth = draw.GetTextSize(closeText)
    local closeX = math.floor(self.x + self.width - closeWidth - 10)
    local closeY = math.floor(self.y + 8)
    local closeButtonBounds = isInBounds(closeX - 5, closeY - 5, closeX + closeWidth + 5, closeY + 15)

    -- Replace inside Window:_handleCloseButton()
if closeButtonBounds and self.interactionState ~= 'dragging' then
    setColor(menu.colors.closeHover)
    if menu._mouseState.released and self.clickStartedInWindow and 
       (self.clickStartRegion == 'titlebar' or self.clickStartRegion == nil) then
        -- BEFORE: self:unfocus()
        self:close()  -- <— use our hard-close
        menu._mouseState.eventHandled = true
        return true
    end
else
    setColor(menu.colors.close)
end

    draw.Text(closeX, closeY, closeText)
    return false
end

function Window:renderButton(widget, x, y)
    local config = widget.config
    local isHovered = isInBounds(x, y, x + config.width, y + config.height)
    local isActive = menu._state.activeWidget == widget
    
    if isActive then
        setColor(menu.colors.itemActiveBg)
    elseif isHovered then
        setColor(menu.colors.itemHoverBg)
    else
        setColor(menu.colors.itemBg)
    end
    
    -- Ensure all coordinates are integers
    x = math.floor(x)
    y = math.floor(y)
    local x2 = math.floor(x + config.width)
    local y2 = math.floor(y + config.height)
    
    draw.FilledRect(x, y, x2, y2)
    
    setColor(menu.colors.titleText)
    local textWidth = draw.GetTextSize(config.text)
    local textX = math.floor(x + (config.width - textWidth) / 2)
    local textY = math.floor(y + (config.height - 14) / 2)
    draw.Text(textX, textY, config.text)
    
    if isHovered and menu._mouseState.released and not menu._mouseState.eventHandled then
        if config.onClick then
            config.onClick()
        end
        menu._mouseState.eventHandled = true
    end
    
    return config.height
end

function Window:renderTextInput(widget, x, y)
    local config = widget.config
    local isHovered = isInBounds(x, y, x + config.width, y + config.height)
    local isActive = menu._state.activeWidget == widget
    
    -- Initialize widget state if needed
    if not widget.state.inputBuffer then
        widget.state = {
            inputBuffer = config.value or "",
            cursorPosition = #(config.value or ""),
            selectionStart = nil,
            selectionEnd = nil,
            undoState = {
                undoStack = {},
                redoStack = {},
                maxSize = 100,
                lastSavedState = nil,
                lastUndoTime = 0,
                lastRedoTime = 0,
                lastRepeatTime = 0
            }
        }
        -- If there's an initial value, save it as the first state
        if config.value and #config.value > 0 then
            local initialState = {
                buffer = config.value,
                cursorPos = #config.value,
                selectionStart = nil,
                selectionEnd = nil,
                timestamp = globals.RealTime()
            }
            table.insert(widget.state.undoState.undoStack, initialState)
            widget.state.undoState.lastSavedState = initialState
        end
    end
    
    -- Background
    if isActive then
        setColor(menu.colors.itemActiveBg)
    elseif isHovered then
        setColor(menu.colors.itemHoverBg)
    else
        setColor(menu.colors.itemBg)
    end
    
    -- Ensure integer coordinates
    x = math.floor(x)
    y = math.floor(y)
    local width = math.floor(config.width)
    local height = math.floor(config.height)
    
    -- Draw input box
    draw.FilledRect(x, y, x + width, y + height)
    
    -- Handle focus/activation
    if isHovered and menu._mouseState.released and not menu._mouseState.eventHandled then
        -- If a different widget was active, save its state
        if menu._state.activeWidget and menu._state.activeWidget ~= widget then
            menu._state.activeWidget.state.inputBuffer = menu._inputState.inputBuffer
            menu._state.activeWidget.state.cursorPosition = menu._inputState.cursorPosition
            menu._state.activeWidget.state.selectionStart = menu._inputState.selectionStart
            menu._state.activeWidget.state.selectionEnd = menu._inputState.selectionEnd
        end
        
        menu._state.activeWidget = widget
        menu._mouseState.eventHandled = true
        
        -- Update menu input state from widget
        menu._inputState.inputBuffer = widget.state.inputBuffer
        menu._inputState.cursorPosition = widget.state.cursorPosition
        menu._inputState.selectionStart = widget.state.selectionStart
        menu._inputState.selectionEnd = widget.state.selectionEnd
    end
    
    -- Process input when active
    local displayText = widget.state.inputBuffer
    if isActive then
        local changed = false
        if menu.handleInput(config.maxLength, config.preservePrefix) then
            -- Update widget state from input state
            widget.state.inputBuffer = menu._inputState.inputBuffer
            widget.state.cursorPosition = menu._inputState.cursorPosition
            widget.state.selectionStart = menu._inputState.selectionStart
            widget.state.selectionEnd = menu._inputState.selectionEnd
            -- Use menu._inputState for display while active
            displayText = menu._inputState.inputBuffer
            changed = true
        end
        
        -- Handle losing focus
        if input.IsButtonPressed(KEY_ESCAPE) or input.IsButtonPressed(KEY_ENTER) then
            -- Save final state before losing focus
            widget.state.inputBuffer = menu._inputState.inputBuffer
            widget.state.cursorPosition = menu._inputState.cursorPosition
            widget.state.selectionStart = menu._inputState.selectionStart
            widget.state.selectionEnd = menu._inputState.selectionEnd
            
            menu._state.activeWidget = nil
            menu.resetInputState()
            if changed and config.onChange then
                config.onChange(widget.state.inputBuffer)
            end
        end
    end
    
    -- Draw label
    local labelY = math.floor(y - 16)
    setColor(menu.colors.titleText)
    draw.Text(x + 5, labelY, config.text)
    
    -- Apply password masking if needed
    if config.password then
        displayText = string.rep("*", #displayText)
    end
    
    -- Calculate text Y position
    local textY = math.floor(y + (height - 14) / 2)
    
    -- Draw placeholder or text
    if #displayText == 0 and not isActive then
        setColor(menu.colors.inputPlaceholder)
        draw.Text(x + 5, textY, config.placeholder)
    else
        setColor(menu.colors.titleText)
        draw.Text(x + 5, textY, displayText)
    end
    
    -- Draw selection and cursor when active
    if isActive then
        -- Draw selection if exists
        if menu._inputState.selectionStart and menu._inputState.selectionEnd then
            local selStart = math.min(menu._inputState.selectionStart, menu._inputState.selectionEnd)
            local selEnd = math.max(menu._inputState.selectionStart, menu._inputState.selectionEnd)
            
            local beforeSelText = displayText:sub(1, selStart)
            local selText = displayText:sub(selStart + 1, selEnd)
            
            local selStartX = math.floor(x + 5 + draw.GetTextSize(beforeSelText))
            local selWidth = draw.GetTextSize(selText)
            
            setColor(menu.colors.inputSelection)
            draw.FilledRect(
                selStartX,
                y + 2,
                selStartX + selWidth,
                y + height - 2
            )
        end
        
        -- Draw cursor (blinking)
        if globals.RealTime() % 1 < 0.5 then
            local beforeCursorText = displayText:sub(1, menu._inputState.cursorPosition)
            local cursorX = math.floor(x + 5 + draw.GetTextSize(beforeCursorText))
            
            setColor(menu.colors.titleText)
            draw.FilledRect(
                cursorX,
                y + 2,
                cursorX + 1,
                y + height - 2
            )
        end
    end
    
    return height + 20  -- Return height including spacing
end

-- Text input handling functions
function menu.resetInputState()
    menu._inputState = {
        inputBuffer = "",
        cursorPosition = 0,
        selectionStart = nil,
        selectionEnd = nil,
        inputHistory = {},
        inputHistoryIndex = 0,
        clipboard = "",
        lastKeyState = {},
        capsLockEnabled = false,
        lastShiftState = false,
        lastArrowTime = 0,
        lastBackspaceTime = 0
    }
end

function menu.initInputState()
    if not menu._inputState then
        menu.resetInputState()
    end
end

function menu.handleInput(maxLength, preservePrefix)
    maxLength = maxLength or 1024
    preservePrefix = preservePrefix or false
    local currentTime = globals.RealTime()
    local changed = false
    
    local ctrlPressed = input.IsButtonDown(KEY_LCONTROL) or input.IsButtonDown(KEY_RCONTROL)
    local shiftPressed = input.IsButtonDown(KEY_LSHIFT) or input.IsButtonDown(KEY_RSHIFT)
    
    -- Handle Caps Lock toggle
    if input.IsButtonPressed(KEY_CAPSLOCK) and not menu._inputState.lastKeyState[KEY_CAPSLOCK] then
        menu._inputState.capsLockEnabled = not menu._inputState.capsLockEnabled
        changed = true
    end
    menu._inputState.lastKeyState[KEY_CAPSLOCK] = input.IsButtonDown(KEY_CAPSLOCK)
    
    -- Track Shift state
    menu._inputState.lastShiftState = shiftPressed
    
    -- Handle clipboard operations and undo/redo when Ctrl is pressed
    if ctrlPressed then
        -- Select All (Ctrl+A)
        if input.IsButtonPressed(KEY_A) and not menu._inputState.lastKeyState[KEY_A] then
            menu._inputState.lastKeyState[KEY_A] = true
            menu.handleSelectAll(preservePrefix)
            menu.saveState()
            changed = true
        elseif not input.IsButtonDown(KEY_A) then
            menu._inputState.lastKeyState[KEY_A] = false
        end
        
        -- Copy (Ctrl+C)
        if input.IsButtonPressed(KEY_C) and not menu._inputState.lastKeyState[KEY_C] then
            menu._inputState.lastKeyState[KEY_C] = true
            menu.handleCopy()
        elseif not input.IsButtonDown(KEY_C) then
            menu._inputState.lastKeyState[KEY_C] = false
        end
        
        -- Cut (Ctrl+X)
        if input.IsButtonPressed(KEY_X) and not menu._inputState.lastKeyState[KEY_X] then
            menu._inputState.lastKeyState[KEY_X] = true
            if menu.handleCut(preservePrefix) then
                menu.saveState()
                changed = true
            end
        elseif not input.IsButtonDown(KEY_X) then
            menu._inputState.lastKeyState[KEY_X] = false
        end
        
        -- Paste (Ctrl+V)
        if input.IsButtonPressed(KEY_V) and not menu._inputState.lastKeyState[KEY_V] then
            menu._inputState.lastKeyState[KEY_V] = true
            if menu.handlePaste(maxLength, preservePrefix) then
                menu.saveState()
                changed = true
            end
        elseif not input.IsButtonDown(KEY_V) then
            menu._inputState.lastKeyState[KEY_V] = false
        end
        
        -- Undo (Ctrl+Z)
        local ctrlPressed = input.IsButtonDown(KEY_LCONTROL) or input.IsButtonDown(KEY_RCONTROL)
        if ctrlPressed and input.IsButtonDown(KEY_Z) then
            local widget = menu._state.activeWidget
            if widget then
                if not menu._inputState.lastKeyState[KEY_Z] then
                    if #widget.state.undoState.undoStack > 0 then
                        -- Save current state to redo stack
                        local currentState = menu.createStateSnapshot()
                        table.insert(widget.state.undoState.redoStack, currentState)
                        
                        -- Get and apply previous state
                        local prevState = table.remove(widget.state.undoState.undoStack)
                        menu.applyState(prevState)
                        widget.state.undoState.lastUndoTime = currentTime
                        changed = true
                    end
                else
                    -- Handle key repeat for undo
                    local timeHeld = currentTime - widget.state.undoState.lastUndoTime
                    if timeHeld >= menu.ARROW_KEY_DELAY then
                        local timeSinceLastRepeat = currentTime - (widget.state.undoState.lastRepeatTime or 0)
                        if timeSinceLastRepeat >= menu.ARROW_REPEAT_RATE then
                            if #widget.state.undoState.undoStack > 0 then
                                local currentState = menu.createStateSnapshot()
                                table.insert(widget.state.undoState.redoStack, currentState)
                                
                                local prevState = table.remove(widget.state.undoState.undoStack)
                                menu.applyState(prevState)
                                widget.state.undoState.lastRepeatTime = currentTime
                                changed = true
                            end
                        end
                    end
                end
                menu._inputState.lastKeyState[KEY_Z] = true
            end
        else
            menu._inputState.lastKeyState[KEY_Z] = false
        end
        
        -- Redo (Ctrl+Y)
        if input.IsButtonDown(KEY_Y) then
            local widget = menu._state.activeWidget
            if not widget then return changed end
            
            if not menu._inputState.lastKeyState[KEY_Y] then
                -- Initial press
                widget.state.undoState.lastRedoTime = currentTime
                widget.state.undoState.lastRepeatTime = currentTime
                
                if #widget.state.undoState.redoStack > 0 then
                    -- Save current state to undo stack
                    local currentState = menu.createStateSnapshot()
                    table.insert(widget.state.undoState.undoStack, currentState)
                    
                    -- Get and apply redo state
                    local redoState = table.remove(widget.state.undoState.redoStack)
                    menu.applyState(redoState)
                    changed = true
                end
            else
                -- Check for repeat
                local timeHeld = currentTime - widget.state.undoState.lastRedoTime
                if timeHeld >= menu.ARROW_KEY_DELAY then
                    local timeSinceLastRepeat = currentTime - widget.state.undoState.lastRepeatTime
                    if timeSinceLastRepeat >= menu.ARROW_REPEAT_RATE then
                        if #widget.state.undoState.redoStack > 0 then
                            -- Save current state to undo stack
                            local currentState = menu.createStateSnapshot()
                            table.insert(widget.state.undoState.undoStack, currentState)
                            
                            -- Get and apply redo state
                            local redoState = table.remove(widget.state.undoState.redoStack)
                            menu.applyState(redoState)
                            widget.state.undoState.lastRepeatTime = currentTime
                            changed = true
                        end
                    end
                end
            end
            menu._inputState.lastKeyState[KEY_Y] = true
        else
            menu._inputState.lastKeyState[KEY_Y] = false
        end
    end
    
    -- Handle backspace with immediate first press and key repeat
    if input.IsButtonDown(KEY_BACKSPACE) then
        if menu._inputState.selectionStart and menu._inputState.selectionEnd then
            -- Handle selection deletion
            local start = math.min(menu._inputState.selectionStart, menu._inputState.selectionEnd)
            local finish = math.max(menu._inputState.selectionStart, menu._inputState.selectionEnd)
            
            -- Prevent deleting prefix if preservePrefix is true
            if preservePrefix and start == 0 then start = 1 end
            
            menu._inputState.inputBuffer = menu._inputState.inputBuffer:sub(1, start) ..
                                       menu._inputState.inputBuffer:sub(finish + 1)
            menu._inputState.cursorPosition = start
            menu._inputState.selectionStart = nil
            menu._inputState.selectionEnd = nil
            menu.saveState()
            changed = true
        else
            -- Check if we can delete (cursor position check)
            if menu._inputState.cursorPosition > (preservePrefix and 1 or 0) then
                if not menu._inputState.lastKeyState[KEY_BACKSPACE] then
                    -- First press - delete immediately
                    menu._inputState.inputBuffer = menu._inputState.inputBuffer:sub(1, menu._inputState.cursorPosition - 1) ..
                                               menu._inputState.inputBuffer:sub(menu._inputState.cursorPosition + 1)
                    menu._inputState.cursorPosition = menu._inputState.cursorPosition - 1
                    menu._inputState.lastBackspaceTime = currentTime
                    menu._inputState.lastRepeatTime = currentTime
                    menu.saveState()
                    changed = true
                else
                    -- Key is being held - handle repeat
                    local timeSinceFirstPress = currentTime - menu._inputState.lastBackspaceTime
                    if timeSinceFirstPress >= menu.BACKSPACE_DELAY then
                        local timeSinceLastRepeat = currentTime - menu._inputState.lastRepeatTime
                        if timeSinceLastRepeat >= menu.BACKSPACE_REPEAT_RATE then
                            menu._inputState.inputBuffer = menu._inputState.inputBuffer:sub(1, menu._inputState.cursorPosition - 1) ..
                                                       menu._inputState.inputBuffer:sub(menu._inputState.cursorPosition + 1)
                            menu._inputState.cursorPosition = menu._inputState.cursorPosition - 1
                            menu._inputState.lastRepeatTime = currentTime
                            menu.saveState()
                            changed = true
                        end
                    end
                end
            end
        end
        menu._inputState.lastKeyState[KEY_BACKSPACE] = true
    else
        menu._inputState.lastKeyState[KEY_BACKSPACE] = false
        menu._inputState.lastRepeatTime = nil
    end

    -- Keep your existing Ctrl+Arrow and regular arrow navigation code here unchanged
    if ctrlPressed then
        -- For Ctrl+Arrow, only move on fresh key press, not hold
        if not menu._inputState.lastKeyState[KEY_LEFT] and input.IsButtonDown(KEY_LEFT) then
            menu._inputState.lastKeyState[KEY_LEFT] = true
            local pos = menu._inputState.cursorPosition
            local minPos = preservePrefix and 1 or 0

            -- Skip any spaces before cursor
            while pos > minPos and menu._inputState.inputBuffer:sub(pos, pos):match("%s") do
                pos = pos - 1
            end
            
            -- Skip to start of current/previous word
            while pos > minPos and not menu._inputState.inputBuffer:sub(pos, pos):match("%s") do
                pos = pos - 1
            end
            
            -- Skip any trailing spaces
            while pos > minPos and menu._inputState.inputBuffer:sub(pos, pos):match("%s") do
                pos = pos - 1
            end
            
            if shiftPressed then
                if not menu._inputState.selectionStart then
                    menu._inputState.selectionStart = menu._inputState.cursorPosition
                end
                menu._inputState.selectionEnd = pos
            else
                menu._inputState.selectionStart = nil
                menu._inputState.selectionEnd = nil
            end
            
            menu._inputState.cursorPosition = pos
            changed = true
        elseif not input.IsButtonDown(KEY_LEFT) then
            menu._inputState.lastKeyState[KEY_LEFT] = false
        end
        
        if not menu._inputState.lastKeyState[KEY_RIGHT] and input.IsButtonDown(KEY_RIGHT) then
            menu._inputState.lastKeyState[KEY_RIGHT] = true
            local pos = menu._inputState.cursorPosition
            
            -- Skip any spaces after cursor
            while pos < #menu._inputState.inputBuffer and menu._inputState.inputBuffer:sub(pos + 1, pos + 1):match("%s") do
                pos = pos + 1
            end
            
            -- Skip to end of current/next word
            while pos < #menu._inputState.inputBuffer and not menu._inputState.inputBuffer:sub(pos + 1, pos + 1):match("%s") do
                pos = pos + 1
            end
            
            if shiftPressed then
                if not menu._inputState.selectionStart then
                    menu._inputState.selectionStart = menu._inputState.cursorPosition
                end
                menu._inputState.selectionEnd = pos
            else
                menu._inputState.selectionStart = nil
                menu._inputState.selectionEnd = nil
            end
            
            menu._inputState.cursorPosition = pos
            changed = true
        elseif not input.IsButtonDown(KEY_RIGHT) then
            menu._inputState.lastKeyState[KEY_RIGHT] = false
        end
    else
        -- Keep your existing regular arrow key navigation code here unchanged
        if input.IsButtonDown(KEY_LEFT) then
            local minPos = preservePrefix and 1 or 0
            
            if not menu._inputState.lastKeyState[KEY_LEFT] then
                -- Initial press - start the timer
                menu._inputState.lastArrowTime = currentTime
                menu._inputState.lastRepeatTime = currentTime
                
                -- Move cursor immediately on first press
                if menu._inputState.cursorPosition > minPos then
                    menu._inputState.cursorPosition = menu._inputState.cursorPosition - 1
                    if shiftPressed then
                        if not menu._inputState.selectionStart then
                            menu._inputState.selectionStart = menu._inputState.cursorPosition + 1
                        end
                        menu._inputState.selectionEnd = menu._inputState.cursorPosition
                    else
                        menu._inputState.selectionStart = nil
                        menu._inputState.selectionEnd = nil
                    end
                    changed = true
                end
            else
                -- Check for repeat
                local timeHeld = currentTime - menu._inputState.lastArrowTime
                if timeHeld >= menu.ARROW_KEY_DELAY then
                    local timeSinceLastRepeat = currentTime - menu._inputState.lastRepeatTime
                    if timeSinceLastRepeat >= menu.ARROW_REPEAT_RATE then
                        -- Repeat the movement
                        if menu._inputState.cursorPosition > minPos then
                            menu._inputState.cursorPosition = menu._inputState.cursorPosition - 1
                            if shiftPressed then
                                if not menu._inputState.selectionStart then
                                    menu._inputState.selectionStart = menu._inputState.cursorPosition + 1
                                end
                                menu._inputState.selectionEnd = menu._inputState.cursorPosition
                            else
                                menu._inputState.selectionStart = nil
                                menu._inputState.selectionEnd = nil
                            end
                            menu._inputState.lastRepeatTime = currentTime
                            changed = true
                        end
                    end
                end
            end
            menu._inputState.lastKeyState[KEY_LEFT] = true
        else
            menu._inputState.lastKeyState[KEY_LEFT] = false
        end
        
        if input.IsButtonDown(KEY_RIGHT) then
            if not menu._inputState.lastKeyState[KEY_RIGHT] then
                -- Initial press - start the timer
                menu._inputState.lastArrowTime = currentTime
                menu._inputState.lastRepeatTime = currentTime
                
                -- Move cursor immediately on first press
                if menu._inputState.cursorPosition < #menu._inputState.inputBuffer then
                    menu._inputState.cursorPosition = menu._inputState.cursorPosition + 1
                    if shiftPressed then
                        if not menu._inputState.selectionStart then
                            menu._inputState.selectionStart = menu._inputState.cursorPosition - 1
                        end
                        menu._inputState.selectionEnd = menu._inputState.cursorPosition
                    else
                        menu._inputState.selectionStart = nil
                        menu._inputState.selectionEnd = nil
                    end
                    changed = true
                end
            else
                -- Check for repeat
                local timeHeld = currentTime - menu._inputState.lastArrowTime
                if timeHeld >= menu.ARROW_KEY_DELAY then
                    local timeSinceLastRepeat = currentTime - menu._inputState.lastRepeatTime
                    if timeSinceLastRepeat >= menu.ARROW_REPEAT_RATE then
                        -- Repeat the movement
                        if menu._inputState.cursorPosition < #menu._inputState.inputBuffer then
                            menu._inputState.cursorPosition = menu._inputState.cursorPosition + 1
                            if shiftPressed then
                                if not menu._inputState.selectionStart then
                                    menu._inputState.selectionStart = menu._inputState.cursorPosition - 1
                                end
                                menu._inputState.selectionEnd = menu._inputState.cursorPosition
                            else
                                menu._inputState.selectionStart = nil
                                menu._inputState.selectionEnd = nil
                            end
                            menu._inputState.lastRepeatTime = currentTime
                            changed = true
                        end
                    end
                end
            end
            menu._inputState.lastKeyState[KEY_RIGHT] = true
        else
            menu._inputState.lastKeyState[KEY_RIGHT] = false
        end
    end
    
    -- Process character input with key repeat
    for key, chars in pairs(menu._inputMap) do
        if input.IsButtonDown(key) then
            local shouldProcess = false
            
            if not menu._keyRepeatState.pressStartTimes[key] then
                menu._keyRepeatState.pressStartTimes[key] = currentTime
                menu._keyRepeatState.lastRepeatTimes[key] = currentTime
                shouldProcess = true
            else
                local timeHeld = currentTime - menu._keyRepeatState.pressStartTimes[key]
                if timeHeld >= menu._keyRepeatState.INITIAL_DELAY then
                    local timeSinceLastRepeat = currentTime - menu._keyRepeatState.lastRepeatTimes[key]
                    if timeSinceLastRepeat >= menu._keyRepeatState.REPEAT_RATE then
                        shouldProcess = true
                        menu._keyRepeatState.lastRepeatTimes[key] = currentTime
                    end
                end
            end
            
            if shouldProcess and not ctrlPressed then
                local nextChar
                if chars.normal:match("%a") then
                    local useUpperCase = (menu._inputState.capsLockEnabled and not shiftPressed) or 
                                       (not menu._inputState.capsLockEnabled and shiftPressed)
                    nextChar = useUpperCase and chars.shift or chars.normal
                else
                    nextChar = shiftPressed and chars.shift or chars.normal
                end
                
                if menu._inputState.selectionStart and menu._inputState.selectionEnd then
                    local start = math.min(menu._inputState.selectionStart, menu._inputState.selectionEnd)
                    local finish = math.max(menu._inputState.selectionStart, menu._inputState.selectionEnd)
                    
                    if preservePrefix and start == 0 then start = 1 end
                    
                    if (#menu._inputState.inputBuffer - (finish - start) + #nextChar) <= maxLength then
                        local before = menu._inputState.inputBuffer:sub(1, start)
                        local after = menu._inputState.inputBuffer:sub(finish + 1)
                        menu._inputState.inputBuffer = before .. nextChar .. after
                        menu._inputState.cursorPosition = start + #nextChar
                        menu._inputState.selectionStart = nil
                        menu._inputState.selectionEnd = nil
                        menu.saveState()
                        changed = true
                    end
                else
                    if (#menu._inputState.inputBuffer + #nextChar) <= maxLength then
                        local before = menu._inputState.inputBuffer:sub(1, menu._inputState.cursorPosition)
                        local after = menu._inputState.inputBuffer:sub(menu._inputState.cursorPosition + 1)
                        menu._inputState.inputBuffer = before .. nextChar .. after
                        menu._inputState.cursorPosition = menu._inputState.cursorPosition + #nextChar
                        menu.saveState()
                        changed = true
                    end
                end
            end
        else
            menu._keyRepeatState.pressStartTimes[key] = nil
            menu._keyRepeatState.lastRepeatTimes[key] = nil
        end
    end
    
    return changed
end

function Window:renderCheckbox(widget, x, y)
    local config = widget.config
    local boxSize = math.floor(config.height - 6)
    local isHovered = isInBounds(x, y, x + config.width, y + config.height)
    
    -- Ensure all coordinates are integers
    x = math.floor(x)
    y = math.floor(y)
    
    -- Pre-calculate all coordinates for FilledRect
    local boxEndX = math.floor(x + boxSize)
    local boxEndY = math.floor(y + boxSize)
    
    if isHovered then
        setColor(menu.colors.itemHoverBg)
    else
        setColor(menu.colors.itemBg)
    end
    
    -- Draw checkbox background
    draw.FilledRect(x, y, boxEndX, boxEndY)
    
    -- Draw checkmark if checked
    if widget.state.checked then
        setColor(menu.colors.checkmark)
        local innerX1 = math.floor(x + 3)
        local innerY1 = math.floor(y + 3)
        local innerX2 = math.floor(x + boxSize - 3)
        local innerY2 = math.floor(y + boxSize - 3)
        draw.FilledRect(innerX1, innerY1, innerX2, innerY2)
    end
    
    -- Draw text
    setColor(menu.colors.titleText)
    local textX = math.floor(x + boxSize + 6)
    local textY = math.floor(y + (config.height - 14) / 2)
    draw.Text(textX, textY, config.text)
    
    -- Handle interaction
    if isHovered and menu._mouseState.released and not menu._mouseState.eventHandled then
        widget.state.checked = not widget.state.checked
        if config.onChange then
            config.onChange(widget.state.checked)
        end
        menu._mouseState.eventHandled = true
    end
    
    return config.height
end

function Window:renderSlider(widget, x, y)
    local config = widget.config
    local isHovered = isInBounds(x, y, x + config.width, y + config.height)
    local isActive = menu._state.activeWidget == widget
    
    if isHovered or isActive then
        setColor(menu.colors.itemHoverBg)
    else
        setColor(menu.colors.itemBg)
    end
    
    x, y = math.floor(x), math.floor(y)
    draw.FilledRect(x, y, x + config.width, y + config.height)
    
    local range = config.max - config.min
    local percentage = (widget.state.value - config.min) / range
    local sliderWidth = math.floor(config.width * percentage)
    
    setColor(menu.colors.sliderBar)
    draw.FilledRect(x, y, x + sliderWidth, y + config.height)
    
    setColor(menu.colors.titleText)
    local text = string.format("%s: %.1f", config.text, widget.state.value)
    local textWidth = draw.GetTextSize(text)
    local textX = math.floor(x + (config.width - textWidth) / 2)
    local textY = math.floor(y + (config.height - 14) / 2)
    draw.Text(textX, textY, text)
    
    if isHovered and input.IsButtonDown(MOUSE_LEFT) and not menu._mouseState.eventHandled then
        menu._state.activeWidget = widget
        local mouseX = getMousePos()
        local newPercentage = math.max(0, math.min(1, (mouseX - x) / config.width))
        local newValue = config.min + (range * newPercentage)
        widget.state.value = math.floor(newValue * 10) / 10  -- Round to 1 decimal place
        if config.onChange then
            config.onChange(widget.state.value)
        end
        menu._mouseState.eventHandled = true
    elseif not input.IsButtonDown(MOUSE_LEFT) and menu._state.activeWidget == widget then
        menu._state.activeWidget = nil
    end
    
    return config.height
end

function Window:renderProgressBar(widget, x, y)
    local config = widget.config
    
    x, y = math.floor(x), math.floor(y)
    setColor(menu.colors.itemBg)
    draw.FilledRect(x, y, x + config.width, y + config.height)
    
    local range = config.max - config.min
    local percentage = (widget.state.value - config.min) / range
    local progressWidth = math.floor(config.width * percentage)
    
    setColor(menu.colors.progressBar)
    draw.FilledRect(x, y, x + progressWidth, y + config.height)
    
    return config.height
end

function Window:renderComboBox(widget, x, y)
    local config = widget.config
    local isHovered = isInBounds(x, y, x + config.width, y + config.height)
    local totalHeight = config.height
    
    -- Ensure all coordinates are integers
    x = math.floor(x)
    y = math.floor(y)
    local endX = math.floor(x + config.width)
    local endY = math.floor(y + config.height)
    
    if isHovered then
        setColor(menu.colors.itemHoverBg)
    else
        setColor(menu.colors.itemBg)
    end
    draw.FilledRect(x, y, endX, endY)
    
    setColor(menu.colors.titleText)
    local selectedText = string.format("%s: %s", config.text, config.options[widget.state.selected])
    local textY = math.floor(y + (config.height - 14) / 2)
    draw.Text(x + 5, textY, selectedText)
    
    -- Draw dropdown arrow
    local arrowX = math.floor(x + config.width - 15)
    local arrowY = math.floor(y + (config.height - 8) / 2)
    setColor(menu.colors.titleText)
    if widget.state.isOpen then
        draw.Line(arrowX, arrowY + 4, arrowX + 4, arrowY)
        draw.Line(arrowX + 8, arrowY + 4, arrowX + 4, arrowY)
    else
        draw.Line(arrowX, arrowY, arrowX + 4, arrowY + 4)
        draw.Line(arrowX + 8, arrowY, arrowX + 4, arrowY + 4)
    end
    
    if isHovered and menu._mouseState.released and not menu._mouseState.eventHandled then
        widget.state.isOpen = not widget.state.isOpen
        menu._mouseState.activeDropdown = widget.state.isOpen and widget or nil
        menu._mouseState.eventHandled = true
    end
    
    if widget.state.isOpen and menu._mouseState.activeDropdown == widget then
        local dropdownY = math.floor(y + config.height)
        local dropdownHeight = math.floor(#config.options * config.height)
        
        setColor(menu.colors.dropdownBg)
        draw.FilledRect(x, dropdownY, endX, math.floor(dropdownY + dropdownHeight))
        
        for i, option in ipairs(config.options) do
            local optionY = math.floor(dropdownY + (i-1) * config.height)
            local isOptionHovered = isInBounds(x, optionY, endX, math.floor(optionY + config.height))
            
            if isOptionHovered then
                setColor(menu.colors.itemHoverBg)
                draw.FilledRect(x, optionY, endX, math.floor(optionY + config.height))
                
                if menu._mouseState.released and not menu._mouseState.eventHandled then
                    widget.state.selected = i
                    widget.state.isOpen = false
                    menu._mouseState.activeDropdown = nil
                    if config.onChange then
                        config.onChange(i, option)
                    end
                    menu._mouseState.eventHandled = true
                end
            end
            
            setColor(menu.colors.dropdownText)
            local optTextY = math.floor(optionY + (config.height - 14) / 2)
            draw.Text(x + 5, optTextY, option)
        end
        
        totalHeight = totalHeight + dropdownHeight
    end
    
    return totalHeight
end

function Window:renderList(widget, x, y)
    local config = widget.config
    
    -- Ensure all coordinates are integers
    x = math.floor(x)
    y = math.floor(y)
    
    -- Calculate minimum height - ensure list takes up at least 3 item slots even when empty
    local minVisibleItems = 3  -- You can adjust this number as needed
    local visibleItems = math.max(minVisibleItems, math.min(#config.items, config.visibleItems))
    local visibleHeight = math.floor(visibleItems * config.itemHeight)
    
    local hasScrollbar = #config.items > config.visibleItems
    local width = math.floor(config.width - (hasScrollbar and 16 or 0))
    
    -- Handle scrolling with rate limiting
    if isInBounds(x, y, x + width + (hasScrollbar and 16 or 0), y + visibleHeight) then
        local currentTime = globals.RealTime()
        if currentTime - menu._mouseState.lastScrollTime >= menu.SCROLL_DELAY then
            if input.IsButtonPressed(MOUSE_WHEEL_UP) and widget.state.scrollOffset > 0 then
                widget.state.scrollOffset = widget.state.scrollOffset - 1
                menu._mouseState.lastScrollTime = currentTime
            elseif input.IsButtonPressed(MOUSE_WHEEL_DOWN) and 
                   widget.state.scrollOffset < #config.items - config.visibleItems then
                widget.state.scrollOffset = widget.state.scrollOffset + 1
                menu._mouseState.lastScrollTime = currentTime
            end
        end
    end
    
    -- Draw background for minimum height
    setColor(menu.colors.itemBg)
    draw.FilledRect(x, y, x + width + (hasScrollbar and 16 or 0), y + visibleHeight)
    
    -- Draw visible items
    for i = 1, math.min(#config.items, visibleItems) do
        local itemIndex = i + widget.state.scrollOffset
        local item = config.items[itemIndex]
        if item then
            local itemY = math.floor(y + (i-1) * config.itemHeight)
            local itemEndY = math.floor(itemY + config.itemHeight)
            
            local isHovered = isInBounds(x, itemY, x + width, itemEndY)
            
            if isHovered then
                setColor(menu.colors.itemHoverBg)
                draw.FilledRect(x, itemY, x + width, itemEndY)
            end
            
            setColor(menu.colors.titleText)
            local text = truncateText(item.text, width, hasScrollbar, isHovered, item.extraText)
            local textY = math.floor(itemY + (config.itemHeight - 14) / 2)
            draw.Text(x + 5, textY, text)
            
            if isHovered and item.extraText then
                local textWidth = draw.GetTextSize(text)
                draw.Text(x + 10 + textWidth, textY, item.extraText)
            end
            
            if isHovered and menu._mouseState.released and not menu._mouseState.eventHandled then
                if config.onItemClick then
                    config.onItemClick(itemIndex, item)
                    menu._mouseState.eventHandled = true
                end
            end
        end
    end
    
    -- Draw and handle scrollbar
    if hasScrollbar then
        local scrollbarX = math.floor(x + width)
        local scrollbarWidth = 16
        local contentHeight = #config.items * config.itemHeight
        local thumbHeight = math.max(20, math.floor((visibleHeight / contentHeight) * visibleHeight))
        local maxOffset = #config.items - config.visibleItems
        local scrollRatio = widget.state.scrollOffset / maxOffset
        local thumbY = math.floor(y + scrollRatio * (visibleHeight - thumbHeight))
        
        -- Draw scrollbar background
        setColor(menu.colors.scrollbarBg)
        draw.FilledRect(scrollbarX, y, scrollbarX + scrollbarWidth, y + visibleHeight)
        
        -- Draw thumb
        if menu._mouseState.isDraggingScrollbar and menu._state.activeWidget == widget then
            setColor(menu.colors.scrollbarThumbActive)
        elseif isInBounds(scrollbarX, thumbY, scrollbarX + scrollbarWidth, thumbY + thumbHeight) then
            setColor(menu.colors.scrollbarThumbHover)
        else
            setColor(menu.colors.scrollbarThumb)
        end
        draw.FilledRect(scrollbarX, thumbY, scrollbarX + scrollbarWidth, math.floor(thumbY + thumbHeight))
        
        -- Handle scrollbar interaction
        if input.IsButtonDown(MOUSE_LEFT) then
            local isOverScrollbar = isInBounds(scrollbarX, y, scrollbarX + scrollbarWidth, y + visibleHeight)
            local mouseY = select(2, getMousePos())
            
            if isOverScrollbar and not menu._mouseState.isDraggingScrollbar then
                menu._state.activeWidget = widget
                menu._mouseState.isDraggingScrollbar = true
                menu._mouseState.eventHandled = true
            end
            
            if menu._mouseState.isDraggingScrollbar and menu._state.activeWidget == widget then
                -- Calculate new scroll position based on mouse position
                local relativeY = math.max(0, math.min(mouseY - y, visibleHeight))
                local newScrollRatio = relativeY / visibleHeight
                widget.state.scrollOffset = math.floor(newScrollRatio * maxOffset)
                -- Clamp the scroll offset
                widget.state.scrollOffset = math.max(0, math.min(widget.state.scrollOffset, maxOffset))
            end
        elseif menu._mouseState.isDraggingScrollbar and menu._state.activeWidget == widget then
            menu._mouseState.isDraggingScrollbar = false
            menu._state.activeWidget = nil
        end
    end
    
    return visibleHeight
end

-- Add TabPanel creation method to Window
function Window:renderTabPanel()
    if not self._tabPanel then
        self._tabPanel = TabPanel.new({}, self)
    end
    return self._tabPanel
end

function Window:render()
    if not self.isOpen then return end
    
    self.height = math.floor(self:calculateHeight())
    
    local skipProcessing = self:_updateMouseState()
    if skipProcessing then return end

    if menu._mouseState.isDragging then
        if input.IsButtonDown(MOUSE_LEFT) and self.clickStartedInTitleBar then
            local mouseX, mouseY = getMousePos()
            self.x = math.floor(mouseX - menu._mouseState.dragOffsetX)
            self.y = math.floor(mouseY - menu._mouseState.dragOffsetY)
        else
            menu._mouseState.isDragging = false
            self.interactionState = 'none'
            self.clickStartedInTitleBar = false
        end
    elseif self.clickStartedInTitleBar and not menu._mouseState.isDragging and 
           input.IsButtonDown(MOUSE_LEFT) then
        local mouseX, mouseY = getMousePos()
        menu._mouseState.dragOffsetX = math.floor(mouseX - self.x)
        menu._mouseState.dragOffsetY = math.floor(mouseY - self.y)
        menu._mouseState.isDragging = true
        self.interactionState = 'dragging'
    end

    -- Draw window frame
    setColor(menu.colors.border)
    draw.OutlinedRect(
        math.floor(self.x - 1),
        math.floor(self.y - 1),
        math.floor(self.x + self.width + 1),
        math.floor(self.y + self.height + 1)
    )
    
    setColor(menu.colors.windowBg)
    draw.FilledRect(
        math.floor(self.x),
        math.floor(self.y),
        math.floor(self.x + self.width),
        math.floor(self.y + self.height)
    )
    
    -- Draw title bar
    setColor(menu.colors.titleBarBg)
    draw.FilledRect(
        math.floor(self.x),
        math.floor(self.y),
        math.floor(self.x + self.width),
        math.floor(self.y + self.titleBarHeight)
    )
    
    setColor(menu.colors.titleText)
    draw.Text(
        math.floor(self.x + 10),
        math.floor(self.y + 8),
        self.title
    )
    
    if self:_handleCloseButton() then return end
    
    local currentY = math.floor(self.y + self.titleBarHeight)
    
    -- Render tab panel if exists
    if self._tabPanel and #self._tabPanel.tabOrder > 0 then
        currentY = currentY + self._tabPanel:render(menu, self.x, currentY)
    end
    
    -- Initialize first tab if not done yet
    if self._tabPanel and not self._tabPanel.initialized and self._tabPanel.currentTab then
        self._tabPanel.initialized = true
        if self._tabPanel.tabs[self._tabPanel.currentTab] then
            self._tabPanel.tabs[self._tabPanel.currentTab]()
        end
    end
    
    -- Render widgets
    for _, widget in ipairs(self.widgets) do
        local baseX = math.floor(self.x + 10)
        if widget.type == 'button' then
            currentY = currentY + self:renderButton(widget, baseX, currentY)
        elseif widget.type == 'checkbox' then
            currentY = currentY + self:renderCheckbox(widget, baseX, currentY)
        elseif widget.type == 'slider' then
            currentY = currentY + self:renderSlider(widget, baseX, currentY)
        elseif widget.type == 'progress' then
            currentY = currentY + self:renderProgressBar(widget, baseX, currentY)
        elseif widget.type == 'combo' then
            currentY = currentY + self:renderComboBox(widget, baseX, currentY)
        elseif widget.type == 'list' then
            currentY = currentY + self:renderList(widget, baseX, currentY)
        elseif widget.type == 'textinput' then
            currentY = currentY + self:renderTextInput(widget, baseX, currentY)
        end
        currentY = math.floor(currentY + 5)
    end
end

-- Add this to the Window class
function Window:close()
    -- Fully close this window
    self.isOpen = false

    -- If the active window is this one, clear it (do NOT auto-reopen previous here)
    if menu._state.activeWindow == self then
        menu._state.activeWindow = nil
    end

    -- If an active widget belongs to this window, clear it
    if menu._state.activeWidget and menu._state.activeWidget.window == self then
        menu._state.activeWidget = nil
    end

    -- If an active dropdown belongs to this window, close & clear it
    if menu._mouseState.activeDropdown and menu._mouseState.activeDropdown.window == self then
        menu._mouseState.activeDropdown.state.isOpen = false
        menu._mouseState.activeDropdown = nil
    end

    -- Kill any dragging state that could eat mouse input
    menu._mouseState.isDragging = false
    menu._mouseState.isDraggingScrollbar = false
    self.clickStartedInWindow = false
    self.clickStartedInTitleBar = false
    self.interactionState = 'none'
    self.clickStartRegion = nil

    -- Optional: if you want to *remove* the window from the stack entirely:
    -- for i, w in ipairs(menu._state.windows) do
    --     if w == self then table.remove(menu._state.windows, i) break end
    -- end

    if self.onClose then self.onClose() end
end


-- Public API functions
function menu.createWindow(title, config)
    if type(config) ~= "table" then config = {} end
    return Window.new(title, config)
end

function menu.closeAll()
    for _, window in ipairs(menu._state.windows) do
        if window.isOpen then
            window.isOpen = false
            if window.onClose then window.onClose() end
        end
    end
    menu._state.activeWindow = nil
    menu._state.activeWidget = nil
    menu._mouseState.activeDropdown = nil
end

function menu.isAnyWindowOpen()
    for _, window in ipairs(menu._state.windows) do
        if window.isOpen then return true end
    end
    return false
end

-- Font management
local function updateFont()
    local currentFont = gui.GetValue("font")
    if currentFont ~= menu._state.lastFontSetting then
        menu._state.menuFont = draw.CreateFont(currentFont, 14, 400)
        menu._state.lastFontSetting = currentFont
    end
    draw.SetFont(menu._state.menuFont)
end

-- Handle UI Scale
local originalScaleFactor = client.GetConVar("vgui_ui_scale_factor")
if originalScaleFactor ~= 1 then
    client.SetConVar("vgui_ui_scale_factor", "1")
end

-- Main draw callback
callbacks.Register("Draw", function()
    updateFont()

    local anyWindowOpen = menu.isAnyWindowOpen()

    if anyWindowOpen then
        -- A WINDOW IS OPEN: Enable UI input, show the cursor.
        input.SetMouseInputEnabled(true) -- CORRECT: true for UI control

        -- --- Render all windows ---
        menu._mouseState.eventHandled = false
        table.sort(menu._state.windows, function(a, b) return a.zIndex < b.zIndex end)
        
        for i = 1, #menu._state.windows do
            local window = menu._state.windows[i]
            if window and window.isOpen then
                window:render()
            end
        end

    else
        -- NO WINDOWS ARE OPEN: Disable UI input, return control to the game for aiming.
        input.SetMouseInputEnabled(false) -- CORRECT: false for game control

        -- --- Safety cleanup for any lingering UI state ---
        if menu._state.activeWidget then menu._state.activeWidget = nil end
        if menu._mouseState.activeDropdown then
            menu._mouseState.activeDropdown.state.isOpen = false
            menu._mouseState.activeDropdown = nil
        end
        menu._mouseState.isDragging = false
        menu._mouseState.isDraggingScrollbar = false
    end
end)

-- Cleanup on unload
callbacks.Register("Unload", function()
    input.SetMouseInputEnabled(false)
    
    if originalScaleFactor ~= 1 then
        client.SetConVar("vgui_ui_scale_factor", tostring(originalScaleFactor))
    end
    
    menu.closeAll()
    menu._state.windows = {}
end)

return menu