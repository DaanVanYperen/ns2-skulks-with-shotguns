// Reward killstreaks!
function ScoringMixin:rewardKill()
    if Server then 
        if self.killstreak == 2 then 
            self:GiveUpgrade(kTechId.Adrenaline) 
            Shared:ShotgunMessage("Double Kill! " .. self:GetName() .. " gained adrenaline!")
        end
        if self.killstreak == 4 then 
            self:GiveUpgrade(kTechId.Celerity) 
            Shared:ShotgunMessage("Multi Kill! " .. self:GetName() .. " gained celerity!") 
        end
        if self.killstreak == 6 then 
            self:GiveUpgrade(kTechId.Regeneration) 
            Shared:ShotgunMessage("Ultra Kill! " .. self:GetName() .. " gained regeneration!") 
        end
        if self.killstreak == 8 then 
            self:GiveUpgrade(kTechId.Caparace) 
            Shared:ShotgunMessage("Megakill! " .. self:GetName() .. " gained carapace!") 
        end
        if self.killstreak >= 10 then
            self:SetOnFire()
            Shared:ShotgunMessage("MONSTERKILL!! " .. self:GetName() .. " is on fire!")
        end
    end
end
