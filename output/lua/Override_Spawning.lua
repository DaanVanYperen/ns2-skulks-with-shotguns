
// allow eggs to spawn further away.
//local kEggMinRange = 4
//local kEggMaxRange = 5000

kAlienEggsPerHive = 5
kAlienSpawnTime = 2
kEggGenerationRate = 1

/* unstable
function Hive:GenerateEggSpawns(hiveLocationName)

    PROFILE("Hive:GenerateEggSpawns")
    
    self.eggSpawnPoints = { }
    
    local minNeighbourDistance = 1.5
    local maxEggSpawns = 200
    local maxAttempts = maxEggSpawns * 10
    // pre-generate maxEggSpawns, trying at most maxAttempts times
    for index = 1, maxAttempts do
    
        // Note: We use kTechId.Skulk here instead of kTechId.Egg because they do not share the same extents.
        // The Skulk is a bit bigger so there are cases where it would find a location big enough for an Egg
        // but too small for a Skulk and the Skulk would be stuck when spawned.
        local extents = LookupTechData(kTechId.Skulk, kTechDataMaxExtents, nil)
        local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)  
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, self:GetModelOrigin(), kEggMinRange, kEggMaxRange, EntityFilterAll())
        
        if spawnPoint ~= nil then
            spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
        end
        
        local location = spawnPoint and GetLocationForPoint(spawnPoint)
        local locationName = location and location:GetName() or ""
        
        local sameLocation = spawnPoint ~= nil and locationName == hiveLocationName
        
        if spawnPoint ~= nil and sameLocation then
        
            local tooCloseToNeighbor = false
            for _, point in ipairs(self.eggSpawnPoints) do
            
                if (point - spawnPoint):GetLengthSquared() < (minNeighbourDistance * minNeighbourDistance) then
                
                    tooCloseToNeighbor = true
                    break
                    
                end
                
            end
            
            if not tooCloseToNeighbor then
            
                table.insert(self.eggSpawnPoints, spawnPoint)
                if #self.eggSpawnPoints >= maxEggSpawns then
                    break
                end
                
            end
            
        end
        
    end
    
    if #self.eggSpawnPoints < kAlienEggsPerHive then
        Print("Hive in location \"%s\" only generated %d egg spawns (needs %d). Make room more open.", hiveLocationName, table.count(self.eggSpawnPoints), kAlienEggsPerHive)
    end
    
end
*/