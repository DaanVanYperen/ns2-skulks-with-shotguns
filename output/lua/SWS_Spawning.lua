
// allow eggs to spawn further away.
//local kEggMinRange = 4
//local kEggMaxRange = 5000

kAlienEggsPerHive = 5
kAlienSpawnTime = 2
kEggGenerationRate = 1

function NS2Gamerules:GetCanSpawnImmediately()
    return false
end
