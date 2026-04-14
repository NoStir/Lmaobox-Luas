# Entity Props

*Source: https://lmaobox.net/lua/TF2_props/*

---



# Entity Props


Entity props and tables
```
"TF2EntProps"
{
    "DT_TFWearableLevelableItem"
    {
        "m_unLevel"     "Int"
    }
    "DT_TFWearableCampaignItem"
    {
        "m_nState"      "Int"
    }
    "DT_TFBaseRocket"
    {
        "m_vInitialVelocity"        "Vector"
        "m_vecOrigin"       "Vector"
        "m_angRotation"     "Vector"
        "m_iDeflected"      "Int"
        "m_hLauncher"       "Int"
    }
    "DT_TFWeaponBaseGrenadeProj"
    {
        "m_vInitialVelocity"        "Vector"
        "m_bCritical"       "Int"
        "m_iDeflected"      "Int"
        "m_vecOrigin"       "Vector"
        "m_angRotation"     "Vector"
        "m_hDeflectOwner"       "Int"
    }
    "DT_TFWeaponBase"
    {
        "m_bLowered"        "Int"
        "m_iReloadMode"     "Int"
        "m_bResetParity"        "Int"
        "m_bReloadedThroughAnimEvent"       "Int"
        "m_bDisguiseWeapon"     "Int"
        "LocalActiveTFWeaponData"
        {
            "m_flLastCritCheckTime"     "Float"
            "m_flReloadPriorNextFire"       "Float"
            "m_flLastFireTime"      "Float"
            "m_flEffectBarRegenTime"        "Float"
            "m_flObservedCritChance"        "Float"
        }
        "NonLocalTFWeaponData"      "DataTable"
        "m_flEnergy"        "Float"
        "m_hExtraWearable"      "Int"
        "m_hExtraWearableViewModel"     "Int"
        "m_bBeingRepurposedForTaunt"        "Int"
        "m_nKillComboClass"     "Int"
        "m_nKillComboCount"     "Int"
        "m_flInspectAnimEndTime"        "Float"
        "m_nInspectStage"       "Int"
        "m_iConsecutiveShots"       "Int"
    }
    "DT_TFWeaponRobotArm"
    {
        "m_hRobotArm"       "Int"
    }
    "DT_TFWeaponThrowable"
    {
        "m_flChargeBeginTime"       "Float"
    }
    "DT_TFWeaponKatana"
    {
        "m_bIsBloody"       "Int"
    }
    "DT_SniperDot"
    {
        "m_flChargeStartTime"       "Float"
    }
    "DT_TFSniperRifleClassic"
    {
        "m_bCharging"       "Int"
    }
    "DT_TFSniperRifle"
    {
        "SniperRifleLocalData"
        {
            "m_flChargedDamage"     "Float"
        }
    }
    "DT_WeaponChargedSMG"
    {
        "m_flMinicritCharge"        "Float"
    }
    "DT_TFWeaponSlap"
    {
        "m_bFirstHit"       "Int"
        "m_nNumKills"       "Int"
    }
    "DT_TFWeaponRocketPack"
    {
        "m_flInitLaunchTime"        "Float"
        "m_flLaunchTime"        "Float"
        "m_flToggleEndTime"     "Float"
        "m_bEnabled"        "Int"
    }
    "DT_Crossbow"
    {
        "m_flRegenerateDuration"        "Float"
        "m_flLastUsedTimestamp"     "Float"
    }
    "DT_WeaponRaygun"
    {
        "m_bUseNewProjectileCode"       "Int"
    }
    "DT_WeaponPipebombLauncher"
    {
        "PipebombLauncherLocalData"
        {
            "m_iPipebombCount"      "Int"
            "m_flChargeBeginTime"       "Float"
        }
    }
    "DT_ParticleCannon"
    {
        "m_flChargeBeginTime"       "Float"
        "m_iChargeEffect"       "Int"
    }
    "DT_WeaponMinigun"
    {
        "m_iWeaponState"        "Int"
        "m_bCritShot"       "Int"
    }
    "DT_WeaponMedigun"
    {
        "m_hHealingTarget"      "Int"
        "m_bHealing"        "Int"
        "m_bAttacking"      "Int"
        "m_bChargeRelease"      "Int"
        "m_bHolstered"      "Int"
        "m_nChargeResistType"       "Int"
        "m_hLastHealingTarget"      "Int"
        "LocalTFWeaponMedigunData"
        {
            "m_flChargeLevel"       "Float"
        }
        "NonLocalTFWeaponMedigunData"
        {
            "m_flChargeLevel"       "Float"
        }
    }
    "DT_WeaponLunchBox"
    {
        "m_bBroken"     "Int"
    }
    "DT_TFWeaponKnife"
    {
        "m_bReadyToBackstab"        "Int"
        "m_bKnifeExists"        "Int"
        "m_flKnifeRegenerateDuration"       "Float"
        "m_flKnifeMeltTimestamp"        "Float"
    }
    "DT_WeaponGrenadeLauncher"
    {
        "m_flDetonateTime"      "Float"
        "m_iCurrentTube"        "Int"
        "m_iGoalTube"       "Int"
    }
    "DT_TFProjectile_Pipebomb"
    {
        "m_bTouched"        "Int"
        "m_iType"       "Int"
        "m_hLauncher"       "Int"
        "m_bDefensiveBomb"      "Int"
    }
    "DT_GrapplingHook"
    {
        "m_hProjectile"     "Int"
    }
    "DT_WeaponFlareGun_Revenge"
    {
        "m_fLastExtinguishTime"     "Float"
    }
    "DT_WeaponFlareGun"
    {
        "m_flChargeBeginTime"       "Float"
    }
    "DT_WeaponFlameThrower"
    {
        "m_iWeaponState"        "Int"
        "m_bCritFire"       "Int"
        "m_bHitTarget"      "Int"
        "m_flChargeBeginTime"       "Float"
        "LocalFlameThrowerData"
        {
            "m_iActiveFlames"       "Int"
            "m_iDamagingFlames"     "Int"
            "m_hFlameManager"       "Int"
            "m_bHasHalloweenSpell"      "Int"
        }
    }
    "DT_WeaponFlameBall"
    {
        "m_flRechargeScale"     "Float"
    }
    "DT_WeaponCompoundBow"
    {
        "m_bArrowAlight"        "Int"
        "m_bNoFire"     "Int"
    }
    "DT_TFWeaponStickBomb"
    {
        "m_iDetonated"      "Int"
    }
    "DT_TFWeaponBreakableMelee"
    {
        "m_bBroken"     "Int"
    }
    "DT_TFDroppedWeapon"
    {
        "m_Item"
        {
            "m_iItemDefinitionIndex"        "Int"
            "m_iEntityLevel"        "Int"
            "m_iItemIDHigh"     "Int"
            "m_iItemIDLow"      "Int"
            "m_iAccountID"      "Int"
            "m_iEntityQuality"      "Int"
            "m_bInitialized"        "Int"
            "m_bOnlyIterateItemViewAttributes"      "Int"
            "m_AttributeList"
            {
                "m_Attributes"
                {
                    "lengthproxy"
                    {
                        "lengthprop20"      "Int"
                    }
                }
            }
            "m_iTeamNumber"     "Int"
            "m_NetworkedDynamicAttributesForDemos"
            {
                "m_Attributes"
                {
                    "lengthproxy"
                    {
                        "lengthprop20"      "Int"
                    }
                }
            }
        }
        "m_flChargeLevel"       "Float"
    }
    "DT_TFWeaponSapper"
    {
        "m_flChargeBeginTime"       "Float"
    }
    "DT_TFWeaponBuilder"
    {
        "m_iBuildState"     "Int"
        "BuilderLocalData"
        {
            "m_iObjectType"     "Int"
            "m_hObjectBeingBuilt"       "Int"
            "m_aBuildableObjectTypes"       "DataTable"
        }
        "m_iObjectMode"     "Int"
        "m_flWheatleyTalkingUntil"      "Float"
    }
    "DT_TFWeaponBuilder"
    {
        "m_iBuildState"     "Int"
        "BuilderLocalData"
        {
            "m_iObjectType"     "Int"
            "m_hObjectBeingBuilt"       "Int"
            "m_aBuildableObjectTypes"       "DataTable"
        }
        "m_iObjectMode"     "Int"
        "m_flWheatleyTalkingUntil"      "Float"
    }
    "DT_TFProjectile_Rocket"
    {
        "m_bCritical"       "Int"
    }
    "DT_TFProjectile_Flare"
    {
        "m_bCritical"       "Int"
    }
    "DT_TFProjectile_EnergyBall"
    {
        "m_bChargedShot"        "Int"
        "m_vColor1"     "Vector"
        "m_vColor2"     "Vector"
    }
    "DT_TFProjectile_Arrow"
    {
        "m_bArrowAlight"        "Int"
        "m_bCritical"       "Int"
        "m_iProjectileType"     "Int"
    }
    "DT_MannVsMachineStats"
    {
        "m_iCurrentWaveIdx"     "Int"
        "m_iServerWaveID"       "Int"
        "m_runningTotalWaveStats"
        {
            "nCreditsDropped"       "Int"
            "nCreditsAcquired"      "Int"
            "nCreditsBonus"     "Int"
            "nPlayerDeaths"     "Int"
            "nBuyBacks"     "Int"
        }
        "m_previousWaveStats"
        {
            "nCreditsDropped"       "Int"
            "nCreditsAcquired"      "Int"
            "nCreditsBonus"     "Int"
            "nPlayerDeaths"     "Int"
            "nBuyBacks"     "Int"
        }
        "m_currentWaveStats"
        {
            "nCreditsDropped"       "Int"
            "nCreditsAcquired"      "Int"
            "nCreditsBonus"     "Int"
            "nPlayerDeaths"     "Int"
            "nBuyBacks"     "Int"
        }
        "m_iCurrencyCollectedForRespec"     "Int"
        "m_nRespecsAwardedInWave"       "Int"
    }
    "DT_TFBaseBoss"
    {
        "m_lastHealthPercentage"        "Float"
    }
    "DT_BossAlpha"
    {
        "m_isNuking"        "Int"
    }
    "DT_TFWeaponSpellBook"
    {
        "m_iSelectedSpellIndex"     "Int"
        "m_iSpellCharges"       "Int"
        "m_flTimeNextSpell"     "Float"
        "m_bFiredAttack"        "Int"
    }
    "DT_Hightower_TeleportVortex"
    {
        "m_iState"      "Int"
    }
    "DT_TeleportVortex"
    {
        "m_iState"      "Int"
    }
    "DT_Zombie"
    {
        "m_flHeadScale"     "Float"
    }
    "DT_Merasmus"
    {
        "m_bRevealed"       "Int"
        "m_bIsDoingAOEAttack"       "Int"
        "m_bStunned"        "Int"
    }
    "DT_EyeballBoss"
    {
        "m_lookAtSpot"      "Vector"
        "m_attitude"        "Int"
    }
    "DT_TFBotHintEngineerNest"
    {
        "m_bHasActiveTeleporter"        "Int"
    }
    "DT_BotNPCMinion"
    {
        "m_stunTarget"      "Int"
    }
    "DT_BotNPC"
    {
        "m_laserTarget"     "Int"
        "m_isNuking"        "Int"
    }
    "DT_PasstimeGun"
    {
        "m_eThrowState"     "Int"
        "m_fChargeBeginTime"        "Float"
    }
    "DT_TFRobotDestruction_Robot"
    {
        "m_iHealth"     "Int"
        "m_iMaxHealth"      "Int"
        "m_eType"       "Int"
    }
    "DT_TFReviveMarker"
    {
        "m_hOwner"      "Int"
        "m_iHealth"     "Int"
        "m_iMaxHealth"      "Int"
        "m_nRevives"        "Int"
    }
    "DT_TFProjectile_BallOfFire"
    {
        "m_vecInitialVelocity"      "Vector"
        "m_vecSpawnOrigin"      "Vector"
    }
    "DT_TFBaseProjectile"
    {
        "m_vInitialVelocity"        "Vector"
        "m_hLauncher"       "Int"
    }
    "DT_TFPointManager"
    {
        "m_nRandomSeed"     "Int"
        "m_unNextPointIndex"        "Int"
        "m_nSpawnTime"      "DataTable"
    }
    "DT_TFRobotDestructionLogic"
    {
        "m_nMaxPoints"      "Int"
        "m_nBlueScore"      "Int"
        "m_nRedScore"       "Int"
        "m_nBlueTargetPoints"       "Int"
        "m_nRedTargetPoints"        "Int"
        "m_flBlueTeamRespawnScale"      "Float"
        "m_flRedTeamRespawnScale"       "Float"
        "m_flBlueFinaleEndTime"     "Float"
        "m_flRedFinaleEndTime"      "Float"
        "m_flFinaleLength"      "Float"
        "m_szResFile"       "String"
        "m_eWinningMethod"      "DataTable"
        "m_flCountdownEndTime"      "Float"
    }
    "DT_TFRobotDestruction_RobotGroup"
    {
        "m_pszHudIcon"      "String"
        "m_iTeamNum"        "Int"
        "m_nGroupNumber"        "Int"
        "m_nState"      "Int"
        "m_flRespawnStartTime"      "Float"
        "m_flRespawnEndTime"        "Float"
        "m_flLastAttackedTime"      "Float"
    }
    "DT_TFPlayerDestructionLogic"
    {
        "m_hRedTeamLeader"      "Int"
        "m_hBlueTeamLeader"     "Int"
        "m_iszCountdownImage"       "String"
        "m_bUsingCountdownImage"        "Int"
    }
    "DT_TFMinigameLogic"
    {
        "m_hActiveMinigame"     "Int"
    }
    "DT_TFMinigame"
    {
        "m_nMinigameTeamScore"      "DataTable"
        "m_nMaxScoreForMiniGame"        "Int"
        "m_pszHudResFile"       "String"
        "m_eScoringType"        "Int"
    }
    "DT_TFPowerupBottle"
    {
        "m_bActive"     "Int"
        "m_usNumCharges"        "Int"
    }
    "DT_HalloweenSoulPack"
    {
        "m_hTarget"     "Int"
        "m_vecPreCurvePos"      "Vector"
        "m_vecStartCurvePos"        "Vector"
        "m_flDuration"      "Float"
    }
    "DT_BonusRoundLogic"
    {
        "m_aBonusPlayerRoll"
        {
            "lengthproxy"
            {
                "lengthprop101"     "Int"
            }
        }
        "m_hBonusWinner"        "Int"
        "m_Item"
        {
            "m_iItemDefinitionIndex"        "Int"
            "m_iEntityLevel"        "Int"
            "m_iItemIDHigh"     "Int"
            "m_iItemIDLow"      "Int"
            "m_iAccountID"      "Int"
            "m_iEntityQuality"      "Int"
            "m_bInitialized"        "Int"
            "m_bOnlyIterateItemViewAttributes"      "Int"
            "m_AttributeList"
            {
                "m_Attributes"
                {
                    "lengthproxy"
                    {
                        "lengthprop20"      "Int"
                    }
                }
            }
            "m_iTeamNumber"     "Int"
            "m_NetworkedDynamicAttributesForDemos"
            {
                "m_Attributes"
                {
                    "lengthproxy"
                    {
                        "lengthprop20"      "Int"
                    }
                }
            }
        }
    }
    "DT_TFGameRulesProxy"
    {
        "tf_gamerules_data"
        {
            "m_nGameType"       "Int"
            "m_nStopWatchState"     "Int"
            "m_pszTeamGoalStringRed"        "String"
            "m_pszTeamGoalStringBlue"       "String"
            "m_flCapturePointEnableTime"        "Float"
            "m_nHudType"        "Int"
            "m_bIsInTraining"       "Int"
            "m_bAllowTrainingAchievements"      "Int"
            "m_bIsWaitingForTrainingContinue"       "Int"
            "m_bIsTrainingHUDVisible"       "Int"
            "m_bIsInItemTestingMode"        "Int"
            "m_hBonusLogic"     "Int"
            "m_bPlayingKoth"        "Int"
            "m_bPlayingMedieval"        "Int"
            "m_bPlayingHybrid_CTF_CP"       "Int"
            "m_bPlayingSpecialDeliveryMode"     "Int"
            "m_bPlayingRobotDestructionMode"        "Int"
            "m_hRedKothTimer"       "Int"
            "m_hBlueKothTimer"      "Int"
            "m_nMapHolidayType"     "Int"
            "m_itHandle"        "Int"
            "m_bPlayingMannVsMachine"       "Int"
            "m_hBirthdayPlayer"     "Int"
            "m_nBossHealth"     "Int"
            "m_nMaxBossHealth"      "Int"
            "m_fBossNormalizedTravelDistance"       "Int"
            "m_bMannVsMachineAlarmStatus"       "Int"
            "m_bHaveMinPlayersToEnableReady"        "Int"
            "m_bBountyModeEnabled"      "Int"
            "m_nHalloweenEffect"        "Int"
            "m_fHalloweenEffectStartTime"       "Float"
            "m_fHalloweenEffectDuration"        "Float"
            "m_halloweenScenario"       "Int"
            "m_bHelltowerPlayersInHell"     "Int"
            "m_bIsUsingSpells"      "Int"
            "m_bCompetitiveMode"        "Int"
            "m_nMatchGroupType"     "Int"
            "m_bMatchEnded"     "Int"
            "m_bPowerupMode"        "Int"
            "m_pszCustomUpgradesFile"       "String"
            "m_bTruceActive"        "Int"
            "m_bShowMatchSummary"       "Int"
            "\"m_bShowCompetitiveMatchSummary\""        "Int"
            "m_bTeamsSwitched"      "Int"
            "m_bMapHasMatchSummaryStage"        "Int"
            "m_bPlayersAreOnMatchSummaryStage"      "Int"
            "m_bStopWatchWinner"        "Int"
            "m_ePlayerWantsRematch"     "DataTable"
            "m_eRematchState"       "Int"
            "m_nNextMapVoteOptions"     "DataTable"
            "m_nForceUpgrades"      "Int"
            "m_nForceEscortPushLogic"       "Int"
            "m_bRopesHolidayLightsAllowed"      "Int"
        }
    }
    "DT_TETFParticleEffect"
    {
        "m_vecOrigin[0]"        "Float"
        "m_vecOrigin[1]"        "Float"
        "m_vecOrigin[2]"        "Float"
        "m_vecStart[0]"     "Float"
        "m_vecStart[1]"     "Float"
        "m_vecStart[2]"     "Float"
        "m_vecAngles"       "Vector"
        "m_iParticleSystemIndex"        "Int"
        "entindex"      "Int"
        "m_iAttachType"     "Int"
        "m_iAttachmentPointIndex"       "Int"
        "m_bResetParticles"     "Int"
        "m_bCustomColors"       "Int"
        "m_CustomColors.m_vecColor1"        "Vector"
        "m_CustomColors.m_vecColor2"        "Vector"
        "m_bControlPoint1"      "Int"
        "m_ControlPoint1.m_eParticleAttachment"     "Int"
        "m_ControlPoint1.m_vecOffset[0]"        "Float"
        "m_ControlPoint1.m_vecOffset[1]"        "Float"
        "m_ControlPoint1.m_vecOffset[2]"        "Float"
    }
    "DT_TETFExplosion"
    {
        "m_vecOrigin[0]"        "Float"
        "m_vecOrigin[1]"        "Float"
        "m_vecOrigin[2]"        "Float"
        "m_vecNormal"       "Vector"
        "m_iWeaponID"       "Int"
        "entindex"      "Int"
        "m_nDefID"      "Int"
        "m_nSound"      "Int"
        "m_iCustomParticleIndex"        "Int"
    }
    "DT_TETFBlood"
    {
        "m_vecOrigin[0]"        "Float"
        "m_vecOrigin[1]"        "Float"
        "m_vecOrigin[2]"        "Float"
        "m_vecNormal"       "Vector"
        "entindex"      "Int"
    }
    "DT_TFFlameManager"
    {
        "m_hWeapon"     "Int"
        "m_hAttacker"       "Int"
        "m_flSpreadDegree"      "Float"
        "m_flRedirectedFlameSizeMult"       "Float"
        "m_flFlameStartSizeMult"        "Float"
        "m_flFlameEndSizeMult"      "Float"
        "m_flFlameIgnorePlayerVelocity"     "Float"
        "m_flFlameReflectionAdditionalLifeTime"     "Float"
        "m_flFlameReflectionDamageReduction"        "Float"
        "m_iMaxFlameReflectionCount"        "Int"
        "m_nShouldReflect"      "Int"
        "m_flFlameSpeed"        "Float"
        "m_flFlameLifeTime"     "Float"
        "m_flRandomLifeTimeOffset"      "Float"
        "m_flFlameGravity"      "Float"
        "m_flFlameDrag"     "Float"
        "m_flFlameUp"       "Float"
        "m_bIsFiring"       "Int"
    }
    "DT_CHalloweenGiftPickup"
    {
        "m_hTargetPlayer"       "Int"
    }
    "DT_CBonusDuckPickup"
    {
        "m_bSpecial"        "Int"
    }
    "DT_CaptureFlag"
    {
        "m_bDisabled"       "Int"
        "m_bVisibleWhenDisabled"        "Int"
        "m_nType"       "Int"
        "m_nFlagStatus"     "Int"
        "m_flResetTime"     "Float"
        "m_flNeutralTime"       "Float"
        "m_flMaxResetTime"      "Float"
        "m_hPrevOwner"      "Int"
        "m_szModel"     "String"
        "m_szHudIcon"       "String"
        "m_szPaperEffect"       "String"
        "m_szTrailEffect"       "String"
        "m_nUseTrailEffect"     "Int"
        "m_nPointValue"     "Int"
        "m_flAutoCapTime"       "Float"
        "m_bGlowEnabled"        "Int"
        "m_flTimeToSetPoisonous"        "Float"
    }
    "DT_TFTeam"
    {
        "m_nFlagCaptures"       "Int"
        "m_iRole"       "Int"
        "team_object_array_element"     "Int"
        "\"team_object_array\""     "Array"
        "m_hLeader"     "Int"
    }
    "DT_TFPlayerResource"
    {
        "m_iTotalScore"     "DataTable"
        "m_iMaxHealth"      "DataTable"
        "m_iMaxBuffedHealth"        "DataTable"
        "m_iPlayerClass"        "DataTable"
        "m_bArenaSpectator"     "DataTable"
        "m_iActiveDominations"      "DataTable"
        "m_flNextRespawnTime"       "DataTable"
        "m_iChargeLevel"        "DataTable"
        "m_iDamage"     "DataTable"
        "m_iDamageAssist"       "DataTable"
        "m_iDamageBoss"     "DataTable"
        "m_iHealing"        "DataTable"
        "m_iHealingAssist"      "DataTable"
        "m_iDamageBlocked"      "DataTable"
        "m_iCurrencyCollected"      "DataTable"
        "m_iBonusPoints"        "DataTable"
        "m_iPlayerLevel"        "DataTable"
        "m_iStreaks"        "DataTable"
        "m_iUpgradeRefundCredits"       "DataTable"
        "m_iBuybackCredits"     "DataTable"
        "m_iPartyLeaderRedTeamIndex"        "Int"
        "m_iPartyLeaderBlueTeamIndex"       "Int"
        "m_iEventTeamStatus"        "Int"
        "m_iPlayerClassWhenKilled"      "DataTable"
        "m_iConnectionState"        "DataTable"
        "m_flConnectTime"       "DataTable"
    }
    "DT_TFPlayer"
    {
        "m_bSaveMeParity"       "Int"
        "m_bIsMiniBoss"     "Int"
        "m_bIsABot"     "Int"
        "m_nBotSkill"       "Int"
        "m_nWaterLevel"     "Int"
        "m_hRagdoll"        "Int"
        "m_PlayerClass"
        {
            "m_iClass"      "Int"
            "m_iszClassIcon"        "String"
            "m_iszCustomModel"      "String"
            "m_vecCustomModelOffset"        "Vector"
            "m_angCustomModelRotation"      "Vector"
            "m_bCustomModelRotates"     "Int"
            "m_bCustomModelRotationSet"     "Int"
            "m_bCustomModelVisibleToSelf"       "Int"
            "m_bUseClassAnimations"     "Int"
            "m_iClassModelParity"       "Int"
        }
        "m_Shared"
        {
            "m_nPlayerCond"     "Int"
            "m_bJumping"        "Int"
            "m_nNumHealers"     "Int"
            "m_iCritMult"       "Int"
            "m_iAirDash"        "Int"
            "m_nAirDucked"      "Int"
            "m_flDuckTimer"     "Float"
            "m_nPlayerState"        "Int"
            "m_iDesiredPlayerClass"     "Int"
            "m_flMovementStunTime"      "Float"
            "m_iMovementStunAmount"     "Int"
            "m_iMovementStunParity"     "Int"
            "m_hStunner"        "Int"
            "m_iStunFlags"      "Int"
            "m_nArenaNumChanges"        "Int"
            "m_bArenaFirstBloodBoost"       "Int"
            "m_iWeaponKnockbackID"      "Int"
            "m_bLoadoutUnavailable"     "Int"
            "m_iItemFindBonus"      "Int"
            "m_bShieldEquipped"     "Int"
            "m_bParachuteEquipped"      "Int"
            "m_iNextMeleeCrit"      "Int"
            "m_iDecapitations"      "Int"
            "m_iRevengeCrits"       "Int"
            "m_iDisguiseBody"       "Int"
            "m_hCarriedObject"      "Int"
            "m_bCarryingObject"     "Int"
            "m_flNextNoiseMakerTime"        "Float"
            "m_iSpawnRoomTouchCount"        "Int"
            "m_iKillCountSinceLastDeploy"       "Int"
            "m_flFirstPrimaryAttack"        "Float"
            "m_flEnergyDrinkMeter"      "Float"
            "m_flHypeMeter"     "Float"
            "m_flChargeMeter"       "Float"
            "m_flInvisChangeCompleteTime"       "Float"
            "m_nDisguiseTeam"       "Int"
            "m_nDisguiseClass"      "Int"
            "m_nDisguiseSkinOverride"       "Int"
            "m_nMaskClass"      "Int"
            "m_hDisguiseTarget"     "Int"
            "m_iDisguiseHealth"     "Int"
            "m_bFeignDeathReady"        "Int"
            "m_hDisguiseWeapon"     "Int"
            "m_nTeamTeleporterUsed"     "Int"
            "m_flCloakMeter"        "Float"
            "m_flSpyTranqBuffDuration"      "Float"
            "tfsharedlocaldata"
            {
                "m_nDesiredDisguiseTeam"        "Int"
                "m_nDesiredDisguiseClass"       "Int"
                "m_flStealthNoAttackExpire"     "Float"
                "m_flStealthNextChangeTime"     "Float"
                "m_bLastDisguisedAsOwnTeam"     "Int"
                "m_flRageMeter"     "Float"
                "m_bRageDraining"       "Int"
                "m_flNextRageEarnTime"      "Float"
                "m_bInUpgradeZone"      "Int"
                "m_flItemChargeMeter"       "DataTable"
                "m_bPlayerDominated"        "DataTable"
                "m_bPlayerDominatingMe"     "DataTable"
                "m_ScoreData"
                {
                    "m_iCaptures"       "Int"
                    "m_iDefenses"       "Int"
                    "m_iKills"      "Int"
                    "m_iDeaths"     "Int"
                    "m_iSuicides"       "Int"
                    "m_iDominations"        "Int"
                    "m_iRevenge"        "Int"
                    "m_iBuildingsBuilt"     "Int"
                    "m_iBuildingsDestroyed"     "Int"
                    "m_iHeadshots"      "Int"
                    "m_iBackstabs"      "Int"
                    "m_iHealPoints"     "Int"
                    "m_iInvulns"        "Int"
                    "m_iTeleports"      "Int"
                    "m_iResupplyPoints"     "Int"
                    "m_iKillAssists"        "Int"
                    "m_iPoints"     "Int"
                    "m_iBonusPoints"        "Int"
                    "m_iDamageDone"     "Int"
                    "m_iCrits"      "Int"
                }
                "m_RoundScoreData"
                {
                    "m_iCaptures"       "Int"
                    "m_iDefenses"       "Int"
                    "m_iKills"      "Int"
                    "m_iDeaths"     "Int"
                    "m_iSuicides"       "Int"
                    "m_iDominations"        "Int"
                    "m_iRevenge"        "Int"
                    "m_iBuildingsBuilt"     "Int"
                    "m_iBuildingsDestroyed"     "Int"
                    "m_iHeadshots"      "Int"
                    "m_iBackstabs"      "Int"
                    "m_iHealPoints"     "Int"
                    "m_iInvulns"        "Int"
                    "m_iTeleports"      "Int"
                    "m_iResupplyPoints"     "Int"
                    "m_iKillAssists"        "Int"
                    "m_iPoints"     "Int"
                    "m_iBonusPoints"        "Int"
                    "m_iDamageDone"     "Int"
                    "m_iCrits"      "Int"
                }
            }
            "m_ConditionList"
            {
                "_condition_bits"       "Int"
            }
            "m_iTauntIndex"     "Int"
            "m_iTauntConcept"       "Int"
            "m_nPlayerCondEx"       "Int"
            "m_iStunIndex"      "Int"
            "m_nHalloweenBombHeadStage"     "Int"
            "m_nPlayerCondEx2"      "Int"
            "m_nPlayerCondEx3"      "Int"
            "m_nStreaks"        "DataTable"
            "m_unTauntSourceItemID_Low"     "Int"
            "m_unTauntSourceItemID_High"        "Int"
            "m_flRuneCharge"        "Float"
            "m_bHasPasstimeBall"        "Int"
            "m_bIsTargetedForPasstimePass"      "Int"
            "m_hPasstimePassTarget"     "Int"
            "m_askForBallTime"      "Float"
            "m_bKingRuneBuffActive"     "Int"
            "m_ConditionData"
            {
                "lengthproxy"
                {
                    "lengthprop131"     "Int"
                }
            }
            "m_nPlayerCondEx4"      "Int"
            "m_flHolsterAnimTime"       "Float"
            "m_hSwitchTo"       "Int"
        }
        "m_hItem"       "Int"
        "tflocaldata"
        {
            "m_vecOrigin"       "VectorXY"
            "m_vecOrigin[2]"        "Float"
            "player_object_array_element"       "Int"
            "\"player_object_array\""       "Array"
            "m_angEyeAngles[0]"     "Float"
            "m_angEyeAngles[1]"     "Float"
            "m_bIsCoaching"     "Int"
            "m_hCoach"      "Int"
            "m_hStudent"        "Int"
            "m_nCurrency"       "Int"
            "m_nExperienceLevel"        "Int"
            "m_nExperienceLevelProgress"        "Int"
            "m_bMatchSafeToLeave"       "Int"
        }
        "tfnonlocaldata"
        {
            "m_vecOrigin"       "VectorXY"
            "m_vecOrigin[2]"        "Float"
            "m_angEyeAngles[0]"     "Float"
            "m_angEyeAngles[1]"     "Float"
        }
        "m_bAllowMoveDuringTaunt"       "Int"
        "m_bIsReadyToHighFive"      "Int"
        "m_hHighFivePartner"        "Int"
        "m_nForceTauntCam"      "Int"
        "m_flTauntYaw"      "Float"
        "m_nActiveTauntSlot"        "Int"
        "m_iTauntItemDefIndex"      "Int"
        "m_flCurrentTauntMoveSpeed"     "Float"
        "m_flVehicleReverseTime"        "Float"
        "m_flMvMLastDamageTime"     "Float"
        "\"m_flLastDamageTime\""        "Float"
        "m_bInPowerPlay"        "Int"
        "m_iSpawnCounter"       "Int"
        "m_bArenaSpectator"     "Int"
        "m_AttributeManager"
        {
            "m_hOuter"      "Int"
            "m_ProviderType"        "Int"
            "m_iReapplyProvisionParity"     "Int"
        }
        "m_flHeadScale"     "Float"
        "m_flTorsoScale"        "Float"
        "m_flHandScale"     "Float"
        "m_bUseBossHealthBar"       "Int"
        "m_bUsingVRHeadset"     "Int"
        "m_bForcedSkin"     "Int"
        "m_nForcedSkin"     "Int"
        "m_bGlowEnabled"        "Int"
        "TFSendHealersDataTable"
        {
            "m_nActiveWpnClip"      "Int"
        }
        "m_flKartNextAvailableBoost"        "Float"
        "m_iKartHealth"     "Int"
        "m_iKartState"      "Int"
        "m_hGrapplingHookTarget"        "Int"
        "m_hSecondaryLastWeapon"        "Int"
        "m_bUsingActionSlot"        "Int"
        "m_flInspectTime"       "Float"
        "m_flHelpmeButtonPressTime"     "Float"
        "m_iCampaignMedals"     "Int"
        "m_iPlayerSkinOverride"     "Int"
        "m_bViewingCYOAPDA"     "Int"
        "m_bRegenerating"       "Int"
    }
    "DT_TFRagdoll"
    {
        "m_vecRagdollOrigin"        "Vector"
        "m_hPlayer"     "Int"
        "m_vecForce"        "Vector"
        "m_vecRagdollVelocity"      "Vector"
        "m_nForceBone"      "Int"
        "m_bGib"        "Int"
        "m_bBurning"        "Int"
        "m_bElectrocuted"       "Int"
        "m_bFeignDeath"     "Int"
        "m_bWasDisguised"       "Int"
        "m_bOnGround"       "Int"
        "m_bCloaked"        "Int"
        "m_bBecomeAsh"      "Int"
        "m_iDamageCustom"       "Int"
        "m_iTeam"       "Int"
        "m_iClass"      "Int"
        "m_hRagWearables"
        {
            "lengthproxy"
            {
                "lengthprop8"       "Int"
            }
        }
        "m_bGoldRagdoll"        "Int"
        "m_bIceRagdoll"     "Int"
        "m_bCritOnHardHit"      "Int"
        "m_flHeadScale"     "Float"
        "m_flTorsoScale"        "Float"
        "m_flHandScale"     "Float"
    }
    "DT_TEPlayerAnimEvent"
    {
        "m_hPlayer"     "Int"
        "m_iEvent"      "Int"
        "m_nData"       "Int"
    }
    "DT_TFPasstimeLogic"
    {
        "m_hBall"       "Int"
        "m_trackPoints[0]"      "Vector"
        "m_trackPoints"     "Array"
        "m_iNumSections"        "Int"
        "m_iCurrentSection"     "Int"
        "m_flMaxPassRange"      "Float"
        "m_iBallPower"      "Int"
        "m_flPackSpeed"     "Float"
        "m_bPlayerIsPackMember"     "DataTable"
    }
    "DT_PasstimeBall"
    {
        "m_iCollisionCount"     "Int"
        "m_hHomingTarget"       "Int"
        "m_hCarrier"        "Int"
        "m_hPrevCarrier"        "Int"
    }
    "DT_TFObjectiveResource"
    {
        "m_nMannVsMachineMaxWaveCount"      "Int"
        "m_nMannVsMachineWaveCount"     "Int"
        "m_nMannVsMachineWaveEnemyCount"        "Int"
        "m_nMvMWorldMoney"      "Int"
        "m_flMannVsMachineNextWaveTime"     "Float"
        "m_bMannVsMachineBetweenWaves"      "Int"
        "m_nFlagCarrierUpgradeLevel"        "Int"
        "m_flMvMBaseBombUpgradeTime"        "Float"
        "m_flMvMNextBombUpgradeTime"        "Float"
        "m_iszMvMPopfileName"       "String"
        "m_iChallengeIndex"     "Int"
        "m_nMvMEventPopfileType"        "Int"
        "m_nMannVsMachineWaveClassCounts"       "DataTable"
        "m_iszMannVsMachineWaveClassNames[0]"       "String"
        "m_iszMannVsMachineWaveClassNames"      "Array"
        "m_nMannVsMachineWaveClassFlags"        "DataTable"
        "m_nMannVsMachineWaveClassCounts2"      "DataTable"
        "m_iszMannVsMachineWaveClassNames2[0]"      "String"
        "m_iszMannVsMachineWaveClassNames2"     "Array"
        "m_nMannVsMachineWaveClassFlags2"       "DataTable"
        "m_bMannVsMachineWaveClassActive"       "DataTable"
        "m_bMannVsMachineWaveClassActive2"      "DataTable"
    }
    "DT_TFGlow"
    {
        "m_iMode"       "Int"
        "m_glowColor"       "Int"
        "m_bDisabled"       "Int"
        "m_hTarget"     "Int"
    }
    "DT_TEFireBullets"
    {
        "m_vecOrigin"       "Vector"
        "m_vecAngles[0]"        "Float"
        "m_vecAngles[1]"        "Float"
        "m_iWeaponID"       "Int"
        "m_iMode"       "Int"
        "m_iSeed"       "Int"
        "m_iPlayer"     "Int"
        "m_flSpread"        "Float"
        "m_bCritical"       "Int"
    }
    "DT_AmmoPack"
    {
        "m_vecInitialVelocity"      "Vector"
        "m_angRotation[0]"      "Float"
        "m_angRotation[1]"      "Float"
        "m_angRotation[2]"      "Float"
    }
    "DT_ObjectTeleporter"
    {
        "m_iState"      "Int"
        "m_flRechargeTime"      "Float"
        "m_flCurrentRechargeDuration"       "Float"
        "m_iTimesUsed"      "Int"
        "m_flYawToExit"     "Float"
        "m_bMatchBuilding"      "Int"
    }
    "DT_ObjectSentrygun"
    {
        "m_iAmmoShells"     "Int"
        "m_iAmmoRockets"        "Int"
        "m_iState"      "Int"
        "m_bPlayerControlled"       "Int"
        "m_nShieldLevel"        "Int"
        "m_bShielded"       "Int"
        "m_hEnemy"      "Int"
        "m_hAutoAimTarget"      "Int"
        "SentrygunLocalData"
        {
            "m_iKills"      "Int"
            "m_iAssists"        "Int"
        }
    }
    "DT_ObjectDispenser"
    {
        "m_iState"      "Int"
        "m_iAmmoMetal"      "Int"
        "m_iMiniBombCounter"        "Int"
        "healing_array_element"     "Int"
        "\"healing_array\""     "Array"
    }
    "DT_MonsterResource"
    {
        "m_iBossHealthPercentageByte"       "Int"
        "m_iBossStunPercentageByte"     "Int"
        "m_iSkillShotCompleteCount"     "Int"
        "m_fSkillShotComboEndTime"      "Float"
        "m_iBossState"      "Int"
    }
    "DT_FuncPasstimeGoal"
    {
        "m_bTriggerDisabled"        "Int"
        "m_iGoalType"       "Int"
    }
    "DT_CaptureZone"
    {
        "m_bDisabled"       "Int"
    }
    "DT_CurrencyPack"
    {
        "m_bDistributed"        "Int"
    }
    "DT_BaseObject"
    {
        "m_iHealth"     "Int"
        "m_iMaxHealth"      "Int"
        "m_bHasSapper"      "Int"
        "m_iObjectType"     "Int"
        "m_bBuilding"       "Int"
        "m_bPlacing"        "Int"
        "m_bCarried"        "Int"
        "m_bCarryDeploy"        "Int"
        "m_bMiniBuilding"       "Int"
        "m_flPercentageConstructed"     "Float"
        "m_fObjectFlags"        "Int"
        "m_hBuiltOnEntity"      "Int"
        "m_bDisabled"       "Int"
        "m_hBuilder"        "Int"
        "m_vecBuildMaxs"        "Vector"
        "m_vecBuildMins"        "Vector"
        "m_iDesiredBuildRotations"      "Int"
        "m_bServerOverridePlacement"        "Int"
        "m_iUpgradeLevel"       "Int"
        "m_iUpgradeMetal"       "Int"
        "m_iUpgradeMetalRequired"       "Int"
        "m_iHighestUpgradeLevel"        "Int"
        "m_iObjectMode"     "Int"
        "m_bDisposableBuilding"     "Int"
        "m_bWasMapPlaced"       "Int"
        "m_bPlasmaDisable"      "Int"
    }
    "DT_TestTraceline"
    {
        "m_clrRender"       "Int"
        "m_vecOrigin"       "Vector"
        "m_angRotation[0]"      "Float"
        "m_angRotation[1]"      "Float"
        "m_angRotation[2]"      "Float"
        "moveparent"        "Int"
    }
    "DT_TEWorldDecal"
    {
        "m_vecOrigin"       "Vector"
        "m_nIndex"      "Int"
    }
    "DT_TESpriteSpray"
    {
        "m_vecOrigin"       "Vector"
        "m_vecDirection"        "Vector"
        "m_nModelIndex"     "Int"
        "m_fNoise"      "Float"
        "m_nCount"      "Int"
        "m_nSpeed"      "Int"
    }
    "DT_TESprite"
    {
        "m_vecOrigin"       "Vector"
        "m_nModelIndex"     "Int"
        "m_fScale"      "Float"
        "m_nBrightness"     "Int"
    }
    "DT_TESparks"
    {
        "m_nMagnitude"      "Int"
        "m_nTrailLength"        "Int"
        "m_vecDir"      "Vector"
    }
    "DT_TESmoke"
    {
        "m_vecOrigin"       "Vector"
        "m_nModelIndex"     "Int"
        "m_fScale"      "Float"
        "m_nFrameRate"      "Int"
    }
    "DT_TEShowLine"
    {
        "m_vecEnd"      "Vector"
    }
    "DT_TEProjectedDecal"
    {
        "m_vecOrigin"       "Vector"
        "m_angRotation"     "Vector"
        "m_flDistance"      "Float"
        "m_nIndex"      "Int"
    }
    "DT_TEPlayerDecal"
    {
        "m_vecOrigin"       "Vector"
        "m_nEntity"     "Int"
        "m_nPlayer"     "Int"
    }
    "DT_TEPhysicsProp"
    {
        "m_vecOrigin"       "Vector"
        "m_angRotation[0]"      "Float"
        "m_angRotation[1]"      "Float"
        "m_angRotation[2]"      "Float"
        "m_vecVelocity"     "Vector"
        "m_nModelIndex"     "Int"
        "m_nFlags"      "Int"
        "m_nSkin"       "Int"
        "m_nEffects"        "Int"
    }
    "DT_TEParticleSystem"
    {
        "m_vecOrigin[0]"        "Float"
        "m_vecOrigin[1]"        "Float"
        "m_vecOrigin[2]"        "Float"
    }
    "DT_TEMuzzleFlash"
    {
        "m_vecOrigin"       "Vector"
        "m_vecAngles"       "Vector"
        "m_flScale"     "Float"
        "m_nType"       "Int"
    }
    "DT_TELargeFunnel"
    {
        "m_nModelIndex"     "Int"
        "m_nReversed"       "Int"
    }
    "DT_TEKillPlayerAttachments"
    {
        "m_nPlayer"     "Int"
    }
    "DT_TEImpact"
    {
        "m_vecOrigin"       "Vector"
        "m_vecNormal"       "Vector"
        "m_iType"       "Int"
        "m_ucFlags"     "Int"
    }
    "DT_TEGlowSprite"
    {
        "m_vecOrigin"       "Vector"
        "m_nModelIndex"     "Int"
        "m_fScale"      "Float"
        "m_fLife"       "Float"
        "m_nBrightness"     "Int"
    }
    "DT_TEShatterSurface"
    {
        "m_vecOrigin"       "Vector"
        "m_vecAngles"       "Vector"
        "m_vecForce"        "Vector"
        "m_vecForcePos"     "Vector"
        "m_flWidth"     "Float"
        "m_flHeight"        "Float"
        "m_flShardSize"     "Float"
        "m_nSurfaceType"        "Int"
        "m_uchFrontColor[0]"        "Int"
        "m_uchFrontColor[1]"        "Int"
        "m_uchFrontColor[2]"        "Int"
        "m_uchBackColor[0]"     "Int"
        "m_uchBackColor[1]"     "Int"
        "m_uchBackColor[2]"     "Int"
    }
    "DT_TEFootprintDecal"
    {
        "m_vecOrigin"       "Vector"
        "m_vecDirection"        "Vector"
        "m_nEntity"     "Int"
        "m_nIndex"      "Int"
        "m_chMaterialType"      "Int"
    }
    "DT_TEFizz"
    {
        "m_nEntity"     "Int"
        "m_nModelIndex"     "Int"
        "m_nDensity"        "Int"
        "m_nCurrent"        "Int"
    }
    "DT_TEExplosion"
    {
        "m_nModelIndex"     "Int"
        "m_fScale"      "Float"
        "m_nFrameRate"      "Int"
        "m_nFlags"      "Int"
        "m_vecNormal"       "Vector"
        "m_chMaterialType"      "Int"
        "m_nRadius"     "Int"
        "m_nMagnitude"      "Int"
    }
    "DT_TEEnergySplash"
    {
        "m_vecPos"      "Vector"
        "m_vecDir"      "Vector"
        "m_bExplosive"      "Int"
    }
    "DT_TEEffectDispatch"
    {
        "m_EffectData"
        {
            "m_vOrigin[0]"      "Float"
            "m_vOrigin[1]"      "Float"
            "m_vOrigin[2]"      "Float"
            "m_vStart[0]"       "Float"
            "m_vStart[1]"       "Float"
            "m_vStart[2]"       "Float"
            "m_vAngles"     "Vector"
            "m_vNormal"     "Vector"
            "m_fFlags"      "Int"
            "m_flMagnitude"     "Float"
            "m_flScale"     "Float"
            "m_nAttachmentIndex"        "Int"
            "m_nSurfaceProp"        "Int"
            "m_iEffectName"     "Int"
            "m_nMaterial"       "Int"
            "m_nDamageType"     "Int"
            "m_nHitBox"     "Int"
            "entindex"      "Int"
            "m_nColor"      "Int"
            "m_flRadius"        "Float"
            "m_bCustomColors"       "Int"
            "m_CustomColors.m_vecColor1"        "Vector"
            "m_CustomColors.m_vecColor2"        "Vector"
            "m_bControlPoint1"      "Int"
            "m_ControlPoint1.m_eParticleAttachment"     "Int"
            "m_ControlPoint1.m_vecOffset[0]"        "Float"
            "m_ControlPoint1.m_vecOffset[1]"        "Float"
            "m_ControlPoint1.m_vecOffset[2]"        "Float"
        }
    }
    "DT_TEDynamicLight"
    {
        "m_vecOrigin"       "Vector"
        "r"     "Int"
        "g"     "Int"
        "B"     "Int"
        "exponent"      "Int"
        "m_fRadius"     "Float"
        "m_fTime"       "Float"
        "m_fDecay"      "Float"
    }
    "DT_TEDecal"
    {
        "m_vecOrigin"       "Vector"
        "m_vecStart"        "Vector"
        "m_nEntity"     "Int"
        "m_nHitBox"     "Int"
        "m_nIndex"      "Int"
    }
    "DT_TEClientProjectile"
    {
        "m_vecOrigin"       "Vector"
        "m_vecVelocity"     "Vector"
        "m_nModelIndex"     "Int"
        "m_nLifeTime"       "Int"
        "m_hOwner"      "Int"
    }
    "DT_TEBubbleTrail"
    {
        "m_vecMins"     "Vector"
        "m_vecMaxs"     "Vector"
        "m_nModelIndex"     "Int"
        "m_flWaterZ"        "Float"
        "m_nCount"      "Int"
        "m_fSpeed"      "Float"
    }
    "DT_TEBubbles"
    {
        "m_vecMins"     "Vector"
        "m_vecMaxs"     "Vector"
        "m_nModelIndex"     "Int"
        "m_fHeight"     "Float"
        "m_nCount"      "Int"
        "m_fSpeed"      "Float"
    }
    "DT_TEBSPDecal"
    {
        "m_vecOrigin"       "Vector"
        "m_nEntity"     "Int"
        "m_nIndex"      "Int"
    }
    "DT_TEBreakModel"
    {
        "m_vecOrigin"       "Vector"
        "m_angRotation[0]"      "Float"
        "m_angRotation[1]"      "Float"
        "m_angRotation[2]"      "Float"
        "m_vecSize"     "Vector"
        "m_vecVelocity"     "Vector"
        "m_nModelIndex"     "Int"
        "m_nRandomization"      "Int"
        "m_nCount"      "Int"
        "m_fTime"       "Float"
        "m_nFlags"      "Int"
    }
    "DT_TEBloodStream"
    {
        "m_vecDirection"        "Vector"
        "r"     "Int"
        "g"     "Int"
        "B"     "Int"
        "a"     "Int"
        "m_nAmount"     "Int"
    }
    "DT_TEBloodSprite"
    {
        "m_vecOrigin"       "Vector"
        "m_vecDirection"        "Vector"
        "r"     "Int"
        "g"     "Int"
        "B"     "Int"
        "a"     "Int"
        "m_nSprayModel"     "Int"
        "m_nDropModel"      "Int"
        "m_nSize"       "Int"
    }
    "DT_TEBeamSpline"
    {
        "m_nPoints"     "Int"
        "m_vecPoints[0]"        "Vector"
        "m_vecPoints"       "Array"
    }
    "DT_TEBeamRingPoint"
    {
        "m_vecCenter"       "Vector"
        "m_flStartRadius"       "Float"
        "m_flEndRadius"     "Float"
    }
    "DT_TEBeamRing"
    {
        "m_nStartEntity"        "Int"
        "m_nEndEntity"      "Int"
    }
    "DT_TEBeamPoints"
    {
        "m_vecStartPoint"       "Vector"
        "m_vecEndPoint"     "Vector"
    }
    "DT_TEBeamLaser"
    {
        "m_nStartEntity"        "Int"
        "m_nEndEntity"      "Int"
    }
    "DT_TEBeamFollow"
    {
        "m_iEntIndex"       "Int"
    }
    "DT_TEBeamEnts"
    {
        "m_nStartEntity"        "Int"
        "m_nEndEntity"      "Int"
    }
    "DT_TEBeamEntPoint"
    {
        "m_nStartEntity"        "Int"
        "m_nEndEntity"      "Int"
        "m_vecStartPoint"       "Vector"
        "m_vecEndPoint"     "Vector"
    }
    "DT_BaseBeam"
    {
        "m_nModelIndex"     "Int"
        "m_nHaloIndex"      "Int"
        "m_nStartFrame"     "Int"
        "m_nFrameRate"      "Int"
        "m_fLife"       "Float"
        "m_fWidth"      "Float"
        "m_fEndWidth"       "Float"
        "m_nFadeLength"     "Int"
        "m_fAmplitude"      "Float"
        "m_nSpeed"      "Int"
        "r"     "Int"
        "g"     "Int"
        "B"     "Int"
        "a"     "Int"
        "m_nFlags"      "Int"
    }
    "DT_TEMetalSparks"
    {
        "m_vecPos"      "Vector"
        "m_vecDir"      "Vector"
    }
    "DT_SteamJet"
    {
        "m_SpreadSpeed"     "Float"
        "m_Speed"       "Float"
        "m_StartSize"       "Float"
        "m_EndSize"     "Float"
        "m_Rate"        "Float"
        "m_JetLength"       "Float"
        "m_bEmit"       "Int"
        "m_bFaceLeft"       "Int"
        "m_nType"       "Int"
        "m_spawnflags"      "Int"
        "m_flRollSpeed"     "Float"
    }
    "DT_SmokeStack"
    {
        "m_SpreadSpeed"     "Float"
        "m_Speed"       "Float"
        "m_StartSize"       "Float"
        "m_EndSize"     "Float"
        "m_Rate"        "Float"
        "m_JetLength"       "Float"
        "m_bEmit"       "Int"
        "m_flBaseSpread"        "Float"
        "m_flTwist"     "Float"
        "m_flRollSpeed"     "Float"
        "m_iMaterialModel"      "Int"
        "m_AmbientLight.m_vPos"     "Vector"
        "m_AmbientLight.m_vColor"       "Vector"
        "m_AmbientLight.m_flIntensity"      "Float"
        "m_DirLight.m_vPos"     "Vector"
        "m_DirLight.m_vColor"       "Vector"
        "m_DirLight.m_flIntensity"      "Float"
        "m_vWind"       "Vector"
    }
    "DT_DustTrail"
    {
        "m_SpawnRate"       "Float"
        "m_Color"       "Vector"
        "m_ParticleLifetime"        "Float"
        "m_StopEmitTime"        "Float"
        "m_MinSpeed"        "Float"
        "m_MaxSpeed"        "Float"
        "m_MinDirectedSpeed"        "Float"
        "m_MaxDirectedSpeed"        "Float"
        "m_StartSize"       "Float"
        "m_EndSize"     "Float"
        "m_SpawnRadius"     "Float"
        "m_bEmit"       "Int"
        "m_Opacity"     "Float"
    }
    "DT_FireTrail"
    {
        "m_nAttachment"     "Int"
        "m_flLifetime"      "Float"
    }
    "DT_SporeTrail"
    {
        "m_flSpawnRate"     "Float"
        "m_vecEndColor"     "Vector"
        "m_flParticleLifetime"      "Float"
        "m_flStartSize"     "Float"
        "m_flEndSize"       "Float"
        "m_flSpawnRadius"       "Float"
        "m_bEmit"       "Int"
    }
    "DT_SporeExplosion"
    {
        "m_flSpawnRate"     "Float"
        "m_flParticleLifetime"      "Float"
        "m_flStartSize"     "Float"
        "m_flEndSize"       "Float"
        "m_flSpawnRadius"       "Float"
        "m_bEmit"       "Int"
        "m_bDontRemove"     "Int"
    }
    "DT_RocketTrail"
    {
        "m_SpawnRate"       "Float"
        "m_StartColor"      "Vector"
        "m_EndColor"        "Vector"
        "m_ParticleLifetime"        "Float"
        "m_StopEmitTime"        "Float"
        "m_MinSpeed"        "Float"
        "m_MaxSpeed"        "Float"
        "m_StartSize"       "Float"
        "m_EndSize"     "Float"
        "m_SpawnRadius"     "Float"
        "m_bEmit"       "Int"
        "m_nAttachment"     "Int"
        "m_Opacity"     "Float"
        "m_bDamaged"        "Int"
        "m_flFlareScale"        "Float"
    }
    "DT_SmokeTrail"
    {
        "m_SpawnRate"       "Float"
        "m_StartColor"      "Vector"
        "m_EndColor"        "Vector"
        "m_ParticleLifetime"        "Float"
        "m_StopEmitTime"        "Float"
        "m_MinSpeed"        "Float"
        "m_MaxSpeed"        "Float"
        "m_MinDirectedSpeed"        "Float"
        "m_MaxDirectedSpeed"        "Float"
        "m_StartSize"       "Float"
        "m_EndSize"     "Float"
        "m_SpawnRadius"     "Float"
        "m_bEmit"       "Int"
        "m_nAttachment"     "Int"
        "m_Opacity"     "Float"
    }
    "DT_PropVehicleDriveable"
    {
        "m_hPlayer"     "Int"
        "m_nSpeed"      "Int"
        "m_nRPM"        "Int"
        "m_flThrottle"      "Float"
        "m_nBoostTimeLeft"      "Int"
        "m_nHasBoost"       "Int"
        "m_nScannerDisabledWeapons"     "Int"
        "m_nScannerDisabledVehicle"     "Int"
        "m_bEnterAnimOn"        "Int"
        "m_bExitAnimOn"     "Int"
        "m_bUnableToFire"       "Int"
        "m_vecEyeExitEndpoint"      "Vector"
        "m_bHasGun"     "Int"
        "m_vecGunCrosshair"     "Vector"
    }
    "DT_ParticleSmokeGrenade"
    {
        "m_flSpawnTime"     "Float"
        "m_FadeStartTime"       "Float"
        "m_FadeEndTime"     "Float"
        "m_CurrentStage"        "Int"
    }
    "DT_ParticleFire"
    {
        "m_vOrigin"     "Vector"
        "m_vDirection"      "Vector"
    }
    "DT_TEGaussExplosion"
    {
        "m_nType"       "Int"
        "m_vecDirection"        "Vector"
    }
    "DT_QuadraticBeam"
    {
        "m_targetPosition"      "Vector"
        "m_controlPosition"     "Vector"
        "m_scrollRate"      "Float"
        "m_flWidth"     "Float"
    }
    "DT_Embers"
    {
        "m_nDensity"        "Int"
        "m_nLifeTime"       "Int"
        "m_nSpeed"      "Int"
        "m_bEmit"       "Int"
    }
    "DT_EnvWind"
    {
        "m_EnvWindShared"
        {
            "m_iMinWind"        "Int"
            "m_iMaxWind"        "Int"
            "m_iMinGust"        "Int"
            "m_iMaxGust"        "Int"
            "m_flMinGustDelay"      "Float"
            "m_flMaxGustDelay"      "Float"
            "m_iGustDirChange"      "Int"
            "m_iWindSeed"       "Int"
            "m_iInitialWindDir"     "Int"
            "m_flInitialWindSpeed"      "Float"
            "m_flStartTime"     "Float"
            "m_flGustDuration"      "Float"
        }
    }
    "DT_Precipitation"
    {
        "m_nPrecipType"     "Int"
    }
    "DT_WeaponIFMBaseCamera"
    {
        "m_flRenderAspectRatio"     "Float"
        "m_flRenderFOV"     "Float"
        "m_flRenderArmLength"       "Float"
        "m_vecRenderPosition"       "Vector"
        "m_angRenderAngles"     "Vector"
    }
    "DT_TFWearable"
    {
        "m_bDisguiseWearable"       "Int"
        "m_hWeaponAssociatedWith"       "Int"
    }
    "DT_BaseAttributableItem"
    {
        "m_AttributeManager"
        {
            "m_hOuter"      "Int"
            "m_ProviderType"        "Int"
            "m_iReapplyProvisionParity"     "Int"
            "m_Item"
            {
                "m_iItemDefinitionIndex"        "Int"
                "m_iEntityLevel"        "Int"
                "m_iItemIDHigh"     "Int"
                "m_iItemIDLow"      "Int"
                "m_iAccountID"      "Int"
                "m_iEntityQuality"      "Int"
                "m_bInitialized"        "Int"
                "m_bOnlyIterateItemViewAttributes"      "Int"
                "m_AttributeList"
                {
                    "m_Attributes"
                    {
                        "lengthproxy"
                        {
                            "lengthprop20"      "Int"
                        }
                    }
                }
                "m_iTeamNumber"     "Int"
                "m_NetworkedDynamicAttributesForDemos"
                {
                    "m_Attributes"
                    {
                        "lengthproxy"
                        {
                            "lengthprop20"      "Int"
                        }
                    }
                }
            }
        }
    }
    "DT_EconEntity"
    {
        "m_AttributeManager"
        {
            "m_hOuter"      "Int"
            "m_ProviderType"        "Int"
            "m_iReapplyProvisionParity"     "Int"
            "m_Item"
            {
                "m_iItemDefinitionIndex"        "Int"
                "m_iEntityLevel"        "Int"
                "m_iItemIDHigh"     "Int"
                "m_iItemIDLow"      "Int"
                "m_iAccountID"      "Int"
                "m_iEntityQuality"      "Int"
                "m_bInitialized"        "Int"
                "m_bOnlyIterateItemViewAttributes"      "Int"
                "m_AttributeList"
                {
                    "m_Attributes"
                    {
                        "lengthproxy"
                        {
                            "lengthprop20"      "Int"
                        }
                    }
                }
                "m_iTeamNumber"     "Int"
                "m_NetworkedDynamicAttributesForDemos"
                {
                    "m_Attributes"
                    {
                        "lengthproxy"
                        {
                            "lengthprop20"      "Int"
                        }
                    }
                }
            }
        }
        "m_bValidatedAttachedEntity"        "Int"
    }
    "DT_HandleTest"
    {
        "m_Handle"      "Int"
        "m_bSendHandle"     "Int"
    }
    "DT_TeamplayRoundBasedRulesProxy"
    {
        "teamplayroundbased_gamerules_data"
        {
            "m_iRoundState"     "Int"
            "m_bInWaitingForPlayers"        "Int"
            "m_iWinningTeam"        "Int"
            "m_bInOvertime"     "Int"
            "m_bInSetup"        "Int"
            "m_bSwitchedTeamsThisRound"     "Int"
            "m_bAwaitingReadyRestart"       "Int"
            "m_flRestartRoundTime"      "Float"
            "m_flMapResetTime"      "Float"
            "m_nRoundsPlayed"       "Int"
            "m_flNextRespawnWave"       "DataTable"
            "m_TeamRespawnWaveTimes"        "DataTable"
            "m_bTeamReady"      "DataTable"
            "m_bStopWatch"      "Int"
            "m_bMultipleTrains"     "Int"
            "m_bPlayerReady"        "DataTable"
            "m_bCheatsEnabledDuringLevel"       "Int"
            "m_flCountdownTime"     "Float"
            "m_flStateTransitionTime"       "Float"
        }
    }
    "DT_TeamRoundTimer"
    {
        "m_bTimerPaused"        "Int"
        "m_flTimeRemaining"     "Float"
        "m_flTimerEndTime"      "Float"
        "m_nTimerMaxLength"     "Int"
        "m_bIsDisabled"     "Int"
        "m_bShowInHUD"      "Int"
        "m_nTimerLength"        "Int"
        "m_nTimerInitialLength"     "Int"
        "m_bAutoCountdown"      "Int"
        "m_nSetupTimeLength"        "Int"
        "m_nState"      "Int"
        "m_bStartPaused"        "Int"
        "m_bShowTimeRemaining"      "Int"
        "m_bInCaptureWatchState"        "Int"
        "m_bStopWatchTimer"     "Int"
        "m_flTotalTime"     "Float"
    }
    "DT_SpriteTrail"
    {
        "m_flLifetime"      "Float"
        "m_flStartWidth"        "Float"
        "m_flEndWidth"      "Float"
        "m_flStartWidthVariance"        "Float"
        "m_flTextureRes"        "Float"
        "m_flMinFadeLength"     "Float"
        "m_vecSkyboxOrigin"     "Vector"
        "m_flSkyboxScale"       "Float"
    }
    "DT_Sprite"
    {
        "m_hAttachedToEntity"       "Int"
        "m_nAttachment"     "Int"
        "m_flScaleTime"     "Float"
        "m_flSpriteScale"       "Float"
        "m_flSpriteFramerate"       "Float"
        "m_flGlowProxySize"     "Float"
        "m_flHDRColorScale"     "Float"
        "m_flFrame"     "Float"
        "m_flBrightnessTime"        "Float"
        "m_nBrightness"     "Int"
        "m_bWorldSpaceScale"        "Int"
    }
    "DT_Ragdoll_Attached"
    {
        "m_boneIndexAttached"       "Int"
        "m_ragdollAttachedObjectIndex"      "Int"
        "m_attachmentPointBoneSpace"        "Vector"
        "m_attachmentPointRagdollSpace"     "Vector"
    }
    "DT_Ragdoll"
    {
        "m_ragAngles[0]"        "Vector"
        "m_ragAngles"       "Array"
        "m_ragPos[0]"       "Vector"
        "m_ragPos"      "Array"
        "m_hUnragdoll"      "Int"
        "m_flBlendWeight"       "Float"
        "m_nOverlaySequence"        "Int"
    }
    "DT_PoseController"
    {
        "m_hProps"      "DataTable"
        "m_chPoseIndex"     "DataTable"
        "m_bPoseValueParity"        "Int"
        "m_fPoseValue"      "Float"
        "m_fInterpolationTime"      "Float"
        "m_bInterpolationWrap"      "Int"
        "m_fCycleFrequency"     "Float"
        "m_nFModType"       "Int"
        "m_fFModTimeOffset"     "Float"
        "m_fFModRate"       "Float"
        "m_fFModAmplitude"      "Float"
    }
    "DT_FuncLadder"
    {
        "m_vecPlayerMountPositionTop"       "Vector"
        "m_vecPlayerMountPositionBottom"        "Vector"
        "m_vecLadderDir"        "Vector"
        "m_bFakeLadder"     "Int"
    }
    "DT_DetailController"
    {
        "m_flFadeStartDist"     "Float"
        "m_flFadeEndDist"       "Float"
    }
    "DT_World"
    {
        "m_flWaveHeight"        "Float"
        "m_WorldMins"       "Vector"
        "m_WorldMaxs"       "Vector"
        "m_bStartDark"      "Int"
        "m_flMaxOccludeeArea"       "Float"
        "m_flMinOccluderArea"       "Float"
        "m_flMaxPropScreenSpaceWidth"       "Float"
        "m_flMinPropScreenSpaceWidth"       "Float"
        "m_iszDetailSpriteMaterial"     "String"
        "m_bColdWorld"      "Int"
    }
    "DT_WaterLODControl"
    {
        "m_flCheapWaterStartDistance"       "Float"
        "m_flCheapWaterEndDistance"     "Float"
    }
    "DT_VoteController"
    {
        "m_iActiveIssueIndex"       "Int"
        "m_nVoteIdx"        "Int"
        "m_iOnlyTeamToVote"     "Int"
        "m_nVoteOptionCount"        "DataTable"
        "m_nPotentialVotes"     "Int"
        "m_bIsYesNoVote"        "Int"
    }
    "DT_VGuiScreen"
    {
        "m_flWidth"     "Float"
        "m_flHeight"        "Float"
        "m_fScreenFlags"        "Int"
        "m_nPanelName"      "Int"
        "m_nAttachmentIndex"        "Int"
        "m_nOverlayMaterial"        "Int"
        "m_hPlayerOwner"        "Int"
    }
    "DT_PropJeep"
    {
        "m_bHeadlightIsOn"      "Int"
    }
    "DT_PropVehicleChoreoGeneric"
    {
        "m_hPlayer"     "Int"
        "m_bEnterAnimOn"        "Int"
        "m_bExitAnimOn"     "Int"
        "m_vecEyeExitEndpoint"      "Vector"
        "m_vehicleView.bClampEyeAngles"     "Int"
        "m_vehicleView.flPitchCurveZero"        "Float"
        "m_vehicleView.flPitchCurveLinear"      "Float"
        "m_vehicleView.flRollCurveZero"     "Float"
        "m_vehicleView.flRollCurveLinear"       "Float"
        "m_vehicleView.flFOV"       "Float"
        "m_vehicleView.flYawMin"        "Float"
        "m_vehicleView.flYawMax"        "Float"
        "m_vehicleView.flPitchMin"      "Float"
        "m_vehicleView.flPitchMax"      "Float"
    }
    "DT_ProxyToggle"
    {
        "blah"
        {
            "m_WithProxy"       "Int"
        }
    }
    "DT_Tesla"
    {
        "m_SoundName"       "String"
        "m_iszSpriteName"       "String"
    }
    "DT_TeamTrainWatcher"
    {
        "m_flTotalProgress"     "Float"
        "m_iTrainSpeedLevel"        "Int"
        "m_flRecedeTime"        "Float"
        "m_nNumCappers"     "Int"
        "m_hGlowEnt"        "Int"
    }
    "DT_BaseTeamObjectiveResource"
    {
        "m_iTimerToShowInHUD"       "Int"
        "m_iStopWatchTimer"     "Int"
        "m_iNumControlPoints"       "Int"
        "m_bPlayingMiniRounds"      "Int"
        "m_bControlPointsReset"     "Int"
        "m_iUpdateCapHudParity"     "Int"
        "m_vCPPositions[0]"     "Vector"
        "m_vCPPositions"        "Array"
        "m_bCPIsVisible"        "DataTable"
        "m_flLazyCapPerc"       "DataTable"
        "m_iTeamIcons"      "DataTable"
        "m_iTeamOverlays"       "DataTable"
        "m_iTeamReqCappers"     "DataTable"
        "m_flTeamCapTime"       "DataTable"
        "m_iPreviousPoints"     "DataTable"
        "m_bTeamCanCap"     "DataTable"
        "m_iTeamBaseIcons"      "DataTable"
        "m_iBaseControlPoints"      "DataTable"
        "m_bInMiniRound"        "DataTable"
        "m_iWarnOnCap"      "DataTable"
        "m_iszWarnSound[0]"     "String"
        "m_iszWarnSound"        "Array"
        "m_flPathDistance"      "DataTable"
        "m_iCPGroup"        "DataTable"
        "m_bCPLocked"       "DataTable"
        "m_nNumNodeHillData"        "DataTable"
        "m_flNodeHillData"      "DataTable"
        "m_bTrackAlarm"     "DataTable"
        "m_flUnlockTimes"       "DataTable"
        "m_bHillIsDownhill"     "DataTable"
        "m_flCPTimerTimes"      "DataTable"
        "m_iNumTeamMembers"     "DataTable"
        "m_iCappingTeam"        "DataTable"
        "m_iTeamInZone"     "DataTable"
        "m_bBlocked"        "DataTable"
        "m_iOwner"      "DataTable"
        "m_bCPCapRateScalesWithPlayers"     "DataTable"
        "m_pszCapLayoutInHUD"       "String"
        "m_flCustomPositionX"       "Float"
        "m_flCustomPositionY"       "Float"
    }
    "DT_Team"
    {
        "m_iTeamNum"        "Int"
        "m_iScore"      "Int"
        "m_iRoundsWon"      "Int"
        "m_szTeamname"      "String"
        "player_array_element"      "Int"
        "\"player_array\""      "Array"
    }
    "DT_Sun"
    {
        "m_clrRender"       "Int"
        "m_clrOverlay"      "Int"
        "m_vDirection"      "Vector"
        "m_bOn"     "Int"
        "m_nSize"       "Int"
        "m_nOverlaySize"        "Int"
        "m_nMaterial"       "Int"
        "m_nOverlayMaterial"        "Int"
        "HDRColorScale"     "Float"
    }
    "DT_ParticlePerformanceMonitor"
    {
        "m_bMeasurePerf"        "Int"
        "m_bDisplayPerf"        "Int"
    }
    "DT_SpotlightEnd"
    {
        "m_flLightScale"        "Float"
        "m_Radius"      "Float"
    }
    "DT_SlideshowDisplay"
    {
        "m_bEnabled"        "Int"
        "m_szDisplayText"       "String"
        "m_szSlideshowDirectory"        "String"
        "m_chCurrentSlideLists"     "DataTable"
        "m_fMinSlideTime"       "Float"
        "m_fMaxSlideTime"       "Float"
        "m_iCycleType"      "Int"
        "m_bNoListRepeats"      "Int"
    }
    "DT_ShadowControl"
    {
        "m_shadowDirection"     "Vector"
        "m_shadowColor"     "Int"
        "m_flShadowMaxDist"     "Float"
        "m_bDisableShadows"     "Int"
    }
    "DT_SceneEntity"
    {
        "m_nSceneStringIndex"       "Int"
        "m_bIsPlayingBack"      "Int"
        "m_bPaused"     "Int"
        "m_bMultiplayer"        "Int"
        "m_flForceClientTime"       "Float"
        "m_hActorList"
        {
            "lengthproxy"
            {
                "lengthprop16"      "Int"
            }
        }
    }
    "DT_RopeKeyframe"
    {
        "m_iRopeMaterialModelIndex"     "Int"
        "m_hStartPoint"     "Int"
        "m_hEndPoint"       "Int"
        "m_iStartAttachment"        "Int"
        "m_iEndAttachment"      "Int"
        "m_fLockedPoints"       "Int"
        "m_Slack"       "Int"
        "m_RopeLength"      "Int"
        "m_RopeFlags"       "Int"
        "m_TextureScale"        "Float"
        "m_nSegments"       "Int"
        "m_bConstrainBetweenEndpoints"      "Int"
        "m_Subdiv"      "Int"
        "m_Width"       "Float"
        "m_flScrollSpeed"       "Float"
        "m_vecOrigin"       "Vector"
        "moveparent"        "Int"
        "m_iParentAttachment"       "Int"
    }
    "DT_RagdollManager"
    {
        "m_iCurrentMaxRagdollCount"     "Int"
    }
    "DT_PhysicsPropMultiplayer"
    {
        "m_iPhysicsMode"        "Int"
        "m_fMass"       "Float"
        "m_collisionMins"       "Vector"
        "m_collisionMaxs"       "Vector"
    }
    "DT_PhysBoxMultiplayer"
    {
        "m_iPhysicsMode"        "Int"
        "m_fMass"       "Float"
    }
    "DT_DynamicProp"
    {
        "m_bUseHitboxesForRenderBox"        "Int"
    }
    "DT_PointWorldText"
    {
        "m_szText"      "String"
        "m_flTextSize"      "Float"
        "m_flTextSpacingX"      "Float"
        "m_flTextSpacingY"      "Float"
        "m_colTextColor"        "Int"
        "m_nOrientation"        "Int"
        "m_nFont"       "Int"
        "m_bRainbow"        "Int"
    }
    "DT_PointCommentaryNode"
    {
        "m_bActive"     "Int"
        "m_flStartTime"     "Float"
        "m_iszCommentaryFile"       "String"
        "m_iszCommentaryFileNoHDR"      "String"
        "m_iszSpeakers"     "String"
        "m_iNodeNumber"     "Int"
        "m_iNodeNumberMax"      "Int"
        "m_hViewPosition"       "Int"
    }
    "DT_PointCamera"
    {
        "m_FOV"     "Float"
        "m_Resolution"      "Float"
        "m_bFogEnable"      "Int"
        "m_FogColor"        "Int"
        "m_flFogStart"      "Float"
        "m_flFogEnd"        "Float"
        "m_flFogMaxDensity"     "Float"
        "m_bActive"     "Int"
        "m_bUseScreenAspectRatio"       "Int"
    }
    "DT_PlayerResource"
    {
        "m_iPing"       "DataTable"
        "m_iScore"      "DataTable"
        "m_iDeaths"     "DataTable"
        "m_bConnected"      "DataTable"
        "m_iTeam"       "DataTable"
        "m_bAlive"      "DataTable"
        "m_iHealth"     "DataTable"
        "m_iAccountID"      "DataTable"
        "m_bValid"      "DataTable"
        "m_iUserID"     "DataTable"
    }
    "DT_Plasma"
    {
        "m_flStartScale"        "Float"
        "m_flScale"     "Float"
        "m_flScaleTime"     "Float"
        "m_nFlags"      "Int"
        "m_nPlasmaModelIndex"       "Int"
        "m_nPlasmaModelIndex2"      "Int"
        "m_nGlowModelIndex"     "Int"
    }
    "DT_PhysicsProp"
    {
        "m_bAwake"      "Int"
    }
    "DT_PhysBox"
    {
        "m_mass"        "Float"
    }
    "DT_ParticleSystem"
    {
        "m_vecOrigin"       "Vector"
        "m_hOwnerEntity"        "Int"
        "moveparent"        "Int"
        "m_iParentAttachment"       "Int"
        "m_angRotation"     "Vector"
        "m_iEffectIndex"        "Int"
        "m_bActive"     "Int"
        "m_flStartTime"     "Float"
        "m_hControlPointEnts"       "DataTable"
        "m_iControlPointParents"        "DataTable"
        "m_bWeatherEffect"      "Int"
    }
    "DT_MaterialModifyControl"
    {
        "m_szMaterialName"      "String"
        "m_szMaterialVar"       "String"
        "m_szMaterialVarValue"      "String"
        "m_iFrameStart"     "Int"
        "m_iFrameEnd"       "Int"
        "m_bWrap"       "Int"
        "m_flFramerate"     "Float"
        "m_bNewAnimCommandsSemaphore"       "Int"
        "m_flFloatLerpStartValue"       "Float"
        "m_flFloatLerpEndValue"     "Float"
        "m_flFloatLerpTransitionTime"       "Float"
        "m_bFloatLerpWrap"      "Int"
        "m_nModifyMode"     "Int"
    }
    "DT_LightGlow"
    {
        "m_clrRender"       "Int"
        "m_nHorizontalSize"     "Int"
        "m_nVerticalSize"       "Int"
        "m_nMinDist"        "Int"
        "m_nMaxDist"        "Int"
        "m_nOuterMaxDist"       "Int"
        "m_spawnflags"      "Int"
        "m_vecOrigin"       "Vector"
        "m_angRotation"     "Vector"
        "moveparent"        "Int"
        "m_flGlowProxySize"     "Float"
        "HDRColorScale"     "Float"
    }
    "DT_InfoOverlayAccessor"
    {
        "m_iTextureFrameIndex"      "Int"
        "m_iOverlayID"      "Int"
    }
    "DT_FuncSmokeVolume"
    {
        "m_Color1"      "Int"
        "m_Color2"      "Int"
        "m_MaterialName"        "String"
        "m_ParticleDrawWidth"       "Float"
        "m_ParticleSpacingDistance"     "Float"
        "m_DensityRampSpeed"        "Float"
        "m_RotationSpeed"       "Float"
        "m_MovementSpeed"       "Float"
        "m_Density"     "Float"
        "m_spawnflags"      "Int"
        "m_Collision"
        {
            "m_vecMinsPreScaled"        "Vector"
            "m_vecMaxsPreScaled"        "Vector"
            "m_vecMins"     "Vector"
            "m_vecMaxs"     "Vector"
            "m_nSolidType"      "Int"
            "m_usSolidFlags"        "Int"
            "m_nSurroundType"       "Int"
            "m_triggerBloat"        "Int"
            "m_bUniformTriggerBloat"        "Int"
            "m_vecSpecifiedSurroundingMinsPreScaled"        "Vector"
            "m_vecSpecifiedSurroundingMaxsPreScaled"        "Vector"
            "m_vecSpecifiedSurroundingMins"     "Vector"
            "m_vecSpecifiedSurroundingMaxs"     "Vector"
        }
    }
    "DT_FuncRotating"
    {
        "m_vecOrigin"       "Vector"
        "m_angRotation[0]"      "Float"
        "m_angRotation[1]"      "Float"
        "m_angRotation[2]"      "Float"
        "m_flSimulationTime"        "Int"
    }
    "DT_FuncOccluder"
    {
        "m_bActive"     "Int"
        "m_nOccluderIndex"      "Int"
    }
    "DT_Func_LOD"
    {
        "m_fDisappearDist"      "Float"
    }
    "DT_TEDust"
    {
        "m_flSize"      "Float"
        "m_flSpeed"     "Float"
        "m_vecDirection"        "Vector"
    }
    "DT_Func_Dust"
    {
        "m_Color"       "Int"
        "m_SpawnRate"       "Int"
        "m_flSizeMin"       "Float"
        "m_flSizeMax"       "Float"
        "m_LifetimeMin"     "Int"
        "m_LifetimeMax"     "Int"
        "m_DustFlags"       "Int"
        "m_SpeedMax"        "Int"
        "m_DistMax"     "Int"
        "m_nModelIndex"     "Int"
        "m_FallSpeed"       "Float"
        "m_Collision"
        {
            "m_vecMinsPreScaled"        "Vector"
            "m_vecMaxsPreScaled"        "Vector"
            "m_vecMins"     "Vector"
            "m_vecMaxs"     "Vector"
            "m_nSolidType"      "Int"
            "m_usSolidFlags"        "Int"
            "m_nSurroundType"       "Int"
            "m_triggerBloat"        "Int"
            "m_bUniformTriggerBloat"        "Int"
            "m_vecSpecifiedSurroundingMinsPreScaled"        "Vector"
            "m_vecSpecifiedSurroundingMaxsPreScaled"        "Vector"
            "m_vecSpecifiedSurroundingMins"     "Vector"
            "m_vecSpecifiedSurroundingMaxs"     "Vector"
        }
    }
    "DT_FuncConveyor"
    {
        "m_flConveyorSpeed"     "Float"
    }
    "DT_BreakableSurface"
    {
        "m_nNumWide"        "Int"
        "m_nNumHigh"        "Int"
        "m_flPanelWidth"        "Float"
        "m_flPanelHeight"       "Float"
        "m_vNormal"     "Vector"
        "m_vCorner"     "Vector"
        "m_bIsBroken"       "Int"
        "m_nSurfaceType"        "Int"
        "m_RawPanelBitVec"      "DataTable"
    }
    "DT_FuncAreaPortalWindow"
    {
        "m_flFadeStartDist"     "Float"
        "m_flFadeDist"      "Float"
        "m_flTranslucencyLimit"     "Float"
        "m_iBackgroundModelIndex"       "Int"
    }
    "DT_CFish"
    {
        "m_poolOrigin"      "Vector"
        "m_x"       "Float"
        "m_y"       "Float"
        "m_z"       "Float"
        "m_angle"       "Float"
        "m_nModelIndex"     "Int"
        "m_lifeState"       "Int"
        "m_waterLevel"      "Float"
    }
    "DT_EntityFlame"
    {
        "m_hEntAttached"        "Int"
    }
    "DT_FireSmoke"
    {
        "m_flStartScale"        "Float"
        "m_flScale"     "Float"
        "m_flScaleTime"     "Float"
        "m_nFlags"      "Int"
        "m_nFlameModelIndex"        "Int"
        "m_nFlameFromAboveModelIndex"       "Int"
    }
    "DT_EnvTonemapController"
    {
        "m_bUseCustomAutoExposureMin"       "Int"
        "m_bUseCustomAutoExposureMax"       "Int"
        "m_bUseCustomBloomScale"        "Int"
        "m_flCustomAutoExposureMin"     "Float"
        "m_flCustomAutoExposureMax"     "Float"
        "m_flCustomBloomScale"      "Float"
        "m_flCustomBloomScaleMinimum"       "Float"
    }
    "DT_EnvScreenEffect"
    {
        "m_flDuration"      "Float"
        "m_nType"       "Int"
    }
    "DT_EnvScreenOverlay"
    {
        "m_iszOverlayNames[0]"      "String"
        "m_iszOverlayNames"     "Array"
        "m_flOverlayTimes[0]"       "Float"
        "m_flOverlayTimes"      "Array"
        "m_flStartTime"     "Float"
        "m_iDesiredOverlay"     "Int"
        "m_bIsActive"       "Int"
    }
    "DT_EnvProjectedTexture"
    {
        "m_hTargetEntity"       "Int"
        "m_bState"      "Int"
        "m_flLightFOV"      "Float"
        "m_bEnableShadows"      "Int"
        "m_bLightOnlyTarget"        "Int"
        "m_bLightWorld"     "Int"
        "m_bCameraSpace"        "Int"
        "m_LinearFloatLightColor"       "Vector"
        "m_flAmbient"       "Float"
        "m_SpotlightTextureName"        "String"
        "m_nSpotlightTextureFrame"      "Int"
        "m_flNearZ"     "Float"
        "m_flFarZ"      "Float"
        "m_nShadowQuality"      "Int"
    }
    "DT_EnvParticleScript"
    {
        "m_flSequenceScale"     "Float"
    }
    "DT_FogController"
    {
        "m_fog.enable"      "Int"
        "m_fog.blend"       "Int"
        "m_fog.dirPrimary"      "Vector"
        "m_fog.colorPrimary"        "Int"
        "m_fog.colorSecondary"      "Int"
        "m_fog.start"       "Float"
        "m_fog.end"     "Float"
        "m_fog.farz"        "Float"
        "m_fog.maxdensity"      "Float"
        "m_fog.colorPrimaryLerpTo"      "Int"
        "m_fog.colorSecondaryLerpTo"        "Int"
        "m_fog.startLerpTo"     "Float"
        "m_fog.endLerpTo"       "Float"
        "m_fog.lerptime"        "Float"
        "m_fog.duration"        "Float"
    }
    "DT_EntityParticleTrail"
    {
        "m_iMaterialName"       "Int"
        "m_Info"
        {
            "m_flLifetime"      "Float"
            "m_flStartSize"     "Float"
            "m_flEndSize"       "Float"
        }
        "m_hConstraintEntity"       "Int"
    }
    "DT_EntityDissolve"
    {
        "m_flStartTime"     "Float"
        "m_flFadeOutStart"      "Float"
        "m_flFadeOutLength"     "Float"
        "m_flFadeOutModelStart"     "Float"
        "m_flFadeOutModelLength"        "Float"
        "m_flFadeInStart"       "Float"
        "m_flFadeInLength"      "Float"
        "m_nDissolveType"       "Int"
        "m_vDissolverOrigin"        "Vector"
        "m_nMagnitude"      "Int"
    }
    "DT_DynamicLight"
    {
        "m_Flags"       "Int"
        "m_LightStyle"      "Int"
        "m_Radius"      "Float"
        "m_Exponent"        "Int"
        "m_InnerAngle"      "Float"
        "m_OuterAngle"      "Float"
        "m_SpotRadius"      "Float"
    }
    "DT_ColorCorrectionVolume"
    {
        "m_Weight"      "Float"
        "m_lookupFilename"      "String"
    }
    "DT_ColorCorrection"
    {
        "m_vecOrigin"       "Vector"
        "m_minFalloff"      "Float"
        "m_maxFalloff"      "Float"
        "m_flCurWeight"     "Float"
        "m_netLookupFilename"       "String"
        "m_bEnabled"        "Int"
    }
    "DT_BasePlayer"
    {
        "localdata"
        {
            "m_Local"
            {
                "m_chAreaBits"      "DataTable"
                "m_chAreaPortalBits"        "DataTable"
                "m_iHideHUD"        "Int"
                "m_flFOVRate"       "Float"
                "m_bDucked"     "Int"
                "m_bDucking"        "Int"
                "m_bInDuckJump"     "Int"
                "m_flDucktime"      "Float"
                "m_flDuckJumpTime"      "Float"
                "m_flJumpTime"      "Float"
                "m_flFallVelocity"      "Float"
                "m_vecPunchAngle"       "Vector"
                "m_vecPunchAngleVel"        "Vector"
                "m_bDrawViewmodel"      "Int"
                "m_bWearingSuit"        "Int"
                "m_bPoisoned"       "Int"
                "m_bForceLocalPlayerDraw"       "Int"
                "m_flStepSize"      "Float"
                "m_bAllowAutoMovement"      "Int"
                "m_skybox3d.scale"      "Int"
                "m_skybox3d.origin"     "Vector"
                "m_skybox3d.area"       "Int"
                "m_skybox3d.fog.enable"     "Int"
                "m_skybox3d.fog.blend"      "Int"
                "m_skybox3d.fog.dirPrimary"     "Vector"
                "m_skybox3d.fog.colorPrimary"       "Int"
                "m_skybox3d.fog.colorSecondary"     "Int"
                "m_skybox3d.fog.start"      "Float"
                "m_skybox3d.fog.end"        "Float"
                "m_skybox3d.fog.maxdensity"     "Float"
                "m_PlayerFog.m_hCtrl"       "Int"
                "m_audio.localSound[0]"     "Vector"
                "m_audio.localSound[1]"     "Vector"
                "m_audio.localSound[2]"     "Vector"
                "m_audio.localSound[3]"     "Vector"
                "m_audio.localSound[4]"     "Vector"
                "m_audio.localSound[5]"     "Vector"
                "m_audio.localSound[6]"     "Vector"
                "m_audio.localSound[7]"     "Vector"
                "m_audio.soundscapeIndex"       "Int"
                "m_audio.localBits"     "Int"
                "m_audio.entIndex"      "Int"
                "m_szScriptOverlayMaterial"     "String"
            }
            "m_vecViewOffset[0]"        "Float"
            "m_vecViewOffset[1]"        "Float"
            "m_vecViewOffset[2]"        "Float"
            "m_flFriction"      "Float"
            "m_iAmmo"       "DataTable"
            "m_fOnTarget"       "Int"
            "m_nTickBase"       "Int"
            "m_nNextThinkTick"      "Int"
            "m_hLastWeapon"     "Int"
            "m_hGroundEntity"       "Int"
            "m_vecVelocity[0]"      "Float"
            "m_vecVelocity[1]"      "Float"
            "m_vecVelocity[2]"      "Float"
            "m_vecBaseVelocity"     "Vector"
            "m_hConstraintEntity"       "Int"
            "m_vecConstraintCenter"     "Vector"
            "m_flConstraintRadius"      "Float"
            "m_flConstraintWidth"       "Float"
            "m_flConstraintSpeedFactor"     "Float"
            "m_flDeathTime"     "Float"
            "m_nWaterLevel"     "Int"
            "m_flLaggedMovementValue"       "Float"
        }
        "m_AttributeList"
        {
            "m_Attributes"
            {
                "lengthproxy"
                {
                    "lengthprop20"      "Int"
                }
            }
        }
        "pl"
        {
            "deadflag"      "Int"
        }
        "m_iFOV"        "Int"
        "m_iFOVStart"       "Int"
        "m_flFOVTime"       "Float"
        "m_iDefaultFOV"     "Int"
        "m_hZoomOwner"      "Int"
        "m_hVehicle"        "Int"
        "m_hUseEntity"      "Int"
        "m_iHealth"     "Int"
        "m_lifeState"       "Int"
        "m_iBonusProgress"      "Int"
        "m_iBonusChallenge"     "Int"
        "m_flMaxspeed"      "Float"
        "m_fFlags"      "Int"
        "m_iObserverMode"       "Int"
        "m_hObserverTarget"     "Int"
        "m_hViewModel[0]"       "Int"
        "m_hViewModel"      "Array"
        "m_szLastPlaceName"     "String"
        "m_hMyWearables"
        {
            "lengthproxy"
            {
                "lengthprop8"       "Int"
            }
        }
    }
    "DT_BaseFlex"
    {
        "m_flexWeight"      "DataTable"
        "m_blinktoggle"     "Int"
        "m_viewtarget"      "Vector"
    }
    "DT_BaseEntity"
    {
        "AnimTimeMustBeFirst"
        {
            "m_flAnimTime"      "Int"
        }
        "m_flSimulationTime"        "Int"
        "m_ubInterpolationFrame"        "Int"
        "m_vecOrigin"       "Vector"
        "m_angRotation"     "Vector"
        "m_nModelIndex"     "Int"
        "m_fEffects"        "Int"
        "m_nRenderMode"     "Int"
        "m_nRenderFX"       "Int"
        "m_clrRender"       "Int"
        "m_iTeamNum"        "Int"
        "m_CollisionGroup"      "Int"
        "m_flElasticity"        "Float"
        "m_flShadowCastDistance"        "Float"
        "m_hOwnerEntity"        "Int"
        "m_hEffectEntity"       "Int"
        "moveparent"        "Int"
        "m_iParentAttachment"       "Int"
        "movetype"      "Int"
        "movecollide"       "Int"
        "m_Collision"
        {
            "m_vecMinsPreScaled"        "Vector"
            "m_vecMaxsPreScaled"        "Vector"
            "m_vecMins"     "Vector"
            "m_vecMaxs"     "Vector"
            "m_nSolidType"      "Int"
            "m_usSolidFlags"        "Int"
            "m_nSurroundType"       "Int"
            "m_triggerBloat"        "Int"
            "m_bUniformTriggerBloat"        "Int"
            "m_vecSpecifiedSurroundingMinsPreScaled"        "Vector"
            "m_vecSpecifiedSurroundingMaxsPreScaled"        "Vector"
            "m_vecSpecifiedSurroundingMins"     "Vector"
            "m_vecSpecifiedSurroundingMaxs"     "Vector"
        }
        "m_iTextureFrameIndex"      "Int"
        "predictable_id"
        {
            "m_PredictableID"       "Int"
            "m_bIsPlayerSimulated"      "Int"
        }
        "m_bSimulatedEveryTick"     "Int"
        "m_bAnimatedEveryTick"      "Int"
        "m_bAlternateSorting"       "Int"
        "m_nModelIndexOverrides"        "DataTable"
    }
    "DT_BaseDoor"
    {
        "m_flWaveHeight"        "Float"
    }
    "DT_BaseCombatCharacter"
    {
        "bcc_localdata"
        {
            "m_flNextAttack"        "Float"
        }
        "m_hActiveWeapon"       "Int"
        "m_hMyWeapons"      "DataTable"
        "m_bGlowEnabled"        "Int"
    }
    "DT_BaseAnimatingOverlay"
    {
        "overlay_vars"
        {
            "m_AnimOverlay"
            {
                "lengthproxy"
                {
                    "lengthprop15"      "Int"
                }
            }
        }
    }
    "DT_BoneFollower"
    {
        "m_modelIndex"      "Int"
        "m_solidIndex"      "Int"
    }
    "DT_BaseAnimating"
    {
        "m_nSequence"       "Int"
        "m_nForceBone"      "Int"
        "m_vecForce"        "Vector"
        "m_nSkin"       "Int"
        "m_nBody"       "Int"
        "m_nHitboxSet"      "Int"
        "m_flModelScale"        "Float"
        "m_flModelWidthScale"       "Float"
        "m_flPoseParameter"     "DataTable"
        "m_flPlaybackRate"      "Float"
        "m_flEncodedController"     "DataTable"
        "m_bClientSideAnimation"        "Int"
        "m_bClientSideFrameReset"       "Int"
        "m_nNewSequenceParity"      "Int"
        "m_nResetEventsParity"      "Int"
        "m_nMuzzleFlashParity"      "Int"
        "m_hLightingOrigin"     "Int"
        "m_hLightingOriginRelative"     "Int"
        "serveranimdata"
        {
            "m_flCycle"     "Float"
        }
        "m_fadeMinDist"     "Float"
        "m_fadeMaxDist"     "Float"
        "m_flFadeScale"     "Float"
    }
    "DT_InfoLightingRelative"
    {
        "m_hLightingLandmark"       "Int"
    }
    "DT_AI_BaseNPC"
    {
        "m_lifeState"       "Int"
        "m_bPerformAvoidance"       "Int"
        "m_bIsMoving"       "Int"
        "m_bFadeCorpse"     "Int"
        "m_iDeathPose"      "Int"
        "m_iDeathFrame"     "Int"
        "m_iSpeedModRadius"     "Int"
        "m_iSpeedModSpeed"      "Int"
        "m_bSpeedModActive"     "Int"
        "m_bImportanRagdoll"        "Int"
        "m_flTimePingEffect"        "Float"
    }
    "DT_Beam"
    {
        "m_nBeamType"       "Int"
        "m_nBeamFlags"      "Int"
        "m_nNumBeamEnts"        "Int"
        "m_hAttachEntity"       "DataTable"
        "m_nAttachIndex"        "DataTable"
        "m_nHaloIndex"      "Int"
        "m_fHaloScale"      "Float"
        "m_fWidth"      "Float"
        "m_fEndWidth"       "Float"
        "m_fFadeLength"     "Float"
        "m_fAmplitude"      "Float"
        "m_fStartFrame"     "Float"
        "m_fSpeed"      "Float"
        "m_flFramerate"     "Float"
        "m_flHDRColorScale"     "Float"
        "m_clrRender"       "Int"
        "m_nRenderFX"       "Int"
        "m_nRenderMode"     "Int"
        "m_flFrame"     "Float"
        "m_vecEndPos"       "Vector"
        "m_nModelIndex"     "Int"
        "m_nMinDXLevel"     "Int"
        "m_vecOrigin"       "Vector"
        "moveparent"        "Int"
        "beampredictable_id"
        {
            "m_PredictableID"       "Int"
            "m_bIsPlayerSimulated"      "Int"
        }
    }
    "DT_BaseViewModel"
    {
        "m_nModelIndex"     "Int"
        "m_nSkin"       "Int"
        "m_nBody"       "Int"
        "m_nSequence"       "Int"
        "m_nViewModelIndex"     "Int"
        "m_flPlaybackRate"      "Float"
        "m_fEffects"        "Int"
        "m_nAnimationParity"        "Int"
        "m_hWeapon"     "Int"
        "m_hOwner"      "Int"
        "m_nNewSequenceParity"      "Int"
        "m_nResetEventsParity"      "Int"
        "m_nMuzzleFlashParity"      "Int"
        "m_flPoseParameter[0]"      "Float"
        "m_flPoseParameter"     "Array"
    }
    "DT_BaseProjectile"
    {
        "m_hOriginalLauncher"       "Int"
    }
    "DT_BaseGrenade"
    {
        "m_flDamage"        "Float"
        "m_DmgRadius"       "Float"
        "m_bIsLive"     "Int"
        "m_hThrower"        "Int"
        "m_vecVelocity"     "Vector"
        "m_fFlags"      "Int"
    }
    "DT_BaseCombatWeapon"
    {
        "LocalWeaponData"
        {
            "m_iClip1"      "Int"
            "m_iClip2"      "Int"
            "m_iPrimaryAmmoType"        "Int"
            "m_iSecondaryAmmoType"      "Int"
            "m_nViewModelIndex"     "Int"
            "m_nCustomViewmodelModelIndex"      "Int"
            "m_bFlipViewModel"      "Int"
        }
        "LocalActiveWeaponData"
        {
            "m_flNextPrimaryAttack"     "Float"
            "m_flNextSecondaryAttack"       "Float"
            "m_nNextThinkTick"      "Int"
            "m_flTimeWeaponIdle"        "Float"
        }
        "m_iViewModelIndex"     "Int"
        "m_iWorldModelIndex"        "Int"
        "m_iState"      "Int"
        "m_hOwner"      "Int"
    }
}

```


