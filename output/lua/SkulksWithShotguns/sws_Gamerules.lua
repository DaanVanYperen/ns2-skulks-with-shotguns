// We override NS2Gamerules to avoid having to override the NS2 gameserver.
// @todo port this all to our own gamerules class.

if (Server) then            

    local kGameEndCheckInterval = 0.75
    local kTimeLimit = 60*5

    function NS2Gamerules:GetCanSpawnImmediately()
        // we want to force respawn via spawners.
        return true
    end

    function NS2Gamerules:BuildTeam(teamType)
        // TEAM MODE - we always want aliens, because only aliens are shotgun worthy!
        return AlienTeam()
    end

    // Force joining aliens.
    function NS2Gamerules:GetCanJoinTeamNumber(teamNumber)
    
        // TEAM MODE - we don't care about the teams in team mode!
        if kTeamModeEnabled then
            return true
        end
    
       // DEATMATCH - force team 2
       return  (teamNumber == self.team2:GetTeamNumber())
    end
    
    function NS2Gamerules:CheckGameStart()
    
        if (self:GetGameState() == kGameState.NotStarted) or (self:GetGameState() == kGameState.PreGame) then
        
            // Start game when we have /any/ players in the game.
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
    
    function NS2Gamerules:OnClientConnect(client)        
        Gamerules.OnClientConnect(self, client)
        
        local player = client:GetControllingPlayer()
        
        // warn players they are not getting a typical match. 
        // Wouldn't want to confuse the greens.
        player:ShotgunMessage("You are playing custom mod: Skulks With Shotguns!")
        player:ShotgunMessage("This is not Vanilla NS2! Have fun!")
    end
    
    function NS2Gamerules:GetPregameLength()
        // we have no need for a pre-game.
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
    
    // returns number of living players on team.
    local function GetNumAlivePlayers(self)
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
                
            // no more living players on team, and out of spawns? game lost/deathmatch over!
            local team1Lost = (GetNumAlivePlayers(self.team1) <= 0) and (not self.team1:GetHasAbilityToRespawn())
            local team2Lost = (GetNumAlivePlayers(self.team2) <= 0) and (not self.team2:GetHasAbilityToRespawn())
            
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
                // no foes remain.
                local noFoesRemain = (GetNumAlivePlayers(self.team2) <= 1) and (not self.team2:GetHasAbilityToRespawn())
                if noFoesRemain then
                    Shared:ShotgunMessage("Total Decimation!")
                    self:DrawGame()
                end
            end
            
            // game is taking too long.
            if self.timeLastGameEndCheck == nil or (Shared.GetTime() > self.timeLastGameEndCheck + kGameEndCheckInterval) then
            
                if self.timeSinceGameStateChanged >= kTimeLimit then
                    Shared:ShotgunMessage("Time limit reached! For shame..")
                    self:DrawGame()
                end

                self.timeLastGameEndCheck = Shared.GetTime()
                
            end
            
        end
        
    end
    
    
    function NS2Gamerules:OnMapPostLoad()

        Gamerules.OnMapPostLoad(self)
        
        // Now allow script actors to hook post load
        local allScriptActors = Shared.GetEntitiesWithClassname("ScriptActor")
        for index, scriptActor in ientitylist(allScriptActors) do
            scriptActor:OnMapPostLoad()
        end
        
        // fall back on resource points as spawns if none exist for the shadow team.
        if table.maxn(Server.shadowSpawnList) <= 0 then
            Shared:ShotgunWarning("Map lacks shadow_spawn entities on the map! Falling back on ResourcePoints.")        
            for index, entity in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
                local spawn = ShadowSpawn()
                spawn:OnCreate()
                spawn:SetAngles(entity:GetAngles())
                spawn:SetOrigin(entity:GetOrigin())
                table.insert(Server.shadowSpawnList, spawn)
            end     
        end
        
        // fall back on resource points as spawns if none exist for the vanilla team.
        if table.maxn(Server.vanillaSpawnList) <= 0 then
            Shared:ShotgunWarning("Map lacks vanilla_spawn entitities on the map! Falling back on ResourcePoints.")
            for index, entity in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
                local spawn = VanillaSpawn()
                spawn:OnCreate()
                spawn:SetAngles(entity:GetAngles())
                spawn:SetOrigin(entity:GetOrigin())
                table.insert(Server.vanillaSpawnList, spawn)
            end     
        end
   end

    // disable these methods in OnUpdate, we don't want them to trigger.
    local function DisabledUpdateAutoTeamBalance(self, dt) end
    local function DisabledCheckForNoCommander(self, onTeam, commanderType) end
    local function DisabledKillEnemiesNearCommandStructureInPreGame(self, timePassed) end
    
    ReplaceLocals( NS2Gamerules.OnUpdate, { UpdateAutoTeamBalance = DisabledUpdateAutoTeamBalance } )
    ReplaceLocals( NS2Gamerules.OnUpdate, { CheckForNoCommander = DisabledCheckForNoCommander } )
    ReplaceLocals( NS2Gamerules.OnUpdate, { KillEnemiesNearCommandStructureInPreGame = DisabledKillEnemiesNearCommandStructureInPreGame } )

end