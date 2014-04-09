
local original_GetPointValue=PointGiverMixin.GetPointValue
function PointGiverMixin:GetPointValue()
    
    // bonus points for killing a flagbearer, decrease points for regular kills.
    if kTeamModeEnabled and HasMixin(self, "Flagbearer") then
        if self:GetFlag() then
            return 11
        else
            return 1
        end
    end
    
    return original_GetPointValue(self)
end