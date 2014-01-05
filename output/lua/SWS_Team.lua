/** -- START UNMODIFIED CODE - JUST HERE TO disable team number in alien spectator -- **/

local function UpdateQueuePosition(self)

    if self:GetIsDestroyed() then
        return false
    end
    
    self.queuePosition = self:GetTeam():GetPlayerPositionInRespawnQueue(self)
    return true
    
end

local function UpdateWaveTime(self)

    if self:GetIsDestroyed() then
        return false
    end
    
    if self.queuePosition <= self:GetTeam():GetEggCount() then
        local entryTime = self:GetRespawnQueueEntryTime() or 0
        self.timeWaveSpawnEnd = entryTime + kAlienSpawnTime
    else
        self.timeWaveSpawnEnd = 0
    end
    
    Server.SendNetworkMessage(Server.GetOwner(self), "SetTimeWaveSpawnEnds", { time = self.timeWaveSpawnEnd }, true)
    
    if not self.sentRespawnMessage then
    
        Server.SendNetworkMessage(Server.GetOwner(self), "SetIsRespawning", { isRespawning = true }, true)
        self.sentRespawnMessage = true
        
    end
    
    return true
    
end

/** -- END UNMODIFIED CODE - JUST HERE TO disable team number in alien spectator -- **/

function AlienSpectator:OnInitialized()

    TeamSpectator.OnInitialized(self)

    // SWS FIX: self:SetTeamNumber(2)
    
    self.eggId = Entity.invalidId
    self.queuePosition = 0
    self.autoSpawnTime = 0
    self.movedToEgg = false
    
    if Server then
    
        self.evolveTechIds = { kTechId.Skulk }
        self:AddTimedCallback(UpdateQueuePosition, 0.1)
        self:AddTimedCallback(UpdateWaveTime, 0.1)
        UpdateQueuePosition(self)
        
    end
    
end


if Server then

// return all available eggs for a certain team.
local function GetFreeEggs( teamNumber )
    local validEggs = {}
    local eggs = GetEntitiesForTeam("Egg", teamNumber)        
    
    // Find the closest egg, doesn't matter which Hive owns it.
    for _, egg in ipairs(eggs) do
        if egg:GetIsFree() then
            table.insert(validEggs, egg)
        end
    end
    
    return validEggs
end

// randomized egg spawning, instead of desired / proximate to death like vanilla.
local function AssignPlayerToEgg(self, player, enemyTeamPosition)

    local success = false    
    local eggs = GetFreeEggs( self:GetTeamNumber() )    
    local egg = eggs[math.random(1,#eggs)]
    
    if egg then
        egg:SetQueuedPlayerId(player:GetId())
        success = true
    end
    
    return success
    
end

function AlienTeam:GetHasAbilityToRespawn()
    local eggs = GetEntitiesForTeam("Egg", self:GetTeamNumber())
    return (table.count(eggs) > 0) or (self:GetTeamResources() > 0)
end

/** -- START UNMODIFIED CODE - JUST HERE FOR AssignPlayerToEgg -- **/

local function GetCriticalHivePosition(self)

    // get position of enemy team, ignore commanders
    local numPositions = 0
    local teamPosition = Vector(0, 0, 0)
    
    for _, player in ipairs( GetEntitiesForTeam("Player", GetEnemyTeamNumber(self:GetTeamNumber())) ) do

        if (player:isa("Marine") or player:isa("Exo")) and player:GetIsAlive() then
        
            numPositions = numPositions + 1
            teamPosition = teamPosition + player:GetOrigin()
        
        end

    end
    
    if numPositions > 0 then    
        return teamPosition / numPositions    
    end

end

local function UpdateEggGeneration(self)

    if not self.timeLastEggUpdate then
        self.timeLastEggUpdate = Shared.GetTime()
    end

    if self.timeLastEggUpdate + ScaleWithPlayerCount(kEggGenerationRate, #GetEntitiesForTeam("Player", self:GetTeamNumber())) < Shared.GetTime() then

        local enemyTeamPosition = GetCriticalHivePosition(self)
        local hives = GetEntitiesForTeam("Hive", self:GetTeamNumber())
        
        local builtHives = {}
        
        // allow only built hives to spawn eggs
        for _, hive in ipairs(hives) do
        
            if hive:GetIsBuilt() and hive:GetIsAlive() then
                table.insert(builtHives, hive)
            end
        
        end
        
        if enemyTeamPosition then
            Shared.SortEntitiesByDistance(enemyTeamPosition, builtHives)
        end
        
        for _, hive in ipairs(builtHives) do
        
            if hive:UpdateSpawnEgg() then
                break
            end
        
        end
        
        self.timeLastEggUpdate = Shared.GetTime()
    
    end

end

local function UpdateEggCount(self)

    self.eggCount = 0

    for _, egg in ipairs(GetEntitiesForTeam("Egg", self:GetTeamNumber())) do
    
        if egg:GetIsFree() and egg:GetGestateTechId() == kTechId.Skulk then        
            self.eggCount = self:GetEggCount() + 1
        end
    
    end

end

local function GetCriticalHivePosition(self)

    // get position of enemy team, ignore commanders
    local numPositions = 0
    local teamPosition = Vector(0, 0, 0)
    
    for _, player in ipairs( GetEntitiesForTeam("Player", GetEnemyTeamNumber(self:GetTeamNumber())) ) do

        if (player:isa("Marine") or player:isa("Exo")) and player:GetIsAlive() then
        
            numPositions = numPositions + 1
            teamPosition = teamPosition + player:GetOrigin()
        
        end

    end
    
    if numPositions > 0 then    
        return teamPosition / numPositions    
    end

end

local function UpdateAlienSpectators(self)

    if self.timeLastSpectatorUpdate == nil then
        self.timeLastSpectatorUpdate = Shared.GetTime() - 1
    end

    if self.timeLastSpectatorUpdate + 1 <= Shared.GetTime() then

        local alienSpectators = self:GetSortedRespawnQueue()
        local enemyTeamPosition = GetCriticalHivePosition(self)
        
        for i = 1, #alienSpectators do
        
            local alienSpectator = alienSpectators[i]
            // Do not spawn players waiting in the auto team balance queue.
            if alienSpectator:isa("AlienSpectator") and not alienSpectator:GetIsWaitingForTeamBalance() then
            
                // Consider min death time.
                if alienSpectator:GetRespawnQueueEntryTime() + kAlienSpawnTime < Shared.GetTime() then
                
                    local egg = nil
                    if alienSpectator.GetHostEgg then
                        egg = alienSpectator:GetHostEgg()
                    end
                    
                    // Player has no egg assigned, check for free egg.
                    if egg == nil then
                    
                        local success = AssignPlayerToEgg(self, alienSpectator, enemyTeamPosition)
                        
                        // We have no eggs currently, makes no sense to check for every spectator now.
                        if not success then
                            break
                        end
                        
                    end
                    
                end
                
            end
            
        end
    
        self.timeLastSpectatorUpdate = Shared.GetTime()

    end
    
end

local function UpdateCystConstruction(self, deltaTime)

    local numCystsToConstruct = self:GetNumCapturedTechPoints()

    for _, cyst in ipairs(GetEntitiesForTeam("Cyst", self:GetTeamNumber())) do
    
        local parent = cyst:GetCystParent()
        if not cyst:GetIsBuilt() and parent and parent:GetIsBuilt() then
      
            cyst:Construct(deltaTime)
            numCystsToConstruct = numCystsToConstruct - 1

        end
        
        if numCystsToConstruct <= 0 then
            break
        end
    
    end

end


function AlienTeam:Update(timePassed)

    PROFILE("AlienTeam:Update")
    
    PlayingTeam.Update(self, timePassed)
    
    self:UpdateTeamAutoHeal(timePassed)
    UpdateEggGeneration(self)
    UpdateEggCount(self)
    UpdateAlienSpectators(self)
    self:UpdateBioMassLevel()
    
    local shellLevel = GetShellLevel(self:GetTeamNumber())  
    for index, alien in ipairs(GetEntitiesForTeam("Alien", self:GetTeamNumber())) do
        alien:UpdateArmorAmount(shellLevel)
        alien:UpdateHealthAmount(math.min(12, self.bioMassLevel), self.maxBioMassLevel)
    end
    
     UpdateCystConstruction(self, timePassed)
    
end

/** -- END UNMODIFIED CODE - JUST HERE FOR AssignPlayerToEgg -- **/

end