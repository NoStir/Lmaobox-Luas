local key = "L" -- replace * with appropriate E_ButtonCode, for example: "key = "F"

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

callbacks.Register("CreateMove", function(cmd)
    local isPressed, tick = input.IsButtonPressed(E_ButtonCode["KEY_" .. key])

    if isPressed and tick ~= last_tick then
        if not isCacheInitialized then
            -- Cache current values without changing them
            for _, target in ipairs(mTargets) do
                local currentValue = gui.GetValue(target)
                mTargetCache[target] = currentValue ~= "none" and currentValue or nil
            end

            for _, target in ipairs(bTargets) do
                bTargetCache[target] = gui.GetValue(target)
            end

            isCacheInitialized = true -- Cache has been initialized, we can toggle from now on

            -- Now immediately perform the first toggle
            for target, cachedValue in pairs(bTargetCache) do
                local currentValue = gui.GetValue(target)
                gui.SetValue(target, currentValue == 0 and cachedValue or 0)
            end

            for target, cachedValue in pairs(mTargetCache) do
                local currentValue = gui.GetValue(target)
                gui.SetValue(target, currentValue == "none" and (cachedValue or "none") or "none")
            end
        else
            -- Toggle using the cached values
            for target, cachedValue in pairs(bTargetCache) do
                local currentValue = gui.GetValue(target)
                gui.SetValue(target, currentValue == 0 and cachedValue or 0)
            end

            for target, cachedValue in pairs(mTargetCache) do
                local currentValue = gui.GetValue(target)
                gui.SetValue(target, currentValue == "none" and (cachedValue or "none") or "none")
            end
        end

        last_tick = tick
    end
end)
