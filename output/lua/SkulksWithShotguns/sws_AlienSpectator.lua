
// retrieve function references for original local functions.
local UpdateQueuePosition = GetLocalFunction(AlienSpectator.OnInitialized, 'UpdateQueuePosition')
local UpdateWaveTime = GetLocalFunction(AlienSpectator.OnInitialized, 'UpdateWaveTime')
function AlienSpectator:OnInitialized()

    TeamSpectator.OnInitialized(self)

    // SWS FIX: self:SetTeamNumber(2)
    
    self.eggId = Entity.invalidId
    self.queuePosition = 0
    self.autoSpawnTime = 0
    self.movedToEgg = false
    
    if Server then
    
        self.evolveTechIds = { kTechId.Skulk }
        self:AddTimedCallback(UpdateQueuePosition, 0.1)
        self:AddTimedCallback(UpdateWaveTime, 0.1)
        UpdateQueuePosition(self)
        
    end
    
end
