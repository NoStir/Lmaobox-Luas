local font = draw.CreateFont("Tahoma", 16, 800)
draw.SetFont(font)
draw.Color(255, 255, 255, 255)

local function test()
    local me = entities.GetLocalPlayer()
    
    -- Ensure 'me' is valid before proceeding
    if not me then
        print("Local player not found.")
        return
    end

    local model = me:GetModel()
    -- Check if the model is valid
    if not model then
        print("Failed to get model for the local player.")
        return
    end

    local studioHdr = models.GetStudioModel(model)
    -- Check if studioHdr is valid
    if not studioHdr then
        print("Failed to get studio model from the player model.")
        return
    end

    local myHitBoxSet = me:GetPropInt("m_nHitboxSet")
    -- Ensure myHitBoxSet is valid
    if myHitBoxSet == nil then
        print("Failed to get hitbox set property.")
        return
    end

    local hitboxSet = studioHdr:GetHitboxSet(myHitBoxSet)
    -- Check if hitboxSet is valid
    if not hitboxSet then
        print("Failed to get hitbox set from studio model.")
        return
    end

    local hitboxes = hitboxSet:GetHitboxes()
    -- Check if hitboxes are valid
    if not hitboxes or #hitboxes == 0 then
        print("No hitboxes found.")
        return
    end

    -- Ensure we can setup bones
    local boneMatrices = me:SetupBones()
    if not boneMatrices then
        print("Failed to setup bones.")
        return
    end

    for i = 1, #hitboxes do
        local hitbox = hitboxes[i]
        local bone = hitbox:GetBone()

        local boneMatrix = boneMatrices[bone]

        if boneMatrix == nil then
            goto continue
        end

        local bonePos = Vector3(boneMatrix[1][4], boneMatrix[2][4], boneMatrix[3][4])

        local screenPos = client.WorldToScreen(bonePos)

        if screenPos == nil then
            goto continue
        end

        draw.Text(screenPos[1], screenPos[2], tostring(i))

        ::continue::
    end
end

callbacks.Register("Draw", "test", test)
