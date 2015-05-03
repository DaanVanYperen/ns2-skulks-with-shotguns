// added killstreak property.








/**
 * ScoringMixin keeps track of a score. It provides function to allow changing the score.
 */
ScoringMixin = CreateMixin(ScoringMixin)
ScoringMixin.type = "Scoring"

local gSessionKills = {}

function GetSessionKills(clientIndex)
    return gSessionKills[clientIndex] or 0
end

ScoringMixin.networkVars =
{
    playerLevel = "private integer",
    playerSkill = "private integer",
}

function ScoringMixin:__initmixin()

    self.score = 0
    // Some types of points are added continuously. These are tracked here.
    self.continuousScores = { }
    
    self.serverJoinTime = Shared.GetTime()
    
end

function ScoringMixin:GetScore()
    return self.score
end

function ScoringMixin:AddScore(points, res, wasKill)

    // Should only be called on the Server.
    if Server then
    
        // Tell client to display cool effect.
        if points ~= nil and points ~= 0 then
        
            local displayRes = ConditionalValue(type(res) == "number", res, 0)
            Server.SendNetworkMessage(Server.GetOwner(self), "ScoreUpdate", { points = points, res = displayRes, wasKill = wasKill == true }, true)
            self.score = Clamp(self.score + points, 0, self:GetMixinConstants().kMaxScore or 100)
            
            if not self.scoreGainedCurrentLife then
                self.scoreGainedCurrentLife = 0
            end

            self.scoreGainedCurrentLife = self.scoreGainedCurrentLife + points    

        end
    
    end
    
end

function ScoringMixin:GetScoreGainedCurrentLife()
    return self.scoreGainedCurrentLife
end

function ScoringMixin:GetPlayerLevel()
    return self.playerLevel
end
  
function ScoringMixin:GetPlayerSkill()
    return self.playerSkill
end

if Server then

    function ScoringMixin:CopyPlayerDataFrom(player)
    
        self.scoreGainedCurrentLife = player.scoreGainedCurrentLife    
        self.score = player.score or 0
        self.kills = player.kills or 0
        self.killstreak = player.killstreak or  0
        self.assistkills = player.assistkills or 0
        self.deaths = player.deaths or 0
        self.playTime = player.playTime or 0
        self.commanderTime = player.commanderTime or 0
        self.marineTime = player.marineTime or 0
        self.alienTime = player.alienTime or 0
        self.entranceTime = player.entranceTime
        self.exitTime = player.exitTime
		
		self.teamAtEntrance = player.teamAtEntrance
        self.totalKills = player.totalKills
        self.totalAssists = player.totalAssists
        self.totalDeaths = player.totalDeaths
        self.playerSkill = player.playerSkill
        self.totalScore = player.totalScore
        self.totalPlayTime = player.totalPlayTime
        self.playerLevel = player.playerLevel
        
    end

    function ScoringMixin:OnKill()    
        self.scoreGainedCurrentLife = 0
    end
    
    function ScoringMixin:GetPlayTime()
        return self.playTime
    end
    
    function ScoringMixin:GetMarinePlayTime()
        return self.marineTime
    end
    
    function ScoringMixin:GetAlienPlayTime()
        return self.alienTime
    end
    
    function ScoringMixin:GetCommanderTime()
        return self.commanderTime
    end
    
    local function SharedUpdate(self, deltaTime)
    
        if not self.commanderTime then
            self.commanderTime = 0
        end
        
        if not self.playTime then
            self.playTime = 0
        end
        
        if not self.marineTime then
            self.marineTime = 0
        end
        
        if not self.alienTime then
            self.alienTime = 0
        end    
        
        if self:GetIsPlaying() then
        
            if self:isa("Commander") then
                self.commanderTime = self.commanderTime + deltaTime
            end
            
            self.playTime = self.playTime + deltaTime
            
            if self:GetTeamType() == kMarineTeamType then
                self.marineTime = self.marineTime + deltaTime
            end
            
            if self:GetTeamType() == kAlienTeamType then
                self.alienTime = self.alienTime + deltaTime
            end
        
        end
    
    end
    
    function ScoringMixin:OnProcessMove(input)
        SharedUpdate(self, input.time)
    end
    
    function ScoringMixin:OnUpdate(deltaTime)
        SharedUpdate(self, deltaTime)
    end

end

function ScoringMixin:AddKill()

    if not self.kills then
        self.kills = 0
    end    
    if not self.killstreak then
        self.killstreak = 0
    end    

    self.kills = Clamp(self.kills + 1, 0, kMaxKills)
    self.killstreak = Clamp(self.killstreak + 1, 0, kMaxKills)

    // Skulks With Shotguns: reward kills.
    self:rewardKill()

    if self.clientIndex and self.clientIndex > 0 then
        if not gSessionKills[self.clientIndex] then
            gSessionKills[self.clientIndex] = 0
        end
        gSessionKills[self.clientIndex] = gSessionKills[self.clientIndex] + 1
    end

end

function ScoringMixin:AddAssistKill()

    if not self.assistkills then
        self.assistkills = 0
    end    

    self.assistkills = Clamp(self.assistkills + 1, 0, kMaxKills)
    
end

function ScoringMixin:GetKills()
    return self.kills
end

function ScoringMixin:GetKillstreak()
    return self.killstreak
end

function ScoringMixin:GetAssistKills()
    return self.assistkills
end

function ScoringMixin:GetDeaths()
    return self.deaths
end

function ScoringMixin:AddDeaths()

    if not self.deaths then
        self.deaths = 0
    end

     // reset killstreak
    self.killstreak = 0
    self.deaths = Clamp(self.deaths + 1, 0, kMaxDeaths)
    
end

function ScoringMixin:SetEntranceTime()
	local teamNumber = self:GetTeamNumber()
	
	if teamNumber ~= self.teamAtEntrance then
		self.entranceTime = Shared.GetTime()
		self.teamAtEntrance = teamNumber
	end
end

function ScoringMixin:GetEntranceTime()
    return self.entranceTime
end

function ScoringMixin:SetExitTime()
    self.exitTime = Shared.GetTime()
end

function ScoringMixin:GetExitTime()
    if not self.exitTime or self.entranceTime > self.exitTime then 
        return
    end
    
    return self.exitTime
end

function ScoringMixin:ResetScores()

    self.score = 0
    self.kills = 0
    self.killstreak = 0
    self.assistkills = 0
    self.deaths = 0    
    
    self.commanderTime = 0
    self.playTime = 0
    self.marineTime = 0
    self.alienTime = 0

    self.entranceTime = Shared.GetTime()
    self.exitTime = nil
    
end

// Only award the pointsGivenOnScore once the amountNeededToScore are added into the score
// determined by the passed in name.
// An example, to give points based on health healed:
// AddContinuousScore("Heal", amountHealed, 100, 1)
function ScoringMixin:AddContinuousScore(name, addAmount, amountNeededToScore, pointsGivenOnScore)

    if Server then
    
        self.continuousScores[name] = self.continuousScores[name] or { amount = 0 }
        self.continuousScores[name].amount = self.continuousScores[name].amount + addAmount
        while self.continuousScores[name].amount >= amountNeededToScore do
        
            self:AddScore(pointsGivenOnScore, 0)
            self.continuousScores[name].amount = self.continuousScores[name].amount - amountNeededToScore
            
        end
        
    end
    
end

if Server then

    function ScoringMixin:SetTotalKills(totalKills)
        self.totalKills = math.round(totalKills)
    end
    
    function ScoringMixin:SetTotalAssists(totalAssists)
        self.totalAssists = math.round(totalAssists)
    end
    
    function ScoringMixin:SetTotalDeaths(totalDeaths)
        self.totalDeaths = math.round(totalDeaths)
    end
    
    function ScoringMixin:SetPlayerSkill(playerSkill)
        self.playerSkill = math.round(playerSkill)
    end
    
    function ScoringMixin:SetTotalScore(totalScore)
        self.totalScore = math.round(totalScore)
    end
    
    function ScoringMixin:SetTotalPlayTime(totalPlayTime)
        self.totalPlayTime = math.round(totalPlayTime)
    end
    
    function ScoringMixin:SetPlayerLevel(playerLevel)
        self.playerLevel = math.round(playerLevel)
    end 

end

