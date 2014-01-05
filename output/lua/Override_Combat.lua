// everything combat related.

// deal full damage to friendlies
kFriendlyFireScalar = 1

// enable deathmatch mode by making everyone enemy of everyone.
local original_GetAreEnemies = GetAreEnemies;
function GetAreEnemies(entityOne, entityTwo)  
    return entityOne and entityTwo
end

// we are not friends! (disables wallsight for teammates)
function GetAreFriends(entityOne, entityTwo)
    return false
end

// specifically allow entity usage by using original enemy logic.
function TeamMixin:GetCanBeUsed(player, useSuccessTable)
        useSuccessTable.useSuccess = false
//    if original_GetAreEnemies(player, self) then
        //useSuccessTable.useSuccess = false
    //end
end

function UmbraMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    if self:GetHasUmbra() then
    
        local modifier = 0.1
    
        damageTable.damage = damageTable.damage * modifier
        
    end
    

end

