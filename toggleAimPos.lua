local toggleKey = (KEY_LSHIFT)
local toggled = false
local aimPos = nil

local function toggleAimPos()
    if not entities.GetLocalPlayer():IsValid() then return end
    aimPos = gui.GetValue("Aim Position")

    if input.IsButtonPressed(toggleKey) and toggled == false then
        if aimPos == "head" then
            gui.SetValue("Aim Position", "body")
        elseif aimPos == "body" then
            gui.SetValue("Aim Position", "hit scan")
        elseif aimPos == "hit scan" then
            gui.SetValue("Aim Position", "head")
        end
        toggled = true
    end

    if input.IsButtonReleased(toggleKey) then
        toggled = false
    end
end

callbacks.Register("Draw", "toggleAimPos", toggleAimPos)