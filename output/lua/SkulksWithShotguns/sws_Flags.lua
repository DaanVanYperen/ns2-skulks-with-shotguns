-- Spawnpoint for Vanilla flag

Script.Load("lua/BaseSpawn.lua")

class 'VanillaFlagSpawn' (BaseSpawn)

VanillaFlagSpawn.kMapName = "vanilla_flag_spawn"

-- Spawnpoint for Shadow Flag

Script.Load("lua/BaseSpawn.lua")

class 'ShadowFlagSpawn' (BaseSpawn)

ShadowFlagSpawn.kMapName = "shadow_flag_spawn"

-- Team flag.

Script.Load("lua/TeamMixin.lua")

kFlagTriggerRange = 2
kFlagActiveTime = 1

class 'Flag' (ScriptActor)

Flag.kMapName = "sws_flag"

Flag.kModelName = PrecacheAsset("models/alien/gorge/gorge.model")
Flag.kModelNameShadow = PrecacheAsset("models/alien/gorge/gorge_shadow.model")
local kAnimationGraph = PrecacheAsset("models/alien/gorge/gorge.animation_graph")

local networkVars =
{
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)


local function CreateHitBox(self)

    if not self.hitBox then
    
        self.hitBox = Shared.CreatePhysicsSphereBody(false, Babbler.kRadius * 1.4, Babbler.kMass, self:GetCoords() )
        self.hitBox:SetGroup(PhysicsGroup.BabblerGroup)
        self.hitBox:SetCoords(self:GetCoords())
        self.hitBox:SetEntity(self)
        self.hitBox:SetPhysicsType(CollisionObject.Kinematic)
        self.hitBox:SetTriggeringEnabled(true)
        
    end

end

function Flag:OnCreate()
    ScriptActor.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DetectableMixin)
end 


// entity pickup self
local function Pickup(self, entity)

        local enemyFlag = self:GetTeamNumber() ~= entity:GetTeamNumber()

        // allow pickup of enemy entity only.
        if enemyFlag then
            // enemy pickup
            if not self.offBase then
                self.offBase = true
                
                // enemy team is taking gorge from base!
                SendEventMessage(self:GetTeam(), kEventMessageTypes.EnemyStoleGorge, entity:GetId())
                SendEventMessage(GetEnemyTeam(self:GetTeam()), kEventMessageTypes.TeamStoleGorge, entity:GetId())
                
                // pickup flag.                
                entity:AttachFlag(self)
            elseif self:GetParent() == nil then

                // enemy team is taking gorge from off base!
                SendEventMessage(self:GetTeam(), kEventMessageTypes.EnemyStoleGorge, entity:GetId())
                SendEventMessage(GetEnemyTeam(self:GetTeam()), kEventMessageTypes.TeamStoleGorge, entity:GetId())

                entity:AttachFlag(self)
            end
        else
            // friendly pickup: respawn the flag!
            if self.offBase then
            
                // team recovered gorge
                SendEventMessage(self:GetTeam(), kEventMessageTypes.TeamRecoveredGorge, entity:GetId())
                SendEventMessage(GetEnemyTeam(self:GetTeam()), kEventMessageTypes.EnemyRecoveredGorge, entity:GetId())
            
                self.offBase = false
                self:GetTeam():ResetRespawnFlag()
            else
                // potential friendly delivery! :D CASH IN POINTSSSSSSSSSS
                if entity:IsBearingFlag() then

                    // team recovered gorge
                    SendEventMessage(self:GetTeam(), kEventMessageTypes.TeamCapturedGorge, entity:GetId())
                    SendEventMessage(GetEnemyTeam(self:GetTeam()), kEventMessageTypes.EnemyCapturedGorge, entity:GetId())
                    
                    // @todo: capture message.
                    entity:GetFlag():GetTeam():ResetRespawnFlag()
                end                
            end
            
        end
end


local function CheckEntityPickupFlag(self, entity)

    if not self.active then
        return false
    end
    
    if not HasMixin(entity, "Flagbearer") then
        return false
    end
    
    // do not allow the dead to pick up flags.
    if  HasMixin(entity, "Live") and not entity:GetIsAlive() then
        return false
    end
        
    local minePos = self:GetEngagementPoint()
    local targetPos = entity:GetEngagementPoint()
    // Do not trigger through walls. But do trigger through other entities.
    if not GetWallBetween(minePos, targetPos, entity) then
    
        // If this fails, targets can sit in trigger, no "polling" update performed.
        if Server then
            Pickup(self, entity)
            return true
        end
        
    end
    
    return false
    
end


local function CheckAllEntsInRangePickupFlag(self)

        local ents = self:GetEntitiesInTrigger()
        for e = 1, #ents do
            CheckEntityPickupFlag(self, ents[e])
        end
    
end

function Flag:OnDrop()

        self.active = false

        local proximityFunc = function(self)
                                 self.active = true
                                 CheckAllEntsInRangePickupFlag(self)
                             end
        self:AddTimedCallback(proximityFunc, kFlagActiveTime)
end

function Flag:OnInitialized()

    if self:GetTeamNumber() == kShadowTeamIndex then
        self:SetModel(Flag.kModelNameShadow, kAnimationGraph)
    else
        self:SetModel(Flag.kModelName, kAnimationGraph)
    end
    
    if Server then
    
        // prepare pickup logic.
        InitMixin(self, TriggerMixin)
        self:SetSphere(kFlagTriggerRange)
        
        self:OnDrop()
    
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    end

end


if Server then 
    /**
     * We need to check when there are entities within the trigger area often.
     */
    function Flag:OnUpdate(dt)
    
        if self:GetParent() == nil then
            self.triggerBody:SetCoords(self:GetCoords())
        end
        
        // The flags are always detected.
        self:SetDetected(true)
    
        local now = Shared.GetTime()
        self.lastPickupUpdateTime = self.lastPickupUpdateTime or now
        if now - self.lastPickupUpdateTime >= 0.5 then
            CheckAllEntsInRangePickupFlag(self)
            self.lastPickupUpdateTime = now
        end
    end
    

    function Flag:OnProcessMove(input)
    
        if Server then
            
            local parent = self:GetParent()
            if parent then
                self:SetOrigin(parent:GetOrigin())
            end
        end
    end    
end
    
function Flag:OnUpdatePhysics()
    //CreateHitBox(self)
    //self.hitBox:SetCoords(self:GetCoords())    
end

function Flag:GetPhysicsModelAllowedOverride()
    return false
end

function Flag:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    if self.physicsBody then
        Shared.DestroyCollisionObject(self.physicsBody)
        self.physicsBody = nil
    end
    
    if self.hitBox then
        Shared.DestroyCollisionObject(self.hitBox)
        self.hitBox = nil
    end
    
    if Client then
        local model = self:GetRenderModel()
        if model and self.addedToHiveVision then
            HiveVision_RemoveModel(model)
        end
    end

end

Shared.LinkClassToMap("Flag", Flag.kMapName, networkVars)