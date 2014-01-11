
// deal full damage to 'friendlies'
kFriendlyFireScalar = 1


// Use this function to change damage according to current upgrades
function NS2Gamerules_GetUpgradedDamage(attacker, doer, damage, damageType, hitPoint)

    local damageScalar = 1

    if attacker ~= nil then
    
        // Boost damage 
        if HasMixin(attacker, "Fire") and attacker:GetIsOnFire() then
           damageScalar = kWeapons3DamageScalar 
        end
        
    end
        
    return damage * damageScalar
    
end
