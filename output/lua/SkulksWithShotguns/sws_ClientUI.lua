
local RemoveScripts = GetLocalFunction(ClientUI.EvaluateUIVisibility, 'RemoveScripts' )
local kShowAsClass = GetLocalFunction(RemoveScripts, 'kShowAsClass')
local kShowOnTeam = GetLocalFunction(RemoveScripts, 'kShowOnTeam')

// information not needed for our gamemode.
kShowAsClass["Alien"].GUIBioMassDisplay = false
kShowAsClass["Alien"].GUIUpgradeChamberDisplay = false

//kShowAsClass["Alien"]["GUISpeedometer"] = true
kShowAsClass["Alien"]["GUIFlagScore"] = true
kShowAsClass["AlienSpectator"]["GUIFlagScore"] = true

kShowOnTeam[kTeam1Index]["GUIAlienSpectatorHUD"] = true
kShowOnTeam[kTeam2Index]["GUIAlienSpectatorHUD"] = true
kShowOnTeam[kTeam1Index]["GUIFlagScore"] = true
kShowOnTeam[kTeam2Index]["GUIFlagScore"] = true
//kShowOnTeam[kTeam1Index]["GUISpeedometer"] = true
//kShowOnTeam[kTeam2Index]["GUISpeedometer"] = true