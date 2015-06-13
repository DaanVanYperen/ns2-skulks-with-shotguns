

// Misc
Script.Load("lua/SkulksWithShotguns/sws_NS2ConsoleCommands_Server.lua")
Script.Load("lua/SkulksWithShotguns/sws_Respawn.lua")

// Custom entity prepping for our mod.
local OriginalGetCreateEntityOnStart = GetCreateEntityOnStart
function GetCreateEntityOnStart(mapName, groupName, values)

    return mapName ~= ShadowSpawn.kMapName
       and mapName ~= VanillaSpawn.kMapName
       and mapName ~= ShadowFlagSpawn.kMapName
       and mapName ~= VanillaFlagSpawn.kMapName
       and OriginalGetCreateEntityOnStart(mapName, groupName, values)

end

Server.shadowSpawnList = table.array(64)
Server.vanillaSpawnList = table.array(64)

// Custom entity loading for our mod.
local OriginalLoadSpecial = GetLoadSpecial
function GetLoadSpecial(mapName, groupName, values)

    local success = false
    
    if mapName == ShadowSpawn.kMapName then
    
        local entity = ShadowSpawn()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        table.insert(Server.shadowSpawnList, entity)
        success = true
        
    elseif mapName == VanillaSpawn.kMapName then
    
        local entity = VanillaSpawn()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        table.insert(Server.vanillaSpawnList, entity)
        success = true
        
    elseif mapName == ShadowFlagSpawn.kMapName then
    
        local entity = ShadowFlagSpawn()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        Server.shadowFlagSpawn = entity
        kTeamModeEnabled = true
        success = true
        
    elseif mapName == VanillaFlagSpawn.kMapName then
    
        local entity = VanillaFlagSpawn()
        entity:OnCreate()
        LoadEntityFromValues(entity, values)
        Server.vanillaFlagSpawn = entity
        kTeamModeEnabled = true
        success = true

    else
        return OriginalLoadSpecial(mapName, groupName, values)
    end
    
    return success
    
end


local function Roundtime(client, minutes)
    kTeamModeTimelimit = minutes * 60
end
CreateServerAdminCommand("Console_sv_roundtime", Roundtime, "<minutes>, Capture the gorge round time in minutes, or 0 to disable.")
