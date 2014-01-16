// We override NS2Gamerules to avoid having to override the NS2 gameserver.
// @todo port this all to our own gamerules class.

if (Server) then            

    local kGameEndCheckInterval = 0.75
    local kDeathmatchTimeLimit = 60*15
    local kCaptureTheGorgeTimeLimit = 60*60

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
    
    function NS2Gamerules:ScorePoint( entity )
        entity:GetTeam().points = entity:GetTeam().points + 1
        RewardOnFireEffect(entity)
        if entity and entity:isa("Player") and HasMixin(entity, "Scoring") then
            entity:AddScore(25, 0)
        end
    end
    
    
    local kPauseToSocializeBeforeMapcycle = 30
    function NS2Gamerules:SetGameState(state)
    
        if state ~= self.gameState then
        
            self.gameState = state
            self.gameInfo:SetState(state)
            self.timeGameStateChanged = Shared.GetTime()
            self.timeSinceGameStateChanged = 0
            
            local frozenState = (state == kGameState.Countdown) and (not Shared.GetDevMode())
            self.team1:SetFrozenState(frozenState)
            self.team2:SetFrozenState(frozenState)
            
            if self.gameState == kGameState.Started then
            
                PostGameViz("Game started")
                self.gameStartTime = Shared.GetTime()
                
                self.gameInfo:SetStartTime(self.gameStartTime)
                
                if kTeamModeEnabled then
                    SendEventMessage(self.team1, kEventMessageTypes.StartTeamGame)
                    SendEventMessage(self.team2, kEventMessageTypes.StartTeamGame)
                else
                    SendEventMessage(self.team1, kEventMessageTypes.StartDeathmatchGame)
                    SendEventMessage(self.team2, kEventMessageTypes.StartDeathmatchGame)
                end
                
                // Reset disconnected player resources when a game starts to prevent shenanigans.
                self.disconnectedPlayerResources = { }
                
            end
            
            // On end game, check for map switch conditions
            if state == kGameState.Team1Won or state == kGameState.Team2Won then
            
                if MapCycle_TestCycleMap() then
                    self.timeToCycleMap = Shared.GetTime() + kPauseToSocializeBeforeMapcycle
                else
                    self.timeToCycleMap = nil
                end
                
            end
            
        end
        
    end    
    function NS2Gamerules:CheckGameStart()
    
        if (self:GetGameState() == kGameState.NotStarted) or (self:GetGameState() == kGameState.PreGame) then
        
            // Start game when we have /any/ players in the game.
            local playerCount = self.team1:GetNumPlayers() + self.team2:GetNumPlayers()
            
            if  (playerCount > 0) then
                if self:GetGameState() == kGameState.NotStarted then
                    self:SetGameState(kGameState.PreGame)
                    self.score = 0
                    Shared:ShotgunMessage("Lock and load!")
                    
                    // @todo find a good location for this.
                    if kTeamModeEnabled then
                        // team mode requires longer spawn time.
                        kAlienSpawnTime = kTeamAlienSpawnTime
                    end
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

    local function ResetPlayerScores()

        for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do            
            if player.ResetScores then
                player:ResetScores()
            end            
        end
    
    end

    function NS2Gamerules:UpdatePregame(timePassed)

        if self:GetGameState() == kGameState.PreGame then
           
                self.team1:PlayPrivateTeamSound(ConditionalValue(self.team1:GetTeamType() == kAlienTeamType, NS2Gamerules.kAlienStartSound, NS2Gamerules.kMarineStartSound))
                self.team2:PlayPrivateTeamSound(ConditionalValue(self.team2:GetTeamType() == kAlienTeamType, NS2Gamerules.kAlienStartSound, NS2Gamerules.kMarineStartSound))
                
                ResetPlayerScores()
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
                
            if kTeamModeEnabled then                            
            
                // no more living players on team, and out of spawns? game lost/deathmatch over!
                local team1Won = (self.team1:GetPoints() >= kCaptureWinPoints)
                local team2Won = (self.team2:GetPoints() >= kCaptureWinPoints)
            
                if team1Won then
                    Shared:ShotgunMessage("Blue Team Wins!")
                    self.team1:PlayPrivateTeamSound(kSfxBlueWins)
                    self.team2:PlayPrivateTeamSound(kSfxBlueWins)                    
                    self:EndGame(self.team1)
                end                
                if team2Won then
                    Shared:ShotgunMessage("Red Team Wins!")
                    self.team1:PlayPrivateTeamSound(kSfxRedWins)
                    self.team2:PlayPrivateTeamSound(kSfxRedWins)
                    self:EndGame(self.team2)
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
            
                if (not kTeamModeEnabled and (self.timeSinceGameStateChanged >= kDeathmatchTimeLimit)) or
                   (kTeamModeEnabled and (self.timeSinceGameStateChanged >= kCaptureTheGorgeTimeLimit)) then
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