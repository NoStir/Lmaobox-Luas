local key = "L" --replace * with appropriate E_ButtonCode, for example: "key = "F"

local mTargetCache = {}
local bTargetCache = {} 
local bTargets = { "players", "buildings", "respawn timers" }
local mTargets = {
    "ammo/medkit", "dropped ammo", "MvM Money", "halloween item",
    "halloween spells", "halloween pumpkin", "power ups", "npc",
    "projectiles", "capture flag"
}

local last_tick = 0
local isCacheInitialized = false 

local function GetTargetValues(targets)
    local values = {}
    for _, target in ipairs(targets) do
        values[target] = gui.GetValue(target)
    end
    return values
end

callbacks.Register("CreateMove", function(cmd)
    local isPressed, tick = input.IsButtonPressed(E_ButtonCode["KEY_" .. key])

    if isPressed and tick ~= last_tick then
        if not isCacheInitialized then
            for _, target in ipairs(mTargets) do
                local currentValue = gui.GetValue(target)
                mTargetCache[target] = currentValue ~= "none" and currentValue or nil
            end

            for _, target in ipairs(bTargets) do
                bTargetCache[target] = gui.GetValue(target)
            end

            isCacheInitialized = true
        else
            
            for target, cachedValue in pairs(bTargetCache) do
                local currentValue = gui.GetValue(target)

                if currentValue == 0 then
                    gui.SetValue(target, cachedValue)
                else
                    gui.SetValue(target, 0)
                end
            end

            for target, cachedValue in pairs(mTargetCache) do
                local currentValue = gui.GetValue(target)
                if currentValue == "none" then
                    gui.SetValue(target, cachedValue or "none")
                else
                    gui.SetValue(target, "none")
                end
            end
        end

        last_tick = tick
    end
end)