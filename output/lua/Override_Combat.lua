// everything combat related.

// deal full damage to friendlies
kFriendlyFireScalar = 1

// enable deathmatch mode by making everyone enemy of everyone.
local original_GetAreEnemies = GetAreEnemies;
function GetAreEnemies(entityOne, entityTwo)  
    return entityOne and entityTwo
end

// specifically allow command chair entry using original enemy logic.
function TeamMixin:GetCanBeUsed(player, useSuccessTable)
    if original_GetAreEnemies(player, self) then
        useSuccessTable.useSuccess = false
    end
end
