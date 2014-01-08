
    // pick a random team, or Team2 for non team games
    local function GetRandomShotgunTeam()
    
        // without teams we have deathmatch. put all in same team.
        if not kTeamModeEnabled then
            return kTeam2Index
        end
    
        // Join team with less players or random.
        local team1Players = GetGamerules():GetTeam(kTeam1Index):GetNumPlayers()
        local team2Players = GetGamerules():GetTeam(kTeam2Index):GetNumPlayers()
        
        // Join team with least.
        if team1Players < team2Players then
            return kTeam1Index
        elseif team2Players < team1Players then
            return kTeam2Index
        elseif math.random() < 0.5 then
           return kTeam1Index
        else
           return kTeam2Index
        end    
    end

    local function OnCommandJoinShotgun(client)
        local player = client:GetControllingPlayer()
        if player ~= nil and player:GetTeamNumber() == kTeamReadyRoom then
            GetGamerules():JoinTeam(player, GetRandomShotgunTeam())            
        end 
    end

    Event.Hook("Console_jointeamone", OnCommandJoinShotgun)
    Event.Hook("Console_jointeamtwo", OnCommandJoinShotgun)
    Event.Hook("Console_j1", OnCommandJoinShotgun)
    Event.Hook("Console_j2", OnCommandJoinShotgun)
