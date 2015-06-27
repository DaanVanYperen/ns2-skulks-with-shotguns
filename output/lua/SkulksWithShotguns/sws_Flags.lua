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

local kFlagTakenSound = "sound/NS2.fev/alien/gorge/taunt"

class 'Flag' (ScriptActor)

Flag.kMapName = "sws_flag"

Flag.kModelName = PrecacheAsset("models/alien/gorge/gorge.model")
Flag.kModelNameShadow = PrecacheAsset("models/alien/gorge/gorge_shadow.model")
local kAnimationGraph = PrecacheAsset("models/alien/gorge/gorge.animation_graph")

local networkVars =
{
    lastTimeYelled = "time",
    m_angles = "interpolated angles (by 10 [], by 10 [], by 10 [])",
    m_origin = "compensated interpolated position (by 0.05 [2 3 5], by 0.05 [2 3 5], by 0.05 [2 3 5])",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)


kAbductionYellInterval = 4

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
    
    self:SetUpdates(true)
    self:SetRelevancyDistance(Math.infinity)
    
    self.lastTimeYelled = 0
    
    if Server then
        self:AddTimedCallback(Flag.UpdateAbductionYell, 0.5)
    end
end 


// entity pickup self
local function Pickup(self, entity)

        local enemyFlag = self:GetTeamNumber() ~= entity:GetTeamNumber()

        // allow pickup of enemy entity only.
        if enemyFlag then
            // enemy pickup
            if not self.offBase then
                self.offBase = true
                
                self:OnTaken()
                                
                // enemy team is taking gorge from base!
                SendEventMessage(self:GetTeam(), kEventMessageTypes.EnemyStoleGorge, entity:GetClientIndex())
                SendEventMessage(GetEnemyTeam(self:GetTeam()), kEventMessageTypes.TeamStoleGorge, entity:GetClientIndex())

                // corresponding vocals.
                self:GetTeam():PlayPrivateTeamSound(kSfxGorgeStolenOur)
                GetEnemyTeam(self:GetTeam()):PlayPrivateTeamSound(kSfxGorgeStolenTheir)
                
                // pickup flag.                
                entity:AttachFlag(self)
            elseif self:GetParent() == nil then
            
                self:OnTaken()

                // enemy team is taking gorge from off base!
                SendEventMessage(self:GetTeam(), kEventMessageTypes.EnemyStoleGorge, entity:GetClientIndex())
                SendEventMessage(GetEnemyTeam(self:GetTeam()), kEventMessageTypes.TeamStoleGorge, entity:GetClientIndex())

                entity:AttachFlag(self)
            end
        else
            // friendly pickup: respawn the flag!
            if self.offBase then
            
                // team recovered gorge
                SendEventMessage(self:GetTeam(), kEventMessageTypes.TeamRecoveredGorge, entity:GetClientIndex())
                SendEventMessage(GetEnemyTeam(self:GetTeam()), kEventMessageTypes.EnemyRecoveredGorge, entity:GetClientIndex())
                rewardPoints(entity, kScorePointsRecoverGorge)
            
                self.offBase = false
                DestroyEntity(self)
            else
                // potential friendly delivery! :D CASH IN POINTSSSSSSSSSS
                if entity:IsBearingFlag() then

                    // team recovered gorge
                    SendEventMessage(self:GetTeam(), kEventMessageTypes.TeamCapturedGorge, entity:GetClientIndex())
                    SendEventMessage(GetEnemyTeam(self:GetTeam()), kEventMessageTypes.EnemyCapturedGorge, entity:GetClientIndex())
                    
                    // play vocals, but only if player is not about to win (which will spam sounds)
                    local teamWon = (entity:GetTeam():GetPoints() >= kCaptureWinPoints-1)
                    if not teamWon then
                        // corresponding vocals.
                        if entity:GetTeamNumber() == kVanillaTeamIndex then
                            entity:GetTeam():PlayPrivateTeamSound(kSfxRedScores)
                            GetEnemyTeam(entity:GetTeam()):PlayPrivateTeamSound(kSfxRedScores)
                        else
                            entity:GetTeam():PlayPrivateTeamSound(kSfxBlueScores)
                            GetEnemyTeam(entity:GetTeam()):PlayPrivateTeamSound(kSfxBlueScores)
                        end
                    end
                    
                    // @todo: capture message.
                    GetGamerules():ScorePoint(entity)
                    DestroyEntity(entity:GetFlag())
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
            if CheckEntityPickupFlag(self, ents[e]) then
                // abort checking if the entity has just been picked up /removed /whatever.
                return
            end
        end
    
end

function Flag:Yell()
    self.lastTimeYelled = Shared.GetTime()
   if not self:GetIsDestroyed() then
       StartSoundEffectOnEntity(kFlagTakenSound, self)
   end
end

function Flag:OnTaken()
    self:Yell()
end

function Flag:OnDrop()

        if not self:GetIsDestroyed() then
            self:Yell()
            self:GetTeam():PlayPrivateTeamSound(kSfxGorgeDrop)
            GetEnemyTeam(self:GetTeam()):PlayPrivateTeamSound(kSfxGorgeDrop)

            self.active = false

            self.droppedTime = Shared.GetTime()

            local proximityFunc = function(self)
                                 self.active = true
                                 CheckAllEntsInRangePickupFlag(self)
                             end
            self:AddTimedCallback(proximityFunc, kFlagActiveTime)
        end
end

/*
function Flag:OnUpdateAnimationInput(modelMixin)

    if self.offBase then
        modelMixin:SetAnimationInput("move", "belly")  
    else
        modelMixin:SetAnimationInput("move", "idle")  
    end
end*/
    
function Flag:OnInitialized()

    self.offBase = false

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

    function Flag:GetLastTimeYelled()
        return self.lastTimeYelled
    end

    function Flag:OnAdjustModelCoords(coords)
    
        local scale = 0.5
        
        if self:GetParent() == nil then
          scale = 1
        end
    
        coords.xAxis = coords.xAxis * scale
        coords.yAxis = coords.yAxis * scale
        coords.zAxis = coords.zAxis * scale
        
        return coords
    
    end


if Server then 

    /**
     * Yell at certain intervals, which will show up on aura.
     */
    function Flag:UpdateAbductionYell()
        if self:GetParent() ~= nil and Shared.GetTime() - self.lastTimeYelled > kAbductionYellInterval then
            self:Yell()
        end
        
        return true
    end
    
       
    function Flag:DetachReset()
        if self:GetParent() ~= nil then
            //self:GetParent():DetachAll()   
            SendEventMessage(self:GetTeam(), kEventMessageTypes.TeamTimeoutGorge)
            SendEventMessage(GetEnemyTeam(self:GetTeam()), kEventMessageTypes.EnemyTimeoutGorge)                
            self:GetTeam():ResetRespawnFlag()                
        end 
        self.droppedTime = kFlagFloorTimeout
    end

    /**
     * We need to check when there are entities within the trigger area often.
     */
    function Flag:OnUpdate(dt)

        local now = Shared.GetTime()

        if self:GetParent() == nil then
        
            self.lastTimeYelled = 0
        
            // Move triggerbody if we lose parent
            self.triggerBody:SetCoords(self:GetCoords())
            
            // respawn flag if it is on the floor for too long
            self.droppedTime = self.droppedTime or now
            if self.offBase and (now - self.droppedTime >= kFlagFloorTimeout) then 
                SendEventMessage(self:GetTeam(), kEventMessageTypes.TeamTimeoutGorge)
                SendEventMessage(GetEnemyTeam(self:GetTeam()), kEventMessageTypes.EnemyTimeoutGorge)                
                self:GetTeam():ResetRespawnFlag()                
            end
        end
        
        // The flags are always detected.
        self:SetDetected(true)
    
        self.lastPickupUpdateTime = self.lastPickupUpdateTime or now
        if now - self.lastPickupUpdateTime >= (1/30) then
            CheckAllEntsInRangePickupFlag(self)
            self.lastPickupUpdateTime = now
        end
    end
    
    function Flag:GetCarrier()
        return self:GetParent()
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