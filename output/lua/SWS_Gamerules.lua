if (Server) then  

    function NS2Gamerules:BuildTeam(teamType)

        // we always want aliens, because only aliens are shotgun worthy!
        if (teamType == kAlienTeamType) or kTeamModeEnabled  then
            return AlienTeam()
        end
        
        // for deathmatch mode spawn marine team, to abuse the fact it doesn't spawn any structures.
        return MarineTeam()
    end
    
    function NS2Gamerules:CheckGameStart()
    
        if (self:GetGameState() == kGameState.NotStarted) or (self:GetGameState() == kGameState.PreGame) then
        
            // Start game when we have 
            local playerCount = self.team1:GetNumPlayers() + self.team2:GetNumPlayers()
            
            if  (playerCount > 0) then
                if self:GetGameState() == kGameState.NotStarted then
                    self:SetGameState(kGameState.PreGame)
                    Shared:ShotgunMessage("Lock and load!")
                end
            else
                if (self:GetGameState() == kGameState.PreGame) then
                    self:SetGameState(kGameState.NotStarted)
                    Shared:ShotgunMessage("Round aborted!")
                end
            end
            
        end
        
    end
    
    local kGameEndCheckInterval = 0.75
    local kTimeLimit = 60*5
          
    function NS2Gamerules:OnClientConnect(client)        
        Gamerules.OnClientConnect(self, client)
        
        local player = client:GetControllingPlayer()
        
        player:ShotgunMessage("You are playing custom mod: Skulks With Shotguns!")
        player:ShotgunMessage("This is not Vanilla NS2! Have fun!")
    end
    
    function NS2Gamerules:GetPregameLength()
        return 0
    end

    function NS2Gamerules:UpdatePregame(timePassed)

        if self:GetGameState() == kGameState.PreGame then
           
                self.team1:PlayPrivateTeamSound(ConditionalValue(self.team1:GetTeamType() == kAlienTeamType, NS2Gamerules.kAlienStartSound, NS2Gamerules.kMarineStartSound))
                self.team2:PlayPrivateTeamSound(ConditionalValue(self.team2:GetTeamType() == kAlienTeamType, NS2Gamerules.kAlienStartSound, NS2Gamerules.kMarineStartSound))
                
                self:SetGameState(kGameState.Started)
                self.sponitor:OnStartMatch()
                self.playerRanking:StartGame()
           
        end
        
    end
    

function Team:GetNumAlivePlayers()

    local numPlayers = 0
    
    for index, playerId in ipairs(self.playerIds) do

        local player = Shared.GetEntity(playerId)
        if player ~= nil and player:GetId() ~= Entity.invalidId and player:GetIsAlive() == true then
        
            numPlayers = numPlayers + 1
            
        end
        
    end
    
    return numPlayers
    
end
    
    function NS2Gamerules:CheckGameEnd()
    
        if self:GetGameStarted() and self.timeGameEnded == nil and not self.preventGameEnd then
                
            local team1Lost = (self.team1:GetNumAlivePlayers() <= 0) and (not self.team1:GetHasAbilityToRespawn())
            local team2Lost = (self.team2:GetNumAlivePlayers() <= 0) and (not self.team2:GetHasAbilityToRespawn())
            
            if kTeamModeEnabled then 
                if team1Lost then
                    Shared:ShotgunMessage("Team Vanilla Wins!")
                    self:EndGame(self.team2)
                end
                if team2Lost then
                    Shared:ShotgunMessage("Team Shadow Wins!")
                    self:EndGame(self.team1)
                end                
            else
                local noFoesRemain = (self.team2:GetNumAlivePlayers() <= 1) and (not self.team2:GetHasAbilityToRespawn())
                if noFoesRemain then
                    Shared:ShotgunMessage("Total Decimation!")
                    self:DrawGame()
                end
            end
            
            if self.timeLastGameEndCheck == nil or (Shared.GetTime() > self.timeLastGameEndCheck + kGameEndCheckInterval) then
            
                if self.timeSinceGameStateChanged >= kTimeLimit then
                    Shared:ShotgunMessage("Time limit reached! For shame..")
                    self:DrawGame()
                end

                self.timeLastGameEndCheck = Shared.GetTime()
                
            end
            
        end
        
    end

    // Network variable type time has a maximum value it can contain, so reload the map if
    // the age exceeds the limit and no game is going on.
    local kMaxServerAgeBeforeMapChange = 36000
    local function ServerAgeCheck(self)
    
        if self.gameState ~= kGameState.Started and Shared.GetTime() > kMaxServerAgeBeforeMapChange then
            MapCycle_ChangeMap(Shared.GetMapName())
        end
        
    end
    
    -- Force joining aliens.
    function NS2Gamerules:GetCanJoinTeamNumber(teamNumber)
    
        // we don't care about the teams in team mode!
        if kTeamModeEnabled then
            return true
        end
    
       return  (teamNumber == self.team2:GetTeamNumber())
    end

    local kPlayerSkillUpdateRate = 10
    local function UpdatePlayerSkill(self)
    
        self.lastTimeUpdatedPlayerSkill = self.lastTimeUpdatedPlayerSkill or 0
        if Shared.GetTime() - self.lastTimeUpdatedPlayerSkill > kPlayerSkillUpdateRate then
        
            self.lastTimeUpdatedPlayerSkill = Shared.GetTime()
            
            -- Remove the player skill old tag.
            local tags = { }
            Server.GetTags(tags)
            for t = 1, #tags do
            
                if string.find(tags[t], "P_S") then
                    Server.RemoveTag(tags[t])
                end
                
            end
            
            local averageSkill, marineAverageSkill, alienAverageSKill = self.playerRanking:GetAveragePlayerSkill()
            Server.AddTag("P_S" .. math.floor(averageSkill))
            
            self.gameInfo:SetAveragePlayerSkill(averageSkill)
            
        end
        
        self.playerRanking:OnUpdate()
        
    end
    
    function NS2Gamerules:OnUpdate(timePassed)
    
        PROFILE("NS2Gamerules:OnUpdate")
         
        GetEffectManager():OnUpdate(timePassed)
        
        UpdatePlayerSkill(self)
        
        if Server then
        
            if self.justCreated then
            
                if not self.gameStarted then
                    self:ResetGame()
                end
                
                self.justCreated = false
                
            end
            
            if self:GetMapLoaded() then
            
                self:CheckGameStart()
                self:CheckGameEnd()
                
                self:UpdatePregame(timePassed)
                self:UpdateToReadyRoom()
                self:UpdateMapCycle()
                ServerAgeCheck(self)
                
                self.timeSinceGameStateChanged = self.timeSinceGameStateChanged + timePassed
                
                self.worldTeam:Update(timePassed)
                self.team1:Update(timePassed)
                self.team2:Update(timePassed)
                self.spectatorTeam:Update(timePassed)
                
                // Send scores every so often
                self:UpdateScores()
                self:UpdatePings()
                self:UpdateHealth()
                self:UpdateTechPoints()
            end

            self.sponitor:Update(timePassed)
            
        end
        
    end
        
end