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
        speed = speed * 0.9
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