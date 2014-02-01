/**
 * Excessive trauma causes an explosion.
 */ 
ExplosiveTraumaMixin = CreateMixin( ExplosiveTraumaMixin )
ExplosiveTraumaMixin.type = "ExplosiveTrauma"

ExplosiveTraumaMixin.networkVars =
{
}

function ExplosiveTraumaMixin:__initmixin()
    self.primed = false    
end

if Server then
    
    function ExplosiveTraumaMixin:SetPrimed( primed )
        self.primed = primed
    end

    function ExplosiveTraumaMixin:OnKill()
        Shared.Message("ExplosiveTraumaMixin:OnKill")
        if not self:GetIsAlive() and self.primed then
                self:SetBypassRagdoll(true)
                self:TriggerEffects("xenocide", {effecthostcoords = Coords.GetTranslation(self:GetOrigin())})
        end        
    end
end