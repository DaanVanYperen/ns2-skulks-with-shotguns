
function Crag:GetCanTakeDamageOverride()
    return false
end


local function TeamIndiscriminateGetHealTargets(self)

    local targets = {}
    
    // priority on players
    for _, player in ipairs(GetEntitiesWithinRange("Player", self:GetOrigin(), Crag.kHealRadius)) do
    
        if player:GetIsAlive() then
            table.insert(targets, player)
        end
        
    end

    for _, healable in ipairs(GetEntitiesWithinRange("Live",  self:GetOrigin(), Crag.kHealRadius)) do
        
        if healable:GetIsAlive() then
            table.insertunique(targets, healable)
        end
        
    end

    return targets

end

ReplaceLocals( Crag.PerformHealing, { GetHealTargets = TeamIndiscriminateGetHealTargets } )