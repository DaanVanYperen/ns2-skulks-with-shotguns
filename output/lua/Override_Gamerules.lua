if (Server) then  
    function NS2Gamerules:CheckGameStart()
    
        if (self:GetGameState() == kGameState.NotStarted) or (self:GetGameState() == kGameState.PreGame) then
        
            // Start game when we have 
            local playerCount = self.team1:GetNumPlayers() + self.team2:GetNumPlayers()
            
            if  (playerCount > 0) then
                if self:GetGameState() == kGameState.NotStarted then
                    self:SetGameState(kGameState.PreGame)
                    Shared:ShotgunMessage("Round started!")
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
    local kTimeLimit = 120
          
    function NS2Gamerules:OnClientConnect(client)        
        Gamerules.OnClientConnect(self, client)
        
        local player = client:GetControllingPlayer()
        
        player:ShotgunMessage("You are playing custom mod: Skulks With Shotguns!")
        player:ShotgunMessage("This is not Vanilla NS2! Have fun!")
    end

    function NS2Gamerules:CheckGameEnd()
    
        if self:GetGameStarted() and self.timeGameEnded == nil and not self.preventGameEnd then
        
            if self.timeLastGameEndCheck == nil or (Shared.GetTime() > self.timeLastGameEndCheck + kGameEndCheckInterval) then
            
                if self.timeSinceGameStateChanged >= kTimeLimit then
                    Shared:ShotgunMessage("Round timelimit reached!")
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