if Server then 

    local function OnCommandJoinShotgun(client)
        local player = client:GetControllingPlayer()
        if player ~= nil and player:GetTeamNumber() == kTeamReadyRoom then
            GetGamerules():JoinTeam(player, kTeam2Index)            
        end 
    end

    Event.Hook("Console_jointeamone", OnCommandJoinShotgun)
    Event.Hook("Console_jointeamtwo", OnCommandJoinShotgun)
    Event.Hook("Console_j1", OnCommandJoinShotgun)
    Event.Hook("Console_j2", OnCommandJoinShotgun)

end
