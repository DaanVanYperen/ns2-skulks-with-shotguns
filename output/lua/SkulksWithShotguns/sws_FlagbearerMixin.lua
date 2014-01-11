// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\FlagbearerMixin.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
//    Handles flags attaching to units.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// TODO: create better effect
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/parasited.surface_shader")
local kMaterialName = "cinematics/vfx_materials/parasited.material"

FlagbearerMixin = CreateMixin(FlagbearerMixin)
FlagbearerMixin.type = "Flagbearer"

FlagbearerMixin.expectedMixins =
{
    EntityChange = "Required to update list of flag Ids"
}

local kFlagAttachPoint = "babbler_attach1"

FlagbearerMixin.networkVars =
{
    hasFlag = "boolean"
}

function FlagbearerMixin:__initmixin()

    self.attachedFlag = nil
    self.hasFlag = false
end

function FlagbearerMixin:IsBearingFlag()
   return self.hasFlag
end

if Server then

    function FlagbearerMixin:AttachFlag(flag)
    
        local success = false
        if self.attachedFlag == nil then
            self.attachedFlag = flag
            flag:SetParent(self)
            flag:SetAttachPoint(kFlagAttachPoint)
            success = true
            self.hasFlag = true
        end
        
        return success
    
    end
    
    function FlagbearerMixin:DetachFlag(flag)
        DetachAll(self)
    end

/*    
    function FlagbearerMixin:GetFlagAttachPointCoords(flag)
        local attachPointName = self.attachedFlags[flag:GetId()]
        if attachPointName then
            return self:GetAttachPointCoords(attachPointName)
        end
    end */

    function FlagbearerMixin:OnEntityChange(oldId, newId)

        if (self.attachedFlag ~= nil) and (self.attachedFlag:GetId() == oldId )  then
            self.attachedFlag = nil
            self.hasFlag = false
        end

    end
    
    function FlagbearerMixin:GetFlag()
        return self.attachedFlag
    end
    
    local function DetachAll(self)
        if (self.attachedFlag ~= nil) then
            local flag = self.attachedFlag
            local origin, success = self:GetAttachPointOrigin(kFlagAttachPoint)
            if origin then
                flag:SetOrigin(origin)
            end
        
            // warn the gorge has been dropped.
            SendEventMessage(flag:GetTeam(), kEventMessageTypes.TeamDroppedGorge, self:GetId())
            SendEventMessage(GetEnemyTeam(flag:GetTeam()), kEventMessageTypes.EnemyDroppedGorge, self:GetId())
        
            self.attachedFlag:OnDrop()
            self.attachedFlag:SetParent(nil)
            self.attachedFlag = nil
            self.hasFlag = false
        end    
    end
    
    function FlagbearerMixin:OnLeap()
        DetachAll(self)    
    end


    function FlagbearerMixin:OnKill()
        DetachAll(self)    
    end

    function FlagbearerMixin:OnDestroy()
        DetachAll(self)
    end
    
    function FlagbearerMixin:GetFreeFlagAttachPointOrigin()
    
        local freeAttachPoint = #self.freeAttachPoints > 0 and self.freeAttachPoints[1] or false
        if freeAttachPoint then
            return self:GetAttachPointOrigin(freeAttachPoint)
        end
    
    end

end
