-- @TODO currently disabled due to jerkyness while playing with this class.

-- SWS START Remove this after we re-enable ShotgunSkulks
function Skulk:InitWeapons()

    Alien.InitWeapons(self)
    
    self:GiveItem(Shotgun.kMapName)
    self:SetActiveWeapon(Shotgun.kMapName)
    
	// spawn aliens with several seconds of umbra, to get to a safe location.
    if Server then
        self:SetHasUmbra(true, kSpawnUmbraDuration)
    end      
end

// Disable buy menu for skulks.
function Skulk:Buy()
    self:PlayEvolveErrorSound()
end
-- SWS END Remove this after we re-enable ShotgunSkulks

-- add support for TWO alien teams.
function AlienUI_GetEggCount()

    local eggCount = 0
    local player = Client.GetLocalPlayer()

    if player then     
        local teamInfo = GetTeamInfoEntity(player:GetTeamNumber())
        if teamInfo then
            eggCount = teamInfo:GetEggCount()
        end
    end
    
    return eggCount
    
end

Script.Load("lua/Skulk.lua")
Script.Load("lua/SkulksWithShotguns/sws_FlagbearerMixin.lua")
Script.Load("lua/SkulksWithShotguns/sws_EventMessageMixin.lua")

class 'ShotgunSkulk' (Skulk)

ShotgunSkulk.kMapName = "shotgun_skulk"

local networkVars =
{
}

AddMixinNetworkVars(FlagbearerMixin, networkVars)

function ShotgunSkulk:OnCreate()

    Skulk.OnCreate(self)

    InitMixin(self, FlagbearerMixin)

    if Client then
        InitMixin(self, EventMessageMixin, { kGUIScriptName = "GUIEventMessage" })
    end
end

function ShotgunSkulk:OnInitialized()

    Skulk.OnInitialized(self)

    if Server then 
        // Skulks With Shotguns - Add a babbler-shotgun on head node (don't ask). XD
        self.freeAttachPoints = { "babbler_attach3" }
        local babbler = CreateEntity(Babbler.kMapName, self:GetOrigin(), self:GetTeamNumber())    
        self:AttachBabbler(babbler)
        //babbler:SetGroundMoveType(true)
    end
    
end


function ShotgunSkulk:GetMaxSpeed(possible)

    local speed = Skulk.GetMaxSpeed(self,possible)
    
    // slow down flag bearing skulks just a tad so they can be effectively chased
    if self:IsBearingFlag() then
        speed = speed * kSkulkSpeedFactorWhileCarryGorge
    end

    return speed
    
end 

function ShotgunSkulk:InitWeapons()

    Alien.InitWeapons(self)
    
    self:GiveItem(Shotgun.kMapName)
    self:SetActiveWeapon(Shotgun.kMapName)
    
	// spawn aliens with several seconds of umbra, to get to a safe location.
    if Server then
        self:SetHasUmbra(true, kSpawnUmbraDuration)
    end      
end

// Disable buy menu for skulks.
function ShotgunSkulk:Buy()
    self:PlayEvolveErrorSound()
end

Shared.LinkClassToMap("ShotgunSkulk", ShotgunSkulk.kMapName, networkVars)