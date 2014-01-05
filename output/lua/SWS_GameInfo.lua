Script.Load("lua/Entity.lua")

class 'SWSGameInfo' (Entity)

SWSGameInfo.kMapName = "sws_game_info"

function GetSwsGameInfoEntity()
    local entityList = Shared.GetEntitiesWithClassname("SWSGameInfo")
    if entityList:GetSize() > 0 then    
        return entityList:GetEntityAtIndex(0)
    end
end

local networkVars = 
{
    isTeamBased = "boolean",
}

function SWSGameInfo:OnCreate()
    self.isTeamBased = false
end

if Server then
    function SWSGameInfo:SetTeamBased(value)
        self.isTeamBased = value
    end
end

function SWSGameInfo:GetTeamBased()
    return self.isTeamBased
end

Shared.LinkClassToMap("SWSGameInfo", SWSGameInfo.kMapName, networkVars)
