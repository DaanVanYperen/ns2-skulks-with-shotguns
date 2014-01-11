if Server then

    Script.Load("lua/SkulksWithShotguns/sws_Flags.lua")
    Script.Load("lua/SkulksWithShotguns/sws_Skulks.lua")
    
    // disable default structure spawning.   
    function AlienTeam:SpawnInitialStructures(techPoint)
        return nil,nil
    end


    function AlienTeam:Initialize(teamName, teamNumber)
    
        PlayingTeam.Initialize(self, teamName, teamNumber)
        
        self.respawnEntity = ShotgunSkulk.kMapName
    
        // List stores all the structures owned by builder player types such as the Gorge.
        // This list stores them based on the player platform ID in order to maintain structure
        // counts even if a player leaves and rejoins a server.
        self.clientOwnedStructures = { }
        self.lastAutoHealIndex = 1
        
        self.updateAlienArmorInTicks = nil
        
        self.timeLastWave = 0
        self.bioMassLevel = 0
        self.bioMassAlertLevel = 0
        self.maxBioMassLevel = 0
        self.bioMassFraction = 0
    
    end
    
    function AlienTeam:GetHasAbilityToRespawn()
        local eggs = GetEntitiesForTeam("Egg", self:GetTeamNumber())
        local hive = GetEntitiesForTeam("Hive", self:GetTeamNumber())
        return (table.count(eggs) > 0) or ((self:GetTeamResources() > 0) and (table.count(hive) > 0))
    end
    
    function AlienTeam:GetSpawnLocations()
        if self:GetTeamNumber() == kVanillaTeamIndex then
            return Server.vanillaSpawnList
        else
            return Server.shadowSpawnList
        end
    end
    
    function AlienTeam:GetFlagSpawnLocation()
        if self:GetTeamNumber() == kVanillaTeamIndex then
            return Server.vanillaFlagSpawn
        else
            return Server.shadowFlagSpawn
        end
    end    
    
    function AlienTeam:RespawnPlayer(player, origin, angles)

        assert(self:GetIsPlayerOnTeam(player), "Player isn't on team!")
    
        if origin == nil or angles == nil then
    
            // Randomly choose unobstructed spawn points to respawn the player
            local spawnPoint = nil
            local spawnPoints = self:GetSpawnLocations()
            local numSpawnPoints = table.maxn(spawnPoints)
            
            if numSpawnPoints > 0 then
                    local spawnPoint = GetRandomClearSpawnPoint(player, spawnPoints)
                    if spawnPoint ~= nil then
                        origin = spawnPoint:GetOrigin()
                        angles = spawnPoint:GetAngles()
                    end
            end
        end     
            
        // Move origin up and drop it to floor to prevent stuck issues with floating errors or slightly misplaced spawns
        if origin ~= nil then
        
            SpawnPlayerAtPoint(player, origin, angles)
            
            player:ClearEffects()
        
            return true
        
        else
            Print("Team:RespawnPlayer(player, %s, %s) - Must specify origin.", ToString(origin), ToString(angles))
        end
    
        return false
    end
    
    function AlienTeam:placeRandomStalkForTeam( )
    
        local availableStalkSpots = { }
        
        // determine free points.
        for index, current in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
           if current:GetAttached() == nil then
               availableStalkSpots[(#availableStalkSpots+1)] = current
           end
        end
        
        if #availableStalkSpots > 0 then        
            // success! pick a random spot.
            return availableStalkSpots[math.random(1,#availableStalkSpots)]:SpawnResourceTowerForTeam(self, kTechId.Hive)
        else
            // error!
            return nil
        end
    end
    
    function AlienTeam:ResetRespawnFlag()
    
        local flagSpawnpoint = self:GetFlagSpawnLocation()
        
        for index, flag in ipairs(GetEntitiesForTeam("Flag", self:GetTeamNumber())) do
            DestroyEntity(flag)
        end
        
        local flag = CreateEntity(Flag.kMapName, flagSpawnpoint:GetOrigin(), self:GetTeamNumber())
        flag:SetOrigin(flagSpawnpoint:GetOrigin())    
        if flag:GetAngles() ~= nil then
            flag:SetAngles(flagSpawnpoint:GetAngles())
        end        
        
    end
    
    function AlienTeam:FlagExists()
        return next(GetEntitiesForTeam("Flag", self:GetTeamNumber())) ~= nil
    end
        
    // override default spawning behaviour. we want to spawn at random location.
    function AlienTeam:ResetTeam()

            self.conceded = false
    
            if kTeamModeEnabled then        
                self:ResetRespawnFlag()
            end
        
            local stalks = { }

            // count the number of stalk spots available..            local count = 0
            local count = Shared.GetEntitiesWithClassname("ResourcePoint"):GetSize() 
                
            if kTeamModeEnabled then
                 // for team based mode, we want to divide the stalks between the teams.
                 // round it down to 2's.
                 count = count - (count % 2)
                 count = count / 2
            end
            
            // don't spawn buildings for Shadow skulks in deathmatch mode.
            if kTeamModeEnabled or (self:GetTeamNumber() == kVanillaTeamIndex) then
                
                // place stalks in a random order.
                while count > 0 do
                    hive = self:placeRandomStalkForTeam(resourcePoints)
                    if hive ~= nil then
                        stalks[(#stalks+1)] = hive
                    else
                        Shared.Message("Error: Not enough resource Points available. Make sure there are at least 2 in the map")
                    end
                    count = count - 1
                end
    
                if #stalks > 0 then
                    local players = GetEntitiesForTeam("Player", self:GetTeamNumber())
                    for p = 1, #players do
                        local player = players[p]
                        player:OnInitialSpawn(stalks[math.random(1,#stalks)]:GetOrigin())
                        player:SetResources(kPlayerInitialIndivRes)
                    end
        
                    return stalks[1]
                end
               
            end
    
            return nil
    end
    
    // randomized egg spawning, instead of desired / proximate to death like vanilla.
    local function CustomAssignPlayerToEgg(self, player, enemyTeamPosition)
        
        local team = player:GetTeam()
        if team ~= nil then
            if team:GetTeamResources() <= 0 then
                 // no resources remaining to spawn eggs! re-enter the queue with a big delay.
                 player:SetRespawnQueueEntryTime(Shared.GetTime() + 5)
                return false
            end
            
            // manual replace respawn! We don't want the whole egg business. also fix it so we spawn shotgun skulks.
            local success, player = team:ReplaceRespawnPlayer(player, nil, nil)
            if player ~= nil then
                player:SetCameraDistance(0)
                player:SetHatched()
                
                player:TriggerEffects("teleport_end", { classname = player:GetClassName() })
                
                // pay for the respawn. PAY!
                team:AddTeamResources(-1)
            end
            
            return success
        end

        return false
    end
    

    // we don't want egg generation. Instead, we ensure our flag is still here.
    local function ExtendedAlienTeamUpdateMethod(self) 
    
        // restore missing flag.
        shouldCheckForFlag = (self.timeLastFlagCheck or 0) + 1 < Shared.GetTime()
        if shouldCheckForFlag and not self:FlagExists() then
            self.timeLastFlagCheck = Shared.GetTime()
            self:ResetRespawnFlag()
        end
    end

    local function CustomUpdateEggCount(self)
        // team resources count as eggs.
        self.eggCount = self:GetTeamResources()
    end

    // we need to do this to replace egg spawning logic. 
    local updateAlienSpectators = GetLocalFunction(AlienTeam.Update, 'UpdateAlienSpectators')
    ReplaceLocals( updateAlienSpectators, {  AssignPlayerToEgg = CustomAssignPlayerToEgg } )

    // replace egg spawning and counting logic.            
    ReplaceLocals( AlienTeam.Update, { UpdateEggGeneration = ExtendedAlienTeamUpdateMethod, UpdateEggCount = CustomUpdateEggCount } )

end