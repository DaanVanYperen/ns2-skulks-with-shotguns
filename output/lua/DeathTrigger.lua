// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\DeathTrigger.lua
//
//    Created by:   Brian Cronin (brian@unknownworlds.com)
//
// Kill entity that touches this.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TechMixin.lua")
Script.Load("lua/Mixins/SignalListenerMixin.lua")

class 'DeathTrigger' (Trigger)

DeathTrigger.kMapName = "death_trigger"

local networkVars =
{
    teamNumber = string.format("integer (-1 to %d)", kSpectatorIndex),
}

AddMixinNetworkVars(TechMixin, networkVars)

local function KillEntity(self, entity)

    if Server then
        if HasMixin(entity, "Live") and entity:GetIsAlive() and entity:GetCanDie(true) then

            // SWS - reset flag in kill zones.        
            if HasMixin(entity,"Flagbearer") then
                 if entity:GetFlag() ~= nil then
                     entity:GetFlag():DetachReset()
                 end
            end    
        
            // SWS - support for team kill triggers.
            if ( self.teamNumber <= 0 ) or ( self.teamNumber == entity:GetTeamNumber() ) then
            
                local direction = GetNormalizedVector(entity:GetModelOrigin() - self:GetOrigin())
                entity:Kill(self, self, self:GetOrigin(), direction)
            end
        end
        
        // drop flag in killzone.
        if entity:isa("Flag") then
            if entity:GetCarrier() ~= nil then 
                entity:DetachReset()
            end
        end
    end
    
end

local function KillAllInTrigger(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        KillEntity(self, entity)
    end
    
end

function DeathTrigger:OnCreate()

    Trigger.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, SignalListenerMixin)
    
    self.enabled = true
    
    self:RegisterSignalListener(function() KillAllInTrigger(self) end, "kill")

    if Server then
        self:SetUpdates(true)
    end
end

local function GetDamageOverTimeIsEnabled(self)
    return self.damageOverTime ~= nil and self.damageOverTime > 0
end

function DeathTrigger:OnInitialized()

    Trigger.OnInitialized(self)
    
    self:SetTriggerCollisionEnabled(true)
    
    self:SetUpdates(GetDamageOverTimeIsEnabled(self))
    
end

local function DoDamageOverTime(entity, damage)

    if HasMixin(entity, "Live") then
        entity:TakeDamage(damage, nil, nil, nil, nil, 0, damage, kDamageType.Normal)
    end
    
end

function DeathTrigger:OnUpdate(deltaTime)

    if GetDamageOverTimeIsEnabled(self) then
        self:ForEachEntityInTrigger(function(entity) DoDamageOverTime(entity, self.damageOverTime * deltaTime) end)
    end
    
end

function DeathTrigger:OnTriggerEntered(enterEnt, triggerEnt)

    if self.enabled and not GetDamageOverTimeIsEnabled(self) then
        KillEntity(self, enterEnt)
    end
    
end

Shared.LinkClassToMap("DeathTrigger", DeathTrigger.kMapName, networkVars)