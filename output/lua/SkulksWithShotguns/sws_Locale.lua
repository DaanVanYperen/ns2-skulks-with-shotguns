kCustomLocaleMessages = {
    // @TODO cleanup unused.
    HIVE = 'Stalk',
    HIVE_TOOLTIP = 'Produces eggs for your team.',
    HIVE_HINT = 'Produces eggs for your team.',
    TEAM_RES = 'REMAINING SPAWNS: %d',
    ALIEN_TEAM_GAME_STARTED = 'Objective: Kill all opposition',
    RESOURCE_NOZZLE = 'Dead Stalk',
    RESOURCE_NOZZLE_TOOLTIP = 'No more eggs can span here.',
    ALIEN_ALERT_HIVE_DYING = 'Stalk is dying',
    ALIEN_ALERT_HIVE_UNDERATTACK = 'Stalk under attack',
    HIVE_KILLED = "%s Stalk Killed",
    HIVE_LOW_HEALTH = "%s Stalk Death Imminent",
    HIVE_UNDER_ATTACK = "%s Stalk under attack",
}

if Locale then
    local OldResolveString = Locale.ResolveString
    
    local function ResolveString(input)
    
        local result = nil
        
        if kCustomLocaleMessages[input] ~= nil then
            result = kCustomLocaleMessages[input]
        end
        
        if result == nil then
            result = OldResolveString(input)
        end
        
        return result
    
    end
    
    Locale.ResolveString = ResolveString
end