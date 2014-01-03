// Everything combat related.

// aliens never sprint. 
function Alien:GetIsSprinting()
    return false
end

local kSpawnUmbraDuration = 3

function Skulk:InitWeapons()

    Alien.InitWeapons(self)
    
    self:GiveItem(Shotgun.kMapName)
    self:SetActiveWeapon(Shotgun.kMapName)
    
	// spawn aliens with several seconds of umbra, to get to a safe location.
    if Server then
        self:SetHasUmbra(true, kSpawnUmbraDuration)
    end    
end

function LeapMixin:GetHasSecondary(player)
    return true
end

// Disable buy menu for skulks.
function Skulk:Buy()
    self:PlayEvolveErrorSound()
end
