// Replace shotty. We don't make a separate weapon cause it's a pain in the butt just starting out modding!

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/LeapMixin.lua")

class 'Shotgun' (Ability)

Shotgun.kMapName = "shotgun"

local kAnimationGraph = PrecacheAsset("models/alien/skulk/skulk_view.animation_graph")

Shotgun.kActivity = enum { 'None', 'Primary' }

kShotgunHUDSlot = 2

local kBulletSize = 0.016
local kShotgunSize = 0.15 // size of parasite blob
local kSpreadDistance = 10
local kStartOffset = 0
local kSpreadVectors =
{
    GetNormalizedVector(Vector(-0.01, 0.01, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-0.45, 0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(0.45, 0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(0.45, -0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(-0.45, -0.45, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-1, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(1, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0, -1, kSpreadDistance)),
    GetNormalizedVector(Vector(0, 1, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-0.35, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0.35, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0, -0.35, kSpreadDistance)),
    GetNormalizedVector(Vector(0, 0.35, kSpreadDistance)),
    
    GetNormalizedVector(Vector(-0.8, -0.8, kSpreadDistance)),
    GetNormalizedVector(Vector(-0.8, 0.8, kSpreadDistance)),
    GetNormalizedVector(Vector(0.8, 0.8, kSpreadDistance)),
    GetNormalizedVector(Vector(0.8, -0.8, kSpreadDistance)),
    
}

local kMuzzleEffect = PrecacheAsset("cinematics/marine/shotgun/muzzle_flash.cinematic")
local kMuzzleAttachPoint = "Bone_Tongue"

local networkVars =
{
    blocked = "boolean",
    activity = "enum Shotgun.kActivity"
}

function Shotgun:OnCreate()

    Ability.OnCreate(self)
    
    self.activity = Shotgun.kActivity.None
    
    InitMixin(self, LeapMixin)
    InitMixin(self, BulletsMixin)

end

function Shotgun:GetBulletsPerShot()
    return 17
end

function Shotgun:GetRange()
    return 100
end

function Shotgun:GetAnimationGraphName()
    return kAnimationGraph
end

function Shotgun:GetDeathIconIndex()
    return kDeathMessageIcon.Shotgun
end

function Shotgun:GetSecondaryTechId()
    return kTechId.Leap
end

function Shotgun:GetEnergyCost(player)
    return 15
end

function Shotgun:GetHUDSlot()
    return kShotgunHUDSlot
end

function Shotgun:GetPrimaryAttackRequiresPress()
    return true
end

function Shotgun:OnProcessMove(input)

    Ability.OnProcessMove(self, input)
    
    // We need to clear this out in OnProcessMove (rather than ProcessMoveOnWeapon)
    // since this will get called after the view model has been updated from
    // Player:OnProcessMove. 
    self.activity = Shotgun.kActivity.None

end

// Only play weapon effects every other bullet to avoid sonic overload
function Shotgun:GetTracerEffectFrequency()
    return 0.5
end

function Shotgun:PerformShotgunFire(player)
    local viewAngles = player:GetViewAngles()
    viewAngles.roll = NetworkRandom() * math.pi * 2

    local shootCoords = viewAngles:GetCoords()

    // Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local range = self:GetRange()
    
    if GetIsVortexed(player) then
        range = 5
    end
    
    // disable umbra upon firing a shotty.
    if Server then      
        if ( HasMixin(player, "Umbra") ) then
             // disable umbra.
             player.dragsUmbra = false
             player.timeUmbraExpires = 0
        end
    end
    
    local numberBullets = self:GetBulletsPerShot()
    local startPoint = player:GetEyePos()

    self:TriggerEffects("shotgun_attack_sound")
    self:TriggerEffects("shotgun_attack")
        
    -- SWS START: Determine if we should cause explosive trauma to anyone hit by pellets, before the target gets killed.
    if Server then
    
        local totalDamage = {}
        local totalBullets = math.min(numberBullets, #kSpreadVectors)
        
        for bullet = 1, totalBullets do    
            if not kSpreadVectors[bullet] then
                break
            end    
    
            local spreadDirection = shootCoords:TransformVector(kSpreadVectors[bullet])

            local endPoint = startPoint + spreadDirection * range
            startPoint = player:GetEyePos() + shootCoords.xAxis * kSpreadVectors[bullet].x * kStartOffset + shootCoords.yAxis * kSpreadVectors[bullet].y * kStartOffset
        
            local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
            if not trace.entity then 
                -- Limit the box trace to the point where the ray hit as an optimization.
                local boxTraceEndPoint = trace.fraction ~= 1 and trace.endPoint or endPoint
                local extents = GetDirectedExtentsForDiameter(spreadDirection, kBulletSize)
                trace = Shared.TraceBox(extents, startPoint, boxTraceEndPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
            end
                
            if (trace.fraction < 1 or GetIsVortexed(player)) and trace.entity then
                local entityId = trace.entity:GetId()
                if totalDamage[entityId] == nil then
                    totalDamage[entityId] = 0
                end
                totalDamage[entityId] = totalDamage[entityId] + kShotgunDamage
            end              
        end
                
        for entityId, value in pairs(totalDamage) do
            local entity = Shared.GetEntity(entityId)
            if (entity ~= nil) and HasMixin(entity, "ExplosiveTrauma") then
                // prime if all pellets but one strike the target (perfect hit).
                entity:SetPrimed(value >= kShotgunDamage * (totalBullets-6))
            end
        end
        
    end
    -- SWS END: Explosive Trauma.
    
    
    for bullet = 1, math.min(numberBullets, #kSpreadVectors) do
    
        if not kSpreadVectors[bullet] then
            break
        end    
    
        local spreadDirection = shootCoords:TransformVector(kSpreadVectors[bullet])

        local endPoint = startPoint + spreadDirection * range
        startPoint = player:GetEyePos() + shootCoords.xAxis * kSpreadVectors[bullet].x * kStartOffset + shootCoords.yAxis * kSpreadVectors[bullet].y * kStartOffset
        
        local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
        if not trace.entity then
        
            -- Limit the box trace to the point where the ray hit as an optimization.
            local boxTraceEndPoint = trace.fraction ~= 1 and trace.endPoint or endPoint
            local extents = GetDirectedExtentsForDiameter(spreadDirection, kBulletSize)
            trace = Shared.TraceBox(extents, startPoint, boxTraceEndPoint, CollisionRep.Damage, PhysicsMask.Bullets, filter)
            
        end
        
        local damage = 0
            
        // don't damage 'air'..
        if trace.fraction < 1 or GetIsVortexed(player) then
        
            local direction = (trace.endPoint - startPoint):GetUnit()
            local impactPoint = trace.endPoint - direction * kHitEffectOffset
            local surfaceName = trace.surface

            local effectFrequency = self:GetTracerEffectFrequency()
            local showTracer = bullet % effectFrequency == 0
            
            self:ApplyBulletGameplayEffects(player, trace.entity, impactPoint, direction, kShotgunDamage, trace.surface, showTracer)
            
            if Client and showTracer then
                TriggerFirstPersonTracer(self, trace.endPoint)
            end
            
        end
        
        local client = Server and player:GetClient() or Client
        if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
            RegisterHitEvent(player, bullet, startPoint, trace, damage)
        end
        
    end
    
    TEST_EVENT("Shotgun primary attack")
end

function Shotgun:PerformPrimaryAttack(player)

    self.activity = Shotgun.kActivity.Primary
    self.primaryAttacking = true
    
    local success = false

    if not self.blocked then
    
        self.blocked = true
        
        success = true
        
        self:PerformShotgunFire(player)
        
    end
    
    return success
    
end

function Shotgun:OnHolster(player)

    Ability.OnHolster(self, player)
    
    self.blocked = false
    
end

function Shotgun:OnTag(tagName)

    PROFILE("Shotgun:OnTag")

    if tagName == "attack_end" then
        self.blocked = false
        self.primaryAttacking = false
    end

end

function Shotgun:OnUpdateAnimationInput(modelMixin)

    PROFILE("Shotgun:OnUpdateAnimationInput")

    modelMixin:SetAnimationInput("ability", "parasite")
    
    local activityString = "none"
    if self.activity == Shotgun.kActivity.Primary then
        activityString = "primary"
    end
    modelMixin:SetAnimationInput("activity", activityString)
    
end

Shared.LinkClassToMap("Shotgun", Shotgun.kMapName, networkVars)