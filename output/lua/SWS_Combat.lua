// everything combat related.

// deal full damage to friendlies
kFriendlyFireScalar = 1

// enable deathmatch mode by making everyone enemy of everyone.
local original_GetAreEnemies = GetAreEnemies;
function GetAreEnemies(entityOne, entityTwo)  

    // in team mode, do team checks.
    if kTeamModeEnabled then
        return original_GetAreEnemies(entityOne,entityTwo)
    end

    return entityOne and entityTwo
end

// we are not friends! (disables wallsight for teammates)
local original_GetAreFriends = GetAreFriends;
function GetAreFriends(entityOne, entityTwo)

    // in team mode, do team checks.
    if kTeamModeEnabled then
        return original_GetAreFriends(entityOne,entityTwo)
    end
    
    return false
end

// we don't allow any entity usage.
function TeamMixin:GetCanBeUsed(player, useSuccessTable)
      useSuccessTable.useSuccess = false
end

function UmbraMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    // spawn umbra shielding.
    if self:GetHasUmbra() then
        local modifier = 0.1
        damageTable.damage = damageTable.damage * modifier
    end

end

// eggs are immune to damage.
function Egg:GetCanTakeDamageOverride()
    return false
end
