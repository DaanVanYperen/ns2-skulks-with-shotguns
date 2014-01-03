
kCustomLocaleMessages = {
    HIVE = 'Stalk',
    HIVE_TOOLTIP = 'Produces eggs while alive.',
    HIVE_HINT = 'Produces eggs while alive.',
    TEAM_RES = 'EGG RESERVE: %d',
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