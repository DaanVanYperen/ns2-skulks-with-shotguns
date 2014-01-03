
    function Shared:ShotgunMessage(chatMessage)
        if (chatMessage == nil) then return end
        Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Shotgun Mod", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
        Shared.Message("Chat All - Shotgun Mod: " .. chatMessage)
        Server.AddChatToHistory(chatMessage, "Shotgun Mod", 0, kTeamReadyRoom, false)
    end

    function Player:ShotgunMessage(chatMessage)
        Server.SendNetworkMessage(self, "Chat", BuildChatMessage(false, "Shotgun Mod", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
    end      


Script.Load("lua/Override_Skulk.lua")
Script.Load("lua/Override_Combat.lua")
Script.Load("lua/Override_Spawning.lua")
Script.Load("lua/Override_Gamerules.lua")
Script.Load("lua/Override_Commands.lua")
Script.Load("lua/Override_Scoring.lua")
Script.Load("lua/Override_Structures.lua")
Script.Load("lua/Override_Team.lua")