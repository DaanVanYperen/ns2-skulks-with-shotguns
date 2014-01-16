kCustomLocaleMessages = {
    // @TODO cleanup unused.
    HIVE = 'Stalk',
    HIVE_TOOLTIP = 'Produces eggs for your team.',
    HIVE_HINT = 'Produces eggs for your team.',
    TEAM_RES = 'REMAINING SPAWNS: %d',
    TEAM_GAME_STARTED = 'Objective: Capture the enemy gorge',
    DEATHMATCH_GAME_STARTED = 'Objective: Kill all opposition',
    RESOURCE_NOZZLE = 'Dead Stalk',
    RESOURCE_NOZZLE_TOOLTIP = 'No more eggs can span here.',
    ALIEN_ALERT_HIVE_DYING = 'Stalk is dying',
    ALIEN_ALERT_HIVE_UNDERATTACK = 'Stalk under attack',
    HIVE_KILLED = "%s Stalk Killed",
    HIVE_LOW_HEALTH = "%s Stalk Death Imminent",
    HIVE_UNDER_ATTACK = "%s Stalk under attack",
    
    MARINE_VICTORY = "Blue Team Wins!",
    MARINE_DEFEAT = "Blue Team loses",

    ALIEN_VICTORY = "Red Team Wins!",
    ALIEN_DEFEAT = "Red Team loses",
    
    // %s=Playername
    ENEMY_STOLE_GORGE = "%s stole your gorge!",
    ENEMY_RECOVERED_GORGE = "%s rescued their gorge!",
    ENEMY_CAPTURED_GORGE = "%s captured your gorge!",
    ENEMY_DROPPED_GORGE = "%s dropped enemy gorge!",   
    ENEMY_TIMEOUT_GORGE = "enemy gorge walked back!",   

    // %s=You/Playername
    TEAM_STOLE_GORGE = "%s grabbed enemy gorge!",
    TEAM_RECOVERED_GORGE = "%s recovered our gorge!",
    TEAM_CAPTURED_GORGE = "%s captured enemy gorge!",
    TEAM_DROPPED_GORGE = "%s dropped your gorge!",   
    TEAM_TIMEOUT_GORGE = "Your gorge walked back!",   
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
