// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/AlienTeamInfo.lua
//
// AlienTeamInfo is used to sync information about a team to clients.
// Only alien team players (and spectators) will receive the information about number
// of shells, spurs or veils.
//
// Created by Andreas Urwalek (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TeamInfo.lua")
Script.Load("lua/NS2Utility.lua")

class 'ShotgunAlienTeamInfo' (AlienTeamInfo)

ShotgunAlienTeamInfo.kMapName = "ShotgunAlienTeamInfo"

local networkVars =
{
    points = "integer (0 to 99)",
    enemyPoints = "integer (0 to 99)",
    carrierId = "integer",
    secondsRemaining = "integer",
    enemyCarrierId = "integer",
    teamMode = "boolean"
}

function ShotgunAlienTeamInfo:OnCreate()

    AlienTeamInfo.OnCreate(self)

    self.points = 0
    self.enemyPoints = 0
    self.secondsRemaining = 0
    self.teamMode = kTeamModeEnabled
    self.carrierId = nil
    self.enemyCarrierId = nil

end

function ShotgunAlienTeamInfo:Reset()
    
        AlienTeamInfo.Reset(self)
        self.points = 0
        self.enemyPoints = 0
        self.secondsRemaining = 0
        self.carrierId = nil
        self.enemyCarrierId = nil
        self.teamMode = kTeamModeEnabled
        
end


// determine who is carrying the enemy flag for passed team.
local function GetFlagCarrierFor(team)
    local flag = GetEnemyTeam(team):GetTeamFlag()
    if flag ~= nil then
        local carrier = flag:GetCarrier()
        if carrier ~= nil then
            return carrier:GetClientIndex()
        end
    end
    return nil
end

function ShotgunAlienTeamInfo:OnUpdate(deltaTime)
    
    AlienTeamInfo.OnUpdate(self, deltaTime)
        
    local team = self:GetTeam()
    if team then
        self.points      = team.points or 0
        self.enemyPoints = GetEnemyTeam(team).points or 0
        self.eggCount    = team:GetTeamResources() // We work with teamres instead.
        self.teamMode    = kTeamModeEnabled
        self.secondsRemaining = math.max( 0, kTeamModeTimelimit - (math.floor( Shared.GetTime() ) - GetGameInfoEntity():GetStartTime()) )
        
        self.carrierId      = GetFlagCarrierFor(team)
        self.enemyCarrierId = GetFlagCarrierFor(GetEnemyTeam(team))
    end

end

function AlienTeamInfo:GetTeamMode()
    return self.teamMode
end

function AlienTeamInfo:GetPoints()
    return self.points
end

function ShotgunAlienTeamInfo:GetSecondsRemaining()
    return self.secondsRemaining
end

function AlienTeamInfo:GetEnemyPoints()
    return self.enemyPoints
end

function AlienTeamInfo:GetCarrierId()
    return self.carrierId
end

function AlienTeamInfo:GetEnemyCarrierId()
    return self.enemyCarrierId
end

Shared.LinkClassToMap("ShotgunAlienTeamInfo", ShotgunAlienTeamInfo.kMapName, networkVars)