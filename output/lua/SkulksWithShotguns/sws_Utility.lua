function Shared:ShotgunMessage(chatMessage)
    if (chatMessage == nil) then return end
    Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Shotgun Mod", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
    Shared.Message("Chat All - Shotgun Mod: " .. chatMessage)
    Server.AddChatToHistory(chatMessage, "Shotgun Mod", 0, kTeamReadyRoom, false)
end

function Shared:ShotgunEgoStroke(player, chatMessagePlayer, chatMessageOthers)
    if (chatMessage == nil) then return end
    Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Shotgun Mod", -1, kTeamReadyRoom, kNeutralTeamType, chatMessagePlayer), true)
    Shared.Message("Chat All - Shotgun Mod: " .. chatMessage)
    Server.AddChatToHistory(chatMessage, "Shotgun Mod", 0, kTeamReadyRoom, false)
end

function Shared:ShotgunError(errorMessage)
    if (chatMessage == nil) then return end
    self:ShotgunMessage("ERROR: " .. errorMessage)
    Shared.Message("ERROR: " .. errorMessage)
end

function Shared:ShotgunWarning(errorMessage)
    if (chatMessage == nil) then return end
    self:ShotgunMessage("warning: " .. errorMessage)
    Shared.Message("warning: " .. errorMessage)
end

function Player:ShotgunMessage(chatMessage)
    Server.SendNetworkMessage(self, "Chat", BuildChatMessage(false, "Shotgun Mod", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
end      


    
    /**
     * Return enemy team of passed in team.
     */
    function GetEnemyTeam(team)
    
        local rules = GetGamerules()
    
        if team == rules:GetTeam1() then 
            return rules:GetTeam2()
         else
            return rules:GetTeam1()
        end
    end


-- Retrieve local function in a non-local function
-- Useful if you need to override a local function in a local function with ReplaceLocals but lack a reference to it.
function GetLocalFunction(originalFunction, localFunctionName)

    local index = 1
    while true do
        
        local n, v = debug.getupvalue(originalFunction, index)
        if not n then
           break
        end
            
        if n == localFunctionName then
            return v
        end
            
        index = index + 1
            
    end
    
    return nil
    
end