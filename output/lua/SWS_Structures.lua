
local function CreateCysts(hive, harvester, teamNumber)

    local hiveOrigin = hive:GetOrigin()
    local harvesterOrigin = harvester:GetOrigin()
    
    // Spawn all the Cyst spawn points close to the hive.
    local dist = (hiveOrigin - harvesterOrigin):GetLength()
    for c = 1, #Server.cystSpawnPoints do
    
        local spawnPoint = Server.cystSpawnPoints[c]
        if (spawnPoint - hiveOrigin):GetLength() <= (dist * 1.5) then
        
            local cyst = CreateEntityForTeam(kTechId.Cyst, spawnPoint, teamNumber, nil)
            cyst:SetConstructionComplete()
            cyst:SetInfestationFullyGrown()
            cyst:SetImmuneToRedeploymentTime(1)
            
        end
        
    end
    
end
 
// Disable infestation tracking right now.
function InfestationTrackerMixin:UpdateInfestedState(onInfestation)
    self:SetInfestationState(true)
end

if Server then 

    // stop anything from spawning initially.
    function PlayingTeam:SpawnInitialStructures(techPoint)
        return nil,nil
    end 

    function MarineTeam:SpawnInitialStructures(techPoint)
        return nil,nil
    end
    
    function AlienTeam:SpawnInitialStructures(techPoint)
        return nil,nil
    end
    
    function PlayingTeam:ResetTeam()
        self.conceded = false
        return nil
    end
        
    // override default spawning behaviour. we want to spawn at random location.
    function AlienTeam:ResetTeam()

        self.conceded = false
        
            local hives = { }
            local i = 0
        
            for index, current in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
                if current:GetAttached() == nil then
                        current:SpawnResourceTowerForTeam(self, kTechId.Hive)
                        hives[(#hives+1)] = hive
                end
            end

            if #hives > 0 then
                local players = GetEntitiesForTeam("Player", self:GetTeamNumber())
                for p = 1, #players do
                    local player = players[p]
                    player:OnInitialSpawn(hives[math.random(1,#hives)]:GetOrigin())
                    player:SetResources(kPlayerInitialIndivRes)
                end
    
                return hives[1]
            end
    
            return nil
    end

end