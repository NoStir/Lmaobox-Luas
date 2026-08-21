local previousValues = {}

local function hasChanged(key, value)
    if previousValues[key] ~= value then
        previousValues[key] = value
        return true
    end
    return false
end

local function sendInfo(info)
    local infoString = tostring(info)
    print(infoString)
    client.ChatPrintf(tostring(infoString))
end

-- { label, netprop, type }
local props = {
    {"saveMeParity", "m_bSaveMeParity", "int"},
    {"isMiniBoss", "m_bIsMiniBoss", "int"},
    {"isABot", "m_bIsABot", "int"},
    {"botSkill", "m_nBotSkill", "int"},
--[[
    {"waterLevel", "m_nWaterLevel", "int"}, ## This one is spammy so I commented it out.
]]
    {"ragdoll", "m_hRagdoll", "int"},
    {"class", "m_iClass", "int"},
    {"classIcon", "m_iszClassIcon", "string"},
    {"customModel", "m_iszCustomModel", "string"},
    {"customModelOffset", "m_vecCustomModelOffset", "vector"},
    {"customModelRotation", "m_angCustomModelRotation", "vector"},
    {"customModelRotates", "m_bCustomModelRotates", "int"},
    {"customModelRotationSet", "m_bCustomModelRotationSet", "int"},
    {"customModelVisibleToSelf", "m_bCustomModelVisibleToSelf", "int"},
    {"useClassAnimations", "m_bUseClassAnimations", "int"},
    {"classModelParity", "m_iClassModelParity", "int"},
    {"playerCond", "m_nPlayerCond", "int"},
    {"jumping", "m_bJumping", "int"},
    {"numHealers", "m_nNumHealers", "int"},
    {"critMult", "m_iCritMult", "int"},
    {"airDash", "m_iAirDash", "int"},
    {"airDucked", "m_nAirDucked", "int"},
    {"duckTimer", "m_flDuckTimer", "float"},
    {"playerState", "m_nPlayerState", "int"},
    {"desiredPlayerClass", "m_iDesiredPlayerClass", "int"},
    {"movementStunTime", "m_flMovementStunTime", "float"},
    {"movementStunAmount", "m_iMovementStunAmount", "int"},
    {"movementStunParity", "m_iMovementStunParity", "int"},
    {"stunner", "m_hStunner", "int"},
    {"stunFlags", "m_iStunFlags", "int"},
    {"arenaNumChanges", "m_nArenaNumChanges", "int"},
    {"arenaFirstBloodBoost", "m_bArenaFirstBloodBoost", "int"},
    {"weaponKnockbackID", "m_iWeaponKnockbackID", "int"},
    {"loadoutUnavailable", "m_bLoadoutUnavailable", "int"},
    {"itemFindBonus", "m_iItemFindBonus", "int"},
    {"shieldEquipped", "m_bShieldEquipped", "int"},
    {"parachuteEquipped", "m_bParachuteEquipped", "int"},
    {"nextMeleeCrit", "m_iNextMeleeCrit", "int"},
    {"decapitations", "m_iDecapitations", "int"},
    {"revengeCrits", "m_iRevengeCrits", "int"},
    {"disguiseBody", "m_iDisguiseBody", "int"},
    {"carriedObject", "m_hCarriedObject", "int"},
    {"carryingObject", "m_bCarryingObject", "int"},
    {"nextNoiseMakerTime", "m_flNextNoiseMakerTime", "float"},
    {"spawnRoomTouchCount", "m_iSpawnRoomTouchCount", "int"},
    {"killCountSinceLastDeploy", "m_iKillCountSinceLastDeploy", "int"},
    {"firstPrimaryAttack", "m_flFirstPrimaryAttack", "float"},
    {"energyDrinkMeter", "m_flEnergyDrinkMeter", "float"},
    {"hypeMeter", "m_flHypeMeter", "float"},
    {"chargeMeter", "m_flChargeMeter", "float"},
    {"invisChangeCompleteTime", "m_flInvisChangeCompleteTime", "float"},
    {"disguiseTeam", "m_nDisguiseTeam", "int"},
    {"disguiseClass", "m_nDisguiseClass", "int"},
    {"disguiseSkinOverride", "m_nDisguiseSkinOverride", "int"},
    {"maskClass", "m_nMaskClass", "int"},
    {"disguiseTargetIndex", "m_iDisguiseTargetIndex", "int"},
    {"disguiseHealth", "m_iDisguiseHealth", "int"},
    {"feignDeathReady", "m_bFeignDeathReady", "int"},
    {"disguiseWeapon", "m_hDisguiseWeapon", "int"},
    {"teamTeleporterUsed", "m_nTeamTeleporterUsed", "int"},
    {"cloakMeter", "m_flCloakMeter", "float"},
    {"spyTranqBuffDuration", "m_flSpyTranqBuffDuration", "float"},
}

local function watchProps()
    local me = entities.GetLocalPlayer()
    if not me then return end

    for _, p in ipairs(props) do
        local label, prop, kind = p[1], p[2], p[3]
        local value
        if kind == "float" then
            value = me:GetPropFloat(prop)
        elseif kind == "string" then
            value = me:GetPropString(prop)
        elseif kind == "vector" then
            value = tostring(me:GetPropVector(prop))
        else
            value = me:GetPropInt(prop)
        end

        if value ~= nil and hasChanged(label, value) then
            sendInfo(label .. ": " .. tostring(value))
        end
    end
end

callbacks.Register("Draw", "prop_watcher", watchProps)