if Server then

    // disable default structure spawning.   
    function AlienTeam:SpawnInitialStructures(techPoint)
        return nil,nil
    end
    
    function AlienTeam:GetHasAbilityToRespawn()
        local eggs = GetEntitiesForTeam("Egg", self:GetTeamNumber())
        local hive = GetEntitiesForTeam("Hive", self:GetTeamNumber())
        return (table.count(eggs) > 0) or ((self:GetTeamResources() > 0) and (table.count(hive) > 0))
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
        
    // override default spawning behaviour. we want to spawn at random location.
    function AlienTeam:ResetTeam()

        self.conceded = false
        
            local stalks = { }

            // count the number of stalk spots available..            local count = 0
            local count = Shared.GetEntitiesWithClassname("ResourcePoint"):GetSize() 
                
            if kTeamModeEnabled then
                 // for team based mode, we want to divide the stalks between the teams.
                 // round it down to 2's.
                 count = count - (count % 2)
                 count = count / 2
            end
                
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
    
            return nil
    end


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
    local function CustomAssignPlayerToEgg(self, player, enemyTeamPosition)

        local success = false    
        local eggs = GetFreeEggs( self:GetTeamNumber() )    
        local egg = eggs[math.random(1,#eggs)]
    
        if egg then
            egg:SetQueuedPlayerId(player:GetId())
            success = true
        end
    
        return success
        
    end
    
    local updateAlienSpectators = GetLocalFunction(AlienTeam.Update, 'UpdateAlienSpectators')
    ReplaceLocals( updateAlienSpectators, { AssignPlayerToEgg = CustomAssignPlayerToEgg } )
        

end