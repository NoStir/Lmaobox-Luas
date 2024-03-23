-- Store known dispensers to track their count, model changes, building status, and ammo changes
local knownDispensers = {}
local dispenserModels = {
    ["models/buildables/dispenser_light.mdl"] = true,
    ["models/buildables/dispenser_lvl2_light.mdl"] = true,
    ["models/buildables/dispenser_lvl3_light.mdl"] = true,
    ["models/buildables/dispenser.mdl"] = true, -- Model for a dispenser being built
    ["models/buildables/dispenser_blueprint.mdl"] = true -- Model for a dispenser blueprint    
}
local lastCount = 0

-- Function to update dispenser count, detect model changes, alert when a dispenser is being built, and detect ammo changes
local function updateDispenserCountAndBuildingStatus()
    local highestIndex = entities.GetHighestEntityIndex()
    local currentDispensers = {}
    local currentCount = 0

    for _, dispensers in pairs do
        local dispenser = entities.GetByIndex(i)
        if dispenser and dispenser:GetClass() == "CObjectDispenser" then
            print("Dispenser found?")
            local modelName = dispenser:GetModel() and models.GetModelName(entity:GetModel()) or "Unknown Model"
            local ammo = dispenser:GetPropInt("m_iAmmoMetal") or -1 -- Get the current ammo of the dispenser
            local xx = dispenser:GetPropInt("m_hBuilder") -- Get the current m_hTouchTrigger of the dispenser
            
            -- Additional check for dispenser_blueprint model with non-zero ammo
            local isBlueprintWithAmmo = modelName == "models/buildables/dispenser_blueprint.mdl" and ammo > 0
            
            if dispenserModels[modelName] and (modelName ~= "models/buildables/dispenser_blueprint.mdl" or isBlueprintWithAmmo) then
                currentDispensers[i] = {model = modelName, ammo = ammo}
                currentCount = currentCount + 1

                if not knownDispensers[i] then
                    print("New dispenser detected with index " .. tostring(i) .. ", model " .. modelName .. ", and ammo " .. ammo .. " and m_hTouchTrigger: " .. xx)
                else
                    if knownDispensers[i].model ~= modelName then
                        print("Dispenser model change detected at index " .. tostring(i) .. ". Old model: " .. knownDispensers[i].model .. ", New model: " .. modelName)
                    end
                    if knownDispensers[i].ammo ~= ammo then
                        print("Dispenser ammo change detected at index " .. tostring(i) .. ". Old ammo: " .. knownDispensers[i].ammo .. ", New ammo: " .. ammo)
                    end
                end
            end
        end
    end

    for index, data in pairs(knownDispensers) do
        if not currentDispensers[index] then
            print("Dispenser removed. Index " .. tostring(index) .. ", Model: " .. data.model .. ", ammo: " .. data.ammo)
        end
    end

    if currentCount ~= lastCount then
        print("Current dispenser count: " .. currentCount)
        lastCount = currentCount
    end

    knownDispensers = currentDispensers
end

-- Register a callback to continuously check for dispenser updates, building status, and ammo changes
callbacks.Register("Draw", "updateDispenserCountAndBuildingStatusOnDraw", updateDispenserCountAndBuildingStatus)
