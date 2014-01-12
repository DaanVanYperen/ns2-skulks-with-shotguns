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

class 'ShotgunAlienTeamInfo' (AlienTeamInfo)

ShotgunAlienTeamInfo.kMapName = "ShotgunAlienTeamInfo"

local networkVars =
{
    points = "integer (0 to 5)",
}

function ShotgunAlienTeamInfo:OnCreate()

    AlienTeamInfo.OnCreate(self)

    self.points = 0

end

function ShotgunAlienTeamInfo:Reset()
    
        AlienTeamInfo.Reset(self)
        self.points = 0
        
end

function ShotgunAlienTeamInfo:OnUpdate(deltaTime)
    
    AlienTeamInfo.OnUpdate(self, deltaTime)
        
    local team = self:GetTeam()
    if team then
        self.points   = math.random(0,5)
        self.eggCount = team:GetTeamResources() // We work with teamres instead.
    end

end

function AlienTeamInfo:GetPoints()
    return self.eggCount
end

Shared.LinkClassToMap("ShotgunAlienTeamInfo", ShotgunAlienTeamInfo.kMapName, networkVars)