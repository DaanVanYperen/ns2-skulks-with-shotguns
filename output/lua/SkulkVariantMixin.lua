// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\SkulkVariantMixin.lua
//
// ==============================================================================================

Script.Load("lua/Globals.lua")

SkulkVariantMixin = CreateMixin(SkulkVariantMixin)
SkulkVariantMixin.type = "SkulkVariant"

SkulkVariantMixin.kModelNames = {}

for variant, data in pairs(kSkulkVariantData) do
    SkulkVariantMixin.kModelNames[variant] = PrecacheAsset("models/alien/skulk/skulk" .. data.modelFilePart .. ".model" )
end

SkulkVariantMixin.kDefaultModelName = SkulkVariantMixin.kModelNames[kDefaultSkulkVariant]
local kSkulkAnimationGraph = PrecacheAsset("models/alien/skulk/skulk.animation_graph")

SkulkVariantMixin.networkVars =
{
    variant = "enum kSkulkVariant",
}

function SkulkVariantMixin:__initmixin()

    self.variant = kDefaultSkulkVariant
    
end

function SkulkVariantMixin:GetVariant()
    return self.variant
end

function SkulkVariantMixin:GetVariantModel()

    if self:GetTeamNumber() == 1 then
        return SkulkVariantMixin.kModelNames[kSkulkVariant.shadow]
    else
        return SkulkVariantMixin.kModelNames[kSkulkVariant.normal]
    end
end

if Server then

    // Usually because the client connected or changed their options
    function SkulkVariantMixin:OnClientUpdated(client)

        Player.OnClientUpdated( self, client )

        local data = client.variantData
        if data == nil then
            return
        end

        local changed = data.skulkVariant ~= self.variant

            // cleared, pass info to clients
            self.variant = data.skulkVariant
            assert( self.variant ~= -1 )
            local modelName = self:GetVariantModel()
            assert( modelName ~= "" )
            self:SetModel(modelName, kSkulkAnimationGraph)

        if changed then
        end
            
    end

end
