
// Disable buy menu for skulks.
function Skulk:Buy()
    self:PlayEvolveErrorSound()
end

// Skulks With Shotguns: reward kills.
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

// set default levels for our abilities.

function GetShellLevel(teamNumber)
    return 2
end

function GetSpurLevel(teamNumber)
    return 2
end

function GetVeilLevel(teamNumber) 
    return 2
end