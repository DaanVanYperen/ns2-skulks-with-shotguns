
// Constants
Script.Load("lua/SkulksWithShotguns/sws_Globals.lua")
Script.Load("lua/SkulksWithShotguns/sws_DamageTypes.lua")
Script.Load("lua/SkulksWithShotguns/sws_Sounds.lua")

// Utilities
Script.Load("lua/SkulksWithShotguns/sws_Locale.lua")
Script.Load("lua/SkulksWithShotguns/sws_Utility.lua")
Script.Load("lua/SkulksWithShotguns/sws_NS2Utility.lua")
Script.Load("lua/SkulksWithShotguns/sws_EventMessenger.lua")

// Mixin overrides
Script.Load("lua/SkulksWithShotguns/sws_UmbraMixin.lua")
Script.Load("lua/SkulksWithShotguns/sws_TeamMixin.lua")
Script.Load("lua/SkulksWithShotguns/sws_ScoringMixin.lua")
Script.Load("lua/SkulksWithShotguns/sws_LeapMixin.lua")
Script.Load("lua/SkulksWithShotguns/sws_FireMixin.lua")
Script.Load("lua/SkulksWithShotguns/sws_PointGiverMixin.lua")

// New Mixins
Script.Load("lua/SkulksWithShotguns/sws_FlagbearerMixin.lua")
Script.Load("lua/SkulksWithShotguns/sws_EventMessageMixin.lua")
Script.Load("lua/SkulksWithShotguns/sws_ExplosiveTraumaMixin.lua")

// Entity overrides.
Script.Load("lua/SkulksWithShotguns/sws_AlienSpectator.lua")
Script.Load("lua/SkulksWithShotguns/sws_AlienTeam.lua")
Script.Load("lua/SkulksWithShotguns/sws_Gamerules.lua")
Script.Load("lua/SkulksWithShotguns/sws_MarineTeam.lua")
Script.Load("lua/SkulksWithShotguns/sws_PlayingTeam.lua")
Script.Load("lua/SkulksWithShotguns/sws_MapBlip.lua")
Script.Load("lua/SkulksWithShotguns/sws_Crag.lua")

// New Entities
Script.Load("lua/SkulksWithShotguns/sws_Skulks.lua") -- shotgun skulks
Script.Load("lua/SkulksWithShotguns/sws_Respawn.lua")
Script.Load("lua/SkulksWithShotguns/sws_Flags.lua")
Script.Load("lua/SkulksWithShotguns/sws_AlienTeamInfo.lua")

// Client Specific Stuff
// loading it here, so we don't get strange precedence issues.
if Client then
    Script.Load("lua/SkulksWithShotguns/sws_Player_Client.lua")
    Script.Load("lua/SkulksWithShotguns/sws_ClientUI.lua")
end