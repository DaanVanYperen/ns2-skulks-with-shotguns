Script.Load("lua/SWS_Locale.lua")

    function Shared:ShotgunMessage(chatMessage)
        if (chatMessage == nil) then return end
        Server.SendNetworkMessage("Chat", BuildChatMessage(false, "Shotgun Mod", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
        Shared.Message("Chat All - Shotgun Mod: " .. chatMessage)
        Server.AddChatToHistory(chatMessage, "Shotgun Mod", 0, kTeamReadyRoom, false)
    end

    function Player:ShotgunMessage(chatMessage)
        Server.SendNetworkMessage(self, "Chat", BuildChatMessage(false, "Shotgun Mod", -1, kTeamReadyRoom, kNeutralTeamType, chatMessage), true)
    end      

// number of eggs that can spawn in one round.
kPlayingTeamInitialTeamRes = 2
kTeamResourcePerTick = 0

kTeam1Name = "Shadow"
kTeam2Name = "Vanilla"

kTeamModeEnabled = true

Script.Load("lua/SWS_GameInfo.lua")
Script.Load("lua/SWS_Skulk.lua")
Script.Load("lua/SWS_Combat.lua")
Script.Load("lua/SWS_Spawning.lua")
Script.Load("lua/SWS_Gamerules.lua")
Script.Load("lua/SWS_Commands.lua")
Script.Load("lua/SWS_Structures.lua")
Script.Load("lua/SWS_Team.lua")
Script.Load("lua/SWS_Rewards.lua")