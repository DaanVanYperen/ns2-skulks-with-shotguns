// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\Skulk.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//                  Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/Weapons/Alien/BiteLeap.lua")
Script.Load("lua/Weapons/Alien/Parasite.lua")
Script.Load("lua/Weapons/Alien/XenocideLeap.lua")
Script.Load("lua/Alien.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/CelerityMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/WallMovementMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/BabblerClingMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/SkulkVariantMixin.lua")

-- SWS START
Script.Load("lua/SkulksWithShotguns/sws_FlagbearerMixin.lua")
Script.Load("lua/SkulksWithShotguns/sws_EventMessageMixin.lua")
Script.Load("lua/SkulksWithShotguns/sws_ExplosiveTraumaMixin.lua")
kSkulkSpeedFactorWhileCarryGorge = 0.95
-- SWS END

class 'Skulk' (Alien)

Skulk.kMapName = "skulk"

Skulk.kModelName = PrecacheAsset("models/alien/skulk/skulk.model")
-- SWS START
local kViewModelName = PrecacheAsset("models/alien/skulk/skulk_vred.model")
local kBlueViewModelName = PrecacheAsset("models/alien/skulk/skulk_vblu.model")
-- SWS END
local kSkulkAnimationGraph = PrecacheAsset("models/alien/skulk/skulk.animation_graph")

// Balance, movement, animation
Skulk.kViewOffsetHeight = .55

Skulk.kHealth = kSkulkHealth
Skulk.kArmor = kSkulkArmor

local kDashSound = PrecacheAsset("sound/NS2.fev/alien/skulk/full_speed")

local kLeapVerticalForce = 10.8
local kLeapTime = 0.2
local kLeapForce = 7.6

local kMaxSpeed = 7.0

local kMass = 45 // ~100 pounds
// How big the spheres are that are casted out to find walls, "feelers".
// The size is calculated so the "balls" touch each other at the end of their range
local kNormalWallWalkFeelerSize = 0.25
local kNormalWallWalkRange = 0.3

// jump is valid when you are close to a wall but not attached yet at this range
local kJumpWallRange = 0.4
local kJumpWallFeelerSize = 0.1

Skulk.kXExtents = .45
Skulk.kYExtents = .45
Skulk.kZExtents = .45

local kWallJumpInterval = 0.4
local kWallJumpForce = 5.2 // scales down the faster you are
local kMinWallJumpForce = 0.1
local kVerticalWallJumpForce = 4.3

if Server then
    Script.Load("lua/Skulk_Server.lua", true)
elseif Client then
    Script.Load("lua/Skulk_Client.lua", true)
end

local networkVars =
{
    wallWalking = "compensated boolean",
    timeLastWallWalkCheck = "private compensated time",
    leaping = "compensated boolean",
    timeOfLeap = "private compensated time",
    timeOfLastJumpLand = "private compensated time",
    timeLastWallJump = "private compensated time",
    jumpLandSpeed = "private compensated float",
    dashing = "compensated boolean",    
    timeOfLastPhase = "private time",
}

AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(CelerityMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(BabblerClingMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(SkulkVariantMixin, networkVars)

-- SWS START
AddMixinNetworkVars(FlagbearerMixin, networkVars)
AddMixinNetworkVars(ExplosiveTraumaMixin, networkVars)
-- SWS END

function Skulk:OnCreate()

    if Client then
        Player.screenEffects.darkVision = nil
    end

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kSkulkFov })
    InitMixin(self, WallMovementMixin)
    InitMixin(self, SkulkVariantMixin)
    
    Alien.OnCreate(self)

    InitMixin(self, DissolveMixin)
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, TunnelUserMixin)
    
    if Client then
        InitMixin(self, RailgunTargetMixin)
        self.timeDashChanged = 0
    end
    
    -- SWS START
    InitMixin(self, ExplosiveTraumaMixin)
    InitMixin(self, FlagbearerMixin)

    if Client then
        InitMixin(self, EventMessageMixin, { kGUIScriptName = "GUIEventMessage" })
    end
    -- SWS END

    
end

function Skulk:OnInitialized()

    Alien.OnInitialized(self)
    
    // Note: This needs to be initialized BEFORE calling SetModel() below
    // as SetModel() will call GetHeadAngles() through SetPlayerPoseParameters()
    // which will cause a script error if the Skulk is wall walking BEFORE
    // the Skulk is initialized on the client.
    self.currentWallWalkingAngles = Angles(0.0, 0.0, 0.0)
    
    self:SetModel(self:GetVariantModel(), kSkulkAnimationGraph)
    
    self.wallWalking = false
    self.wallWalkingNormalGoal = Vector.yAxis
    
    if Client then
    
        self.currentCameraRoll = 0
        self.goalCameraRoll = 0
        
        self:AddHelpWidget("GUIEvolveHelp", 2)
        self:AddHelpWidget("GUISkulkParasiteHelp", 1)
        self:AddHelpWidget("GUISkulkLeapHelp", 2)
        self:AddHelpWidget("GUIMapHelp", 1)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
    end
    
    self.leaping = false
    
    self.timeLastWallJump = 0
    
    InitMixin(self, IdleMixin)

    -- SWS START
    if Server then 
        // Skulks With Shotguns - Add a babbler-shotgun on head node (don't ask). XD
        self.freeAttachPoints = { "babbler_attach3" }
        local babbler = CreateEntity(Babbler.kMapName, self:GetOrigin(), self:GetTeamNumber())    
        self:AttachBabbler(babbler)
    end
    -- SWS END

end

function Skulk:GetCarapaceSpeedReduction()
    return kSkulkCarapaceSpeedReduction
end

function Skulk:OnDestroy()

    Alien.OnDestroy(self)

    if Client then
    
        if self.playingDashSound then
        
            Shared.StopSound(self, kDashSound)
            self.playingDashSound = false
        
        end
    
    end

end

function Skulk:GetBaseArmor()
    return Skulk.kArmor
end

function Skulk:GetCrouchSpeedScalar()
    return 0
end

function Skulk:GetBaseHealth()
    return Skulk.kHealth
end

function Skulk:GetHealthPerBioMass()
    return kSkulkHealthPerBioMass
end

function Skulk:GetArmorFullyUpgradedAmount()
    return kSkulkArmorFullyUpgradedAmount
end

function Skulk:GetMaxViewOffsetHeight()
    return Skulk.kViewOffsetHeight
end

function Skulk:GetCrouchShrinkAmount()
    return 0
end

function Skulk:GetExtentsCrouchShrinkAmount()
    return 0
end

function Skulk:OnLeap()

    local velocity = self:GetVelocity() * 0.5
    local forwardVec = self:GetViewAngles():GetCoords().zAxis
    local newVelocity = velocity + GetNormalizedVectorXZ(forwardVec) * kLeapForce
    
    // Add in vertical component.
    newVelocity.y = kLeapVerticalForce * forwardVec.y + kLeapVerticalForce * 0.5 + ConditionalValue(velocity.y < 0, velocity.y, 0)
    
    self:SetVelocity(newVelocity)
    
    self.leaping = true
    self.wallWalking = false
    self:DisableGroundMove(0.2)
    
    self.timeOfLeap = Shared.GetTime()
    
end

function Skulk:GetRecentlyWallJumped()
    return self.timeLastWallJump + kWallJumpInterval > Shared.GetTime()
end

function Skulk:GetCanWallJump()

    local wallWalkNormal = self:GetAverageWallWalkingNormal(kJumpWallRange, kJumpWallFeelerSize)
    if wallWalkNormal then
        return wallWalkNormal.y < 0.5
    end
    
    return false

end

function Skulk:GetViewModelName()

    if self:GetTeamNumber() == kShadowTeamIndex then
        return kBlueViewModelName
    end

    return kViewModelName
end

function Skulk:GetCanJump()
    local canWallJump = self:GetCanWallJump()
    return self:GetIsOnGround() or canWallJump
end

function Skulk:GetIsWallWalking()
    return self.wallWalking
end

function Skulk:GetIsLeaping()
    return self.leaping
end

function Skulk:GetIsWallWalkingPossible() 
    return not self:GetRecentlyJumped() and not self:GetCrouching()
end

local function PredictGoal(self, velocity)

    PROFILE("Skulk:PredictGoal")

    local goal = self.wallWalkingNormalGoal
    if velocity:GetLength() > 1 and not self:GetIsOnSurface() then

        local movementDir = GetNormalizedVector(velocity)
        local trace = Shared.TraceCapsule(self:GetOrigin(), movementDir * 2.5, Skulk.kXExtents, 0, CollisionRep.Move, PhysicsMask.Movement, EntityFilterOne(self))

        if trace.fraction < 1 and not trace.entity then
            goal = trace.normal    
        end

    end

    return goal

end

function Skulk:GetPlayFootsteps()
    return self:GetVelocityLength() > .75 and self:GetIsOnGround() and self:GetIsAlive() and not self.movementModiferState
end

function Skulk:GetTriggerLandEffect()
    local xzSpeed = self:GetVelocity():GetLengthXZ()
    return Alien.GetTriggerLandEffect(self) and (not self.movementModiferState or xzSpeed > 7)
end

// Update wall-walking from current origin
function Skulk:PreUpdateMove(input, runningPrediction)

    PROFILE("Skulk:PreUpdateMove")
    /*
    local dashDesired = bit.band(input.commands, Move.MovementModifier) ~= 0 and self:GetVelocity():GetLength() > 4
    if not self.dashing and dashDesired and self:GetEnergy() > 15 then
        self.dashing = true    
    elseif self.dashing and not dashDesired then
        self.dashing = false
    end
    
    if self.dashing then    
        self:DeductAbilityEnergy(input.time * 30)    
    end
    
    if self:GetEnergy() == 0 then
        self.dashing = false
    end
    */
    if self:GetCrouching() then
        self.wallWalking = false
    end

    if self.wallWalking then

        // Most of the time, it returns a fraction of 0, which means
        // trace started outside the world (and no normal is returned)           
        local goal = self:GetAverageWallWalkingNormal(kNormalWallWalkRange, kNormalWallWalkFeelerSize)
        if goal ~= nil then
        
            self.wallWalkingNormalGoal = goal
            self.wallWalking = true

        else
            self.wallWalking = false
        end
    
    end
    
    if not self:GetIsWallWalking() then
        // When not wall walking, the goal is always directly up (running on ground).
        self.wallWalkingNormalGoal = Vector.yAxis
    end

    if self.leaping and Shared.GetTime() > self.timeOfLeap + kLeapTime then
        self.leaping = false
    end
    
    self.currentWallWalkingAngles = self:GetAnglesFromWallNormal(self.wallWalkingNormalGoal or Vector.yAxis) or self.currentWallWalkingAngles

end

function Skulk:GetRollSmoothRate()
    return 5
end

function Skulk:GetPitchSmoothRate()
    return 3
end

function Skulk:GetSlerpSmoothRate()
    return 5
end

function Skulk:GetAngleSmoothRate()
    return 6
end

function Skulk:GetCollisionSlowdownFraction()
    return 0.15
end

function Skulk:GetDesiredAngles(deltaTime)
    return self.currentWallWalkingAngles
end 

function Skulk:GetHeadAngles()

    if self:GetIsWallWalking() then
        return self.currentWallWalkingAngles
    else
        return self:GetViewAngles()
    end

end

function Skulk:GetAngleSmoothingMode()

    if self:GetIsWallWalking() then
        return "quatlerp"
    else
        return "euler"
    end

end

function Skulk:GetIsUsingBodyYaw()
    return not self:GetIsWallWalking()
end

function Skulk:OnJump()

    self.wallWalking = false

    local jumpEffectName = "jump"
    
    local velocityLength = self:GetVelocity():GetLengthXZ()
    
    if velocityLength > 11 then
        jumpEffectName = "jump_best"            
    elseif velocityLength > 8.5 then
        jumpEffectName = "jump_good"
    end

    self:TriggerEffects(jumpEffectName, {surface = self:GetMaterialBelowPlayer()})
    
end

function Skulk:OnWorldCollision(normal, impactForce, newVelocity)

    PROFILE("Skulk:OnWorldCollision")

    self.wallWalking = self:GetIsWallWalkingPossible() and normal.y < 0.5
    
end

function Skulk:GetMaxSpeed(possible)

    if possible then
        return kMaxSpeed
    end

    local maxspeed = kMaxSpeed
    if self:GetIsWallWalking() then
        maxspeed = maxspeed + 0.25
    end
    
    if self.movementModiferState then
        maxspeed = maxspeed * 0.5
    end

    -- SWS START
    // slow down flag bearing skulks just a tad so they can be effectively chased
    if self:IsBearingFlag() then
        maxspeed = maxspeed * kSkulkSpeedFactorWhileCarryGorge
    end
    -- SWS END
    
    return maxspeed
    
end

function Skulk:GetMass()
    return kMass
end

function Skulk:OverrideUpdateOnGround(onGround)
    return onGround or self:GetIsWallWalking()
end

function Skulk:ModifyGravityForce(gravityTable)

    if self:GetIsWallWalking() and not self:GetCrouching() then
        gravityTable.gravity = 0

    elseif self:GetIsOnGround() then
        gravityTable.gravity = 0
        
    end

end

function Skulk:GetJumpHeight()
    return Skulk.kJumpHeight
end

function Skulk:GetPerformsVerticalMove()
    return self:GetIsWallWalking()
end

function Skulk:ModifyJump(input, velocity, jumpVelocity)

    if self:GetCanWallJump() then
    
        local direction = input.move.z == -1 and -1 or 1
    
        // we add the bonus in the direction the move is going
        local viewCoords = self:GetViewAngles():GetCoords()
        self.bonusVec = viewCoords.zAxis * direction
        self.bonusVec.y = 0
        self.bonusVec:Normalize()
        
        jumpVelocity.y = 3 + math.min(1, 1 + viewCoords.zAxis.y) * 2

        local celerityMod = (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * 0.4
        local currentSpeed = velocity:GetLengthXZ()
        local fraction = 1 - Clamp( currentSpeed / (11 + celerityMod), 0, 1)        
        
        local force = math.max(kMinWallJumpForce, (kWallJumpForce + celerityMod) * fraction)
          
        self.bonusVec:Scale(force)      

        if not self:GetRecentlyWallJumped() then
        
            self.bonusVec.y = viewCoords.zAxis.y * kVerticalWallJumpForce
            jumpVelocity:Add(self.bonusVec)

        end
        
        self.timeLastWallJump = Shared.GetTime()
        
    end
    
end

// The Skulk movement should factor in the vertical velocity
// only when wall walking.
function Skulk:GetMoveSpeedIs2D()
    return not self:GetIsWallWalking()
end

function Skulk:GetAcceleration()
    return 13
end

function Skulk:GetAirControl()
    return 27
end

function Skulk:GetGroundTransistionTime()
    return 0.1
end

function Skulk:GetAirAcceleration()
    return 9
end

function Skulk:GetAirFriction()
    return 0.055 - (GetHasCelerityUpgrade(self) and GetSpurLevel(self:GetTeamNumber()) or 0) * 0.009
end 

function Skulk:GetGroundFriction()
    return 11
end

function Skulk:GetCanStep()
    return not self:GetIsWallWalking()
end

function Skulk:OnUpdateAnimationInput(modelMixin)

    PROFILE("Skulk:OnUpdateAnimationInput")
    
    Alien.OnUpdateAnimationInput(self, modelMixin)
    
    if self:GetIsLeaping() then
        modelMixin:SetAnimationInput("move", "leap")
    end
    
    modelMixin:SetAnimationInput("onwall", self:GetIsWallWalking() and not self:GetIsJumping())
    
end

local function UpdateDashEffects(self)

    if Client then
    
        local dashing = self:GetVelocity():GetLengthXZ() > 8.7

        if self.clientDashing ~= dashing then
        
            self.timeDashChanged = Shared.GetTime()
            self.clientDashing = dashing
            
        end
        
        local soundAllowed = not GetHasSilenceUpgrade(self) or self.silenceLevel < 3        

        if self:GetIsAlive() and dashing and not self.playingDashSound and (Shared.GetTime() - self.timeDashChanged) > 1 then
        
            local volume = GetHasSilenceUpgrade(self) and 1 - (self.silenceLevel / 3) or 1        
            local localPlayerScalar = Client.GetLocalPlayer() == self and 0.26 or 1        
            volume = volume * localPlayerScalar
        
            Shared.PlaySound(self, kDashSound, volume)
            self.playingDashSound = true
        
        elseif not self:GetIsAlive() or ( not dashing and self.playingDashSound ) then    
        
            Shared.StopSound(self, kDashSound)
            self.playingDashSound = false
        
        end
    
    end

end

function Skulk:OnUpdate(deltaTime)
    
    Alien.OnUpdate(self, deltaTime)
    
    //UpdateDashEffects(self)
    
end

function Skulk:GetMovementSpecialTechId()
    return kTechId.Sneak
end

function Skulk:GetHasMovementSpecial()
    return self.movementModiferState
end

function Skulk:OnProcessMove(input)

    Alien.OnProcessMove(self, input)
    
    //UpdateDashEffects(self)

end

function Skulk:GetIsSmallTarget()
    return true
end

local kSkulkEngageOffset = Vector(0, 0.5, 0)
function Skulk:GetEngagementPointOverride()
    return self:GetOrigin() + kSkulkEngageOffset
end

Shared.LinkClassToMap("Skulk", Skulk.kMapName, networkVars, true)
