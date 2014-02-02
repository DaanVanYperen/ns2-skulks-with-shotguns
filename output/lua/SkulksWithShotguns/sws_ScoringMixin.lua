
local function PlaySound( self, soundEffect )
    Server.PlayPrivateSound(self, soundEffect, self, 1.0, Vector(0, 0, 0), true)
end

// Reward killstreaks!
function ScoringMixin:rewardKill()
    if Server then 
        if self.killstreak == 2 then 
            self:GiveUpgrade(kTechId.Adrenaline) 
            Shared:ShotgunMessage("Double Kill! " .. self:GetName() .. " gained adrenaline!")
            PlaySound(self, kSfxKillstreak1)
        end
        if self.killstreak == 4 then 
            self:GiveUpgrade(kTechId.Celerity) 
            Shared:ShotgunMessage("Multi Kill! " .. self:GetName() .. " gained celerity!") 
            PlaySound(self, kSfxKillstreak2)
        end
        if self.killstreak == 6 then 
            self:GiveUpgrade(kTechId.Regeneration) 
            Shared:ShotgunMessage("Ultra Kill! " .. self:GetName() .. " gained regeneration!") 
            PlaySound(self, kSfxKillstreak3)
        end
        if self.killstreak == 8 then 
            self:GiveUpgrade(kTechId.Caparace) 
            Shared:ShotgunMessage("MONSTERKILL!! " .. self:GetName() .. " gained carapace!") 
            PlaySound(self, kSfxKillstreak4)
        end
        
        
        // Give players that achieve quick successive kills the fire effect which gives 1.3x damage boost.
        local now = Shared.GetTime()        
        self.lastKillTime = self.lastKillTime or 0
        if now - self.lastKillTime <= 3 then
            RewardOnFireEffect(self)
            PlaySound(self, kSfxKillstreak4)
        end
        self.lastKillTime = now
    end
end

function RewardOnFireEffect(self)
   self:SetOnFire()
   Shared:ShotgunMessage(self:GetName() .. " is on fire! (temporary Weapons III)")
end
