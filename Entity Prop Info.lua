local previousValues = {}

local function hasChanged(key, value)
    if previousValues[key] ~= value then
        previousValues[key] = value
        return true
    end
    return false
end

local function x()

local me = entities.GetLocalPlayer()
--client.ChatPrintf("me: " .. tostring(me))

local saveMeParity = me:GetPropInt("m_bSaveMeParity")
local isMiniBoss = me:GetPropInt("m_bIsMiniBoss")
local isABot = me:GetPropInt("m_bIsABot")
local botSkill = me:GetPropInt("m_nBotSkill")
--local waterLevel = me:GetPropInt("m_nWaterLevel")
local ragdoll = me:GetPropInt("m_hRagdoll")

if hasChanged("saveMeParity", saveMeParity) then
    client.ChatPrintf("saveMeParity: " .. saveMeParity)
end

if hasChanged("isMiniBoss", isMiniBoss) then
    client.ChatPrintf("isMiniBoss: " .. isMiniBoss)
end

if hasChanged("isABot", isABot) then
    client.ChatPrintf("isABot: " .. isABot)
end

if hasChanged("botSkill", botSkill) then
    client.ChatPrintf("botSkill: " .. botSkill)
end

if hasChanged("waterLevel", waterLevel) then
    client.ChatPrintf("waterLevel: " .. waterLevel)
end

if hasChanged("ragdoll", ragdoll) then
    client.ChatPrintf("ragdoll: " .. ragdoll)
end

local class = me:GetPropInt("m_iClass")
local classIcon = me:GetPropString("m_iszClassIcon")
local customModel = me:GetPropString("m_iszCustomModel")
local customModelOffset = me:GetPropVector("m_vecCustomModelOffset")
local customModelRotation = me:GetPropVector("m_angCustomModelRotation")
local customModelRotates = me:GetPropInt("m_bCustomModelRotates")
local customModelRotationSet = me:GetPropInt("m_bCustomModelRotationSet")
local customModelVisibleToSelf = me:GetPropInt("m_bCustomModelVisibleToSelf")
local useClassAnimations = me:GetPropInt("m_bUseClassAnimations")
local classModelParity = me:GetPropInt("m_iClassModelParity")

if hasChanged("class", class) then
    client.ChatPrintf("class: " .. class)
end

if hasChanged("classIcon", classIcon) then
    client.ChatPrintf("classIcon: " .. classIcon)
end

if hasChanged("customModel", customModel) then
    client.ChatPrintf("customModel: " .. customModel)
end

if hasChanged("customModelOffset", customModelOffset) then
    client.ChatPrintf("customModelOffset: " .. tostring(customModelOffset))
end

if hasChanged("customModelRotation", customModelRotation) then
    client.ChatPrintf("customModelRotation: " .. tostring(customModelRotation))
end

if hasChanged("customModelRotates", customModelRotates) then
    client.ChatPrintf("customModelRotates: " .. customModelRotates)
end

if hasChanged("customModelRotationSet", customModelRotationSet) then
    client.ChatPrintf("customModelRotationSet: " .. customModelRotationSet)
end

if hasChanged("customModelVisibleToSelf", customModelVisibleToSelf) then
    client.ChatPrintf("customModelVisibleToSelf: " .. customModelVisibleToSelf)
end

if hasChanged("useClassAnimations", useClassAnimations) then
    client.ChatPrintf("useClassAnimations: " .. useClassAnimations)
end

if hasChanged("classModelParity", classModelParity) then
    client.ChatPrintf("classModelParity: " .. classModelParity)
end

local playerCond = me:GetPropInt("m_nPlayerCond")
local jumping = me:GetPropInt("m_bJumping")
local numHealers = me:GetPropInt("m_nNumHealers")
local critMult = me:GetPropInt("m_iCritMult")
local airDash = me:GetPropInt("m_iAirDash")
local airDucked = me:GetPropInt("m_nAirDucked")
local duckTimer = me:GetPropFloat("m_flDuckTimer")
local playerState = me:GetPropInt("m_nPlayerState")
local desiredPlayerClass = me:GetPropInt("m_iDesiredPlayerClass")
local movementStunTime = me:GetPropFloat("m_flMovementStunTime")
local movementStunAmount = me:GetPropInt("m_iMovementStunAmount")
local movementStunParity = me:GetPropInt("m_iMovementStunParity")
local stunner = me:GetPropInt("m_hStunner")
local stunFlags = me:GetPropInt("m_iStunFlags")
local arenaNumChanges = me:GetPropInt("m_nArenaNumChanges")
local arenaFirstBloodBoost = me:GetPropInt("m_bArenaFirstBloodBoost")
local weaponKnockbackID = me:GetPropInt("m_iWeaponKnockbackID")
local loadoutUnavailable = me:GetPropInt("m_bLoadoutUnavailable")
local itemFindBonus = me:GetPropInt("m_iItemFindBonus")
local shieldEquipped = me:GetPropInt("m_bShieldEquipped")
local parachuteEquipped = me:GetPropInt("m_bParachuteEquipped")
local nextMeleeCrit = me:GetPropInt("m_iNextMeleeCrit")
local decapitations = me:GetPropInt("m_iDecapitations")
local revengeCrits = me:GetPropInt("m_iRevengeCrits")
local disguiseBody = me:GetPropInt("m_iDisguiseBody")
local carriedObject = me:GetPropInt("m_hCarriedObject")
local carryingObject = me:GetPropInt("m_bCarryingObject")
local nextNoiseMakerTime = me:GetPropFloat("m_flNextNoiseMakerTime")
local spawnRoomTouchCount = me:GetPropInt("m_iSpawnRoomTouchCount")
local killCountSinceLastDeploy = me:GetPropInt("m_iKillCountSinceLastDeploy")
local firstPrimaryAttack = me:GetPropFloat("m_flFirstPrimaryAttack")
local energyDrinkMeter = me:GetPropFloat("m_flEnergyDrinkMeter")
local hypeMeter = me:GetPropFloat("m_flHypeMeter")
local chargeMeter = me:GetPropFloat("m_flChargeMeter")
local invisChangeCompleteTime = me:GetPropFloat("m_flInvisChangeCompleteTime")
local disguiseTeam = me:GetPropInt("m_nDisguiseTeam")
local disguiseClass = me:GetPropInt("m_nDisguiseClass")
local disguiseSkinOverride = me:GetPropInt("m_nDisguiseSkinOverride")
local maskClass = me:GetPropInt("m_nMaskClass")
local disguiseTargetIndex = tostring(me:GetPropInt("m_iDisguiseTargetIndex"))
local disguiseHealth = me:GetPropInt("m_iDisguiseHealth")
local feignDeathReady = me:GetPropInt("m_bFeignDeathReady")
local disguiseWeapon = me:GetPropInt("m_hDisguiseWeapon")
local teamTeleporterUsed = me:GetPropInt("m_nTeamTeleporterUsed")
local cloakMeter = me:GetPropFloat("m_flCloakMeter")
local spyTranqBuffDuration = me:GetPropFloat("m_flSpyTranqBuffDuration")

if hasChanged("playerCond", playerCond) then
    client.ChatPrintf("playerCond: " .. playerCond)
end

if hasChanged("jumping", jumping) then
    client.ChatPrintf("jumping: " .. jumping)
end

if hasChanged("numHealers", numHealers) then
    client.ChatPrintf("numHealers: " .. numHealers)
end

if hasChanged("critMult", critMult) then
    client.ChatPrintf("critMult: " .. critMult)
end

if hasChanged("airDash", airDash) then
    client.ChatPrintf("airDash: " .. airDash)
end

if hasChanged("airDucked", airDucked) then
    client.ChatPrintf("airDucked: " .. airDucked)
end

if hasChanged("duckTimer", duckTimer) then
    client.ChatPrintf("duckTimer: " .. duckTimer)
end

if hasChanged("playerState", playerState) then
    client.ChatPrintf("playerState: " .. playerState)
end

if hasChanged("desiredPlayerClass", desiredPlayerClass) then
    client.ChatPrintf("desiredPlayerClass: " .. desiredPlayerClass)
end

if hasChanged("movementStunTime", movementStunTime) then
    client.ChatPrintf("movementStunTime: " .. movementStunTime)
end

if hasChanged("movementStunAmount", movementStunAmount) then
    client.ChatPrintf("movementStunAmount: " .. movementStunAmount)
end

if hasChanged("movementStunParity", movementStunParity) then
    client.ChatPrintf("movementStunParity: " .. movementStunParity)
end

if hasChanged("stunner", stunner) then
    client.ChatPrintf("stunner: " .. stunner)
end

if hasChanged("stunFlags", stunFlags) then
    client.ChatPrintf("stunFlags: " .. stunFlags)
end

if hasChanged("arenaNumChanges", arenaNumChanges) then
    client.ChatPrintf("arenaNumChanges: " .. arenaNumChanges)
end

if hasChanged("arenaFirstBloodBoost", arenaFirstBloodBoost) then
    client.ChatPrintf("arenaFirstBloodBoost: " .. arenaFirstBloodBoost)
end

if hasChanged("weaponKnockbackID", weaponKnockbackID) then
    client.ChatPrintf("weaponKnockbackID: " .. weaponKnockbackID)
end

if hasChanged("loadoutUnavailable", loadoutUnavailable) then
    client.ChatPrintf("loadoutUnavailable: " .. loadoutUnavailable)
end

if hasChanged("itemFindBonus", itemFindBonus) then
    client.ChatPrintf("itemFindBonus: " .. itemFindBonus)
end

if hasChanged("shieldEquipped", shieldEquipped) then
    client.ChatPrintf("shieldEquipped: " .. shieldEquipped)
end

if hasChanged("parachuteEquipped", parachuteEquipped) then
    client.ChatPrintf("parachuteEquipped: " .. parachuteEquipped)
end

if hasChanged("nextMeleeCrit", nextMeleeCrit) then
    client.ChatPrintf("nextMeleeCrit: " .. nextMeleeCrit)
end

if hasChanged("decapitations", decapitations) then
    client.ChatPrintf("decapitations: " .. decapitations)
end

if hasChanged("revengeCrits", revengeCrits) then
    client.ChatPrintf("revengeCrits: " .. revengeCrits)
end

if hasChanged("disguiseBody", disguiseBody) then
    client.ChatPrintf("disguiseBody: " .. disguiseBody)
end

if hasChanged("carriedObject", carriedObject) then
    client.ChatPrintf("carriedObject: " .. carriedObject)
end

if hasChanged("carryingObject", carryingObject) then
    client.ChatPrintf("carryingObject: " .. carryingObject)
end

if hasChanged("nextNoiseMakerTime", nextNoiseMakerTime) then
    client.ChatPrintf("nextNoiseMakerTime: " .. nextNoiseMakerTime)
end

if hasChanged("spawnRoomTouchCount", spawnRoomTouchCount) then
    client.ChatPrintf("spawnRoomTouchCount: " .. spawnRoomTouchCount)
end

if hasChanged("killCountSinceLastDeploy", killCountSinceLastDeploy) then
    client.ChatPrintf("killCountSinceLastDeploy: " .. killCountSinceLastDeploy)
end

if hasChanged("firstPrimaryAttack", firstPrimaryAttack) then
    client.ChatPrintf("firstPrimaryAttack: " .. firstPrimaryAttack)
end

if hasChanged("energyDrinkMeter", energyDrinkMeter) then
    client.ChatPrintf("energyDrinkMeter: " .. energyDrinkMeter)
end

if hasChanged("hypeMeter", hypeMeter) then
    client.ChatPrintf("hypeMeter: " .. hypeMeter)
end

if hasChanged("chargeMeter", chargeMeter) then
    client.ChatPrintf("chargeMeter: " .. chargeMeter)
end

if hasChanged("invisChangeCompleteTime", invisChangeCompleteTime) then
    client.ChatPrintf("invisChangeCompleteTime: " .. invisChangeCompleteTime)
end

if hasChanged("disguiseTeam", disguiseTeam) then
    client.ChatPrintf("disguiseTeam: " .. disguiseTeam)
end

if hasChanged("disguiseClass", disguiseClass) then
    client.ChatPrintf("disguiseClass: " .. disguiseClass)
end

if hasChanged("disguiseSkinOverride", disguiseSkinOverride) then
    client.ChatPrintf("disguiseSkinOverride: " .. disguiseSkinOverride)
end

if hasChanged("maskClass", maskClass) then
    client.ChatPrintf("maskClass: " .. maskClass)
end

if hasChanged("disguiseTargetIndex", disguiseTargetIndex) then
    client.ChatPrintf("disguiseTargetIndex: " .. disguiseTargetIndex)
end

if hasChanged("disguiseHealth", disguiseHealth) then
    client.ChatPrintf("disguiseHealth: " .. disguiseHealth)
end

if hasChanged("feignDeathReady", feignDeathReady) then
    client.ChatPrintf("feignDeathReady: " .. feignDeathReady)
end

if hasChanged("disguiseWeapon", disguiseWeapon) then
    client.ChatPrintf("disguiseWeapon: " .. disguiseWeapon)
end

if hasChanged("teamTeleporterUsed", teamTeleporterUsed) then
    client.ChatPrintf("teamTeleporterUsed: " .. teamTeleporterUsed)
end

if hasChanged("cloakMeter", cloakMeter) then
    client.ChatPrintf("cloakMeter: " .. cloakMeter)
end

if hasChanged("spyTranqBuffDuration", spyTranqBuffDuration) then
    client.ChatPrintf("spyTranqBuffDuration: " .. spyTranqBuffDuration)
end

end 

callbacks.Register("Draw", x)