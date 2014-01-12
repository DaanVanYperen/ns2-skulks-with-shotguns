
local RemoveScripts = GetLocalFunction(ClientUI.EvaluateUIVisibility, 'RemoveScripts' )
local kShowAsClass = GetLocalFunction(RemoveScripts, 'kShowAsClass')

// information not needed for our gamemode.
kShowAsClass["Alien"].GUIBioMassDisplay = false
kShowAsClass["Alien"].GUIUpgradeChamberDisplay = false