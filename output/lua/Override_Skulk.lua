// Everything combat related.

// aliens never sprint. 
function Alien:GetIsSprinting()
    return false
end

function Skulk:InitWeapons()

    Alien.InitWeapons(self)
    
    self:GiveItem(Shotgun.kMapName)
    self:SetActiveWeapon(Shotgun.kMapName)
end

function LeapMixin:GetHasSecondary(player)
    return true
end
