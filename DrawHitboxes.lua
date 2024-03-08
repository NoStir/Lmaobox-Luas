-- This function is called every frame to draw on the screen.
callbacks.Register("Draw", function()
    -- Get the local player entity.
    local me = entities.GetLocalPlayer()
    
    -- Iterate over all players.
    local players = entities.FindByClass("CTFPlayer")
    for i, player in ipairs(players) do
        -- Check if the player is not the local player and is alive.
        if player ~= me and player:IsAlive() then
            -- Check if the player is on the enemy team.
            if player:GetTeamNumber() ~= me:GetTeamNumber() then
                -- Get the player's model and hitbox set.
                local model = player:GetModel()
                local studioHdr = models.GetStudioModel(model)
                local myHitBoxSet = player:GetPropInt("m_nHitboxSet")
                local hitboxSet = studioHdr:GetHitboxSet(myHitBoxSet)
                local hitboxes = hitboxSet:GetHitboxes()

                -- Setup bones for accurate position.
                local boneMatrices = player:SetupBones()

                -- Iterate over all hitboxes to draw their bounding boxes.
                for j, hitbox in ipairs(hitboxes) do
                    local bone = hitbox:GetBone()
                    local boneMatrix = boneMatrices[bone]
                    if boneMatrix then
                        -- Get hitbox bounds (min and max points).
                        local mins, maxs = hitbox:GetBounds()
                        local minPos, maxPos = Vector3(boneMatrix:TransformPoint(mins)), Vector3(boneMatrix:TransformPoint(maxs))

                        -- Convert 3D positions to screen positions.
                        local screenMinPos, screenMaxPos = client.WorldToScreen(minPos), client.WorldToScreen(maxPos)
                        if screenMinPos and screenMaxPos then
                            -- Draw a rectangle to represent the hitbox bounds.
                            draw.Color(255, 0, 0, 255) -- Red color for visibility.
                            draw.OutlinedRect(screenMinPos[1], screenMinPos[2], screenMaxPos[1], screenMaxPos[2])
                        end
                    end
                end
            end
        end
    end
end)
