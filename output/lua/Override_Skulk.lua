// Everything combat related.

// aliens never sprint. 
function Alien:GetIsSprinting()
    return false
end

local kSpawnUmbraDuration = 3

function Skulk:InitWeapons()

    Alien.InitWeapons(self)
    
    self:GiveItem(Shotgun.kMapName)
    self:SetActiveWeapon(Shotgun.kMapName)
    
	// spawn aliens with several seconds of umbra, to get to a safe location.
    if Server then
        self:SetHasUmbra(true, kSpawnUmbraDuration)
    end      
end


function Skulk:OnInitialized()

    Alien.OnInitialized(self)
    
    // Note: This needs to be initialized BEFORE calling SetModel() below
    // as SetModel() will call GetHeadAngles() through SetPlayerPoseParameters()
    // which will cause a script error if the Skulk is wall walking BEFORE
    // the Skulk is initialized on the client.
    self.currentWallWalkingAngles = Angles(0.0, 0.0, 0.0)
    
    self:SetModel(self:GetVariantModel(), kSkulkAnimationGraph)
    
    self.wallWalking = false
    self.wallWalkingNormalGoal = Vector.yAxis
    
    if Client then
    
        self.currentCameraRoll = 0
        self.goalCameraRoll = 0
        
        self:AddHelpWidget("GUIEvolveHelp", 2)
        self:AddHelpWidget("GUISkulkParasiteHelp", 1)
        self:AddHelpWidget("GUISkulkLeapHelp", 2)
        self:AddHelpWidget("GUIMapHelp", 1)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
    end
    
    self.leaping = false
    
    self.timeLastWallJump = 0
    
    InitMixin(self, IdleMixin)
    
    if Server then 
        // Skulks With Shotguns - Add a babbler-shotgun on head node (don't ask). XD
        self.freeAttachPoints = { "babbler_attach3" }
        local babbler = CreateEntity(Babbler.kMapName, self:GetOrigin(), self:GetTeamNumber())    
        self:AttachBabbler(babbler)
        //babbler:SetGroundMoveType(true)
    end
    
end

function LeapMixin:GetHasSecondary(player)
    return true
end
