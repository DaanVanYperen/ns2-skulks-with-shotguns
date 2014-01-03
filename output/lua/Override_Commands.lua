if Server then 

    local function JoinTeam(player, teamIndex)
    
        if player ~= nil and player:GetTeamNumber() == kTeamReadyRoom then
        
            // Auto team balance checks.
            local allowed = GetGamerules():GetCanJoinTeamNumber(teamIndex)
                
            if allowed or Shared.GetCheatsEnabled() then
                return GetGamerules():JoinTeam(player, teamIndex)
            else
                Server.SendNetworkMessage(player, "JoinError", BuildJoinErrorMessage(), false)
                return false
            end
            
        end 
    
        return false
    
    end 


    local function OnCommandJoinShotgun(client)
        local player = client:GetControllingPlayer()
        JoinTeam(player,kTeam2Index)
    end
    Event.Hook("Console_j1", OnCommandJoinShotgun)
    Event.Hook("Console_j2", OnCommandJoinShotgun)

end