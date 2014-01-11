

-- like the regular mixin SharedUpdate, except stripped out all damage.
local function SharedUpdate(self, deltaTime)

    if Client then
        UpdateFireMaterial(self)
        self:_UpdateClientFireEffects()
    end

    if not self:GetIsOnFire() then
        return
    end
    
    if Server then
        
        // See if we put ourselves out
        if Shared.GetTime() - self.timeBurnInit > kFlamethrowerBurnDuration then
            self:SetGameEffectMask(kGameEffect.OnFire, false)
        end
        
    end
    
end

function FireMixin:OnUpdate(deltaTime)   
    SharedUpdate(self, deltaTime)
end

function FireMixin:OnProcessMove(input)   
    SharedUpdate(self, input.time)
end
