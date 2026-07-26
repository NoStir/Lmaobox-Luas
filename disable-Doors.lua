local toggleState = false
local last_tick = 0

local doors = {
    "door_slide",
    "noentry",
    "door_grate"
}

-- Function to toggle material flag on preset door materials

local function toggleDraw(toggleState)
    materials.Enumerate(function(mat)
        for i, door in ipairs(doors) do
            if string.find(mat:GetName(), door) then
                mat:SetMaterialVarFlag(MATERIAL_VAR_WIREFRAME, toggleState) -- Alternatively, you can use MATERIAL_VAR_NO_DRAW to truely hide the material
            end
        end
    end)
end
-- Callback for keypress with tick tracking to prevent multiple triggers on one key press
callbacks.Register("CreateMove", function()
    local state, tick = input.IsButtonPressed(KEY_J) -- Replace KEY_J with your desired key
    if state and tick ~= last_tick then
        -- Toggle the state
        toggleState = not toggleState
        -- Apply the change
        toggleDraw(toggleState)
        -- Store the last tick
        last_tick = tick
    end
end)
