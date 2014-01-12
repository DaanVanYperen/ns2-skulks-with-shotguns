// number of eggs that can spawn in one round.
kPlayingTeamInitialTeamRes = 60
kTeamResourcePerTick = 0

// Duration the spawn umbra is in effect.
kSpawnUmbraDuration = 1.25

kTeam1Name = "Shadow"
kTeam2Name = "Vanilla"

kShadowTeamIndex = kTeam1Index
kVanillaTeamIndex = kTeam2Index

kCaptureWinPoints = 5

// Speed factor of shotgun skulks while carrying gorge (flag).
kSkulkSpeedFactorWhileCarryGorge = 0.95

// Seconds the gorge remains on the floor when dropped. 
// important for if it gets lodged somewhere unreachable by accident.
kFlagFloorTimeout = 45

// SWS team mode.
kTeamModeEnabled = false

// Tweak egg spawns.
kAlienEggsPerHive = 5
kAlienSpawnTime = 2
kEggGenerationRate = 1

function ConcatEnum(e1, e2)
   local values = {}
   
   for index, value in ipairs(e1) do
       table.insert(values, value)
   end

   for index, value in ipairs(e2) do
        table.insert(values, value)
   end
    
   return enum(values)        
end

local newEntityClasses = enum(  { "ShotgunSkulk", "Flag" } )

// Register shotgunskulk
kPlayerStatus =  ConcatEnum(kPlayerStatus, newEntityClasses)
kMinimapBlipType = ConcatEnum(kMinimapBlipType, newEntityClasses)

// Introduce icons for new entities.
local Original_BuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()
   local result = Original_BuildClassToGrid()
    
    result["ShotgunSkulk"] = result["Skulk"]
    result["Flag"] = result["Gorge"]
    
    return result
end 