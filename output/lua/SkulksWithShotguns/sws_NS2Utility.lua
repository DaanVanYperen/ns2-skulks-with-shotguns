
// enable deathmatch mode by making everyone enemy of everyone.
local original_GetAreEnemies = GetAreEnemies;
function GetAreEnemies(entityOne, entityTwo)  

    // in team mode, we want regular team checks.
    if kTeamModeEnabled then
        return original_GetAreEnemies(entityOne,entityTwo)
    end

    return entityOne and entityTwo
end

// we are not friends! (disables wallsight for teammates)
local original_GetAreFriends = GetAreFriends;
function GetAreFriends(entityOne, entityTwo)

    // in team mode, do regular friend checks.
    if kTeamModeEnabled then
        return original_GetAreFriends(entityOne,entityTwo)
    end
    
    return false
end

// force default level for shell
function GetShellLevel(teamNumber)
    return 3
end

// force default level for spur
function GetSpurLevel(teamNumber)
    return 3
end

// force default level for veil
function GetVeilLevel(teamNumber) 
    return 3
end