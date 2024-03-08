local font = draw.CreateFont("Tahoma", 16, 800)
draw.SetFont(font)
draw.Color(255, 255, 255, 255)

local function OnDraw()
    local player = entities.GetLocalPlayer()
    if not player then return end -- Check if the player entity exists

    local weapon = player:GetPropEntity("m_hActiveWeapon")
    if not weapon then return end -- Check if the weapon entity exists

    local loadoutSlot = weapon:GetLoadoutSlot() + 2 -- Adjusting for indexing
    local ammoTable = player:GetPropDataTableInt("m_iAmmo")
    if not ammoTable or not ammoTable[loadoutSlot] then return end -- Check if ammo data exists

    local ammoCount = ammoTable[loadoutSlot]
    local x, y = 200, 200 -- Example position, you might want to adjust this


    
 
    -- Draw the text on screen
    draw.Text(x, y, "Current ammo count: " .. ammoCount)
end

-- Register the draw callback
callbacks.Register("Draw", "ShowAmmoOnScreen", OnDraw)