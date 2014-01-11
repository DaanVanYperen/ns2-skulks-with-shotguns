
local OriginalMapBlipUpdateRelevancy = MapBlip.UpdateRelevancy
function MapBlip:UpdateRelevancy()

    if kTeamModeEnabled then
        OriginalMapBlipUpdateRelevancy(self)
    else
        self:SetRelevancyDistance(Math.infinity)
        local mask = 0

        if self:GetIsSighted() then
            mask = bit.bor(mask, kRelevantToTeam1)
            mask = bit.bor(mask, kRelevantToTeam2)
        end
    
        self:SetExcludeRelevancyMask( mask )
    end  
end
